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
    @IBOutlet weak var streaknumberLabel: UILabel!
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
    
    private let db = Firestore.firestore()
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
        
        streakinfoview.isUserInteractionEnabled = true
        journalview.isUserInteractionEnabled = true
        tipsView.isUserInteractionEnabled = true

        // attach a tap gesture to each
        let streakTap = UITapGestureRecognizer(target: self, action: #selector(streakInfoTapped))
        streakinfoview.addGestureRecognizer(streakTap)

        let journalTap = UITapGestureRecognizer(target: self, action: #selector(journalTapped))
        journalview.addGestureRecognizer(journalTap)

        let tipsTap = UITapGestureRecognizer(target: self, action: #selector(tipsViewTapped))
        tipsView.addGestureRecognizer(tipsTap)
        
        fetchUserName()
        subscribeToJournals()
        fetchRandomTip()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        journalListener?.remove()
    }
    
    // MARK: – User
    
    private func fetchUserName() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { [weak self] snap, error in
            guard let self = self else { return }
            if let data = snap?.data(),
               let username = data["username"] as? String {
                DispatchQueue.main.async {
                    self.welcomeusernameLabel.text = "Welcome \(username)"
                }
            } else {
                DispatchQueue.main.async {
                    self.welcomeusernameLabel.text = "Welcome!"
                }
            }
        }
    }
    
    // MARK: – Journals
    
    private func subscribeToJournals() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        journalListener = db.collection("journals")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("Journal listener error:", err.localizedDescription)
                    return
                }
                
                let docs = snap?.documents ?? []
                print("Received \(docs.count) journal docs")
                
                // Decode into models
                var entries: [JournalModel] = docs.compactMap { doc in
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
                        userId:    uid,
                        title:     title,
                        date:      ts.dateValue(),
                        content:   content,
                        imageURLs: images,
                        emotion:   emotion
                    )
                }
                
                // Manually sort by date descending
                entries.sort { $0.date > $1.date }
                
                DispatchQueue.main.async {
                    if entries.isEmpty {
                        // No journals yet
                        self.streakLabel.text         = "0 days"
                        self.avgemotionsLabel.text    = ""
                        self.journalTitleLabel.text   = "Add a journal to fill in these values"
                        self.journalEmotionLabel.text = ""
                        self.journalContentLabel.text = ""
                        self.journalDateLabel.text    = ""
                    } else {
                        // 1) Streak: “X day(s)”
                        let days = entries.currentStreak
                        self.streakLabel.text = days == 1
                        ? "1 day"
                        : "\(days) days"
                        
                        // 2) Mode of last 5 emotions
                        let lastFive = Array(entries.prefix(5))
                        let freq = Dictionary(grouping: lastFive, by: { $0.emotion })
                            .mapValues { $0.count }
                        let mostFrequent = freq.max { $0.value < $1.value }?.key
                        ?? .happiness
                        self.avgemotionsLabel.text = mostFrequent.description
                        
                        // 3) Populate latest entry
                        let latest = entries[0]
                        self.journalTitleLabel.text   = latest.title
                        self.journalEmotionLabel.text = latest.emotion.description
                        self.journalContentLabel.text = latest.content
                        self.journalDateLabel.text    =
                        self.dateFormatter.string(from: latest.date)
                    }
                }
            }
        
    }
    
    // MARK: – Tips
    
    private func fetchRandomTip() {
        db.collection("tips").getDocuments { [weak self] snap, error in
            guard let self = self else { return }
            if let error = error {
                print("tips fetch error:", error.localizedDescription)
                return
            }
            let tips = snap?.documents.compactMap { doc -> TipModel? in
                let d = doc.data()
                guard let q = d["quote"] as? String else { return nil }
                return TipModel(id: doc.documentID,
                                quote: q,
                                author: d["author"] as? String)
            } ?? []
            
            let text = tips.randomElement()?.quote ?? "No tips available"
            DispatchQueue.main.async {
                self.tipsLabel.text = text
            }
        }
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//      switch segue.identifier {
//      case "ShowStreakInfo":
//        let dest = segue.destination as! StreakDetailVC
//        // dest.streak = self.currentStreak
//      case "ShowJournals":
//        let dest = segue.destination as! JournalVC
//        // dest.journals = self.entries
//      case "ShowTips":
//        let dest = segue.destination as! TipsVC
//        // dest.tips = self.tipsArray
//      default:
//        break
//      }
//    }
}
