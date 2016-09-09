//
//  ViewController.swift
//  iOSPhotoFilter
//
//  Created by Gaultier Moraillon on 02/12/2015.
//  Copyright © 2015 Gaultier Moraillon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var PhotoLibrary: UIButton!
    @IBOutlet weak var Camera: UIButton!
    @IBOutlet weak var ImageDisplay: UIImageView!
    @IBOutlet weak var ChangeFilter: UIButton!
    @IBOutlet weak var SaveButton: UIButton!
    
    var currentImage: UIImage!
    var DefaultImage: UIImage!
    let context = CIContext(options: nil)
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChangeFilter.enabled = false
        SaveButton.enabled = false
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func PhotoLibraryAction(sender: UIButton) {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        ChangeFilter.enabled = true
        SaveButton.enabled = true
        presentViewController(picker, animated: true, completion: nil)
        
    }

    
    @IBAction func CameraAction(sender: UIButton) {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .Camera
        ChangeFilter.enabled = true
        SaveButton.enabled = true
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        ImageDisplay.image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        currentImage = ImageDisplay.image
        DefaultImage = ImageDisplay.image
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func SwipeGesture(sender: UISwipeGestureRecognizer) {
        let inputImage = CIImage(image: ImageDisplay.image!)
        let randomColor = [kCIInputAngleKey: (Double(arc4random_uniform(314)) / 100)]
        let filteredImage = inputImage!.imageByApplyingFilter("CIHueAdjust", withInputParameters: randomColor)
        let renderedImage = context.createCGImage(filteredImage, fromRect: filteredImage.extent)
        ImageDisplay.image = UIImage(CGImage: renderedImage,
            scale: 1.0 ,
            orientation: UIImageOrientation.Right)
    }
    
    
    @IBAction func ChangeFilter(sender: AnyObject) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "CIColorInvert", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIColorMonochrome", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIFalseColor", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPhotoEffectNoir", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIColorCrossPolynomial", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Default", style: .Default, handler: putDefaultImage))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)

        
    }
    
    
    func putDefaultImage(action: UIAlertAction!){
        self.ImageDisplay.image = DefaultImage
    }
    
    func setFilter(action: UIAlertAction!) {
        currentFilter = CIFilter(name: action.title!)
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()

    }
    
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(0.5, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(0.5 * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(0.5 * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
        
        let cgimg = context.createCGImage(currentFilter.outputImage!, fromRect: currentFilter.outputImage!.extent)
        let processedImage = UIImage(CGImage: cgimg)
       let protrait : UIImage = UIImage(CGImage: processedImage.CGImage!,
        scale: 1.0 ,
        orientation: UIImageOrientation.Right)
        self.ImageDisplay.image = protrait
    }
    
    
    @IBAction func SaveAction(sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(ImageDisplay.image!, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
}

