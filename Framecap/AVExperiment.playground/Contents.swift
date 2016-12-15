import PlaygroundSupport
import UIKit
import AVFoundation
import  CoreMedia

let types = UIImagePickerController.availableMediaTypes(for: .camera)

class PickerVC:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pop: UIPopoverController?
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
        pop?.dismiss(animated: true)
    }
    
    func openLib() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            var picker = UIImagePickerController()
            picker.delegate = self 
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            if UIDevice.current.userInterfaceIdiom == .pad {
                pop = UIPopoverController(contentViewController: picker)
                pop?.present(from: CGRect.zero, in: self.view, permittedArrowDirections: .any, animated: true)
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

let vc = PickerVC()
PlaygroundPage.current.liveView = vc

