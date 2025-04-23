//
//  JournalShowCaseVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseFirestore

class JournalShowCaseVC: UIViewController {
    
    // MARK: – IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var emotionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var topjournaltitlelabel: UILabel!
    
    // MARK: – Properties
    var journalId: String!
    private let db = Firestore.firestore()
    
    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(journalId != nil, "journalId must be set before presenting!")
        loadJournal()
    }
    
    // MARK: – Firestore Fetch
    private func loadJournal() {
        let docRef = db.collection("journals").document(journalId)
        docRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching journal:", error.localizedDescription)
                return
            }
            guard let data = snapshot?.data() else {
                print("No data for journalId \(self.journalId!)")
                return
            }
            
            // Manually map fields
            let title      = data["title"] as? String ?? ""
            let ts         = data["date"] as? Timestamp
            let date       = ts?.dateValue() ?? Date()
            let content    = data["content"] as? String ?? ""
            let rawEmotion = data["emotion"] as? Int ?? Emotion.serenity.rawValue
            let emotion    = Emotion(rawValue: rawEmotion) ?? .serenity
            let imageURLs  = data["imageURLs"] as? [String] ?? []
            
            // Update UI on main
            DispatchQueue.main.async {
                self.topjournaltitlelabel.text = title
                self.titleLabel.text           = title
                
                let fmt = DateFormatter()
                fmt.dateStyle = .medium
                self.dateLabel.text = fmt.string(from: date)
                
                self.contentTextView.text = content
                self.emotionLabel.text    = emotion.description
                
                if let first = imageURLs.first,
                   let url = URL(string: first) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data = data, let img = UIImage(data: data) else { return }
                        DispatchQueue.main.async {
                            self.imageView.image = img
                        }
                    }.resume()
                }
            }
        }
    }
}
