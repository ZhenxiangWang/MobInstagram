//
//  imageEditVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 25/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import CoreImage

class imageEditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var filter3Btn: UIButton!
    @IBOutlet var filter2Btn: UIButton!
    @IBOutlet var filter1Btn: UIButton!
    @IBOutlet var picImg: UIImageView!
    
    @IBOutlet var contrastSlid: UISlider!
    @IBOutlet var brightSlid: UISlider!
    
    var img : UIImage = UIImage(named: "pbg.jpg")!
    var ciImage : CIImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picTap = UITapGestureRecognizer(target: self, action: #selector(imageEditVC.selectImg))
        picTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
        
        brightSlid.maximumValue = 0.2
        brightSlid.minimumValue = -0.2
        brightSlid.value = 0
        contrastSlid.maximumValue = 2
        contrastSlid.minimumValue = 0
        contrastSlid.value = 1
        
        
    }
    
    @objc func selectImg(){
        var alert: UIAlertController!
        alert = UIAlertController(title: "Pick Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cleanAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel,handler:nil)
        let cameraAction = UIAlertAction(title: "camera", style: UIAlertAction.Style.default){(action:UIAlertAction)in
            self.cameraImg()
        }
        let albumAction = UIAlertAction(title: "album", style: UIAlertAction.Style.default){ (action:UIAlertAction)in
            self.albumImg()
        }
        alert.addAction(cleanAction)
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func albumImg(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func cameraImg(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.cameraCaptureMode = .photo
            
            let overlayImage = UIImageView(image: UIImage(named: "grid.png"))
            let overlayRect = CGRect(x:0, y:20, width:415, height: 600)
            overlayImage.frame = overlayRect
            imagePicker.cameraOverlayView = overlayImage
            
            
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picImg.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        img = picImg.image!
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmBtn_click(_ sender: Any) {
        let uploadVC = self.storyboard?.instantiateViewController(withIdentifier: "uploadVC") as! uploadVC
        uploadVC.img = picImg.image!
        uploadVC.ciImage = self.ciImage
        self.navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    @IBAction func filter1Btn_click(_ sender: Any) {
        let ciImage = CIImage(image: img)
        let color = CIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 0.5)
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(color, forKey: kCIInputColorKey)
        filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        let outImage = filter?.outputImage
        picImg.image = UIImage(ciImage:outImage!)
        self.ciImage = outImage!
        
        filter1Btn.setTitleColor(.white, for: UIControl.State())
        filter1Btn.backgroundColor = .blue
        filter2Btn.setTitleColor(.blue, for: UIControl.State())
        filter2Btn.backgroundColor = .white
        filter3Btn.setTitleColor(.blue, for: UIControl.State())
        filter3Btn.backgroundColor = .white
    }
    
    @IBAction func filter2Btn_click(_ sender: Any) {
        let ciImage = CIImage(image: img)
        let color = CIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 0.5)
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(color, forKey: kCIInputColorKey)
        filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        let outImage = filter?.outputImage
        picImg.image = UIImage(ciImage:outImage!)
        self.ciImage = outImage!
        
        filter1Btn.setTitleColor(.blue, for: UIControl.State())
        filter1Btn.backgroundColor = .white
        filter2Btn.setTitleColor(.white, for: UIControl.State())
        filter2Btn.backgroundColor = .blue
        filter3Btn.setTitleColor(.blue, for: UIControl.State())
        filter3Btn.backgroundColor = .white
    }
    
    @IBAction func filter3Btn_click(_ sender: Any) {
        let ciImage = CIImage(image: img)
        let color = CIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 0.5)
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(color, forKey: kCIInputColorKey)
        filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        let outImage = filter?.outputImage
        picImg.image = UIImage(ciImage:outImage!)
        self.ciImage = outImage!
        
        filter1Btn.setTitleColor(.blue, for: UIControl.State())
        filter1Btn.backgroundColor = .white
        filter2Btn.setTitleColor(.blue, for: UIControl.State())
        filter2Btn.backgroundColor = .white
        filter3Btn.setTitleColor(.white, for: UIControl.State())
        filter3Btn.backgroundColor = .blue
    }
    
    @IBAction func brightValueChanged(_ sender: Any) {
        let ciImage = self.ciImage
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(brightSlid.value, forKey: kCIInputBrightnessKey)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        let outImage = filter?.outputImage
        picImg.image = UIImage(ciImage:outImage!)
        self.ciImage = outImage!
        
    }
    
    @IBAction func contrastValueChanged(_ sender: Any) {
        let ciImage = self.ciImage
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(contrastSlid.value, forKey: kCIInputContrastKey)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        let outImage = filter?.outputImage
        picImg.image = UIImage(ciImage:outImage!)
        self.ciImage = outImage!
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
