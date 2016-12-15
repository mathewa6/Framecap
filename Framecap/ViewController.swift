//
//  ViewController.swift
//  Framecap
//
//  Created by Adi Mathew on 12/15/16.
//  Copyright © 2016 RCPD. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController()
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.openLib()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedType =  info[UIImagePickerControllerMediaType] as! String
        
        guard let url = info[UIImagePickerControllerMediaURL] as? URL else {
            print("Not a Video...")
            return
        }
        
        //player = AVPlayer(url: url)
        //player?.actionAtItemEnd = .pause
        //let layer = AVPlayerLayer(player: player)
        //layer.frame = self.view.bounds
        //layer.videoGravity = AVLayerVideoGravityResizeAspect
        // self.view.layer.addSublayer(layer)
        // player?.play()
        let imgView = UIImageView(image: frameImage(fromURL: url))
        imgView.frame = self.view.bounds
        UIImageWriteToSavedPhotosAlbum(imgView.image!, nil, nil, nil)
        // imgView.image?.renderingMode =
        self.view.addSubview(imgView)
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
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            if UIDevice.current.userInterfaceIdiom == .pad {
                picker.modalPresentationStyle = .popover
                picker.popoverPresentationController?.sourceView = self.view
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
        
        var time = asset.duration
        time.value = min(time.value, 2)
        //time = CMTimeMultiplyByFloat64(time, 0.5)
        
        do {
            let img = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: img)
        } catch let error as NSError {
            print("Failed : \(error)")
            return nil
        }
    }
}
