//
//  GoogleServicesManager.m
//  Ego
//
//  Created by Mahmoud Amer on 9/16/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "GoogleServicesManager.h"

@implementation GoogleServicesManager


+(void)getRouteFrom:(CLLocationCoordinate2D)fromLocation to:(CLLocationCoordinate2D)toLocation :( void (^)(NSDictionary *))completion{
    NSString *URLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=driving&key=%@", fromLocation.latitude, fromLocation.longitude, toLocation.latitude, toLocation.longitude, GMS_SERVICE_KEY];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[ServiceManager getAccessTokenFromKeychain] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[HelperClass getDeviceLanguage] forHTTPHeaderField:@"X-Ego-Language"];
    
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion((NSDictionary *)responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *failureResponseBody = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"body : %@", failureResponseBody);
            completion(failureResponseBody);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)getCoordinatesFromSharedString:(NSString *)shareString :( void (^)(NSArray *))completion{
    NSLog(@"getCoordinatesFromSharedString : %@", shareString);
    CLLocationCoordinate2D returnCoordinates = CLLocationCoordinate2DMake(0, 0);
    
    if (!([shareString rangeOfString:@"?q="].location == NSNotFound)) {
        NSArray *listItems = [shareString componentsSeparatedByString:@"?q="];
        if([listItems count] > 0){
            NSString *coordinatesString = [listItems objectAtIndex:1];
            NSArray *coordinatesArray = [coordinatesString componentsSeparatedByString:@","];
            if(coordinatesArray && ([coordinatesArray count] > 0)){
                returnCoordinates = CLLocationCoordinate2DMake([[coordinatesArray objectAtIndex:0] floatValue], [[coordinatesArray objectAtIndex:1] floatValue]);
                NSArray *returnArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", returnCoordinates.latitude], [NSString stringWithFormat:@"%f", returnCoordinates.longitude], nil];
                completion(returnArray);
            }else
                completion(nil);
        }else
            completion(nil);
    }else{
        if (!([shareString rangeOfString:@"https://"].location == NSNotFound)) {
            NSArray *listItems = [shareString componentsSeparatedByString:@"https://"];
            NSLog(@"listItems : %@", listItems);
            if([listItems count] > 0){
                NSString *URLString = [NSString stringWithFormat:@"https://www.googleapis.com/urlshortener/v1/url?shortUrl=https://%@&key=%@&projection=FULL", [listItems objectAtIndex:1], GMS_SHORTENURL_KEY];
                NSLog(@"URLString : %@", URLString);
                AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                
                [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if(responseObject){
                        if([responseObject objectForKey:@"longUrl"]){
                            NSString *longURL = [responseObject objectForKey:@"longUrl"];
                            //Not Shared From Web
                            if (([longURL rangeOfString:@"maps/place"].location == NSNotFound)) {
                                //Not From Web, Get coordinates from text address
                                NSLog(@"longURL OBJECT : %@", longURL);
                                if (!([longURL rangeOfString:@"?q="].location == NSNotFound)) {
                                    NSArray *listItems = [longURL componentsSeparatedByString:@"?q="];
                                    if([listItems count] > 0){
                                        NSString *queryString = [listItems objectAtIndex:1];
                                        NSArray *queryArray = [queryString componentsSeparatedByString:@"&"];
                                        NSString *addressString = [queryArray objectAtIndex:0];
                                        NSLog(@"addressString : %@" ,addressString);
                                        [self getCoordinatesFromAddress:addressString :^(NSArray *resultArray){
                                            NSLog(@"prepared Address : %@" ,resultArray);
                                            completion(resultArray);
                                        }];
                                    }else
                                        completion(nil);
                                }else
                                    completion(nil);
                            }else{
                                NSLog(@"Shared from web : %@", longURL);
                                //Shared from web, Get text address and convert to coordinates
                                NSArray *listItems = [longURL componentsSeparatedByString:@"maps/place/"];
                                NSString *fullAddress = [listItems objectAtIndex:1];
                                NSArray *queryAddressArray = [fullAddress componentsSeparatedByString:@"/"];
                                NSString *addressString = [queryAddressArray objectAtIndex:0];
                                NSLog(@"addressString : %@" ,addressString);
                                [self getCoordinatesFromAddress:addressString :^(NSArray *resultArray){
                                    NSLog(@"prepared Address : %@" ,resultArray);
                                    completion(resultArray);
                                }];
                            }
                            
                        }else
                            completion(nil);
                    }else
                        completion(nil);
                    [manager invalidateSessionCancelingTasks:YES];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"getCoordinatesFromSharedString error: %@", error.localizedDescription);
                    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                        completion(nil);
                    }else{
                        completion(nil);
                    }
                    [manager invalidateSessionCancelingTasks:YES];
                }];
            }
        }else{
            [self getCoordinatesFromAddress:shareString :^(NSArray *resultArray){
                completion(resultArray);
            }];
        }
    }
}

+(void)getCoordinatesFromAddress:(NSString *)address :( void (^)(NSArray *))completion{
    NSString *URLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=%@", address, GMS_SHORTENURL_KEY];
    NSLog(@"URLString : %@", URLString);
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Geocoding Response OBJECT : %@", responseObject);
        if(responseObject){
            if([responseObject objectForKey:@"results"] && ([[responseObject objectForKey:@"results"] isKindOfClass:[NSArray class]])){
                NSArray *resultArray = [responseObject objectForKey:@"results"];
                if([resultArray count] > 0){
                    if([[resultArray objectAtIndex:0] objectForKey:@"geometry"]){
                        if([[[resultArray objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"]){
                            CLLocationCoordinate2D returnCoordinates = CLLocationCoordinate2DMake([[[[[resultArray objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue], [[[[[resultArray objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue]);
                            NSArray *returnArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", returnCoordinates.latitude], [NSString stringWithFormat:@"%f", returnCoordinates.longitude], nil];
                            completion(returnArray);
                        }else
                            completion(nil);
                    }else
                        completion(nil);
                }else
                    completion(nil);
            }else
                completion(nil);
        }else
            completion(nil);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getCoordinatesFromSharedString error: %@", error.localizedDescription);
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            completion(nil);
        }else{
            completion(nil);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
}

+(void)getAddressFromCoordinates:(float)latitude andLong:(float)longitude :( void (^)(NSDictionary *))completion{
    NSLog(@"will get add for coor: %f , %f ", latitude, longitude);
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                                   completionHandler:^(GMSReverseGeocodeResponse * response, NSError *error){
                                       
                                       NSLog(@"ressss %@ with error %@ ", response, error);
                                       NSString *pickupString;
                                       if(![response firstResult]){
                                           NSLog(@"here should put unknown location");
                                           pickupString = @"Unnamed Road";
                                       }else{
                                           if([[response firstResult] thoroughfare]){
                                               pickupString = [[response firstResult] thoroughfare];
                                           }else{
                                               pickupString = [NSString stringWithFormat:@"%@", [[[response firstResult] lines] componentsJoinedByString:@","]];
                                           }
                                       }
                                       NSDictionary *returnDicctionary = @{
                                                                           @"address" : pickupString,
                                                                           @"latitude" : [NSNumber numberWithFloat:[[response firstResult] coordinate].latitude],
                                                                           @"longitude" : [NSNumber numberWithFloat:[[response firstResult] coordinate].longitude]
                                                                           };
                                       completion(returnDicctionary);
                                   }];
}

@end
