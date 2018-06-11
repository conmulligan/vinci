//
//  ImageCell.swift
//  Vinci_Example
//
//  Created by Conor Mulligan on 29/04/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoView.image = nil
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
    }
}
