//
//  HelperClass.h
//  Ego
//
//  Created by MacBookPro on 3/22/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "Reachability.h"
#import "ServiceManager.h"

#define ARABIC_LANG_APP_CODE @"ar"
#define ENGLISH_LANG_APP_CODE @"en"
#define ARABIC_LANG_DEVICE_CODE @"ar-US"
#define INDIAN_LANG_DEVICE_CODE @"hi-US"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

#define STAR_ACTIVE @"RideHostoryStar"
#define STAR_INACTIVE @"ridesHistoryEmptyStar"

#define FONT_ROBOTO_REGULAR @"Roboto-Regular"
#define FONT_ROBOTO_LIGHT @"Roboto-Light"
#define FONT_ROBOTO_MEDIUM @"Roboto-Medium"


@interface HelperClass : NSObject


+ (BOOL)checkNetworkReachability;
+ (BOOL)validateText:(NSString *)text ;
+ (BOOL)validateMobileNumber:(NSString *)mobNumber;
+ (BOOL) validateEmailAddress:(NSString*) emailString;
+ (BOOL)validateSSN:(NSString *)ssnString;
+(BOOL)validateFLNames:(NSString *)name;
+ (BOOL)validatedates:(NSString *)dateString;


+ (NSString *)getDeviceLanguage;

+ (UIAlertController *)showAlert:(NSString *)title andMessage:(NSString *)message;

+ (NSDate *)convertStringToDate:(NSString *)strDate fromFormat:(NSString *)strFromFormat;

+(UIVisualEffectView *)createBlurViewWithFrame:(CGRect)frame;

+ (UIImageView *)returnTFImage:(NSString *)image andDimensions:(CGRect)frame;

+(NSDictionary *)serverSideValidation:(NSDictionary *)response;

+(int)convertArabicNumber:(NSString *)numString;

+(float)getBearing:(CLLocationCoordinate2D)locations1 andSecond:(CLLocationCoordinate2D)locattion2;

+(float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second;

+ (NSString *)HEXFromDevicePushToken:(NSData *)data;

+(NSString *)getRideStatusFromEvent:(NSString *)event;

+(BOOL)checkCoordinates:(NSDictionary *)data;

+(BOOL)checkArray:(id)arrayToCheck;

+(NSMutableArray *)removeNotExistingObjects:(NSMutableArray *)originalArray andNewArray:(NSArray *)newArray;
+(NSMutableArray *)getIntersectionBetweenTwoArrays:(NSMutableArray *)originalArray andNewArray:(NSArray *)newArray;

+(NSString *)getCatFromIntSelection:(int)selectedCategory;
+(NSString *)getCatFromIntSelectionForWebService:(int)selectedCategory;

+(BOOL)checkNestedDictionary:(NSDictionary *)dictionary numberOfLevels:(int)levelsNumber withKeysArray:(NSArray *)keysArray;

+(NSMutableArray *)getFavouritesFromClient;

+(double)distanceBetweenFirst:(CLLocation *)firstLocation andSecond:(CLLocation *)secondLocation;

@end
