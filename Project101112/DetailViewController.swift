//
//  DetailViewController.swift
//  Project101112
//
//  Created by Eddie Jung on 8/17/21.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var imagePath: URL?
//    var image: String?
    var caption: String?
    
    override func viewDidLoad() {
        title = caption
        
        if let imageToLoad = imagePath {
            imageView.image = UIImage(contentsOfFile: imageToLoad.path)
        }
    }
}
