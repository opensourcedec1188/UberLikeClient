//
//  ProfileViewController.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/8/17.
//  Copyright © 2017 Amer. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, EditFirstNameDelegate, EditPasswordViewDelegate, EditMobileNumberViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    var client:Client?
    var newClientImage:UIImage?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var clientImgBGView: UIView!
    @IBOutlet weak var clientImageView: UIImageView!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var referralCodeLabel: UILabel!
    
    var editFirstName:EditFirstName?
    var editPassword:EditPasswordView?
    var editMobile:EditMobileNumberView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientImageView.layer.cornerRadius = clientImageView.frame.size.height/2;
        clientImgBGView.layer.cornerRadius = clientImgBGView.frame.size.height/2;
        
        let shadowPath = UIHelperClass.setViewShadow(clientImgBGView, edgeInset: UIEdgeInsetsMake(-1.0, -1.0, -1.0, -1.0), andShadowRadius: 30.0)
        clientImgBGView.layer.shadowPath = shadowPath?.cgPath
        imageLoadingIndicator.isHidden = true
        
        let mainShadowPath = UIHelperClass.setViewShadow(mainView, edgeInset: UIEdgeInsetsMake(-1.0, -1.0, -1.0, -1.0), andShadowRadius: 30.0)
        mainView.layer.shadowPath = mainShadowPath?.cgPath
        
        let yourViewBorder:CAShapeLayer = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor(red: 0.0 / 255.0, green: 172.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0).cgColor
        yourViewBorder.lineDashPattern = [4, 3]
        yourViewBorder.cornerRadius = 4
        let shapeRect = CGRect(x: referralCodeLabel.frame.origin.x, y: referralCodeLabel.frame.origin.y, width: referralCodeLabel.frame.size.width, height: referralCodeLabel.frame.size.height)
        yourViewBorder.bounds = shapeRect
        
        yourViewBorder.position = CGPoint(x: referralCodeLabel.frame.size.width / 2, y: referralCodeLabel.frame.size.height / 2)
        yourViewBorder.path = UIBezierPath(rect: shapeRect).cgPath
        yourViewBorder.fillColor = UIColor.clear.cgColor
        referralCodeLabel.layer.addSublayer(yourViewBorder)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let clientData = ServiceManager.getClientDataFromUserDefaults() as NSDictionary? {
            client = Client.init(clientData: clientData)
            self.displayClientData()
        }
    }
    
    func displayClientData() {
        firstNameLabel.text = client?.firstName
        lastNameLabel.text = client?.lastName
        emailLabel.text = client?.email
        phoneLabel.text = client?.phone
        rateLabel.text = String(format: "%.2f", (client?.ratingsAvg)!)
        referralCodeLabel.text = client?.referralCode
        
        if let imgData:Data = UserDefaults.standard.data(forKey: "clientImageData") as Data? {
            clientImageView.image = UIImage(data: imgData)
        } else {
            if let ridePhotoImgStr = client?.photoUrl {
                clientImageView.setImageWith(URL(string: ridePhotoImgStr)!)
            }
        }
        clientImageView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showCommonView(fieldToEdit: String, fieldText: String, titleLabelText: String) {
        
        editFirstName?.removeFromSuperview()
        
        editFirstName = EditFirstName(frame: self.view.bounds)
        editFirstName?.mainView.frame = CGRect(x: 0, y: (editFirstName?.frame.size.height)!, width: (editFirstName?.mainView.frame.size.width)!, height: (editFirstName?.mainView.frame.size.height)!)
        editFirstName?.delegate = self
        editFirstName?.firstNameTF.text = fieldText
        editFirstName?.fieldToEdit = fieldToEdit
        editFirstName?.titleLabel.text = titleLabelText
        editFirstName?.bgView.alpha = 0.0
        self.view.addSubview(editFirstName!)
        self.view.bringSubview(toFront: editFirstName!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.editFirstName?.bgView.alpha = 1.0
            self.editFirstName?.mainView.frame = CGRect(x:0, y: (self.editFirstName?.frame.size.height)! - (self.editFirstName?.mainView.frame.size.height)!,width: (self.editFirstName?.frame.size.width)!, height: (self.editFirstName?.mainView.frame.size.height)!)
            self.editFirstName?.firstNameTF.becomeFirstResponder()
        }, completion: nil)
        
    }

    @IBAction func changeFirstName(_ sender: UIButton) {
        let fNameLocalized = NSLocalizedString("first_name", comment: "")
        self.showCommonView(fieldToEdit: "firstName", fieldText: (client?.firstName)!, titleLabelText: fNameLocalized)
    }
    
    @IBAction func changeLastName(_ sender: UIButton) {
        let lNameLocalized = NSLocalizedString("last_name", comment: "")
        self.showCommonView(fieldToEdit: "lastName", fieldText: (client?.lastName)!, titleLabelText: lNameLocalized)
    }
    
    @IBAction func changeEmail(_ sender: Any) {
        let emailLocalized = NSLocalizedString("last_name", comment: "")
        self.showCommonView(fieldToEdit: "email", fieldText: (client?.email)!, titleLabelText: emailLocalized)
    }
    
    func closeView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.editFirstName?.bgView.alpha = 0.0
            self.editFirstName?.mainView.frame = CGRect(x:0, y:(self.editFirstName?.frame.size.height)!,width: (self.editFirstName?.mainView.frame.size.width)!, height: (self.editFirstName?.mainView.frame.size.height)!);
        }, completion: { (finished: Bool) in
            self.editFirstName?.bgView.alpha = 1.0
            self.editFirstName?.removeFromSuperview()
        })
    }
    
    func updateInfo() {
        if let clientData = ServiceManager.getClientDataFromUserDefaults() as NSDictionary? {
            client = Client.init(clientData: clientData)
            self.displayClientData()
        }
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
        editPassword?.removeFromSuperview()
        
        editPassword = EditPasswordView(frame: self.view.bounds)
        editPassword?.mainView.frame = CGRect(x: 0, y: (editPassword?.mainView.frame.size.height)!, width: (editPassword?.mainView.frame.size.width)!, height: (editPassword?.mainView.frame.size.height)!)
        editPassword?.delegate = self
        editPassword?.bgView.alpha = 0.0
        self.view.addSubview(editPassword!)
        self.view.bringSubview(toFront: editPassword!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.editPassword?.bgView.alpha = 1.0
            self.editPassword?.mainView.frame = CGRect(x:0, y: 0,width: (self.editPassword?.frame.size.width)!, height: (self.editPassword?.mainView.frame.size.height)!)
            self.editPassword?.oldPasswordTF.becomeFirstResponder()
        }, completion: nil)
    }
    
    func closePasswordView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.editPassword?.bgView.alpha = 0.0
            self.editPassword?.mainView.frame = CGRect(x:0, y: (self.editPassword?.frame.size.height)!,width: (self.editPassword?.mainView.frame.size.width)!, height: (self.editPassword?.mainView.frame.size.height)!);
        }, completion: { (finished: Bool) in
            self.editPassword?.bgView.alpha = 1.0
            self.editPassword?.removeFromSuperview()
        })
    }
    
    @IBAction func changePhone(_ sender: UIButton) {
        editMobile?.removeFromSuperview()
        
        editMobile = EditMobileNumberView(frame: self.view.bounds)
        editMobile?.mainView.frame = CGRect(x: 0, y: (editMobile?.mainView.frame.size.height)!, width: (editMobile?.mainView.frame.size.width)!, height: (editMobile?.mainView.frame.size.height)!)
        editMobile?.delegate = self
        editMobile?.bgView.alpha = 0.0
        self.view.addSubview(editMobile!)
        self.view.bringSubview(toFront: editMobile!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.editMobile?.bgView.alpha = 1.0
            self.editMobile?.mainView.frame = CGRect(x:0, y: 0,width: (self.editMobile?.frame.size.width)!, height: (self.editMobile?.mainView.frame.size.height)!)
            self.editMobile?.passwordTF.becomeFirstResponder()
        }, completion: nil)
    }
    
    func closeMobileView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.editMobile?.bgView.alpha = 0.0
            self.editMobile?.mainView.frame = CGRect(x:0, y: (self.editMobile?.frame.size.height)!,width: (self.editMobile?.mainView.frame.size.width)!, height: (self.editMobile?.mainView.frame.size.height)!);
        }, completion: { (finished: Bool) in
            self.editMobile?.bgView.alpha = 1.0
            self.editMobile?.removeFromSuperview()
        })
    }
    
    @IBAction func changeClientPhotoAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let camAlertAction = UIAlertAction( title : "Camera" ,
                                         style : .default) { action in
                                            self.showImageController(sourceType: 0)
        }
        
        let libraryAlertAction = UIAlertAction( title : "Library" ,
                                         style : .default) { action in
                                            self.showImageController(sourceType: 1)
        }
        
        alertController.addAction(camAlertAction)
        alertController.addAction(libraryAlertAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func showImageController(sourceType:Int) {
        let picker:UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        switch sourceType {
        case 0:
            picker.sourceType = .camera
        case 1:
            picker.sourceType = .photoLibrary
        default:
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        if let chosenImage:UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let imgData = UIImagePNGRepresentation(chosenImage)
            let imgSize = Double((imgData?.count)!) / 1048576
            
            //Get bytes size of image
            var imageSize = Float((imgData?.count)!)
            
            //Transform into Megabytes
            imageSize = imageSize/(1024*1024)
            print("uploaded imageSize \(imageSize)")
            print("uploaded image size is \(imgSize)")
            if imgSize > 0 {
                menuBtn.isEnabled = false
                imageLoadingIndicator.isHidden = false
                imageLoadingIndicator.startAnimating()

                DispatchQueue.global(qos: .background).async {
                    self.uploadImageInBackground(imageToUpload: chosenImage)
                }
            }
            
            dismiss(animated:true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageInBackground(imageToUpload:UIImage) {
        autoreleasepool {
            ProfileServiceManager.uploadClientPhoto(imageToUpload) {
                response in
                print("ProfileServiceManager.uploadClientPhoto : \(String(describing: response))")
                if response?["code"] as! Int == 200{
                    UserDefaults.standard.set(UIImagePNGRepresentation(imageToUpload), forKey: "clientImageData")
                    UserDefaults.standard.synchronize()
                    
                    ServiceManager.getClientData(self.client?._id) {
                        response in
                        
                        guard response != nil else {
                            DispatchQueue.main.async {
                                self.finishUpdloadWithResponse(response: NSDictionary())
                            }
                            return
                        }
                        let responseObj:NSDictionary = (response as NSDictionary?)!
                        if responseObj["data"] != nil {
                            let updatedClientData = responseObj["data"]
                            ServiceManager.saveLogged(inClientData: updatedClientData as! [AnyHashable : Any], andAccessToken: nil)
                            DispatchQueue.main.async {
                                self.finishUpdloadWithResponse(response: response! as NSDictionary)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.finishUpdloadWithResponse(response: response! as NSDictionary)
                            }
                        }
                        
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.finishUpdloadWithResponse(response: response! as NSDictionary)
                    }
                }
            }
        }
    }
    
    func finishUpdloadWithResponse(response: NSDictionary) {
        menuBtn.isEnabled = true
        imageLoadingIndicator.isHidden = true
        imageLoadingIndicator.stopAnimating()
        
        if response["code"] != nil{
            if(response["code"] as! Int == 200){
                self.updateInfo()
            }
        }
    }
    
    @IBAction func shareReferralAction(_ sender: UIButton) {
        
    }
    
    @IBAction func menuBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
