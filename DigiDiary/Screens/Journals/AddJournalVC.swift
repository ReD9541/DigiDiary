//
//  AddJournalVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - AddJournalVC
class AddJournalVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var journaltitleTextField: UITextField!
    @IBOutlet private weak var contentTextField: UITextView!
    @IBOutlet private weak var imgURLTextField: UITextField!
    @IBOutlet private weak var emotionPopupButton: UIButton!
    @IBOutlet private weak var journalentrydateLabel: UILabel!
    @IBOutlet private weak var addthisjournalButton: UIButton!
    
    // MARK: - Properties
    private let repository = FirebaseRepository()
    private var selectedEmotion: Emotion = .serenity
    private let emotions = Emotion.allCases
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Journal"
        stylizeUI()
        setupDateLabel()
        setupEmotionMenu()
    }
    
    // MARK: - Navigation
    /// preparing data before navigating to the journal detail view.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJournalSegue",
           let dest = segue.destination as? JournalShowCaseVC,
           let id   = sender as? String {
            dest.journalId = id
        }
    }
    
    // MARK: - UI Setup
    private func stylizeUI() {
        addthisjournalButton.layer.cornerRadius = 8
        contentTextField.layer.borderWidth = 1
        contentTextField.layer.borderColor = UIColor.lightGray.cgColor
        contentTextField.layer.cornerRadius = 5
    }
    
    /// to display today’s date
    private func setupDateLabel() {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        journalentrydateLabel.text = fmt.string(from: Date())
    }
    
    /// setting a  menu for the emotion button so users can pick from all cases.
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
    
    // MARK: - Actions
    //to update the title as the user types the title
    @IBAction private func journaltitletextFieldEdited(_ sender: Any) {
        title = journaltitleTextField.text
    }
    
    //inpout validation.
    @IBAction private func addthisjournalButtonTapped(_ sender: UIButton) {
        let title = journaltitleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else {
            return showAlert(title: "Title Required", message: "Please enter a journal title.")
        }
        let content = contentTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawURL  = imgURLTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let imageURLs = rawURL.isEmpty ? [] : [rawURL]
        let date = Date()
        
        repository.addJournal(
            title: title,
            content: content,
            imageURLs: imageURLs,
            emotion: selectedEmotion,
            date: date
        ) { [weak self] newId, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Save Unsuccessful", message: "Failed to save journal: \(error.localizedDescription)")
                } else if let id = newId {
                    let alert = UIAlertController(
                        title: "Success",
                        message: "Your journal was saved!",
                        preferredStyle: .alert
                    )
                    alert.addAction(.init(title: "View Entry", style: .default) { _ in
                        self.performSegue(withIdentifier: "showJournalSegue", sender: id)
                    })
                    alert.addAction(.init(title: "Done", style: .default) { _ in
                        self.navigationController?.popToRootViewController(animated: false)
                        self.tabBarController?.selectedIndex = 2
                    })
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
}
