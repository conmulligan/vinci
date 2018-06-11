//
//  TableViewController.swift
//  Vinci
//
//  Created by Conor Mulligan on 27/04/2018.
//  Copyright © 2018 Conor Mulligan. All rights reserved.
//

import UIKit
import Vinci

struct Entity: Decodable {
    let wrapperType: String
    let artworkUrl100: String?
    let artistName: String?
    let collectionName: String?
}

struct EntityResponse: Decodable {
    let results: [Entity]
}

class TableViewController: UITableViewController {
    let searchURL = URL(string: "https://itunes.apple.com/search?term=the+rolling+stones&entity=album")!
    let cellID = "PhotoCell"
    
    var entities = [Entity]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Data
    
    func loadData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = URLSession.shared.dataTask(with: self.searchURL) { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard data != nil else {
                let message = error?.localizedDescription ?? "data task returned nil data."
                self.showError(message: "Error fetching data: \(message)")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(EntityResponse.self, from: data!)
                self.entities = response.results.filter({ $0.artworkUrl100 != nil })
            } catch {
                self.showError(message: "Error decoding JSON: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadSections([0], with: .automatic)
            }
        }
        
        task.resume()
    }
    
    func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alertController, animated: true)
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! PhotoCell
        
        let entity = self.entities[indexPath.row]
        
        cell.titleLabel.text = entity.collectionName
        cell.subtitleLabel.text = entity.artistName
        
        if let str = entity.artworkUrl100, let url = URL(string: str) {
            Vinci.shared.request(with: url) { image, isCached in
                cell.photoView.image = image
            }
        }
        
        return cell
    }
}
