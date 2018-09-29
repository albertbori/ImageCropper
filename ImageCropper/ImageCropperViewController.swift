//
//  ImageCropperViewController.swift
//  Albert Bori
//
//  Created by Albert Bori on 9/27/18.
//  Copyright © 2018 Albert Bori. All rights reserved.
//  Inspired by:
//  - https://medium.com/modernnerd-code/how-to-make-a-custom-image-cropper-with-swift-3-c0ec8c9c7884
//  - https://medium.com/@aatish.rajkarnikar/how-make-a-imagecropper-like-instagram-1557dc5b6a6a
//

import UIKit

protocol ImageCropperViewControllerDelegate: class {
    func cancelImageCropper(imageCropperViewController: ImageCropperViewController)
    func handleCroppedImage(imageCropperViewController: ImageCropperViewController, image: UIImage)
}

class ImageCropperViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var cropAreaView: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait }
    weak var delegate: ImageCropperViewControllerDelegate?
    var imageToCrop: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10
        
        imageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cropAreaView.layer.cornerRadius = cropAreaView.frame.width / 2
        maskCropArea()
        setImageToCrop(image: imageToCrop)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate?.cancelImageCropper(imageCropperViewController: self)
    }
    
    @IBAction func crop(_ sender: UIButton) {
        let cropRect = getImageCropRect()
        guard let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropRect) else { return }
        let croppedImage = UIImage(cgImage: croppedCGImage)
        delegate?.handleCroppedImage(imageCropperViewController: self, image: croppedImage)
    }
    
    func setImageToCrop(image: UIImage) {
        imageView.image = image
        let scale = max(cropAreaView.frame.size.width/image.size.width, cropAreaView.frame.size.height/image.size.height)
        
        imageWidthConstraint.constant = image.size.width * scale
        imageHeightConstraint.constant = image.size.height * scale
        
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        
        let inset = (scrollView.frame.height - cropAreaView.frame.height) / 2
        scrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        scrollView.contentOffset = CGPoint(x: (imageWidthConstraint.constant - scrollView.frame.width) / 2, y: (imageHeightConstraint.constant - scrollView.frame.height) / 2)
    }
    
    func maskCropArea() {
        let outerPath = UIBezierPath(rect: maskView.frame)
        let circlePath = UIBezierPath(ovalIn: cropAreaView.frame)
        outerPath.usesEvenOddFillRule = true
        outerPath.append(circlePath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.fillColor = UIColor.black.withAlphaComponent(0.66).cgColor
        maskView.layer.addSublayer(maskLayer)
    }
    
    func getImageCropRect() -> CGRect {
        guard let image = imageView.image else { return CGRect.zero }
        let imageScale: CGFloat = min(image.size.width/cropAreaView.frame.width, image.size.height/cropAreaView.frame.height)
        let zoomFactor = 1/scrollView.zoomScale
        let x = (scrollView.contentOffset.x + cropAreaView.frame.origin.x) * zoomFactor * imageScale
        let y = (scrollView.contentOffset.y  + cropAreaView.frame.origin.y) * zoomFactor * imageScale
        let width = cropAreaView.frame.size.width * zoomFactor * imageScale
        let height = cropAreaView.frame.size.height * zoomFactor * imageScale
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension ImageCropperViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
