import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    var ref = Database.database().reference()
    let tapRecognite = UITapGestureRecognizer()
//    let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let userDefault = UserDefaults.standard
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var blinkView: UIView!
    @IBOutlet weak var onOffView: UIView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var ledBlinkSwitch: UISwitch!
    @IBOutlet weak var onOffSwitch: UISwitch!
    
    @IBOutlet weak var lightRangeSlider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImage.makeRounded()
        blinkView.borderRounded()
        onOffView.borderRounded()
        sliderView.borderRounded()
        tapRecognite.addTarget(self, action: #selector(ViewController.tappedView))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapRecognite)
        getProfileImage()
        controlValue()
        
    }
    
    func controlValue()  {
        let isOn = userDefault.bool(forKey: "isOn")
        let isBlink = userDefault.bool(forKey: "isBlink")
        let lightRange = userDefault.float(forKey: "lightRange")
        onOffSwitch.isOn = isOn
        ledBlinkSwitch.isOn = isBlink
        lightRangeSlider.value =  lightRange
        
    }
    
    
    @IBAction func ledBlinkSwitch(_ sender: UISwitch) {
        let isOn = sender.isOn
        if isOn {
            ref.child("value/").updateChildValues(["value" : 1024])
            userDefault.set(true, forKey: "isBlink")
        
        }
        else{
            ref.child("value/").updateChildValues(["value" : 512])
            userDefault.set(false, forKey: "isBlink")
        }
    }
    
    @IBAction func onOffSwitch(_ sender: UISwitch) {
        let isOn = sender.isOn
        if isOn {
            ref.child("value/").updateChildValues(["value" : 1024])
            userDefault.set(true, forKey: "isOn")
        }
        else{
            ref.child("value/").updateChildValues(["value" : 0])
            userDefault.set(false, forKey: "isOn")
        }
    }
    
    @IBAction func lightSlider(_ sender: UISlider) {
        let toIntNumber = Int(round(sender.value))
        ref.child("value/").updateChildValues(["value" : toIntNumber])
        userDefault.set(sender.value, forKey: "lightRange")
    }
}

//MARK: - UIImageView Circle
extension UIImageView{
    func makeRounded() {
        
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
        self.layer.backgroundColor = UIColor.white.cgColor
    }
}

//MARK: - Border UIView
extension UIView{
    func borderRounded()  {
        self.layer.cornerRadius = 12
    }
}

//MARK: - UIImagePickerController and LoadPickerImage when app start

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @objc func tappedView()  {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagePicked = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        avatarImage.image = imagePicked
        
        if let data = imagePicked?.pngData() {
//            let url = filename.appendingPathComponent("profile.png")
                let imageBase64String =  data.base64EncodedString()
                userDefault.set(imageBase64String, forKey: "profile")
            
                
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func getProfileImage() {
        if let imageBase64String = userDefault.value(forKey: "profile"),
            let url = URL(string: String(format:"data:application/octet-stream;base64,%@",imageBase64String as! CVarArg))
        {
            do
            {
                let data =  try Data(contentsOf: url)
                let image = UIImage(data: data)
                avatarImage.image = image
                
            }
            catch
            {
                print("Error decoding image \(error)")
            }
        }
    }
}
