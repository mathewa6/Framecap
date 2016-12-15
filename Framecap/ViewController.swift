//
//  ViewController.swift
//  Framecap
//
//  Created by Adi Mathew on 12/15/16.
//  Copyright © 2016 RCPD. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CoreMedia


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var videoButton: UIButton!
    var picker = UIImagePickerController()
    var player: AVPlayer?
    var currentURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func showVideos(_ sender: UIButton) {
        self.openLib()
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func captureImage() {
        let imgView = UIImageView(image: frameImage(fromURL: currentURL!))
        imgView.frame = self.view.bounds
        let scaledIMG = imageWithImage(image: imgView.image!, scaledToSize: CGSize(width: 64.0, height: 36.0))
        UIImageWriteToSavedPhotosAlbum(scaledIMG, nil, nil, nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let url = info[UIImagePickerControllerMediaURL] as? URL else {
            print("Not a Video...")
            return
        }
        
        currentURL = url
        player = AVPlayer(url: currentURL!)
        
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        
        let butt = UIButton(type: .system)
        butt.addTarget(self, action: #selector(self.captureImage), for: .touchUpInside)
        butt.frame = CGRect(x: 10, y: 100, width: 75, height: 75)
        butt.layer.cornerRadius = butt.frame.size.width/2
        butt.tintColor = UIColor.purple
        butt.isOpaque = true
        butt.showsTouchWhenHighlighted = true
        butt.backgroundColor = UIColor.white
        butt.titleLabel?.textColor = UIColor.white
        butt.titleLabel?.text = "CAPTURE"

        picker.dismiss(animated: true)

        self.present(playerVC,
                     animated: true) {
                        playerVC.player?.play()
                        playerVC.view?.addSubview(butt)
                        playerVC.view?.bringSubview(toFront: butt)
        }
        
        let path = url.path
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
            //UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil,  nil)
        }
        picker.dismiss(animated: true)
    }
    
    func openLib() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.delegate = self
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            picker.videoQuality = .typeHigh
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            if UIDevice.current.userInterfaceIdiom == .pad {
                picker.modalPresentationStyle = .popover
                picker.popoverPresentationController?.sourceView = self.videoButton
                picker.popoverPresentationController?.sourceRect = CGRect(x: self.videoButton.frame.width/2.0,
                                                                          y: self.videoButton.frame.height/2.0,
                                                                          width: self.videoButton.frame.width/2.0,
                                                                          height: self.videoButton.frame.height/2.0)
                picker.popoverPresentationController?.permittedArrowDirections = .left
                self.present(picker, animated: true, completion: nil)
            } else {
                self.present(picker, animated: true, completion: nil)
            }
        }
    }
    
    func frameImage(fromURL url: URL) -> UIImage? {
        let asset = AVAsset (url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = player?.currentTime()
        
        do {
            let img = try generator.copyCGImage(at: time!, actualTime: nil)
            return UIImage(cgImage: img)
        } catch let error as NSError {
            print("Failed : \(error)")
            return nil
        }
    }
}
