import Foundation

/// Hinge ADT. Search writes Loose. Hinge writes a HingeMark and folds to Hinged.
/// Cancel writes a CancelMark and folds to Cancelled. Grade and taste read Cancelled only.
enum FoldFault: Error, Equatable, Sendable {
    case issueMissing
    case mountMissing
    case mountOccupied
    case secondHinge
    case notLoose
    case alreadyCancelled
    case gradeOutOfRange
    case gradeNeedsCancelled
    case nothingToPeel
}

enum LeafSurface: Equatable, Sendable {
    case blank
    case occupied
}

/// Country taste computed from cancelled plates. Hinged wants never enter this value.
struct TasteReading: Equatable, Sendable {
    var cancelMarkCount: Int
    var countryGradeTotals: [String: Int]
    var countryGradeCounts: [String: Int]
    var notes: [String]
    var averageGrade: Double
    var eraCounts: [String: Int]
    var skewCount: Int
    var driftCount: Int
}

enum IssueFold {
    static func surface(_ chart: LeafChart) -> LeafSurface {
        let seated = chart.mounts.contains { $0.issueID != nil }
        if seated || !chart.issues.isEmpty {
            return .occupied
        }
        return .blank
    }

    static func wants(_ chart: LeafChart) -> [Issue] {
        chart.issues.filter { $0.role == .hinged }
    }

    static func crate(_ chart: LeafChart) -> [Issue] {
        chart.issues.filter { $0.role == .cancelled }
    }

    static func looseTray(_ chart: LeafChart) -> [Issue] {
        chart.issues.filter { $0.role == .loose }
    }

    /// Drops a loose issue from the tray. Hinged and cancelled copies stay.
    static func discardLoose(issueID: String, chart: LeafChart) -> LeafChart {
        var chart = chart
        guard chart.issues.contains(where: { $0.id == issueID && $0.role == .loose }) else {
            return chart
        }
        chart.issues.removeAll { $0.id == issueID }
        return chart
    }

    static func era(for year: Int) -> String {
        switch year {
        case ..<1901: return "Classic"
        case 1901...1945: return "Early Modern"
        case 1946...1980: return "Mid-Century"
        default: return "Contemporary"
        }
    }

    /// Search or scan admits an issue as Loose and leaves every mount empty of it.
    static func admitLoose(_ issue: Issue, into chart: LeafChart) -> LeafChart {
        var chart = chart
        var copy = issue
        copy.role = .loose
        copy.mountID = nil
        if let index = chart.issues.firstIndex(where: { $0.id == copy.id }) {
            let existing = chart.issues[index]
            if existing.role == .loose {
                copy.role = .loose
                chart.issues[index] = copy
            }
        } else {
            chart.issues.append(copy)
        }
        return chart
    }

    static func hinge(
        issueID: String,
        mountID: UUID,
        chart: LeafChart,
        day: Int
    ) -> Result<LeafChart, FoldFault> {
        guard let index = chart.issues.firstIndex(where: { $0.id == issueID }) else {
            return .failure(.issueMissing)
        }
        if chart.hingeMarks.contains(where: { $0.issueID == issueID }) || chart.issues[index].role != .loose {
            if chart.hingeMarks.contains(where: { $0.issueID == issueID }) {
                return .failure(.secondHinge)
            }
            return .failure(.notLoose)
        }
        guard let mountIndex = chart.mounts.firstIndex(where: { $0.id == mountID }) else {
            return .failure(.mountMissing)
        }
        if chart.mounts[mountIndex].issueID != nil {
            return .failure(.mountOccupied)
        }
        var chart = chart
        let sequence = chart.nextSequence
        chart.nextSequence += 1
        chart.hingeMarks.append(
            HingeMark(issueID: issueID, mountID: mountID, day: day, sequence: sequence)
        )
        chart.issues[index].role = .hinged
        chart.issues[index].mountID = mountID
        chart.mounts[mountIndex].issueID = issueID
        return .success(chart)
    }

    static func cancel(
        issueID: String,
        chart: LeafChart,
        day: Int
    ) -> Result<LeafChart, FoldFault> {
        guard let index = chart.issues.firstIndex(where: { $0.id == issueID }) else {
            return .failure(.issueMissing)
        }
        var chart = chart
        let sequence = chart.nextSequence
        chart.nextSequence += 1
        switch chart.issues[index].role {
        case .loose:
            chart.skewMarks.append(SkewMark(issueID: issueID, day: day, sequence: sequence))
            return .success(chart)
        case .hinged:
            let seated = chart.hingeMarks.contains { $0.issueID == issueID }
            if !seated {
                chart.driftMarks.append(DriftMark(issueID: issueID, day: day, sequence: sequence))
                return .success(chart)
            }
            chart.cancelMarks.append(CancelMark(issueID: issueID, day: day, sequence: sequence))
            chart.issues[index].role = .cancelled
            return .success(chart)
        case .cancelled:
            return .failure(.alreadyCancelled)
        }
    }

    static func grade(
        issueID: String,
        grade: Int,
        note: String,
        chart: LeafChart
    ) -> Result<LeafChart, FoldFault> {
        guard (1...5).contains(grade) else {
            return .failure(.gradeOutOfRange)
        }
        guard let issue = chart.issues.first(where: { $0.id == issueID }) else {
            return .failure(.issueMissing)
        }
        guard issue.role == .cancelled else {
            return .failure(.gradeNeedsCancelled)
        }
        var chart = chart
        if let index = chart.plates.firstIndex(where: { $0.issueID == issueID }) {
            chart.plates[index].grade = grade
            chart.plates[index].note = note
        } else {
            chart.plates.append(Plate(issueID: issueID, grade: grade, note: note))
        }
        return .success(chart)
    }

    /// Drops the latest HingeMark or CancelMark and unfolds that step.
    static func peel(chart: LeafChart) -> Result<LeafChart, FoldFault> {
        let lastHinge = chart.hingeMarks.max { $0.sequence < $1.sequence }
        let lastCancel = chart.cancelMarks.max { $0.sequence < $1.sequence }
        switch (lastHinge, lastCancel) {
        case (nil, nil):
            return .failure(.nothingToPeel)
        case let (hinge?, nil):
            return .success(dropHinge(hinge, chart: chart))
        case let (nil, cancel?):
            return .success(dropCancel(cancel, chart: chart))
        case let (hinge?, cancel?):
            if cancel.sequence >= hinge.sequence {
                return .success(dropCancel(cancel, chart: chart))
            }
            return .success(dropHinge(hinge, chart: chart))
        }
    }

    static func taste(_ chart: LeafChart) -> TasteReading {
        var totals: [String: Int] = [:]
        var counts: [String: Int] = [:]
        var notes: [String] = []
        var eras: [String: Int] = [:]
        var gradeSum = 0
        var gradeCount = 0
        let cancelledIDs = Set(chart.issues.filter { $0.role == .cancelled }.map(\.id))
        for plate in chart.plates where cancelledIDs.contains(plate.issueID) {
            guard let issue = chart.issues.first(where: { $0.id == plate.issueID }) else {
                continue
            }
            totals[issue.country, default: 0] += plate.grade
            counts[issue.country, default: 0] += 1
            if let year = issue.year {
                eras[era(for: year), default: 0] += 1
            }
            gradeSum += plate.grade
            gradeCount += 1
            if !plate.note.isEmpty {
                notes.append(plate.note)
            }
        }
        let average = gradeCount == 0 ? 0 : Double(gradeSum) / Double(gradeCount)
        return TasteReading(
            cancelMarkCount: chart.cancelMarks.count,
            countryGradeTotals: totals,
            countryGradeCounts: counts,
            notes: notes,
            averageGrade: average,
            eraCounts: eras,
            skewCount: chart.skewMarks.count,
            driftCount: chart.driftMarks.count
        )
    }

    static func cancelEnabled(issueID: String, chart: LeafChart) -> Bool {
        guard let issue = chart.issues.first(where: { $0.id == issueID }) else {
            return false
        }
        return issue.role == .hinged && chart.hingeMarks.contains { $0.issueID == issueID }
    }

    private static func dropHinge(_ mark: HingeMark, chart: LeafChart) -> LeafChart {
        var chart = chart
        chart.hingeMarks.removeAll { $0.id == mark.id }
        if let index = chart.issues.firstIndex(where: { $0.id == mark.issueID }) {
            chart.issues[index].role = .loose
            chart.issues[index].mountID = nil
        }
        if let mountIndex = chart.mounts.firstIndex(where: { $0.id == mark.mountID }) {
            chart.mounts[mountIndex].issueID = nil
        }
        return chart
    }

    private static func dropCancel(_ mark: CancelMark, chart: LeafChart) -> LeafChart {
        var chart = chart
        chart.cancelMarks.removeAll { $0.id == mark.id }
        chart.plates.removeAll { $0.issueID == mark.issueID }
        if let index = chart.issues.firstIndex(where: { $0.id == mark.issueID }) {
            chart.issues[index].role = .hinged
        }
        return chart
    }
}
