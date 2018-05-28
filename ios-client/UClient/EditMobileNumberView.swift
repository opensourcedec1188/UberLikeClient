//
//  EditMobileNumberView.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/11/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

import UIKit

protocol EditMobileNumberViewDelegate: NSObjectProtocol {
    func closeMobileView()
    func updateInfo()
}

class EditMobileNumberView: UIView, CustomTextFieldDelegate, UITextFieldDelegate {
    weak var delegate: EditMobileNumberViewDelegate?
    @IBOutlet weak var CONTENTVIEW: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    // MARK: - Password View
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordSubView: UIView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var showPassBtn: UIButton!
    
    // MARK: - Mobile View
    @IBOutlet weak var mobileContainerView: UIView!
    @IBOutlet weak var mobileSubView: UIView!
    @IBOutlet weak var mobileTF: UITextField!
    // MARK: - OTP View
    @IBOutlet weak var otpContainerView: UIView!
    @IBOutlet weak var moobileNumberLabel: UILabel!
    @IBOutlet weak var firstDigitTF: CustomTextField!
    @IBOutlet weak var secondDigitTF: CustomTextField!
    @IBOutlet weak var thirdDigitTF: CustomTextField!
    @IBOutlet weak var forthDigitTF: CustomTextField!
    @IBOutlet weak var resendOTPButton: UIButton!
    var counter: Int = 0
    var timer: Timer?
    
    var loadingView:LoadingCustomView = LoadingCustomView()
    var mobileNumberEnglish = ""
    var userInsertedCode = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("EditMobileNumberView", owner: self, options: nil)
        addSubview(CONTENTVIEW)
        CONTENTVIEW.frame = bounds
        mobileContainerView.frame = CGRect(x: frame.size.width, y: mobileContainerView.frame.origin.y, width: mobileContainerView.frame.size.width, height: mobileContainerView.frame.size.height)
        otpContainerView.frame = CGRect(x: frame.size.width, y: otpContainerView.frame.origin.y, width: otpContainerView.frame.size.width, height: otpContainerView.frame.size.height)

        firstDigitTF.customTFDelegate = self
        secondDigitTF.customTFDelegate = self
        thirdDigitTF.customTFDelegate = self
        forthDigitTF.customTFDelegate = self
        /* empty 4-digits textfields */
        forthDigitTF.text = ""
        thirdDigitTF.text = forthDigitTF.text
        secondDigitTF.text = thirdDigitTF.text
        firstDigitTF.text = secondDigitTF.text
        
        passwordTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        mobileTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func showOldPassBtnAction(_ sender: UIButton) {
        passwordTF.isSecureTextEntry = !passwordTF.isSecureTextEntry
        if !passwordTF.isSecureTextEntry {
            sender.setImage(UIImage(named: "eyeHidePassword"), for: .normal)
        }
        else {
            sender.setImage(UIImage(named: "eyeShowPassword"), for: .normal)
        }
    }
    
    @IBAction func confirmPasswordAction(_ sender: UIButton) {
        if HelperClass.checkNetworkReachability() {
            let password: String = passwordTF.text!
            if password.count > 5 {
                self.showLoadingView(show: true)
                let params = ["password": password]
                DispatchQueue.global(qos: .background).async {
                    self.validatePassword(parameters: params)
                }
            }
            else {
                self.showError(view: passwordSubView, errorMsg: NSLocalizedString("missing_password", comment: ""))
            }
        }
        else {
            self.showError(view: passwordSubView, errorMsg: NSLocalizedString("network_problem_title", comment: ""))
        }
    }
    
    // MARK: - Validate Password
    func validatePassword(parameters: [String: Any]) {
        autoreleasepool {
            ProfileServiceManager.validatePassword(parameters) {
                response in
                DispatchQueue.main.async {
                    self.finishValidatePassword(response: response as Any)
                }
            }
        }
    }
    
    func finishValidatePassword(response: Any) {
        self.showLoadingView(show: false)
        guard let responseData:NSDictionary = response as? NSDictionary else { return }
        if responseData["code"] as! Int == 200 {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {() -> Void in
                self.passwordContainerView.frame = CGRect(x: -self.passwordContainerView.frame.size.width, y: self.passwordContainerView.frame.origin.y, width: self.passwordContainerView.frame.size.width, height: self.passwordContainerView.frame.size.height)
                self.mobileContainerView.frame = CGRect(x: 0, y: self.mobileContainerView.frame.origin.y, width: self.mobileContainerView.frame.size.width, height: self.mobileContainerView.frame.size.height)
                self.mobileTF.becomeFirstResponder()
            }, completion: {(_ finished: Bool) -> Void in
            })
        } else {
            self.showError(view: passwordSubView, errorMsg: NSLocalizedString("wrong_password", comment: ""))
        }
    }
    
    @IBAction func requestOTPCode(_ sender: UIButton) {
        validateToRequestOTP()
    }
    
    func validateToRequestOTP() {
        if HelperClass.checkNetworkReachability() {
            if let phoneNum:String = mobileTF.text, !phoneNum.isEmpty {
                let language = HelperClass.getDeviceLanguage()
                mobileNumberEnglish = phoneNum
                if language == "ar" {
                    mobileNumberEnglish = String(HelperClass.convertArabicNumber(phoneNum))
                }
                
                if HelperClass.validateMobileNumber(mobileNumberEnglish) {
                    self.showLoadingView(show: true)
                    resendOTPButton.isEnabled = false
                    
                    let params: [String: Any] = [
                        "dialCode": "966",
                        "phone": mobileNumberEnglish,
                        "language": HelperClass.getDeviceLanguage(),
                        ]
                    DispatchQueue.global(qos: .background).async {
                        self.requestOTPInBackground(parameters: params)
                    }
                    
                } else {
                    self.showError(view: mobileSubView, errorMsg: NSLocalizedString("wrong_mobile_error", comment: ""))
                }
            }
        } else {
            
        }
    }
    
    func requestOTPInBackground(parameters: [String: Any]) {
        autoreleasepool {
            ProfileServiceManager.sendChangePhoneOTP(parameters) {
                response in
                DispatchQueue.main.async {
                    self.finishRequestOTPInBackground(response: response as Any)
                }
            }
        }
    }
    
    func finishRequestOTPInBackground(response: Any) {
        self.showLoadingView(show: false)
        resendOTPButton.isEnabled = true
        self.startOTPTimer()
        
        guard let responseData:NSDictionary = response as? NSDictionary else {
            
            return
        }
        if let code = responseData["code"] as? Int {
            if  code == 200 {
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {() -> Void in
                    self.moobileNumberLabel.text = self.mobileTF.text
                    self.mobileContainerView.frame = CGRect(x: -self.mobileContainerView.frame.size.width, y: self.mobileContainerView.frame.origin.y, width: self.mobileContainerView.frame.size.width, height: self.mobileContainerView.frame.size.height)
                    self.otpContainerView.frame = CGRect(x: 0, y: self.otpContainerView.frame.origin.y, width: self.otpContainerView.frame.size.width, height: self.otpContainerView.frame.size.height)
                    self.firstDigitTF.becomeFirstResponder()
                }, completion: {(_ finished: Bool) -> Void in
                })
            } else if code == 409 {
                self.showError(view: mobileSubView, errorMsg: NSLocalizedString("mobile_exists", comment: ""))
            } else if code == 401 {
                self.showError(view: mobileSubView, errorMsg: NSLocalizedString("wrong_password", comment: ""))
            } else {
                self.showError(view: mobileSubView, errorMsg: NSLocalizedString("error_title", comment: ""))
            }
        } else {
            self.showError(view: mobileSubView, errorMsg: NSLocalizedString("error_title", comment: ""))
        }
    }
    
    func startOTPTimer() {
        resendOTPButton.setTitle(NSLocalizedString("resend_btn_initial", comment: ""), for: .normal)
        counter = 30
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:  #selector(self.countdownTimer), userInfo: nil, repeats: true)
    }
    
    @objc func countdownTimer() {
        if counter <= 0 {
            timer?.invalidate()
            handleCountdownFinished()
        }
        else {
            counter -= 1
            resendOTPButton.setTitle("\(UInt(counter)) \(NSLocalizedString("resend_btn_counting", comment: ""))", for: .normal)
        }
    }
    
    func handleCountdownFinished() {
        resendOTPButton.isEnabled = true
        resendOTPButton.setTitle(NSLocalizedString("resend_btn_final", comment: ""), for: .normal)
    }

    
    @IBAction func resendOTPAction(_ sender: UIButton) {
        self.validateToRequestOTP()
    }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        self.delegate?.closeMobileView()
    }
    
    func showError(view: UIView, errorMsg: String) {
        errorLabel.isHidden = false
        errorLabel.text = errorMsg;
        view.backgroundColor = UIColor.init(red: 247.0/255.0, green: 17.0/255.0, blue: 94.0/255.0, alpha: 1.0)
    }
    
    func changeMobileNumber(parameters: [String: Any]) {
        autoreleasepool {
            ProfileServiceManager.changeMobile(parameters) {
                response in
                
                guard let responseData:NSDictionary = response as NSDictionary? else {
                    DispatchQueue.main.async {
                        self.finishChangeMobileNumber(response: NSDictionary())
                    }
                    return
                }
                if let code = responseData["code"] as? Int, code == 200 {
                    let clientData = ServiceManager.getClientDataFromUserDefaults() as NSDictionary?
                    let client = Client.init(clientData: clientData!)
                    ServiceManager.getClientData(client._id) {
                        getClientResponse in
                        
                        if getClientResponse != nil, (getClientResponse as? [String : Any])?["code"] as! Int == 200, let clientData = (getClientResponse as? [String : Any])?["data"] as? [String:Any] {
                            print("will update client info \(String(describing: clientData))")
                            ServiceManager.saveLogged(inClientData: clientData as [String : Any], andAccessToken: nil)
                            DispatchQueue.main.async {
                                self.finishChangeMobileNumber(response: clientData as NSDictionary)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.finishChangeMobileNumber(response: NSDictionary())
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.finishChangeMobileNumber(response: NSDictionary())
                    }
                }
            }
        }
    }
    
    func finishChangeMobileNumber(response: Any) {
        self.showLoadingView(show: false)
        self.delegate?.updateInfo()
        self.delegate?.closeMobileView()
        self.clearTextFields()
    }
    
    func clearTextFields() {
        (firstDigitTF as CustomTextField).text = ""
        (secondDigitTF as CustomTextField).text = ""
        (thirdDigitTF as CustomTextField).text = ""
        (forthDigitTF as CustomTextField).text = ""
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == passwordTF {
            if (textField.text?.count ?? 0) > 0 {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {() -> Void in
                    self.passwordLabel.frame = CGRect(x: self.passwordLabel.frame.origin.x, y: textField.frame.origin.y - self.passwordLabel.frame.size.height, width: self.passwordLabel.frame.size.width, height: self.passwordLabel.frame.size.height)
                    self.passwordLabel.font = UIFont(name: FONT_ROBOTO_LIGHT, size: 12)
                    self.passwordLabel.textColor = UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {() -> Void in
                    self.passwordLabel.frame = CGRect(x: self.passwordLabel.frame.origin.x, y: textField.frame.origin.y - self.passwordLabel.frame.size.height, width: self.passwordLabel.frame.size.width, height: self.passwordLabel.frame.size.height)
                    self.passwordLabel.font = UIFont(name: FONT_ROBOTO_LIGHT, size: 12)
                    self.passwordLabel.textColor = UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
                }, completion: nil)
            }
        }
        
        if textField == passwordTF {
            passwordSubView.backgroundColor = UIColor(red: 34.0 / 255.0, green: 50.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
        }
        if textField == mobileTF {
            mobileSubView.backgroundColor = UIColor(red: 34.0 / 255.0, green: 50.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
        }
        errorLabel.isHidden = true

    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /* If textfield has text */
        
        if let fieldString = textField.text, fieldString.count > 0 {
            /* (user deleted existing textfield digit) -- If typed string == 0 */
            if string.count == 0 {
                /* Delete textfield text */
                textField.text = string
            }
            else {
                /*
                 (User entered new digit -- Not allowed more that one digit)
                 Don't update Textfield (length of textfield text will be more than 1)
                 */
            }
            return false
            /* We already updated the text */
        } else {
            /* Text field has no text
             If typed text length > 0 */
            
            if string.count == 1 {
                /* Set new text */
                textField.text = string
                /* Check which textfield and set the next one to active
                 First digit TextField */
                if textField == firstDigitTF {
                    secondDigitTF.becomeFirstResponder()
                }
                /* Second digit TextField */
                if textField == secondDigitTF {
                    thirdDigitTF.becomeFirstResponder()
                }
                /* third digit TextField */
                if textField == thirdDigitTF {
                    forthDigitTF.becomeFirstResponder()
                }
                /* Forth digit TextField */
                if textField == forthDigitTF {
                    forthDigitTF.resignFirstResponder()
                    /* concatenate 4 strings from 4 textfields */
                    userInsertedCode = "\(firstDigitTF.text ?? "")\(secondDigitTF.text ?? "")\(thirdDigitTF.text ?? "")\(forthDigitTF.text ?? "")"
                    /* Check network connectevity */
                    if HelperClass.checkNetworkReachability() {
                        /* Show loading View */
                        self.showLoadingView(show: true)
                        /* Call the method that deal with back-end */
                        if let mobileNum = mobileTF.text, let pass = passwordTF.text {
                            let parameters = ["phone": mobileNum, "dialCode": "966", "otp": userInsertedCode, "password": pass]
                            DispatchQueue.global(qos: .background).async {
                                self.changeMobileNumber(parameters: parameters)
                            }
                        }
                        /* Hide keyboard */
                        forthDigitTF.resignFirstResponder()
                    } else {
                        /* No network connection */
                        print("Network Problem")
                    }
                }
            }
            return false
        }
    }

    
    func handleDelete(_ textField: UITextField) {
        print("deleeeeet")
        if textField == forthDigitTF {
            thirdDigitTF.becomeFirstResponder()
            thirdDigitTF.text = ""
        }
        /* third digit TextField */
        if textField == thirdDigitTF {
            secondDigitTF.becomeFirstResponder()
            secondDigitTF.text = ""
        }
        /* second digit TextField */
        if textField == secondDigitTF {
            firstDigitTF.becomeFirstResponder()
            firstDigitTF.text = ""
        }
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
