//
//  GalleryCellCollectionViewCell.swift
//  flickr_image_gallery
//
//  Created by Kirill Emelyanenko on 7/7/20.
//  Copyright © 2020 bokka. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
        activityIndicator.startAnimating()
    }
        
    func update(with image: Data?) {
        guard let image = image else { return }
        
        imageView.image = UIImage(data: image)
        activityIndicator.stopAnimating()
    }
    
}
