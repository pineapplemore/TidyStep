//
//  CleaningSession.swift
//  TidyStep
//

import Foundation

struct CleaningSession: Identifiable, Codable, Equatable {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var steps: Int
    var weightKg: Double?
    /// Total paused time (user-triggered pause) to subtract from duration.
    var totalPausedSeconds: TimeInterval = 0

    var durationSeconds: TimeInterval { max(0, endDate.timeIntervalSince(startDate) - totalPausedSeconds) }
    var durationMinutes: Int { Int(durationSeconds / 60) }

    /// Estimated calories (simplified: steps-based + duration, optional weight).
    /// Returns 0 when there is no duration and no steps; otherwise floor of formula to avoid showing 1 for tiny activity.
    var estimatedCalories: Double {
        guard steps > 0 || durationSeconds > 0 else { return 0 }
        let w = weightKg ?? 60
        let stepsCal = Double(steps) * 0.04
        let durationCal = (durationSeconds / 3600) * (w * 2.5)
        return max(0, floor(stepsCal + durationCal))
    }

    init(id: UUID = UUID(), startDate: Date, endDate: Date, steps: Int, weightKg: Double? = nil, totalPausedSeconds: TimeInterval = 0) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.steps = steps
        self.weightKg = weightKg
        self.totalPausedSeconds = totalPausedSeconds
    }
}
