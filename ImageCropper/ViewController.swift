//
//  ViewController.swift
//  ImageCropper
//
//  Created by Albert Bori on 9/29/18.
//  Copyright © 2018 Albert Bori. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var croppedImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        croppedImage.layer.cornerRadius = croppedImage.frame.height / 2
        croppedImage.clipsToBounds = true
    }
    
    @IBAction func testPortrait(_ sender: Any) {
        showImageCropper(for: UIImage(named: "tempCropTestPortrait")!)
    }
    
    @IBAction func testLandscape(_ sender: Any) {
        showImageCropper(for: UIImage(named: "tempCropTestLandscape")!)
    }
    
    private func showImageCropper(for image: UIImage) {
        let imageCropperViewController = ImageCropperViewController()
        imageCropperViewController.delegate = self
        imageCropperViewController.imageToCrop = image
        present(imageCropperViewController, animated: true, completion: nil)
    }
}

extension ViewController: ImageCropperViewControllerDelegate {
    func cancelImageCropper(imageCropperViewController: ImageCropperViewController) {
        imageCropperViewController.dismiss(animated: true, completion: nil)
    }
    
    func handleCroppedImage(imageCropperViewController: ImageCropperViewController, image: UIImage) {
        croppedImage.image = image
        imageCropperViewController.dismiss(animated: true, completion: nil)
    }
}
