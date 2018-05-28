//
//  Ride.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/9/17.
//  Copyright © 2017 Amer. All rights reserved.
//

import Foundation

class Ride {
    var _id:String?
    var acceptedClientLocation:NSDictionary?
    var acceptedDriverFirstName:String?
    var acceptedDriverLocation:NSDictionary?
    var acceptedDriverLocations:NSArray?
    var acceptedDriverPhotoUrl:String?
    var acceptedDriverRating:Int?
    var acceptedTime:Int?
    var acceptedVehicleColor:String?
    var acceptedVehicleManufacturer:String?
    var acceptedVehicleModel:String?
    var acceptedVehiclePhotoUrl:String?
    var acceptedVehiclePlateLetters:String?
    var acceptedVehiclePlateNumber:String?
    var arabicDropoffAddress:String?
    var arabicPickupAddress:String?
    var canceledBy:String?
    var cancellationClientLocation:NSDictionary?
    var cancellationFee:Float?
    var cancellationFeeApplied:Int?
    var cancellationFeeAppliedTo:String?
    var card:Card?
    var clientId:String?
    var driverId:String?
    var dropoffLocation:NSDictionary?
    var englishDropoffAddress:String?
    var englishPickupAddress:String?
    var fare:Int?
    var fareTable:NSArray?
    var initiatedClientFirstName:String?
    var isBeingAccepted:Int?
    var isCanceled:Int?
    var isLuggage:Int?
    var isQuiet:Int?
    var lastDriverLocation:NSDictionary?
    var receipt:Receipt?
    
    init(rideData:NSDictionary? = nil) {
        guard rideData != nil else { return }
        
        self._id = rideData?["_id"] as? String
        self.acceptedClientLocation = rideData?["acceptedClientLocation"] as? NSDictionary
        self.acceptedDriverFirstName = rideData?["acceptedDriverFirstName"] as? String ?? "fName"
        self.acceptedDriverLocation = rideData?["acceptedDriverLocation"] as? NSDictionary
        self.acceptedDriverLocations = rideData?["acceptedDriverLocations"] as? NSArray
        self.acceptedDriverPhotoUrl = rideData?["acceptedDriverPhotoUrl"] as? String
        self.acceptedDriverRating = rideData?["acceptedDriverRating"] as? Int
        self.acceptedTime = rideData?["acceptedTime"] as? Int
        self.acceptedVehicleColor = rideData?["acceptedVehicleColor"] as? String
        self.acceptedVehicleManufacturer = rideData?["acceptedVehicleManufacturer"] as? String
        self.acceptedVehicleModel = rideData?["acceptedVehicleModel"] as? String
        self.acceptedVehiclePhotoUrl = rideData?["acceptedVehiclePhotoUrl"] as? String
        self.acceptedVehiclePlateLetters = rideData?["acceptedVehiclePlateLetters"] as? String ?? ""
        self.acceptedVehiclePlateNumber = rideData?["acceptedVehiclePlateNumber"] as? String ?? ""
        self.arabicDropoffAddress = rideData?["arabicDropoffAddress"] as? String ?? ""
        self.arabicPickupAddress = rideData?["arabicPickupAddress"] as? String ?? ""
        self.canceledBy = rideData?["canceledBy"] as? String ?? ""
        self.cancellationClientLocation = rideData?["cancellationClientLocation"] as? NSDictionary
        self.cancellationFee = rideData?["cancellationFee"] as? Float ?? 0.0
        self.cancellationFeeApplied = rideData?["cancellationFeeApplied"] as? Int
        self.cancellationFeeAppliedTo = rideData?["cancellationFeeAppliedTo"] as? String ?? ""
        
        if let rideCard = rideData!["card"] as? NSDictionary {
            self.card = Card.init(cardData: rideCard)
        }
        
        self.clientId = rideData?["clientId"] as? String
        self.driverId = rideData?["driverId"] as? String
        self.dropoffLocation = rideData?["dropoffLocation"] as? NSDictionary
        self.englishDropoffAddress = rideData?["englishDropoffAddress"] as? String
        self.englishPickupAddress = rideData?["englishPickupAddress"] as? String
        self.fare = rideData?["fare"] as? Int
        self.fareTable = rideData?["fareTable"] as? NSArray
        self.initiatedClientFirstName = rideData?["initiatedClientFirstName"] as? String
        self.isBeingAccepted = rideData?["isBeingAccepted"] as? Int
        self.isCanceled = rideData?["isCanceled"] as? Int
        self.isLuggage = rideData?["isLuggage"] as? Int
        self.isQuiet = rideData?["isQuiet"] as? Int
        self.lastDriverLocation = rideData?["lastDriverLocation"] as? NSDictionary
        self.receipt = Receipt.init(receiptData: rideData?["receipt"] as? NSDictionary)
    }
}

class Card {
    var canceledBy:String?
    var driverFirstName:String?
    var driverPhotoUrl:String?
    var fare:Int?
    var isCanceled:Int?
    var mapPhotoUrl:String?
    var rating:Int?
    var time:String?
    var vehicleColor:String?
    var vehicleManufacturer:String?
    var vehicleModel:String?
    var vehiclePhotoUrl:String?
    
    init(cardData: NSDictionary? = nil) {
        guard let rideCardData = cardData else { return }
        
        self.canceledBy = rideCardData["canceledBy"] as? String
        self.driverFirstName = rideCardData["driverFirstName"] as? String
        self.driverPhotoUrl = rideCardData["driverPhotoUrl"] as? String
        self.fare = rideCardData["fare"] as? Int
        self.isCanceled = rideCardData["isCanceled"] as? Int
        self.mapPhotoUrl = rideCardData["mapPhotoUrl"] as? String
        self.rating = rideCardData["rating"] as? Int
        self.time = rideCardData["time"] as? String
        self.vehicleColor = rideCardData["vehicleColor"] as? String
        self.vehicleManufacturer = rideCardData["vehicleManufacturer"] as? String
        self.vehicleModel = rideCardData["vehicleModel"] as? String
        self.vehiclePhotoUrl = rideCardData["vehiclePhotoUrl"] as? String
    }
}

class Receipt {
    var canceledBy:String?
    var driverFirstName:String?
    var driverPhotoUrl:String?
    var endAddress:String?
    var isCanceled:Int?
    var mapPhotoUrl:String?
    var rating:Int?
    var startAddress:String?
    var time:String?
    var totalFare:Int?
    var vehicleColor:String?
    var vehicleManufacturer:String?
    var vehicleModel:String?
    var vehiclePhotoUrl:String?
    
    init(receiptData: NSDictionary? = nil) {
        guard let rideReceiptData = receiptData else{ return }
        self.canceledBy = rideReceiptData["canceledBy"] as? String
        self.driverFirstName = rideReceiptData["driverFirstName"] as? String
        self.driverPhotoUrl = rideReceiptData["driverPhotoUrl"] as? String
        self.endAddress = rideReceiptData["endAddress"] as? String
        self.isCanceled = rideReceiptData["isCanceled"] as? Int
        self.mapPhotoUrl = rideReceiptData["mapPhotoUrl"] as? String
        self.rating = rideReceiptData["rating"] as? Int
        self.startAddress = rideReceiptData["startAddress"] as? String
        self.time = rideReceiptData["time"] as? String
        self.totalFare = rideReceiptData["totalFare"] as? Int
        self.vehicleColor = rideReceiptData["vehicleColor"] as? String
        self.vehicleManufacturer = rideReceiptData["vehicleManufacturer"] as? String
        self.vehicleModel = rideReceiptData["vehicleModel"] as? String
        self.vehiclePhotoUrl = rideReceiptData["vehiclePhotoUrl"] as? String
    }

}



