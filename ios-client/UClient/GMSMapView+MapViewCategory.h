//
//  GMSMapView+MapViewCategory.h
//  Ego
//
//  Created by Mahmoud Amer on 7/18/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface GMSMapView (MapViewCategory)

+(GMSMapView *) sharedMapView:(CLLocationCoordinate2D)mapCenterCoordinates;

@end
