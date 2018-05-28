//
//  RideDetailsViewController.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/3/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

import UIKit
import QuartzCore

class RideDetailsViewController: UIViewController {
    
    var driverImage: UIImage = UIImage()
    var fetchedRideReceipt:NSDictionary = NSDictionary()
    var rideData:Ride?
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rideImageView: UIImageView!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var rideDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rateContainerView: UIView!
    @IBOutlet weak var firstStar: UIImageView!
    @IBOutlet weak var secondStar: UIImageView!
    @IBOutlet weak var thirdStar: UIImageView!
    @IBOutlet weak var forthStar: UIImageView!
    @IBOutlet weak var fifthStar: UIImageView!
    
    @IBOutlet weak var ridePickupLabel: UILabel!
    @IBOutlet weak var rideDropOffLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var totalFareLabel: UILabel!
    @IBOutlet weak var paymentContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        driverImageView.layer.cornerRadius = 5.0
        
        let shadowPath = UIHelperClass.setViewShadow(reportBtn, edgeInset: UIEdgeInsetsMake(-1.0, -1.0, -1.0, -1.0), andShadowRadius: 5.0)
        reportBtn.layer.shadowPath = shadowPath?.cgPath
        
        let mainViewShadowPath = UIHelperClass.setViewShadow(mainView, edgeInset: UIEdgeInsetsMake(-1.0, -1.0, -1.0, -1.0), andShadowRadius: 5.0)
        mainView.layer.shadowPath = mainViewShadowPath?.cgPath
        
        
        if rideData != nil {
            self.drawReceipt()
            self.displayRideData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func reportRideAction(_ sender: UIButton) {
        let secondViewController = SecondLevelHelpViewController()
        secondViewController.rideID = rideData?._id
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayRideData() {
        if let rideReceipt = rideData?.receipt {
            if let ridePhotoImgStr = rideReceipt.mapPhotoUrl {
                rideImageView.setImageWith(URL(string: ridePhotoImgStr)!)
            }
            
            if let driverPhotoImgStr = rideReceipt.driverPhotoUrl {
                driverImageView.setImageWith(URL(string: driverPhotoImgStr)!)
            }
            driverImageView.layer.cornerRadius = driverImageView.frame.size.height / 2
            
            vehicleLabel.text = "\(rideReceipt.vehicleManufacturer ?? "") \(rideReceipt.vehicleModel ?? "") | \(rideReceipt.vehicleColor ?? "")"
            
            driverNameLabel.text = rideReceipt.driverFirstName ?? ""
            rideDateLabel.text = rideReceipt.time ?? ""
            ridePickupLabel.text = rideReceipt.startAddress ?? ""
            rideDropOffLabel.text = rideReceipt.endAddress ?? ""
            
            totalFareLabel.text = "\(String(format: "%i", (rideReceipt.totalFare)!))"
            
            if let isCanceled = rideReceipt.isCanceled {
                if isCanceled == 1 {
                    guard let canceledBy = rideReceipt.canceledBy else { return }
                    let localizedCanceledBy = NSLocalizedString("canceled_by", comment: "")
                    statusLabel.text = "\(localizedCanceledBy) \(canceledBy)"
                } else {
                    if let rating:Int = rideReceipt.rating{
                        if rating > 0 {
                            self.setRating(rating: rating)
                        } else {
                            self.setRating(rating: 0)
                        }
                    }
                }
            }
        }
    }
    
    func drawReceipt() {
        
        if let fetchedRideTableFareArray = rideData?.fareTable as? [[String : Any]] {
            var i = 0
            for fareDetailsRow in fetchedRideTableFareArray {
                
                print(fareDetailsRow)
                
                let yOrigin = i * 30
                let fareView = FareCustomView(frame: CGRect(x: 0, y: yOrigin, width: Int(paymentContainerView.frame.size.width), height: 30))
                
                if let label = fareDetailsRow["label"] {
                    fareView.titleLabel.text = "\(label)"
                }
                
                if let val = fareDetailsRow["value"]{
                    fareView.valueLabel.text = "\(val)"
                }
                
                if i == (fetchedRideTableFareArray.count - 1) {
                    fareView.separatorView.isHidden = true
                }
                paymentContainerView.addSubview(fareView)
                paymentContainerView.bringSubview(toFront: fareView)
                i += 1
            }
            paymentContainerView.frame = CGRect(x: paymentContainerView.frame.origin.x, y: paymentContainerView.frame.origin.y, width: paymentContainerView.frame.size.width, height: CGFloat((fetchedRideTableFareArray.count * 30) + 10))
            let sizeHeight: CGFloat = paymentContainerView.frame.size.height + paymentContainerView.frame.origin.y
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: sizeHeight)
            scrollView.isScrollEnabled = true
        }
    }
    
    func setRating(rating:Int) {
        print("set rating : \(rating)")
        if (rating < 6) && (rating >= 0) {
            if(rating < 1){
                
            } else if (rating >= 1) && (rating < 2){
                
                firstStar.image = UIImage(named: "RideHostoryStar")
                
            } else if (rating >= 2) && (rating < 3) {
                
                firstStar.image = UIImage(named: "RideHostoryStar")
                secondStar.image = UIImage(named: "RideHostoryStar")
                
            } else if (rating >= 3) && (rating < 4) {
                
                firstStar.image = UIImage(named: "RideHostoryStar")
                secondStar.image = UIImage(named: "RideHostoryStar")
                thirdStar.image = UIImage(named: "RideHostoryStar")
                
            } else if (rating >= 4) && (rating < 5) {
                
                firstStar.image = UIImage(named: "RideHostoryStar")
                secondStar.image = UIImage(named: "RideHostoryStar")
                thirdStar.image = UIImage(named: "RideHostoryStar")
                forthStar.image = UIImage(named: "RideHostoryStar")
                
            } else if rating >= 5 {
                
                firstStar.image = UIImage(named: "RideHostoryStar")
                secondStar.image = UIImage(named: "RideHostoryStar")
                thirdStar.image = UIImage(named: "RideHostoryStar")
                forthStar.image = UIImage(named: "RideHostoryStar")
                fifthStar.image = UIImage(named: "RideHostoryStar")
                
            }
        }
    }

}
