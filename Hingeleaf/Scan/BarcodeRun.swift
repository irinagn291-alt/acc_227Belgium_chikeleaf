import Foundation

/// Digit runs of length 8 to 14 taken from a typed code, a barcode, or a QR URL.
/// A 12-digit UPC-A is also offered with a leading zero.
enum BarcodeRun {
    static func candidates(in payload: String) -> [String] {
        var unique: [String] = []
        for run in maximalDigitRuns(in: payload) {
            let length = run.count
            if (8...14).contains(length) {
                if length == 12 {
                    append("0" + run, to: &unique)
                }
                append(run, to: &unique)
            } else if length > 14 {
                let characters = Array(run)
                for size in 8...14 {
                    let end = size
                    if end <= characters.count {
                        append(String(characters[0..<end]), to: &unique)
                    }
                }
            }
        }
        return unique
    }

    private static func maximalDigitRuns(in payload: String) -> [String] {
        var runs: [String] = []
        var current = ""
        for character in payload {
            if character.isNumber {
                current.append(character)
            } else if !current.isEmpty {
                runs.append(current)
                current = ""
            }
        }
        if !current.isEmpty {
            runs.append(current)
        }
        return runs
    }

    private static func append(_ value: String, to unique: inout [String]) {
        if !unique.contains(value) {
            unique.append(value)
        }
    }
}
