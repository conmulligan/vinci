//
//  TableViewController.swift
//  Vinci
//
//  Created by Conor Mulligan on 27/04/2018.
//  Copyright © 2018 Conor Mulligan. All rights reserved.
//

import UIKit
import Vinci

/// A `Codable` struct representing an iTunes API entity.
struct Entity: Decodable {
    let wrapperType: String
    let artworkUrl100: String?
    let artistName: String?
    let collectionName: String?
}

/// A `Codable` struct representing an iTunes API entity collection.
struct EntityResponse: Decodable {
    let results: [Entity]
}

/// An example of a custom transformer that applies a gaussian blur filter to the image.
open class BlurTransformer: Transformer {
    public var identifier: String
    
    public init() {
        self.identifier = "vinci.example.blur"
    }
    
    public func doTransform(image: UIImage) -> UIImage {
        let ciImage = CIImage(cgImage: image.cgImage!)
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(8, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter?.outputImage else {
            return image
        }
        
        guard let cgImage = CIContext().createCGImage(outputImage, from: ciImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
}

/// Renders a list of Rolling Stones albums using the iTunes API.
class TableViewController: UITableViewController {
    let searchURL = URL(string: "https://itunes.apple.com/search?term=the+rolling+stones&entity=album")!
    let cellID = "PhotoCell"
    
    var entities = [Entity]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Vinci.debugMode = true
        
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
        cell.tag = indexPath.row
        
        let entity = self.entities[indexPath.row]
        
        cell.titleLabel.text = entity.collectionName
        cell.subtitleLabel.text = entity.artistName
        
        if let str = entity.artworkUrl100, let url = URL(string: str) {
            if indexPath.row % 2 == 0 {
                Vinci.shared.request(with: url) { (image, isCached) in
                    if cell.tag == indexPath.row {
                        cell.photoView.image = image
                    }
                }
            } else {
                let transformers: [Transformer] = [
                    MonoTransformer(color: UIColor.blue),
                    BlurTransformer()
                ]
                Vinci.shared.request(with: url, transformers: transformers) { (image, isCached) in
                    if cell.tag == indexPath.row {
                        cell.photoView.image = image
                    }
                }
            }
        }
        
        return cell
    }
}
