//
//  RidesHistoryViewController.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/5/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

import UIKit

class RidesHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var ridesArray:NSArray = []
    var selectedIndex:Int = 0
    var loadingView:LoadingCustomView = LoadingCustomView()

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var noRidesImageView: UIImageView!
    @IBOutlet weak var noRidesLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var ridesTableView: UITableView!
    
    @IBOutlet var defaultCell: RideTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        
        if HelperClass.checkNetworkReachability() == true {
            self.showLoadingView(show: true)
            
            DispatchQueue.global(qos: .background).async {
                self.getPreviousRidesInBG()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPreviousRidesInBG(){
        autoreleasepool {
            RidesServiceManager.getPreviousRides() {
                response in
                
                DispatchQueue.main.async {
                    self.finishGetPreviousRides(response: response as Any)
                }
            }
        }
    }
    
    func finishGetPreviousRides(response:Any) {
        print("finishGetPreviousRides \(response)")
        self.showLoadingView(show: false)
        let responseData:NSDictionary = response as! NSDictionary
        if responseData["data"] != nil {
            ridesArray = responseData["data"] as! NSArray
            ridesTableView.reloadData()
        } else {
            let errorStr = NSLocalizedString("PR_no_prev_rides", comment: "")
            self.showNoRidesMessage(labelText: errorStr)
        }
    }
    
    func showNoRidesMessage(labelText: String){
        ridesTableView.isHidden = true
        noRidesLabel.text = labelText;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ridesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RideTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RideCustomCell") as! RideTableViewCell
        
        //Clear Unique Data
        cell.tag = indexPath.row
        cell.clearRating()
        cell.rideImageView.image = UIImage(named: "map")
        cell.statusLabel.text = ""
        cell.rateContainerView.isHidden = true
        cell.driverImageView.image = UIImage(named: "driver_placeholder.png")
        cell.rideImageView.layer.cornerRadius = 5
        
        var driverVehicleInfo = ""
        
        guard let rideDictionary:NSDictionary = ridesArray[indexPath.row] as? NSDictionary else { return cell }
                
        let ride = Ride.init(rideData: rideDictionary)
        let rideCard = ride.card
        
        driverVehicleInfo = (rideCard?.driverFirstName)!
        
        driverVehicleInfo.append(" | \(rideCard?.vehicleColor ?? "")")
        
        driverVehicleInfo.append(" | \(rideCard?.vehicleManufacturer ?? "")")
        
        driverVehicleInfo.append(" | \(rideCard?.vehicleModel ?? "")")
        
        cell.driverNameLabel.text = driverVehicleInfo
        
        //Date-Time
        cell.dateTimeLabel.text = rideCard?.time
        
        //Fare
        cell.totalFareLabel.text = String(format: "%i", (rideCard?.fare)!)//"\(cardDictionary["fare"] as! Double)"
        
        //Driver Image
        cell.driverImageView.layer.cornerRadius = cell.driverImageView.frame.size.height/2
        cell.driverImageView.layer.borderColor = UIColor.white.cgColor
        cell.driverImageView.layer.borderWidth = 1
        
        if let rideImgImgStr = rideCard?.mapPhotoUrl {
            cell.rideImageView.setImageWith(URL(string: rideImgImgStr)!)
        }
        cell.rideImageView.layer.cornerRadius = 5
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if let driverPhotoImgStr = rideCard?.driverPhotoUrl {
            cell.driverImageView.setImageWith(URL(string: driverPhotoImgStr)!)
        }
        
        //Rating
        if cell.tag == indexPath.row {
            if let isCanceled = rideCard?.isCanceled {
                if isCanceled == 1 {
                    guard let canceledBy = rideCard?.canceledBy else { return cell }
                    let localizedCanceledBy = NSLocalizedString("canceled_by", comment: "")
                    cell.statusLabel.text = "\(localizedCanceledBy) \(canceledBy)"
                } else {
                    if let rating:Int = rideCard?.rating{
                        if rating > 0 {
                            cell.setRating(rating: rating)
                        } else {
                            cell.setRating(rating: 0)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        
        let navigationController:UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "rideDetailsNavigationController") as! UINavigationController
        print("will go with \(ridesArray[indexPath.row])")
        if navigationController.viewControllers.count > 0 {
            let detailsController:RideDetailsViewController = navigationController.viewControllers.first as! RideDetailsViewController
            
            guard let rideDictionary:NSDictionary = ridesArray[indexPath.row] as? NSDictionary else { return }
            let ride = Ride.init(rideData: rideDictionary)
            detailsController.rideData = ride
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    

    @IBAction func leftBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Loading
    func showLoadingView(show:Bool) {
        if show {
            loadingView.removeFromSuperview()
            loadingView = LoadingCustomView(frame: mainView.bounds, andAnimatorY:7)
            mainView.addSubview(loadingView)
            mainView.bringSubview(toFront: loadingView)
        }else{
            loadingView.removeFromSuperview()
        }
    }

}
