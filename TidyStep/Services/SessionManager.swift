//
//  SessionManager.swift
//  TidyStep
//

import Foundation
import CoreMotion
import Combine

final class SessionManager: ObservableObject {
    static let shared = SessionManager()

    private let pedometer = CMPedometer()
    private var sessionStartDate: Date?
    private var thirtyMinuteTimer: Timer?
    private var suppressThirtyMinuteReminder = false
    private let twoHours: TimeInterval = 2 * 3600
    private var twoHourTimer: Timer?
    private var displayTimer: Timer?
    private var pausedAt: Date?
    private var totalPausedSeconds: TimeInterval = 0
    private var stepsAtPause: Int = 0
    private var resumeDate: Date?

    /// Updates every second while session is active so UI shows elapsed time.
    @Published var displayTick: Int = 0

    @Published var isSessionActive = false
    @Published var isPaused = false
    @Published var currentSteps: Int = 0
    @Published var showThirtyMinuteAlert = false
    @Published var showTwoHourAlert = false
    @Published var sessionResult: CleaningSession?

    /// Active duration (excluding paused time).
    var currentDuration: TimeInterval {
        guard let start = sessionStartDate else { return 0 }
        let elapsed = Date().timeIntervalSince(start)
        if isPaused, let p = pausedAt {
            let currentPause = Date().timeIntervalSince(p)
            return elapsed - totalPausedSeconds - currentPause
        }
        return elapsed - totalPausedSeconds
    }

    func startSession(weightKg: Double?) {
        sessionStartDate = Date()
        currentSteps = 0
        totalPausedSeconds = 0
        pausedAt = nil
        stepsAtPause = 0
        resumeDate = nil
        suppressThirtyMinuteReminder = false
        isSessionActive = true
        isPaused = false
        sessionResult = nil

        if CMPedometer.isStepCountingAvailable() {
            startPedometer(from: sessionStartDate!, stepsOffset: 0)
        }
        scheduleTimers()
        startDisplayTimer()
    }

    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.displayTick += 1
            }
        }
        RunLoop.main.add(displayTimer!, forMode: .common)
    }

    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }

    private func startPedometer(from date: Date, stepsOffset: Int) {
        pedometer.startUpdates(from: date) { [weak self] data, _ in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.currentSteps = stepsOffset + data.numberOfSteps.intValue
            }
        }
    }

    private func scheduleTimers() {
        thirtyMinuteTimer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.onThirtyMinuteTick()
            }
        }
        twoHourTimer = Timer.scheduledTimer(withTimeInterval: twoHours, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showTwoHourAlert = true
            }
        }
    }

    /// User taps Pause: stop counting and timers; no reminders until Resume.
    func startPause() {
        guard isSessionActive, !isPaused else { return }
        isPaused = true
        pausedAt = Date()
        stepsAtPause = currentSteps
        if CMPedometer.isStepCountingAvailable() {
            pedometer.stopUpdates()
        }
        thirtyMinuteTimer?.invalidate()
        thirtyMinuteTimer = nil
        twoHourTimer?.invalidate()
        twoHourTimer = nil
        stopDisplayTimer()
    }

    /// User taps Resume: continue counting and restart timers.
    func endPause() {
        guard isSessionActive, isPaused, let p = pausedAt else { return }
        totalPausedSeconds += Date().timeIntervalSince(p)
        pausedAt = nil
        isPaused = false
        resumeDate = Date()
        if CMPedometer.isStepCountingAvailable() {
            startPedometer(from: resumeDate!, stepsOffset: stepsAtPause)
        }
        scheduleTimers()
        startDisplayTimer()
    }

    private func onThirtyMinuteTick() {
        guard isSessionActive, !suppressThirtyMinuteReminder else { return }
        showThirtyMinuteAlert = true
    }

    func userStillCleaning(dismissOnly: Bool) {
        showThirtyMinuteAlert = false
        if dismissOnly { return }
        suppressThirtyMinuteReminder = true
    }

    func userEndSession() {
        showThirtyMinuteAlert = false
        showTwoHourAlert = false
        endSession()
    }

    func confirmTwoHourEnd() {
        showTwoHourAlert = false
        endSession()
    }

    func cancelTwoHourAlert() {
        showTwoHourAlert = false
    }

    private func endSession() {
        guard let start = sessionStartDate else { return }
        let end = Date()
        var finalPaused = totalPausedSeconds
        if isPaused, let p = pausedAt {
            finalPaused += end.timeIntervalSince(p)
        }
        if CMPedometer.isStepCountingAvailable() {
            pedometer.stopUpdates()
        }
        thirtyMinuteTimer?.invalidate()
        thirtyMinuteTimer = nil
        twoHourTimer?.invalidate()
        twoHourTimer = nil
        stopDisplayTimer()
        isSessionActive = false
        isPaused = false

        let weight = StorageManager.shared.userWeightKg
        let session = CleaningSession(
            startDate: start,
            endDate: end,
            steps: currentSteps,
            weightKg: weight,
            totalPausedSeconds: finalPaused
        )
        sessionResult = session
        StorageManager.shared.addSession(session)
    }

    private init() {}
}
