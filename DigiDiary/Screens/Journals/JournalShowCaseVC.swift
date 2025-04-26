//
//  JournalShowCaseVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseFirestore

// MARK: - JournalShowCaseVC
class JournalShowCaseVC: UIViewController {
    
    // MARK: - IBOutlets
    /// to present title, date, content, emotion, and image.
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var emotionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Properties
    /// ID of the journal document to load.
    var journalId: String!
    private var  repository = FirebaseRepository() 
    // MARK: - Lifecycle
    ///  ID is provided.
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(journalId != nil, "journalId must be set before presenting!")
        loadJournal()
    }
    
    // MARK: - Data Fetching
    
    private func loadJournal() {
        repository.fetchJournal(withId: journalId) { [weak self] journal, error in
            guard let self = self else { return }
            if let error = error {
                print("Error loading journal:", error.localizedDescription)
                return
            }
            guard let journal = journal else {
                print("No journal found for ID \(self.journalId!)")
                return
            }
            self.updateUI(with: journal)
        }
    }
    private func updateUI(with journal: JournalModel) {
        DispatchQueue.main.async {
            self.title = journal.title
            self.titleLabel.text       = journal.title
            let fmt = DateFormatter()
            fmt.dateStyle = .medium
            self.dateLabel.text        = fmt.string(from: journal.date)
            self.contentTextView.text  = journal.content
            self.emotionLabel.text     = journal.emotion.description
            
            if let urlString = journal.imageURLs.first,
               let url = URL(string: urlString) {
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
