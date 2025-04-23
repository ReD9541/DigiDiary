//
//  tipmodel.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 23/4/2025.
//

import FirebaseFirestore

struct Tip {
  let quote: String
  let author: String
  let id: String

    init(quote: String, author: String, id: String) {
      self.quote  = quote
      self.author = author
      self.id     = id
    }

    init?(from doc: DocumentSnapshot) {
      let data = doc.data() ?? [:]
      guard
        let quote  = data["quote" ] as? String,
        let author = data["author"] as? String
      else { return nil }
      self.quote  = quote
      self.author = author
      self.id     = doc.documentID
    }
}
