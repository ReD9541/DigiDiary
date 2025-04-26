//
//  JournaltableVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 24/4/2025.
//

import UIKit
import FirebaseAuth

class JournaltableVC: UITableViewController {
    
    // MARK: - Properties
    private var journals: [Journal] = []
    private let repository = FirebaseRepository()
    
    @IBOutlet var journalTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Journals"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        fetchJournals()
    }
    
    // MARK: - Data Fetching
    private func fetchJournals() {
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(title: "Not Logged In",
                      message: "Please log in to view your journals.")
            return
        }
        
        repository.fetchJournals(forUserId: uid) { [weak self] journals, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Fetch Error",
                                   message: error.localizedDescription)
                }
                return
            }
            self.journals = (journals ?? []).sorted { $0.date > $1.date }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        journals.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "journalCell",
            for: indexPath
        ) as! JournalCell
        let journal = journals[indexPath.row]
        cell.configure(with: journal)
        return cell
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let journal = journals[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showJournalSegue",
                     sender: journal.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        guard segue.identifier == "showJournalSegue",
              let dest = segue.destination as? JournalShowCaseVC,
              let id   = sender as? String else { return }
        dest.journalId = id
    }
    
    
    //:MARK: -to edit row
    //  Allow row editing
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let journal = journals[indexPath.row]
        guard let id = journal.id else { return }
        
        
        repository.deleteJournal(withId: id) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "Delete Failed", message: error.localizedDescription)
                } else {
                    self?.showAlert(title: "Deleted", message: "Journal deleted successfully")
                    self?.journals.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
}
