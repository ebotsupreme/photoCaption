//
//  ViewController.swift
//  Project101112
//
//  Created by Eddie Jung on 8/17/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Photo", for: indexPath)
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = picture.caption
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let picture = pictures[indexPath.row]
            vc.image = picture.fileName
            vc.caption = picture.caption
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

