//
//  ViewController.swift
//  Fileter
//
//  Created by Keun young Kim on 2017. 9. 14..
//  Copyright © 2017년 Sample. All rights reserved.
//

import UIKit
import MobileCoreServices
import Social

extension UIImage {
    func fixOrientation() -> UIImage
    {
        if self.imageOrientation == UIImageOrientation.up
        {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        else
        {
            return self
        }
    }
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    var originalImgae: UIImage?
    var filterdImgae: UIImage?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func pick(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let controller = UIImagePickerController()
            controller.sourceType = .savedPhotosAlbum
            controller.mediaTypes = [kUTTypeImage as String]
            controller.allowsEditing = true
            controller.delegate = self
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func take(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let controller = UIImagePickerController()
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeImage as String]
            controller.allowsEditing = true
            controller.delegate = self
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func share(_ sender: Any) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("Core Image Filter Sample")
            vc?.add(imageView.image)
            
            present(vc!, animated: true, completion: nil)
        }
        else
        {
            print("account not set")
        }
        
            
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            imageView.image = originalImgae
        } else {
            imageView.image = filterdImgae
        }
        
    }
    
    
    @IBOutlet weak var seg: UISegmentedControl!
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
 
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            originalImgae = image
            applyFilter(source: image.fixOrientation())
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func applyFilter(source: UIImage) {
        guard let cgimg = source.cgImage else {
            print("invalid image")
            return
        }
        
        guard let openGLContext = EAGLContext(api: .openGLES2) else {
            print("opengl init failed")
            return
        }
        
        let context = CIContext(eaglContext: openGLContext)
        
        let coreImage = CIImage(cgImage: cgimg)
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(coreImage, forKey: "inputImage")
        blurFilter?.setValue(20, forKey: "inputRadius")
        
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(blurFilter?.outputImage, forKey: "inputImage")
        sepiaFilter?.setValue(5, forKey: "inputIntensity")
        
        if let output = sepiaFilter?.outputImage, let result = context.createCGImage(output, from: output.extent) {
            filterdImgae = UIImage(cgImage: result)
            imageView?.image = filterdImgae
            seg.selectedSegmentIndex = 1
        } else {
            seg.selectedSegmentIndex = 0
        }
        
    }

        
    @IBAction func handleGuesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            imageView.image = originalImgae
        } else if sender.state == .ended {
            imageView.image = filterdImgae
        }
            
        }

    
    
    
//
//        let toneFilter = CIFilter(name: "CIToneCurve")
//        toneFilter?.setValue(coreImage, forKey: kCIInputImageKey)
//        toneFilter?.setValue(CIVector(x: 0.0, y: 0.0), forKey: "inputPoint0")
//        toneFilter?.setValue(CIVector(x: 0.3, y: 0.25), forKey: "inputPoint1")
//        toneFilter?.setValue(CIVector(x: 0.48, y: 0.48), forKey: "inputPoint2")
//        toneFilter?.setValue(CIVector(x: 0.64, y: 0.75), forKey: "inputPoint3")
//        toneFilter?.setValue(CIVector(x: 1.0, y: 1.0), forKey: "inputPoint4")
//        
//        let vignetteFilter = CIFilter(name: "CIVignette")
//        vignetteFilter?.setValue(toneFilter?.outputImage, forKey: "inputImage")
//        vignetteFilter?.setValue(NSNumber(value:0.64), forKey: "inputIntensity")
//        vignetteFilter?.setValue(NSNumber(value:1.62), forKey: "inputRadius")
//        
//        let colorPolynomial = CIFilter(name: "CIColorPolynomial")
//        colorPolynomial?.setValue(vignetteFilter?.outputImage, forKey: kCIInputImageKey)
//        colorPolynomial?.setValue(CIVector(x: 0.05, y: 1.0, z: 0.0, w: 0.0), forKey: "inputRedCoefficients")
//        colorPolynomial?.setValue(CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0), forKey: "inputGreenCoefficients")
//        colorPolynomial?.setValue(CIVector(x: -0.04, y: 1.0, z: 0.0, w: 0.0), forKey: "inputBlueCoefficients")
//        colorPolynomial?.setValue(CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0), forKey: "inputAlphaCoefficients")
//        
//        if let output = colorPolynomial?.outputImage, let result = context.createCGImage(output, from: output.extent) {
//            filteredImage = UIImage(cgImage: result)
//            imageView?.image = filteredImage
//        }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }




}

