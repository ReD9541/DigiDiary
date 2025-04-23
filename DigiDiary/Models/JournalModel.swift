//
//  JournalModel.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 23/4/2025.
//

import FirebaseFirestore

// MARK: - Journal Model
struct Journal: Identifiable {
    
    // MARK: - Properties
    @DocumentID var id:    String?
    let userId:    String
    let title:     String
    let date:      Date
    let content:   String
    let imageURLs: [String]
    let emotion:   Emotion
    
    // MARK: - Initializer (initialize from a Firestore DocumentSnapshot)
    init?(from doc: DocumentSnapshot) {
        // to pull the raw data dictionary from the snapshot
        let data = doc.data() ?? [:]
        // this is to validate and unwrap required fields or return nil if missing
        guard
            let uid     = data["userId"]  as? String,
            let title   = data["title"]   as? String,
            let ts      = data["date"]    as? Timestamp,
            let content = data["content"] as? String,
            let emoRaw  = data["emotion"] as? Int,
            let emotion = Emotion(rawValue: emoRaw)
        else {
            return nil
        }
        // assigninig values to my model properties, and converting types
        self.id        = doc.documentID
        self.userId    = uid
        self.title     = title
        self.date      = ts.dateValue()
        self.content   = content
        // an empty array is default if the user doesn't give any img urls
        self.imageURLs = data["imageURLs"] as? [String] ?? []
        self.emotion   = emotion
    }
}
