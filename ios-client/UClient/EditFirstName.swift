//
//  EditFirstName.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/10/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

import UIKit

@objc protocol EditFirstNameDelegate{
    func updateInfo()
    func closeView()
}

class EditFirstName: UIView {
    
    var delegate:EditFirstNameDelegate?
    var loadingView:LoadingCustomView = LoadingCustomView()
    var fieldToEdit:String?
    var client:Client?

    @IBOutlet var CONTENTVIEW: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var firstNameSubview: UIView!
    @IBOutlet weak var dismissBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("EditFirstName", owner: self, options: nil)
        addSubview(CONTENTVIEW)
        CONTENTVIEW.frame = self.bounds
        
        firstNameTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        delegate?.closeView()
        self.superview?.endEditing(true)
    }
    
    @IBAction func updateAction(_ sender: UIButton) {
        
        self.superview?.endEditing(true)
        if HelperClass.checkNetworkReachability() {
            
            if let updatedValue = firstNameTF.text, !updatedValue.isEmpty {
                if fieldToEdit == "email" {
                    if HelperClass.validateEmailAddress(updatedValue) {
                        self.showLoadingView(show: true)
                        DispatchQueue.global(qos: .background).async {
                            self.updateFirstNameInBG(updatedString: updatedValue)
                        }
                    } else {
                        //Show Error
                        let localizedError = NSLocalizedString("personal_invalid_email", comment: "")
                        self.showError(view: firstNameSubview, errorMsg: localizedError)
                    }
                } else {
                    if HelperClass.validateFLNames(updatedValue) {
                        self.showLoadingView(show: true)
                        DispatchQueue.global(qos: .background).async {
                            self.updateFirstNameInBG(updatedString: updatedValue)
                        }
                    } else {
                        let localizedError = NSLocalizedString("prof_invalid_data", comment: "")
                        self.showError(view: firstNameSubview, errorMsg: localizedError)
                    }
                }
            } else {
                let localizedError = NSLocalizedString("Missing", comment: "")
                self.showError(view: firstNameSubview, errorMsg: localizedError)
            }
        } else {
            let localizedError = NSLocalizedString("network_problem_title", comment: "")
            self.showError(view: firstNameSubview, errorMsg: localizedError)
        }
        
    }
    
    func updateFirstNameInBG(updatedString: String) {
        autoreleasepool {
            let parameter: [String: Any] = [fieldToEdit!: updatedString]
            ProfileServiceManager.updateProfileData(parameter) {
                response in
                DispatchQueue.main.async {
                    self.finishUpdateFirstNameInBG(response: response as Any)
                }
            }
        }
    }
    
    func finishUpdateFirstNameInBG(response:Any) {
        print("finishGetPreviousRides \(response)")
        guard let responseData:NSDictionary = response as? NSDictionary else { return }
        if let code = responseData["code"] as? Int, code == 200 {
            let clientData = ServiceManager.getClientDataFromUserDefaults() as NSDictionary?
            client = Client.init(clientData: clientData!)
            ServiceManager.getClientData(client?._id) {
                getClientResponse in
                
                if getClientResponse != nil, (getClientResponse as? [String : Any])?["code"] as! Int == 200, let clientData = (getClientResponse as? [String : Any])?["data"] as? [String:Any] {
                    print("will update client info \(String(describing: clientData))")
                    ServiceManager.saveLogged(inClientData: clientData as [String : Any], andAccessToken: nil)
                    DispatchQueue.main.async {
                        self.finishUpdateWithResponse(response: clientData as NSDictionary)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.finishUpdateWithResponse(response: NSDictionary())
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.finishUpdateWithResponse(response: NSDictionary())
            }
        }
    }
    
    func finishUpdateWithResponse(response: NSDictionary) {
        self.showLoadingView(show: false)
        print("finishUpdateWithResponse \(response)")
        delegate?.updateInfo()
        delegate?.closeView()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        firstNameSubview.backgroundColor = UIColor.init(red: 34.0/255.0, green: 50.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        errorLabel.isHidden = true
    }
    
    func showError(view: UIView, errorMsg: String) {
        errorLabel.isHidden = false
        errorLabel.text = errorMsg;
        view.backgroundColor = UIColor.init(red: 247.0/255.0, green: 17.0/255.0, blue: 94.0/255.0, alpha: 1.0)
    }
    
    // MARK: - Loading
    func showLoadingView(show:Bool) {
        if show {
            loadingView.removeFromSuperview()
            loadingView = LoadingCustomView(frame: self.bounds, andAnimatorY:Float(mainView.frame.origin.y))
            self.addSubview(loadingView)
            self.bringSubview(toFront: loadingView)
        }else{
            loadingView.removeFromSuperview()
        }
    }
    
}
