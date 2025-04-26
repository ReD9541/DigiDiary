//
//  TipstableVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 24/4/2025.
//

import UIKit
import FirebaseFirestore

class TipstableVC: UITableViewController {
    
    private var tips: [Tip] = []
    private var repository = FirebaseRepository()
    
    @IBOutlet var tipsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Motivational Quotes"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        fetchTips()
    }
    
    // MARK: - Data Fetching
    private func fetchTips() {
        repository.fetchTips { [weak self] fetchedTips, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Fetch Error", message: error.localizedDescription)
                }
                return
            }
            
            self.tips = fetchedTips ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tips.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TipCell",
            for: indexPath
        ) as! TipCell
        
        let tip = tips[indexPath.row]
        cell.configure(with: tip)
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // handle tap if needed
    }
}
