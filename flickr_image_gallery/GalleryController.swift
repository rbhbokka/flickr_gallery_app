//
//  GalleryController.swift
//  flickr_image_gallery
//
//  Created by Kirill Emelyanenko on 7/7/20.
//  Copyright © 2020 bokka. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Gallery Cell"

class GalleryController: UICollectionViewController {
    
    var imageCollection = [Data?](repeating: nil, count: 140)
    let url = URL(string: "https://loremflickr.com/200/200")! // changed to https, because don't like idea of messing with security settings
    let rowsCount = 10
    let columnsCount = 7
    let urlSession = URLSession.init(configuration: .default)
    var dataTasks = [URLSessionTask]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadAll()
    }
    
    func setupNavBar() {
        title = "Gallery"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "tornado"), style: .plain, target: self, action: #selector(reloadAll))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square.on.square"), style: .plain, target: self, action: #selector(loadMore))
        navigationController?.navigationBar.barStyle = .black
            
    }
    
    @objc func reloadAll() {
        imageCollection = [Data?](repeating: nil, count: 140)
        collectionView.reloadData()

        dataTasks.forEach { (task) in
            task.cancel()
        }
        
        (0..<self.imageCollection.count).forEach { imageIndex in
            loadImage(at: imageIndex) { cellIndex in
                self.collectionView.reloadItems(at: [cellIndex])
            }
        }
    }
    
    
    @objc func loadMore() {
        imageCollection.append(nil)
        
        let indexToUpdate = IndexPath(item: self.imageCollection.count - 1, section: 0)
        collectionView.insertItems(at: [indexToUpdate])

        loadImage(at: imageCollection.count - 1) {_ in
            self.collectionView.reloadItems(at: [indexToUpdate])
        }
    }
    
    func loadImage(at index: Int, completion: @escaping (_ cellIndex: IndexPath) -> ()) {
        
        let task = urlSession.dataTask(with: self.url) { [weak self] (data, _, _) in
            // in case of multiple reloads it is possible to get into race condition where dying network call is modiying image collection
            guard let count = self?.imageCollection.count, index <= count else { return }
            
            let cellIndex = IndexPath(item: index, section: 0)
            self?.imageCollection[index] = data
            
            DispatchQueue.main.async {
                completion(cellIndex)
            }
        }
        task.resume()
        dataTasks.append(task)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryCell
                
        let data = imageCollection[indexPath.item]
        cell.update(with: data)
    
        // Configure the cell
    
        return cell
    }

}

extension GalleryController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontal = (collectionView.frame.width - 14 /*margins*/) / 7
        let vertical = (collectionView.frame.height - 14 /*margins*/) / 10

        return CGSize(width: horizontal, height: vertical)
    }
}
