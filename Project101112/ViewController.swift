//
//  ViewController.swift
//  Project101112
//
//  Created by Eddie Jung on 8/17/21.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var pictures = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addNewPhoto))
        
        load()
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
            let path = getDocumentsDirectory().appendingPathComponent(picture.fileName)
            vc.imagePath = path
            vc.caption = picture.caption
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func addNewPhoto() {
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            print("camera - picker sourcetype: \(picker.sourceType)")
        } else {
            picker.sourceType = .photoLibrary
            print("photoLibrary - picker sourcetype: \(picker.sourceType)")
        }
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        dismiss(animated: true)
        
        let ac = UIAlertController(title: "Add Caption", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newCaption = ac?.textFields?[0].text else { return }
            let picture = Photo(fileName: imageName, caption: newCaption)
            self?.pictures.insert(picture, at: 0)
            self?.save()
            self?.tableView.reloadData()
        })
        
        present(ac, animated: true)
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        }
    }
    
    func load() {
        let defaults = UserDefaults.standard
        if let savedPictures = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                pictures = try jsonDecoder.decode([Photo].self, from: savedPictures)
            } catch {
                print("Failed to load pictures.")
            }
        }
    }
    
}

// MARK: TODO
// 1. dont let users submit an empty caption
// 2. camera crop box is stuck to the top.

extension UIImagePickerController {
    // copied fix  to scroll crop view box
    open override var childForStatusBarHidden: UIViewController? {
        return nil
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // https://stackoverflow.com/questions/12630155/uiimagepicker-allowsediting-stuck-in-center/13167122#13167122
    open override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            fixCannotMoveEditingBox()
        }
        
        func fixCannotMoveEditingBox() {
                if let cropView = cropView,
                   let scrollView = scrollView,
                   scrollView.contentOffset.y == 0 {
                    
                    var top: CGFloat = 0.0
                    if #available(iOS 11.0, *) {
                        top = cropView.frame.minY + self.view.safeAreaInsets.top
                    } else {
                        // Fallback on earlier versions
                        top = cropView.frame.minY
                    }
                    let bottom = scrollView.frame.height - cropView.frame.height - top
                    scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
                    
                    var offset: CGFloat = 0
                    if scrollView.contentSize.height > scrollView.contentSize.width {
                        offset = 0.5 * (scrollView.contentSize.height - scrollView.contentSize.width)
                    }
                    scrollView.contentOffset = CGPoint(x: 0, y: -top + offset)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.fixCannotMoveEditingBox()
                }
            }
            
            var cropView: UIView? {
                return findCropView(from: self.view)
            }
            
            var scrollView: UIScrollView? {
                return findScrollView(from: self.view)
            }
            
            func findCropView(from view: UIView) -> UIView? {
                let width = UIScreen.main.bounds.width
                let size = view.bounds.size
                if width == size.height, width == size.height {
                    return view
                }
                for view in view.subviews {
                    if let cropView = findCropView(from: view) {
                        return cropView
                    }
                }
                return nil
            }
            
            func findScrollView(from view: UIView) -> UIScrollView? {
                if let scrollView = view as? UIScrollView {
                    return scrollView
                }
                for view in view.subviews {
                    if let scrollView = findScrollView(from: view) {
                        return scrollView
                    }
                }
                return nil
            }
}
