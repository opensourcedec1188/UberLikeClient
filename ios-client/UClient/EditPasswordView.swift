//
//  EditPasswordView.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/11/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

import UIKit

@objc protocol EditPasswordViewDelegate{
    func closePasswordView()
}

class EditPasswordView: UIView {
    
    var delegate:EditPasswordViewDelegate?
    var loadingView:LoadingCustomView = LoadingCustomView()
    
    var oldPassConst:CGFloat = 0
    var updatePassConst:CGFloat = 0
    var confirmPassConst:CGFloat = 0
    
    @IBOutlet var CONTENTVIEW: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var oldPasswordSubView: UIView!
    @IBOutlet weak var oldPasswordTF: UITextField!
    @IBOutlet weak var oldPasswordLabel: UILabel!
    @IBOutlet weak var oltPassTop: NSLayoutConstraint!
    @IBOutlet weak var showOldPassBtn: UIButton!
    
    @IBOutlet weak var updatePassSubview: UIView!
    @IBOutlet weak var updatedPassTF: UITextField!
    @IBOutlet weak var updatedPassLabel: UILabel!
    @IBOutlet weak var updatePassTop: NSLayoutConstraint!
    @IBOutlet weak var showUpdatedPassBtn: UIButton!
    
    @IBOutlet weak var ConfirmSubview: UIView!
    @IBOutlet weak var confirmNewPasswordTF: UITextField!
    @IBOutlet weak var confirmNewPassLabel: UILabel!
    @IBOutlet weak var confirmPassTop: NSLayoutConstraint!
    @IBOutlet weak var showConfirmPassBtn: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("EditPasswordView", owner: self, options: nil)
        addSubview(CONTENTVIEW)
        CONTENTVIEW.frame = self.bounds
        
        oldPasswordTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        updatedPassTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        confirmNewPasswordTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        oldPassConst = oltPassTop.constant
        updatePassConst = updatePassTop.constant
        confirmPassConst = confirmPassTop.constant
    }
    
    @IBAction func showOldPassBtnAction(_ sender: UIButton) {
        oldPasswordTF.isSecureTextEntry = !oldPasswordTF.isSecureTextEntry
        if !oldPasswordTF.isSecureTextEntry {
            sender.setImage(UIImage(named: "eyeHidePassword"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "eyeShowPassword"), for: .normal)
        }
    }
    
    @IBAction func showUpdatedPassBtnAction(_ sender: UIButton) {
        updatedPassTF.isSecureTextEntry = !updatedPassTF.isSecureTextEntry
        if !updatedPassTF.isSecureTextEntry {
            sender.setImage(UIImage(named: "eyeHidePassword"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "eyeShowPassword"), for: .normal)
        }
    }
    
    @IBAction func showConfirmPassBtnAction(_ sender: UIButton) {
        confirmNewPasswordTF.isSecureTextEntry = !confirmNewPasswordTF.isSecureTextEntry
        if !confirmNewPasswordTF.isSecureTextEntry {
            sender.setImage(UIImage(named: "eyeHidePassword"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "eyeShowPassword"), for: .normal)
        }
    }
    
    @IBAction func updateAction(_ sender: UIButton) {
        
        if HelperClass.checkNetworkReachability() {
            if let oldPass = oldPasswordTF.text, !oldPass.isEmpty, let confirmPass = confirmNewPasswordTF.text, !confirmPass.isEmpty, let updatedPass = updatedPassTF.text, !updatedPass.isEmpty {
                if updatedPass.count > 5, confirmPass.count > 5 {
                    if updatedPass == confirmPass {
                        let parameter: [String: Any] = [
                            "oldPassword": oldPass,
                            "newPassword": confirmPass,
                            "newPasswordConfirmation": updatedPass,
                        ]
                        self.showLoadingView(show: true)
                        DispatchQueue.global(qos: .background).async {
                            self.changePasswordInBackground(parameters: parameter)
                        }
                        
                    } else {
                        let localizedError = NSLocalizedString("passwords_equality_error", comment: "")
                        self.showError(view: updatePassSubview, errorMsg: localizedError)
                        let localizedConfirmError = NSLocalizedString("passwords_equality_error", comment: "")
                        self.showError(view: ConfirmSubview, errorMsg: localizedConfirmError)
                    }
                } else {
                    let localizedError = NSLocalizedString("personal_passwords_minimum_error", comment: "")
                    self.showError(view: updatePassSubview, errorMsg: localizedError)
                    let localizedConfirmError = NSLocalizedString("personal_passwords_minimum_error", comment: "")
                    self.showError(view: ConfirmSubview, errorMsg: localizedConfirmError)
                }
            } else {
                if !HelperClass.validateText(confirmNewPasswordTF.text) {
                    let localizedError = NSLocalizedString("missing_confirm_password", comment: "")
                    self.showError(view: ConfirmSubview, errorMsg: localizedError)
                }
                if !HelperClass.validateText(updatedPassTF.text) {
                    let localizedError = NSLocalizedString("missing_new_password", comment: "")
                    self.showError(view: updatePassSubview, errorMsg: localizedError)
                }
                if !HelperClass.validateText(oldPasswordTF.text) {
                    let localizedError = NSLocalizedString("missing_password", comment: "")
                    self.showError(view: oldPasswordSubView, errorMsg: localizedError)
                }
            }
        } else {
            let localizedError = NSLocalizedString("network_problem_title", comment: "")
            self.showError(view: oldPasswordSubView, errorMsg: localizedError)
        }
    }
    
    func changePasswordInBackground(parameters: [String: Any]) {
        autoreleasepool {
            ProfileServiceManager.updatePasswordData(parameters) {
                response in
                DispatchQueue.main.async {
                    self.finishChangePasswordInBackground(response: response as Any)
                }
            }
        }
    }
    
    func finishChangePasswordInBackground(response: Any) {
        self.showLoadingView(show: false)
        guard let responseData:NSDictionary = response as? NSDictionary else { return }
        if let code = responseData["code"] as? Int {
            if  code == 200 {
                delegate?.closePasswordView()
            } else if code == 401 {
                let localizedError = NSLocalizedString("wrong_password", comment: "")
                self.showError(view: ConfirmSubview, errorMsg: localizedError)
            } else {
                let localizedError = NSLocalizedString("error_title", comment: "")
                self.showError(view: ConfirmSubview, errorMsg: localizedError)
            }
        } else {
            let localizedError = NSLocalizedString("error_title", comment: "")
            self.showError(view: ConfirmSubview, errorMsg: localizedError)
        }
    }
    
    func showError(view: UIView, errorMsg: String) {
        errorLabel.isHidden = false
        errorLabel.text = errorMsg;
        view.backgroundColor = UIColor.init(red: 247.0/255.0, green: 17.0/255.0, blue: 94.0/255.0, alpha: 1.0)
    }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        delegate?.closePasswordView()
        self.superview?.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        var currentLabel:UILabel = UILabel()
        var constraint:NSLayoutConstraint = NSLayoutConstraint()
        if textField == oldPasswordTF {
            constraint = oltPassTop
            currentLabel = oldPasswordLabel
            constraint.constant = oldPassConst - 30
        } else if textField == updatedPassTF {
            currentLabel = updatedPassLabel
            constraint = updatePassTop
            constraint.constant = updatePassConst - 30
        } else if textField == confirmNewPasswordTF {
            currentLabel = confirmNewPassLabel
            constraint = confirmPassTop
            constraint.constant = confirmPassConst - 30
        }
        
        if let textStr = textField.text, !textStr.isEmpty{
            UIView.animate(withDuration: 0.1, animations: {
                self.layoutIfNeeded()
                currentLabel.font = UIFont.init(name: FONT_ROBOTO_LIGHT, size: 12)
                currentLabel.textColor = UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
            }, completion: nil)
        }else{
            constraint.constant = constraint.constant + 30
            
            UIView.animate(withDuration: 0.1, animations: {
                self.layoutIfNeeded()
                currentLabel.font = UIFont.init(name: FONT_ROBOTO_LIGHT, size: 16)
                currentLabel.textColor = UIColor(red: 34.0 / 255.0, green: 50.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
            }, completion: nil)
        }
        
        oldPasswordSubView.backgroundColor = UIColor.init(red: 34.0/255.0, green: 50.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        ConfirmSubview.backgroundColor = UIColor.init(red: 34.0/255.0, green: 50.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        updatePassSubview.backgroundColor = UIColor.init(red: 34.0/255.0, green: 50.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        errorLabel.isHidden = true
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
