//
//  TipsVC.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 8/4/2025.
//

import UIKit
import FirebaseFirestore

class TipsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var tips: [Tip] = []
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate   = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        fetchTips()
    }
    
    private func fetchTips() {
        
        db.collection("tips")
            .getDocuments(completion: { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("tips fetch error:", error.localizedDescription)
                    return
                }
                let fetched = snapshot?.documents.compactMap { doc -> Tip? in
                    let data = doc.data()
                    guard let quote  = data["quote" ] as? String else { return nil }
                    let author       = data["author"] as? String ?? "Unknown"
                    return Tip(quote: quote,
                               author: author,
                               id:     doc.documentID )
                } ?? []
                
                print(" fetched \(fetched.count) tips")
                self.tips = fetched
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
    
}
}

// MARK: – UITableViewDataSource
extension TipsVC: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tips.count
  }

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

// MARK: – UITableViewDelegate
extension TipsVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
