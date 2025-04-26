//
//  HomeVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeVC: UIViewController {
    // MARK: – IBOutlets
    
    @IBOutlet weak var welcomeusernameLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var avgemotionsLabel: UILabel!
    
    @IBOutlet weak var journalTitleLabel: UILabel!
    @IBOutlet weak var journalEmotionLabel: UILabel!
    @IBOutlet weak var journalContentLabel: UILabel!
    @IBOutlet weak var journalDateLabel: UILabel!
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    @IBOutlet weak var streakinfoview: CustomUIView!
    @IBOutlet weak var journalview: CustomUIView!
    @IBOutlet weak var tipsView: CustomUIView!
    
    // MARK: – Properties
    
    private let repository = FirebaseRepository()
    private var journalListener: ListenerRegistration?
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    // MARK: – Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        
        streakinfoview.isUserInteractionEnabled = true
        journalview.isUserInteractionEnabled = true
        tipsView.isUserInteractionEnabled = true
        
        let streakTap = UITapGestureRecognizer(target: self, action: #selector(streakInfoTapped))
        streakinfoview.addGestureRecognizer(streakTap)
        
        let journalTap = UITapGestureRecognizer(target: self, action: #selector(journalTapped))
        journalview.addGestureRecognizer(journalTap)
        
        let tipsTap = UITapGestureRecognizer(target: self, action: #selector(tipsViewTapped))
        tipsView.addGestureRecognizer(tipsTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
               guard let uid = Auth.auth().currentUser?.uid else { return }
               
               repository.fetchUsername(for: uid) { [weak self] username, error in
                   DispatchQueue.main.async {
                       self?.welcomeusernameLabel.text = username.map { "Welcome \($0)" }
                                                               ?? "Welcome!"
                   }
               }
               
               // tear down any old listener first
               journalListener?.remove()
               journalListener = repository.subscribeToJournals(for: uid) { [weak self] entries, error in
                   if let entries = entries {
                       self?.processJournalEntries(entries)
                   }
               }
               
               repository.fetchRandomTip { [weak self] tip, error in
                   DispatchQueue.main.async {
                       self?.tipsLabel.text = tip?.quote ?? "No tips available"
                   }
               }
    }
    
    private func processJournalEntries(_ entries: [JournalModel]) {
        //  Sort newest first
        let sortedEntries = entries.sorted { $0.date > $1.date }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if sortedEntries.isEmpty {
                // No journals → show placeholder UI
                self.streakLabel.text         = "0 days"
                self.avgemotionsLabel.text    = ""
                self.journalTitleLabel.text   = "Add a journal to fill in these values"
                self.journalEmotionLabel.text = ""
                self.journalContentLabel.text = ""
                self.journalDateLabel.text    = ""
            } else {
                //  calculate streak
                let days = sortedEntries.currentStreak
                self.streakLabel.text = days == 1 ? "1 day" : "\(days) days"

                // calculate most frequent emotion in last 5 entries
                let lastFive = Array(sortedEntries.prefix(5))
                let freq = Dictionary(grouping: lastFive, by: { $0.emotion })
                            .mapValues { $0.count }
                let mostFrequent = freq.max { $0.value < $1.value }?.key
                                    ?? .happiness
                self.avgemotionsLabel.text = mostFrequent.description

                // Show latest journal details
                let latest = sortedEntries[0]
                self.journalTitleLabel.text   = latest.title
                self.journalEmotionLabel.text = latest.emotion.description
                self.journalContentLabel.text = latest.content
                self.journalDateLabel.text    = self.dateFormatter.string(from: latest.date)
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        journalListener?.remove()
    }
    
    
    
    @objc private func streakInfoTapped() {
        performSegue(withIdentifier: "ShowStreakInfo", sender: self)
    }
    
    @objc private func journalTapped() {
        performSegue(withIdentifier: "ShowJournals", sender: self)
    }
    
    @objc private func tipsViewTapped() {
        performSegue(withIdentifier: "ShowTips", sender: self)
    }
    
}
