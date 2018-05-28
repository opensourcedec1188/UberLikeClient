//
//  Driver.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/9/17.
//  Copyright © 2017 Amer. All rights reserved.
//

import Foundation

class Client {
    var _id:String?
    var email:String?
    var firstName:String?
    var lastName:String?
    var home:NSDictionary?
    var isOnRide:Int?
    var language:String?
    var lastRideId:String?
    var lastRideMessage:String?
    var market:NSDictionary?
    var work:NSDictionary?
    var other:NSDictionary?
    var phone:String?
    var photoUrl:String?
    var ratingsAvg:Double?
    var referralCode:String?
    var wallet:String?
    var walletEnabled:Int?
    
    init(clientData:NSDictionary) {
        self._id = clientData["_id"] as? String
        self.email = clientData["email"] as? String ?? ""
        self.firstName = clientData["firstName"] as? String ?? "fName"
        self.lastName = clientData["lastName"] as? String ?? "lName"
        self.home = clientData["home"] as? NSDictionary
        self.isOnRide = clientData["isOnRide"] as? Int
        self.language = clientData["language"] as? String ?? "en"
        self.lastRideId = clientData["lastRideId"] as? String
        self.lastRideMessage = clientData["lastRideMessage"] as? String
        self.market = clientData["market"] as? NSDictionary
        self.work = clientData["work"] as? NSDictionary
        self.other = clientData["other"] as? NSDictionary
        self.phone = clientData["phone"] as? String
        self.photoUrl = clientData["photoUrl"] as? String ?? ""
        self.ratingsAvg = clientData["ratingsAvg"] as? Double ?? 5.00
        self.referralCode = clientData["referralCode"] as? String
        self.wallet = clientData["wallet"] as? String
        self.walletEnabled = clientData["walletEnabled"] as? Int
    }
    
    
    
    
}
