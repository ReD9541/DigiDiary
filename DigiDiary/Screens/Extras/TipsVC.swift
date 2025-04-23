//
//  TipsVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseFirestore

// MARK: - TipsVC

class TipsVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    private var tips: [Tip] = []
    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    
    ///set up my table view and data loading when the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate   = self

        //to enable dynamic cell hieght
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        fetchTips()
    }

    // MARK: - Data Fetching
    ///  to get all tip documents from Firestore and map them to Tip models.
    private func fetchTips() {
        db.collection("tips")
          .getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Tips fetch error:", error.localizedDescription)
                return  // I bail out on failure
            }

            // this transforms each document into a Tip, makes the author "unknown" if there is no author
            let fetched = snapshot?.documents.compactMap { doc -> Tip? in
                let data   = doc.data()
                guard let quote = data["quote"] as? String else { return nil }
                let author = data["author"] as? String ?? "Unknown"
                return Tip(quote: quote,
                           author: author,
                           id:     doc.documentID)
            } ?? []

            print("Fetched \(fetched.count) tips")
            self.tips = fetched

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TipsVC: UITableViewDataSource {

    ///how many tips I have to show.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tips.count
    }

    ///configuring each cell with its quote and author.
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TipCell",
            for: indexPath
        ) as! TipCell

        let tip = tips[indexPath.row]
        cell.configure(with: tip)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TipsVC: UITableViewDelegate {

    ///deselect the cell without additional actions when tapped.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
