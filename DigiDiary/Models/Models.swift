//
//  Models.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 21/4/2025.
//
import Foundation
import FirebaseFirestore

// MARK: - Emotion

enum Emotion: Int, Codable, CaseIterable {
    case anger = 1        // Red
    case excitement       // Orange
    case happiness        // Yellow
    case serenity         // Green
    case sadness          // Blue

    var description: String {
        switch self {
        case .anger:      return "Anger"
        case .excitement: return "Excitement"
        case .happiness:  return "Happiness"
        case .serenity:   return "Serenity"
        case .sadness:    return "Sadness"
        }
    }
}

// MARK: - User

struct UserModel: Codable, Identifiable {
    @DocumentID var id: String?
    let username: String
    let email: String
}

// MARK: - Journal

struct JournalModel: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let title: String
    let date: Date
    let content: String
    let imageURLs: [String]
    let emotion: Emotion

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case date
        case content
        case imageURLs
        case emotion
    }
}

// MARK: - Streak Calculation

extension Array where Element == JournalModel {
    var currentStreak: Int {
        let calendar = Calendar.current

        let entryDays = Set(self.map { calendar.startOfDay(for: $0.date) })

        var streak = 0
        var day = calendar.startOfDay(for: Date())

        while entryDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else {
                break
            }
            day = previous
        }
        return streak
    }
}

// MARK: - TipModel

struct TipModel: Codable, Identifiable {
    @DocumentID var id: String?
    let quote: String
    let author: String?
}
