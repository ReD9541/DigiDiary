//
//  TipModel.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 23/4/2025.
//

import FirebaseFirestore

// MARK: - Tip Model

struct Tip {
    // MARK: Properties
    let quote: String
    let author: String
    let id: String

    // MARK: Direct Initializer
    /// Creates a Tip instance with known values.
    init(quote: String, author: String, id: String) {
        self.quote  = quote
        self.author = author
        self.id     = id
    }

    // MARK: Firestore Initializer
    /// to constructs a Tip from a Firestore DocumentSnapshot.
    init?(from doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]
        guard
            let quote  = data["quote"]  as? String,
            let author = data["author"] as? String
        else {
            return nil
        }

        self.quote  = quote
        self.author = author
        self.id     = doc.documentID
    }
}
