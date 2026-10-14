import Foundation

/// One client for the Colnect stamp list. DTOs mirror JSON, then map onto Issue.
enum CatalogFault: Error, Equatable, Sendable {
    case notFound
    case transport
    case malformed
    case http(Int)
}

struct CatalogPage: Sendable, Equatable {
    var issues: [Issue]
    var fromShelf: Bool
    var notice: String?
}

struct CatalogTransport: Sendable {
    var perform: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

    static let live: CatalogTransport = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        let session = URLSession(configuration: configuration)
        return CatalogTransport { request in
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw CatalogFault.transport
            }
            return (data, http)
        }
    }()
}

/// cgi search.pl shape: search_terms, json=1, page, page_size 20.
struct ColnectClient: Sendable {
    static let userAgent = "Hingeleaf/1.0 (iOS; +https://hingeleaf-folio.pro)"
    static let listURL = URL(string: "https://colnect.com/en/stamps/list")

    var transport: CatalogTransport
    var shelf: [Issue]

    init(transport: CatalogTransport = .live, shelf: [Issue] = BundledShelf.issues()) {
        self.transport = transport
        self.shelf = shelf
    }

    func search(terms: String, page: Int) async throws -> CatalogPage {
        try Task.checkCancellation()
        do {
            let body = try await fetch(terms: terms, page: page)
            let issues = try mapList(body)
            if issues.isEmpty {
                return shelfPage(terms: terms, notice: "The catalog had no match. Showing the album shelf.")
            }
            return CatalogPage(issues: issues, fromShelf: false, notice: nil)
        } catch is CancellationError {
            throw CancellationError()
        } catch let fault as CatalogFault {
            if fault == .notFound {
                return shelfPage(terms: terms, notice: "That code is not in the catalog. Showing the album shelf.")
            }
            return shelfPage(terms: terms, notice: "The catalog did not answer. Showing the album shelf.")
        } catch {
            return shelfPage(terms: terms, notice: "The catalog did not answer. Showing the album shelf.")
        }
    }

    func resolve(code payload: String) async throws -> CatalogPage {
        let codes = BarcodeRun.candidates(in: payload)
        if codes.isEmpty {
            return shelfPage(terms: payload, notice: "No catalog code in that scan. Showing the album shelf.")
        }
        for code in codes {
            try Task.checkCancellation()
            let page = try await search(terms: code, page: 1)
            if !page.fromShelf {
                return page
            }
        }
        return shelfPage(terms: codes[0], notice: "No pack matched. Showing the album shelf.")
    }

    private func fetch(terms: String, page: Int) async throws -> Data {
        guard let listURL = Self.listURL else {
            throw CatalogFault.malformed
        }
        var parts = URLComponents(url: listURL, resolvingAgainstBaseURL: false)
        parts?.queryItems = [
            URLQueryItem(name: "search_terms", value: terms),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: "20")
        ]
        guard let url = parts?.url else {
            throw CatalogFault.malformed
        }
        var request = URLRequest(url: url)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        return try await load(request, allowRetry: true)
    }

    private func load(_ request: URLRequest, allowRetry: Bool) async throws -> Data {
        do {
            let (data, http) = try await transport.perform(request)
            if http.statusCode == 404 {
                throw CatalogFault.notFound
            }
            if !(200...299).contains(http.statusCode) {
                throw CatalogFault.http(http.statusCode)
            }
            return data
        } catch is CancellationError {
            throw CancellationError()
        } catch let fault as CatalogFault {
            throw fault
        } catch let error as URLError where allowRetry && Self.transient(error) {
            return try await load(request, allowRetry: false)
        } catch {
            throw CatalogFault.transport
        }
    }

    private func mapList(_ data: Data) throws -> [Issue] {
        let dto: ColnectListDTO
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            dto = try decoder.decode(ColnectListDTO.self, from: data)
        } catch {
            throw CatalogFault.malformed
        }
        if dto.status == 0 {
            throw CatalogFault.notFound
        }
        let rows = dto.stamps ?? dto.items ?? []
        return rows.compactMap { $0.issue() }
    }

    private func shelfPage(terms: String, notice: String) -> CatalogPage {
        let folded = terms.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let matched: [Issue]
        if folded.isEmpty {
            matched = Array(shelf.prefix(20))
        } else {
            matched = shelf.filter { issue in
                let haystack = [
                    issue.title,
                    issue.country,
                    issue.topic,
                    issue.catalogNumber,
                    issue.barcode ?? ""
                ].joined(separator: " ").lowercased()
                return haystack.contains(folded)
            }
        }
        return CatalogPage(issues: Array(matched.prefix(20)), fromShelf: true, notice: notice)
    }

    private static func transient(_ error: URLError) -> Bool {
        switch error.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
}

struct ColnectListDTO: Decodable, Sendable {
    var status: Int?
    var stamps: [ColnectStampDTO]?
    var items: [ColnectStampDTO]?
}

struct ColnectStampDTO: Decodable, Sendable {
    var id: String?
    var title: String?
    var name: String?
    var country: String?
    var topic: String?
    var series: String?
    var catalogNumber: String?
    var number: String?
    var year: FlexInt?
    var barcode: String?

    func issue() -> Issue? {
        let resolvedTitle = title ?? name
        guard let resolvedTitle, !resolvedTitle.isEmpty else {
            return nil
        }
        let resolvedID = id ?? "\(country ?? "stamp")-\(catalogNumber ?? number ?? resolvedTitle)"
        return Issue(
            id: resolvedID,
            title: resolvedTitle,
            country: country ?? "",
            topic: topic ?? series ?? "",
            catalogNumber: catalogNumber ?? number ?? "",
            year: year?.value,
            barcode: barcode,
            role: .loose
        )
    }
}

/// Accepts a JSON number or a numeric string. Missing values stay nil.
struct FlexInt: Decodable, Sendable {
    var value: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
            return
        }
        if let number = try? container.decode(Int.self) {
            value = number
            return
        }
        if let number = try? container.decode(Double.self) {
            value = Int(number)
            return
        }
        if let text = try? container.decode(String.self) {
            let digits = text.filter(\.isNumber)
            value = Int(digits)
            return
        }
        value = nil
    }
}

enum BundledShelf {
    static func issues(bundle: Bundle = .main) -> [Issue] {
        guard
            let url = bundle.url(forResource: "Shelf", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        guard let file = try? decoder.decode(ShelfFile.self, from: data) else {
            return []
        }
        return file.issues
    }
}

struct ShelfFile: Decodable, Sendable {
    var schemaVersion: Int
    var issues: [Issue]
}
