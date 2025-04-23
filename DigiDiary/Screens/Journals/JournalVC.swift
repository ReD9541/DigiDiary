//
//  JournalVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - JournalVC
class JournalVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    private var journals: [Journal] = []
    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    ///load data once the view appears.
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.rowHeight          = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.cellLayoutMarginsFollowReadableWidth = false

        fetchJournals()
    }

    // MARK: - Data Fetching
    private func fetchJournals() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("journals")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Fetch journals error:", error.localizedDescription)
                    return
                }
                self.journals = (snapshot?.documents.compactMap(Journal.init(from:)) ?? [])
                    .sorted { $0.date > $1.date }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

// MARK: - UITableViewDataSource
extension JournalVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journals.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "JournalCell",
            for: indexPath
        ) as! JournalCell
        let journal = journals[indexPath.row]
        cell.configure(with: journal)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension JournalVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let journal = journals[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showJournalSegue",
                     sender: journal.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showJournalSegue",
              let dest = segue.destination as? JournalShowCaseVC,
              let id   = sender as? String else { return }
        dest.journalId = id
    }
}
