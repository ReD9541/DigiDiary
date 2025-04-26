//
//  FirebaseRepository.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 24/4/2025.
//

import FirebaseFirestore
import FirebaseAuth

class FirebaseRepository {
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // MARK: - User related method
    // Creates a new Auth user and writes their username & email into Firestore.
    func createUser(email: String,
                    password: String,
                    username: String,
                    completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            guard let uid = result?.user.uid else {
                completion(NSError(domain: "FirebaseRepo",
                                   code: -1,
                                   userInfo: [NSLocalizedDescriptionKey: "Invalid user ID"]))
                return
            }
            let userData: [String:Any] = [
                "username": username,
                "email": email
            ]
            self.db.collection("users")
                .document(uid)
                .setData(userData) { err in
                    completion(err)
                }
        }
    }
    
    // Fetch a user's "username" field
    func fetchUsername(for userId: String,
                       completion: @escaping (_ username: String?, _ error: Error?) -> Void) {
        db.collection("users")
            .document(userId)
            .getDocument { snap, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                let username = snap?.data()?["username"] as? String
                completion(username, nil)
            }
    }
    
    // Update username after reauthentication
    func updateUsername(currentPassword: String,
                        newUsername: String,
                        completion: @escaping (_ error: Error?) -> Void) {
        guard let user = auth.currentUser,
              let email = user.email else {
            completion(NSError(domain: "FirebaseRepo", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(error)
                return
            }
            self.db.collection("users").document(user.uid)
                .updateData(["username": newUsername]) { err in
                    completion(err)
                }
        }
    }
    
    // Update password after reauthentication
    func updatePassword(currentPassword: String,
                        newPassword: String,
                        completion: @escaping (_ error: Error?) -> Void) {
        guard let user = auth.currentUser,
              let email = user.email else {
            completion(NSError(domain: "FirebaseRepo", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(error)
                return
            }
            user.updatePassword(to: newPassword) { err in
                completion(err)
            }
        }
    }
    
    //MARK: - Journal related methods
    
    // Fetch journals for a specific user
    func fetchJournals(forUserId userId: String, completion: @escaping ([Journal]?, Error?) -> Void) {
        db.collection("journals")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                let journals = snapshot?.documents.compactMap { document in
                    return Journal(from: document)
                }
                completion(journals, nil)
            }
    }
    
    // MARK: - Journals
    // Subscribe to journals for a user; returns the listener so you can remove it later
    
    func subscribeToJournals(for userId: String,
                             listener: @escaping (_ entries: [JournalModel]?,
                                                  _ error: Error?) -> Void
    ) -> ListenerRegistration {
        return db.collection("journals")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snap, error in
                if let error = error {
                    listener(nil, error)
                    return
                }
                
                let docs = snap?.documents ?? []
                let entries: [JournalModel] = docs.compactMap { doc in
                    let d = doc.data()
                    guard
                        let ts      = d["date"]      as? Timestamp,
                        let title   = d["title"]     as? String,
                        let content = d["content"]   as? String,
                        let emoRaw  = d["emotion"]   as? Int,
                        let emotion = Emotion(rawValue: emoRaw)
                    else {
                        return nil
                    }
                    let images = d["imageURLs"] as? [String] ?? []
                    return JournalModel(
                        id:        doc.documentID,
                        userId:    userId,
                        title:     title,
                        date:      ts.dateValue(),
                        content:   content,
                        imageURLs: images,
                        emotion:   emotion
                    )
                }
                listener(entries, nil)
            }
    }
    
    /// Subscribe to real-time journal entries as `Journal` models
    @discardableResult
    func subscribeToJournalEntries(
        for userId: String,
        listener: @escaping (_ entries: [Journal]?, _ error: Error?) -> Void
    ) -> ListenerRegistration {
        return db.collection("journals")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    listener(nil, error)
                    return
                }
                let entries: [Journal] = snapshot?.documents.compactMap { doc in
                    Journal(from: doc)
                } ?? []
                listener(entries, nil)
            }
    }
    
    // in FirebaseRepository.swift
    
    /// Deletes a journal document by its Firestore ID
    func deleteJournal(withId id: String, completion: @escaping (Error?) -> Void) {
        db.collection("journals").document(id).delete { error in
            completion(error)
        }
    }
    
    
    // Adds a new journal entry for the current user
    func addJournal(title: String,
                    content: String,
                    imageURLs: [String],
                    emotion: Emotion,
                    date: Date = Date(),
                    completion: @escaping (_ journalId: String?, _ error: Error?) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(nil, NSError(domain: "FirebaseRepo", code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "User not signed in"]))
            return
        }
        let data: [String: Any] = [
            "userId":    uid,
            "title":     title,
            "date":      Timestamp(date: date),
            "content":   content,
            "imageURLs": imageURLs,
            "emotion":   emotion.rawValue
        ]
        var ref: DocumentReference?
        ref = db.collection("journals").addDocument(data: data) { err in
            completion(ref?.documentID, err)
        }
    }
    
    
    // Fetch a single journal by ID
    func fetchJournal(withId id: String,
                      completion: @escaping (_ journal: JournalModel?, _ error: Error?) -> Void) {
        db.collection("journals").document(id)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let d = snapshot?.data(),
                      let ts = d["date"] as? Timestamp,
                      let title = d["title"] as? String,
                      let content = d["content"] as? String,
                      let emoRaw = d["emotion"] as? Int,
                      let emotion = Emotion(rawValue: emoRaw) else {
                    completion(nil, nil)
                    return
                }
                let images = d["imageURLs"] as? [String] ?? []
                // userId stored in model or doc? adjust if needed
                let userId = d["userId"] as? String ?? ""
                let journal = JournalModel(id: id,
                                           userId: userId,
                                           title: title,
                                           date: ts.dateValue(),
                                           content: content,
                                           imageURLs: images,
                                           emotion: emotion)
                completion(journal, nil)
            }
    }
    
    //MARK: - Tips Related methods
    
    //fetchTips for getting tips
    func fetchTips(completion: @escaping ([Tip]?, Error?) -> Void) {
        db.collection("tips")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                let tips = snapshot?.documents.compactMap { doc -> Tip? in
                    let data = doc.data()
                    guard let quote = data["quote"] as? String else { return nil }
                    let author = data["author"] as? String ?? "Unknown"
                    return Tip(quote: quote,
                               author: author,
                               id:     doc.documentID)
                } ?? []
                completion(tips, nil)
            }
    }
    
    // Fetch a random tip from the collection
    func fetchRandomTip(completion: @escaping (_ tip: Tip?, _ error: Error?) -> Void) {
        db.collection("tips")
            .getDocuments { snap, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let allTips = snap?.documents.compactMap { doc -> Tip? in
                    let data = doc.data()
                    guard let quote = data["quote"] as? String else { return nil }
                    let author = data["author"] as? String ?? "Unknown"
                    return Tip(quote: quote,
                               author: author,
                               id:     doc.documentID)
                } ?? []
                
                completion(allTips.randomElement(), nil)
            }
    }
}
