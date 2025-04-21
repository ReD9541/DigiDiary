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
    //MARK: IObuttons
    
    @IBOutlet weak var welcomeusernameLabel: UILabel!
    @IBOutlet weak var streaknumberLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var avgemotionsLabel: UILabel!
    
    @IBOutlet weak var journalTitleLabel: UILabel!
    @IBOutlet weak var journalEmotionLabel: UILabel!
    @IBOutlet weak var journalContentLabel: UILabel!
    @IBOutlet weak var journalDateLabel: UILabel!
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    private let db = Firestore.firestore()
    private var journalListener: ListenerRegistration?
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserName()
        subscribeToJournals()
        fetchRandomTip()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        journalListener?.remove()
    }
    // Do any additional setup after loading the view.
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
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
    
    // MARK: - Journals
    
    private func subscribeToJournals() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        journalListener = db.collection("journals")
            .whereField("userId", isEqualTo: uid)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("Journal listener error:", err)
                    return
                }
                let docs = snap?.documents ?? []
                print("Received \(docs.count) journal docs")
                
                // Decode
                var entries: [JournalModel] = []
                for doc in docs {
                    let d = doc.data()
                    guard
                        let ts       = d["date"]      as? Timestamp,
                        let title    = d["title"]     as? String,
                        let content  = d["content"]   as? String,
                        let emoRaw   = d["emotion"]   as? Int,
                        let emotion  = Emotion(rawValue: emoRaw)
                    else {
                        continue
                    }
                    let images = d["imageURLs"] as? [String] ?? []
                    entries.append(JournalModel(
                        id:        doc.documentID,
                        userId:    uid,
                        title:     title,
                        date:      ts.dateValue(),
                        content:   content,
                        imageURLs: images,
                        emotion:   emotion
                    ))
                }
                
                DispatchQueue.main.async {
                    if entries.isEmpty {
                        // No journals yet
                        self.streaknumberLabel.text    = "0"
                        self.streakLabel.text     = "Add a journal to fill in these values"
                        self.avgemotionsLabel.text = ""
                        
                        self.journalTitleLabel.text     = "Add a journal to fill in these values"
                        self.journalEmotionLabel.text   = ""
                        self.journalContentLabel.text   = ""
                        self.journalDateLabel.text      = ""
                    } else {
                        print(entries)
                        let days = entries.currentStreak
                        self.streaknumberLabel.text  = "\(days)"
                        self.streakLabel.text   = days == 1 ? "Day" : "Days"
                        
                        let avgValue = entries
                            .map { Double($0.emotion.rawValue) }
                            .reduce(0, +)
                        / Double(entries.count)
                        let avgEmo = Emotion(rawValue: Int(avgValue.rounded())) ?? .happiness
                        self.avgemotionsLabel.text = avgEmo.description
                        
                        let latest = entries[0]
                        self.journalTitleLabel.text    = latest.title
                        self.journalEmotionLabel.text  = latest.emotion.description
                        self.journalContentLabel.text  = latest.content
                        self.journalDateLabel.text     = self.dateFormatter.string(from: latest.date)
                    }
                }
            }
    }
    
    
    private func fetchRandomTip() {
        db.collection("tips")
            .getDocuments { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    print("tips fetch error:", error)
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
}
