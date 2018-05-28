//
//  GMSMapView+MapViewCategory.m
//  Ego
//
//  Created by Mahmoud Amer on 7/18/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "GMSMapView+MapViewCategory.h"

#import <GoogleMaps/GoogleMaps.h>

@implementation GMSMapView (MapViewCategory)


+(GMSMapView *) sharedMapView:(CLLocationCoordinate2D)mapCenterCoordinates{
    static GMSMapView *mapView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        CLLocation *location = [[CLLocation alloc] initWithLatitude:mapCenterCoordinates.latitude longitude:mapCenterCoordinates.longitude];
        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:mapCenterCoordinates.latitude
                                                                        longitude:mapCenterCoordinates.longitude
                                                                             zoom:16.0];
        mapView = [GMSMapView mapWithFrame:[UIScreen mainScreen].bounds camera:cameraPosition];
    });
    return mapView;
}
@end
