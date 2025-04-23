//
//  StreakDetailVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - StreakDetailVC
/// I present detailed journaling statistics to the user,
/// fetching entry data in real time and updating the UI.
class StreakDetailVC: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var currentStreakLabel:      UILabel!
    @IBOutlet weak var longestStreakLabel:      UILabel!
    @IBOutlet weak var totalJournalsLabel:      UILabel!
    @IBOutlet weak var mostCommonEmotionLabel:  UILabel!
    @IBOutlet weak var entriesPerWeekLabel:     UILabel!
    @IBOutlet weak var lastJournalDateLabel:    UILabel!

    // MARK: - Properties
    /// I hold a reference to Firestore for fetching journals.
    private let db = Firestore.firestore()
    /// I keep the listener so I can detach it when not needed.
    private var listener: ListenerRegistration?
    /// I format dates in a medium style for display.
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    // MARK: - Lifecycle
    /// I start listening to journal updates every time the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToJournals()
    }
    /// I detach the Firestore listener when the view disappears.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }

    // MARK: - Firestore Subscription
    /// to subscribe to the user's journal collection
    /// and map snapshots into StreakStats for the UI.
    private func subscribeToJournals() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        listener = db.collection("journals")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self,
                      let docs = snap?.documents else { return }
                let entries = docs.compactMap(Journal.init(from:))
                let stats   = entries.streakStats
                DispatchQueue.main.async {
                    self.updateUI(with: stats)
                }
            }
    }

    // MARK: - UI Updates
    /// assignign formatted stats values to my labels.
    private func updateUI(with stats: StreakStats) {
        currentStreakLabel.text     = "\(stats.currentStreak) day" + (stats.currentStreak == 1 ? "" : "s")
        longestStreakLabel.text     = "\(stats.longestStreak) day" + (stats.longestStreak == 1 ? "" : "s")
        totalJournalsLabel.text     = "\(stats.totalEntries)"
        mostCommonEmotionLabel.text = stats.mostCommonEmotion.description
        entriesPerWeekLabel.text    = String(format: "%.1f", stats.entriesPerWeek)
        lastJournalDateLabel.text   = stats.lastEntryDate.map(dateFormatter.string) ?? "—"
    }
}

// MARK: - StreakStats

struct StreakStats {
    let currentStreak:    Int
    let longestStreak:    Int
    let totalEntries:     Int
    let mostCommonEmotion: Emotion
    let entriesPerWeek:   Double
    let lastEntryDate:    Date?
}

// MARK: - Journal Array Extensions
extension Array where Element == Journal {

    // MARK: - calculate Stats
    var streakStats: StreakStats {
        let sorted   = self.sorted { $0.date > $1.date }
        let current  = sorted.currentStreak
        let longest  = sorted.longestStreak
        let total    = sorted.count
        let freq     = Dictionary(grouping: sorted, by: \.emotion).mapValues(\ .count)
        let common   = freq.max { $0.value < $1.value }?.key ?? .happiness
        let perWeek  = sorted.entriesPerWeek
        let lastDate = sorted.first?.date

        return StreakStats(
            currentStreak:     current,
            longestStreak:     longest,
            totalEntries:      total,
            mostCommonEmotion: common,
            entriesPerWeek:    perWeek,
            lastEntryDate:     lastDate
        )
    }

    // MARK: - Current Streak Calculation
    /// using the same logic as in home vc
    var currentStreak: Int {
        let cal  = Calendar.current
        let days = Set(self.map { cal.startOfDay(for: $0.date) })

        var day = cal.startOfDay(for: Date())
        if !days.contains(day) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: day),
                  days.contains(yesterday) else {
                return 0
            }
            day = yesterday
        }

        var streak = 0
        while days.contains(day) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    // MARK: - Longest Streak Calculation
    /// I scan through all journal dates to fin
    var longestStreak: Int {
        let cal  = Calendar.current
        let days = Set(self.map { cal.startOfDay(for: $0.date) })

        return days.reduce(into: 0) { best, start in
            var length = 0
            var day    = start
            while days.contains(day) {
                length += 1
                guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
                day = prev
            }
            best = Swift.max(best, length)
            // it runs for all the journal days and saves best or longest streak
        }
    }

    // MARK: - Entries Per Week Calculation
    var entriesPerWeek: Double {
        let cal   = Calendar.current
        let weeks = Set(self.map { cal.component(.weekOfYear, from: $0.date) })
        return weeks.isEmpty ? 0 : Double(count) / Double(weeks.count)
        //gets the current week of the year, is there hasn't been any entries, returns 0, else returns the no or entries/no of weeks
    }
}
