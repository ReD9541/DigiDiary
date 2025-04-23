//
//  AddJournalVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddJournalVC: UIViewController {
    
    // MARK: – IBOutlets
    @IBOutlet private weak var topbarjournaltitleLabel: UILabel!
    @IBOutlet private weak var journaltitleTextField: UITextField!
    @IBOutlet private weak var contentTextField: UITextView!
    @IBOutlet private weak var imgURLTextField: UITextField!
    @IBOutlet private weak var emotionPopupButton: UIButton!
    @IBOutlet private weak var journalentrydateLabel: UILabel!
    @IBOutlet private weak var addthisjournalButton: UIButton!
    
    // MARK: – Properties
    private let db = Firestore.firestore()
    private var selectedEmotion: Emotion = .serenity
    private let emotions = Emotion.allCases
    
    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        stylizeUI()
        setupDateLabel()
        setupEmotionMenu()
    }
    
    // MARK: – Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJournalSegue",
           let dest = segue.destination as? JournalShowCaseVC,
           let id   = sender as? String {
            dest.journalId = id
        }
    }
    
    // MARK: – UI Setup
    private func stylizeUI() {
        addthisjournalButton.layer.cornerRadius = 8
        
        contentTextField.layer.borderWidth = 1
        contentTextField.layer.borderColor = UIColor.lightGray.cgColor
        contentTextField.layer.cornerRadius = 5
    }
    
    private func setupDateLabel() {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        journalentrydateLabel.text = fmt.string(from: Date())
    }
    
    private func setupEmotionMenu() {
        let actions = emotions.map { emo in
            UIAction(title: emo.description) { [weak self] _ in
                self?.selectedEmotion = emo
                self?.emotionPopupButton.setTitle(emo.description, for: .normal)
            }
        }
        emotionPopupButton.menu = UIMenu(title: "Select Emotion", children: actions)
        emotionPopupButton.showsMenuAsPrimaryAction = true
        emotionPopupButton.setTitle(selectedEmotion.description, for: .normal)
    }
    
    // MARK: – Actions
    @IBAction private func journaltitletextFieldEdited(_ sender: Any) {
        topbarjournaltitleLabel.text = journaltitleTextField.text
    }
    
    @IBAction private func addthisjournalButtonTapped(_ sender: UIButton) {
        // 1) Validate title
        guard let title = journaltitleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            return showAlert(message: "Please enter a journal title.")
        }
        
        // 2) Gather content + image URLs
        let content = contentTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawURL  = imgURLTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let imageURLs = rawURL.isEmpty ? [] : [rawURL]
        
        // 3) Ensure logged‑in
        guard let uid = Auth.auth().currentUser?.uid else {
            return showAlert(message: "You must be logged in to add a journal.")
        }
        
        // 4) Build the data dictionary
        let data: [String:Any] = [
            "userId":    uid,
            "title":     title,
            "date":      Timestamp(date: Date()),
            "content":   content,
            "imageURLs": imageURLs,
            "emotion":   selectedEmotion.rawValue
        ]
        
        // 5) Save to Firestore
        var ref: DocumentReference? = nil
        ref = db.collection("journals").addDocument(data: data) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(message: "Failed to save journal: \(error.localizedDescription)")
            } else if let newId = ref?.documentID {
                let successAlert = UIAlertController(
                    title:   "Success",
                    message: "Your journal was saved!",
                    preferredStyle: .alert
                )
                successAlert.addAction(.init(title: "View Entry", style: .default) { _ in
                    self.performSegue(withIdentifier: "showJournalSegue", sender: newId)
                })
                successAlert.addAction(.init(title: "Done", style: .cancel) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(successAlert, animated: true)
            }
        }
    }
    
    // MARK: – Helpers
    private func showAlert(title: String = "Oops!", message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(.init(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
