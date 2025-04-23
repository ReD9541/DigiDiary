//
//  Models.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 21/4/2025.
//

import Foundation
import FirebaseFirestore

// MARK: - Emotion
/// this is to define  the range of user emotions for journal entries.
enum Emotion: Int, Codable, CaseIterable {
    case anger = 1
    case excitement
    case happiness
    case serenity
    case sadness

    /// For users
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

// MARK: - UserModel
/// This represents an authenticated user in Firestore.
struct UserModel: Codable, Identifiable {
    @DocumentID var id: String?
    let username: String
    let email: String
}

// MARK: - JournalModel
/// This represents a diary entry stored in Firestore.
struct JournalModel: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let title: String
    let date: Date
    let content: String
    let imageURLs: [String]
    let emotion: Emotion

    enum CodingKeys: String, CodingKey {
        case id, userId, title, date, content, imageURLs, emotion
    }
}

// MARK: - Streak Calculation
/// to calculate the current  users streak.
extension Array where Element == JournalModel {
    var currentStreak: Int {
        let calendar = Calendar.current
        
        //make all journal dates into "midnight" and collect into a set
        let entryDays = Set(self.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        
        //coutnig the number of days
        var day = calendar.startOfDay(for: Date())

        while entryDays.contains(day) {
            streak += 1
            
            //if there's an entry add 1 and go back another day or else break
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else {
                break
            }
            day = previous
        }
        //https://www.swiftbysundell.com/articles/computing-dates-in-swift/
        
    
        //return the consecutive days which had entries with today
        return streak
    }
}

// MARK: - TipModel
/// This represents a tip or quote table
struct TipModel: Codable, Identifiable {
    @DocumentID var id: String?
    let quote: String
    let author: String?
}
