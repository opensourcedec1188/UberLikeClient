//
//  RideTableViewCell.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/5/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

import UIKit

class RideTableViewCell: UITableViewCell {

    @IBOutlet weak var rideBGShadowView: UIView!
    @IBOutlet weak var rideImageView: UIImageView!
    
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverImgBGView: UIView!
    @IBOutlet weak var driverImageView: UIImageView!
    
    @IBOutlet weak var blueContainerView: UIView!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var totalFareLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var rateContainerView: UIView!
    @IBOutlet weak var firstStarImgView: UIImageView!
    @IBOutlet weak var secondStarImgView: UIImageView!
    @IBOutlet weak var thirdStarImgView: UIImageView!
    @IBOutlet weak var forthStarImgView: UIImageView!
    @IBOutlet weak var fifthStarImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setRating(rating:Int) {
        if (rating < 6) && (rating >= 0){
            switch (rating) {
            case 0:
                break;
            case 1:
                firstStarImgView.image = UIImage(named: "RideHostoryStar")
                break;
            case 2:
                firstStarImgView.image = UIImage(named: "RideHostoryStar")
                secondStarImgView.image = UIImage(named: "RideHostoryStar")
                break;
            case 3:
                firstStarImgView.image = UIImage(named: "RideHostoryStar")
                secondStarImgView.image = UIImage(named: "RideHostoryStar")
                thirdStarImgView.image = UIImage(named: "RideHostoryStar")
                break;
            case 4:
                firstStarImgView.image = UIImage(named: "RideHostoryStar")
                secondStarImgView.image = UIImage(named: "RideHostoryStar")
                thirdStarImgView.image = UIImage(named: "RideHostoryStar")
                forthStarImgView.image = UIImage(named: "RideHostoryStar")
                break;
            case 5:
                firstStarImgView.image = UIImage(named: "RideHostoryStar")
                secondStarImgView.image = UIImage(named: "RideHostoryStar")
                thirdStarImgView.image = UIImage(named: "RideHostoryStar")
                forthStarImgView.image = UIImage(named: "RideHostoryStar")
                fifthStarImgView.image = UIImage(named: "RideHostoryStar")
                break;
                
            default:
                break;
            }
        }
    }
    
    func clearRating() {
        firstStarImgView.image = UIImage(named: "ridesHistoryEmptyStar")
        secondStarImgView.image = UIImage(named: "ridesHistoryEmptyStar")
        thirdStarImgView.image = UIImage(named: "ridesHistoryEmptyStar")
        forthStarImgView.image = UIImage(named: "ridesHistoryEmptyStar")
        fifthStarImgView.image = UIImage(named: "ridesHistoryEmptyStar")
    }
}
