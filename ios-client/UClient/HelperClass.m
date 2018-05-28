//
//  HelperClass.m
//  Ego
//
//  Created by MacBookPro on 3/22/17.
//  Copyright © 2017 Amer. All rights reserved.
//  For

#import "HelperClass.h"

@implementation HelperClass


/*
 Check if network is reachable
 Returns true if connection available, false if not available
 */
+ (BOOL)checkNetworkReachability
{
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    
    if(!((long)internetReachability.currentReachabilityStatus == 0)){
        NSLog(@"connection available");
        return YES;
    }else{
        NSLog(@"connection NOT available");
        return NO;
    }
}

/*
 Validate string
 Returns true if string is valid
 */
+ (BOOL)validateText:(NSString *)text{
    if(text && !([text isEqualToString:@""]) && !(text.length == 0))
        return YES;
    else
        return NO;
}

/*
 Validate mobile number
 Returns true if mobile number is valid
 */
+ (BOOL)validateMobileNumber:(NSString *)mobNumber{
    NSLog(@"will validate %@", mobNumber);
    BOOL valid = NO;
    if((mobNumber.length == 9) || (mobNumber.length == 10)){
        if([[mobNumber substringToIndex:NSMaxRange([mobNumber rangeOfComposedCharacterSequenceAtIndex:0])] isEqualToString:@"5"])
            valid = YES;
        if([[mobNumber substringToIndex:NSMaxRange([mobNumber rangeOfComposedCharacterSequenceAtIndex:1])] isEqualToString:@"05"])
            valid = YES;
    }
    return valid;
}

/*
 Validate email address
 Returns true if email address is valid
 */
+ (BOOL) validateEmailAddress:(NSString*) emailString {
    
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    NSLog(@"%lu", (unsigned long)regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)validateSSN:(NSString *)ssnString
{
    BOOL valid = NO;
    if(ssnString.length == 10){
        valid = YES;
    }
    return valid;
}

+(BOOL)validateFLNames:(NSString *)name{
    
    BOOL valid = YES;
    
    //Create character set /^[A-Za-z\s]+$/
    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "];
    
    //Invert the set
    validChars = [validChars invertedSet];
    
    //Check against that
    NSRange  range = [name rangeOfCharacterFromSet:validChars];
    if (NSNotFound != range.location) {
        NSLog(@"not valid");
        valid = NO;
    }
    if(valid)
        NSLog(@"valid");
    else
        NSLog(@"not valid");
    return valid;
}

/*
 Method gets the device current language
 Returns shortcode for the current language
 */
+ (NSString *)getDeviceLanguage
{
    NSString *languageCode = @"";
    NSString *deviceLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];

    if([deviceLanguage hasPrefix:@"en"]) //English
        languageCode = ENGLISH_LANG_APP_CODE;
    else if([deviceLanguage hasPrefix:@"ar"]) //Arabic
        languageCode = ARABIC_LANG_APP_CODE;
    else if([deviceLanguage isEqualToString:INDIAN_LANG_DEVICE_CODE]) //Indian
        languageCode = ENGLISH_LANG_APP_CODE;
    else if([self containsString:deviceLanguage andSubstring:ENGLISH_LANG_APP_CODE]) //Others -> English
        languageCode = ENGLISH_LANG_APP_CODE;
    else
        languageCode = @"ar";
    
    return languageCode;
}

/*
 Method check if a string contains another substring
 Params: Parent string, Substring
 Returns: True of contained
 */
+ (BOOL)containsString:(NSString *)string andSubstring:(NSString *)substring
{
    NSRange range = [string rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

/*
 Method that create UIAlertController with title and message
 Params: Title, Message
 Returns: created UIAlertController
 */
#pragma mark - Alerts
+ (UIAlertController *)showAlert:(NSString *)title andMessage:(NSString *)message
{
    if(([HelperClass validateText:title]) && ([HelperClass validateText:message])){
        UIAlertController *myAlertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        
        [myAlertView addAction:doneAction];
        return myAlertView;
    }else{
        UIAlertController *myAlertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"general_problem_title", @"") message:NSLocalizedString(@"general_problem_message", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"")
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        
        [myAlertView addAction:doneAction];
        return myAlertView;
    }
}

+ (BOOL)validatedates:(NSString *)dateString
{
    BOOL valid = NO;
    if(!(dateString.length == 0) /*&& ![dateString isEqualToString:@"0.000000r"]*/){
        valid = YES;
    }
    return valid;
}

+(NSDate *)convertStringToDate:(NSString *)strDate fromFormat:(NSString *)strFromFormat
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = strFromFormat;
    return [dateFormatter dateFromString:strDate];
}

+(UIVisualEffectView *)createBlurViewWithFrame:(CGRect)frame{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = frame;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return blurEffectView;
}

+ (UIImageView *)returnTFImage:(NSString *)image andDimensions:(CGRect)frame
{
    UIImageView *imgforLeft=[[UIImageView alloc] initWithFrame:frame]; // Set frame as per space required around icon
    [imgforLeft setImage:[UIImage imageNamed:image]];
    
    [imgforLeft setContentMode:UIViewContentModeCenter];// Set content mode centre or fit
    
    return imgforLeft;
}

+(NSDictionary *)serverSideValidation:(NSDictionary *)response{
    NSString *title = @"";
    NSString *message = @"";
    NSDictionary *keys = [[NSDictionary alloc] init];
    
    switch ([[response objectForKey:@"code"] intValue]) {
        case 400:
            
            keys = [response objectForKey:@"errors"];
            break;
            
        case 401:
            
            break;
            
        case 402:
            title = @"Something Went Wrong";
            message = @"Please try again later";
            break;
            
        case 404:
            title = @"Something Went Wrong";
            message = @"Please try again later";
            break;
            
        case 409:
            title = @"Already Exists!";
            message = [NSString stringWithFormat:@"Wrong %@", [response objectForKey:@"key"]];
            break;
            
        default:
            break;
    }
    
    if([[response objectForKey:@"code"] intValue] == 400){
        if([keys count] > 0){
            message = @"Wrong in";
            title = @"Wrong Fields Provided";
            for (id key in keys) {
                if([[keys objectForKey:key] intValue] == 1)
                    message = [NSString stringWithFormat:@"%@ (%@)", message, key];
            }
        }
    }
    
    
    NSDictionary *returnDict = @{
                                 @"title" : title,
                                 @"message" : message
                                 };
    
    return  returnDict;
}


+(int)convertArabicNumber:(NSString *)numString{
    NSNumberFormatter *Formatter = [[NSNumberFormatter alloc] init];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"EN"];
    [Formatter setLocale:locale];
    NSNumber *newNum = [Formatter numberFromString:numString];
    
    int returnedEnglishNumber = [newNum intValue];
    return returnedEnglishNumber;
}


+(float)getBearing:(CLLocationCoordinate2D)locations1 andSecond:(CLLocationCoordinate2D)locattion2{
    float fLat = degreesToRadians(locations1.latitude);
    float fLng = degreesToRadians(locations1.longitude);
    float tLat = degreesToRadians(locattion2.latitude);
    float tLng = degreesToRadians(locattion2.longitude);
    
    float degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

+(float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second {
    
    float deltaLongitude = second.longitude - first.longitude;
    float deltaLatitude = second.latitude - first.latitude;
    float angle = (M_PI * .5f) - atan(deltaLatitude / deltaLongitude);
    
    if (deltaLongitude > 0)      return angle;
    else if (deltaLongitude < 0) return angle + M_PI;
    else if (deltaLatitude < 0)  return M_PI;
    
    return 0.0f;
}

+ (NSString *)HEXFromDevicePushToken:(NSData *)data {
    
    NSUInteger capacity = data.length;
    NSMutableString *stringBuffer = [[NSMutableString alloc] initWithCapacity:capacity];
    const unsigned char *dataBuffer = data.bytes;
    
    // Iterate over the bytes
    for (NSUInteger i=0; i < data.length; i++) {
        
        [stringBuffer appendFormat:@"%02.2hhX", dataBuffer[i]];
    }
    
    return [stringBuffer copy];
}

+(NSString *)getRideStatusFromEvent:(NSString *)event{
    NSString *status = @"";
    if(event.length > 0){
        if([event isEqualToString:@"ride-accepted"]){
            status = @"accepted";
        }else if([event isEqualToString:@"driver-arrived"]){
            status = @"arrived";
        }else if([event isEqualToString:@"ride-begun"]){
            status = @"on-ride";
        }else if([event isEqualToString:@"ride-cleared"]){
            status = @"accepted";
        }else if([event isEqualToString:@"ride-accepted"]){
            status = @"clearance";
        }else if([event isEqualToString:@"ride-finished"]){
            status = @"finished";
        }else if([event isEqualToString:@"ride-accepted"]){
            status = @"accepted";
        }else if([event isEqualToString:@"ride-accepted"]){
            status = @"accepted";
        }
    }
    return status;
}

+(BOOL)checkCoordinates:(NSDictionary *)data{
    BOOL valid = NO;
    if(data && ([data isKindOfClass:[NSDictionary class]])){
        if([data objectForKey:@"coordinates"]){
            if([[data objectForKey:@"coordinates"] isKindOfClass:[NSArray class]]){
                NSArray *coordinates = [data objectForKey:@"coordinates"];
                if([coordinates count] > 0){
                    valid = YES;
                }
            }
        }
    }
    return valid;
}

+(BOOL)checkArray:(id)arrayToCheck{
    BOOL valid = NO;
    if([arrayToCheck isKindOfClass:[NSArray class]]){
        if([arrayToCheck count] > 0)
            valid = YES;
    }
    return valid;
}

+(NSMutableArray *)removeNotExistingObjects:(NSMutableArray *)originalArray andNewArray:(NSArray *)newArray{
    //We'll copy array first to be able to delete from it
    NSMutableArray *tempArray = [originalArray mutableCopy];
    for (NSDictionary *driver in originalArray) {
        BOOL exists = NO;
        for(NSDictionary *channel in newArray){
            if([[driver objectForKey:@"channel"] isEqualToString:[channel objectForKey:@"channel"]]){
                exists = YES;
            }
        }
        if(!exists){
            //Remove marker
            GMSMarker *marker = [driver objectForKey:@"marker"];
            if([marker isKindOfClass:[GMSMarker class]])
                marker.map = nil;
            //remove object from array
            [tempArray removeObject:driver];
        }
    }
    originalArray = [self addNewFromFetchedToArray:tempArray andnewArray:newArray];
    return originalArray;
}

+(NSMutableArray *)addNewFromFetchedToArray:(NSMutableArray *)originalArray andnewArray:(NSArray *)newArray{
    
    for(NSDictionary *channel in newArray){
        BOOL exists = NO;
        for (NSDictionary *driver in originalArray) {
            if([[driver objectForKey:@"channel"] isEqualToString:[channel objectForKey:@"channel"]]){
                exists = YES;
            }
        }
        if(!exists)
            [originalArray addObject:@{@"marker" : @"", @"channel" : [channel objectForKey:@"channel"], @"currentLocation" : [channel objectForKey:@"currentLocation"] ? [channel objectForKey:@"currentLocation"] : @"", @"drawn" : @"", @"heading" : [channel objectForKey:@"lastLocationHeading"] ? [channel objectForKey:@"lastLocationHeading"] : @"", @"category" : [channel objectForKey:@"category"]}];
    }
    return originalArray;
}

+(NSMutableArray *)getIntersectionBetweenTwoArrays:(NSMutableArray *)originalArray andNewArray:(NSArray *)newArray
{
    NSMutableSet *intersection = [NSMutableSet setWithArray:originalArray];
    [intersection intersectSet:[NSSet setWithArray:[newArray mutableCopy]]];
    NSMutableArray *resultArray = [[intersection allObjects] mutableCopy];
    return resultArray;
}

+(NSString *)getCatFromIntSelection:(int)selectedCategory{
    NSString *selectedCat = @"Economy";
    switch (selectedCategory) {
        case 1:
            selectedCat = @"Economy";
            break;
        case 2:
            selectedCat = @"Family";
            break;
        case 3:
            selectedCat = @"VIP";
            break;
        default:
            selectedCat = @"";
            break;
    }
    return selectedCat;
}

+(NSString *)getCatFromIntSelectionForWebService:(int)selectedCategory{
    NSString *selectedCat = @"economy";
    switch (selectedCategory) {
        case 1:
            selectedCat = @"economy";
            break;
        case 2:
            selectedCat = @"family";
            break;
        case 3:
            selectedCat = @"vip";
            break;
        default:
            selectedCat = @"economy";
            break;
    }
    return selectedCat;
}


+(BOOL)checkNestedDictionary:(NSDictionary *)dictionary numberOfLevels:(int)levelsNumber withKeysArray:(NSArray *)keysArray{
    BOOL valid = NO;
    
    for(int i = 0 ; i < [keysArray count] ; i++){
        
    }
    
    
    for (id key in dictionary) {
        if ([[dictionary objectForKey:key] isKindOfClass:[NSDictionary class]]) {
            [self checkDictionary:dictionary andKey:key];
        }else {
            NSLog(@"Key: %@", key);
            NSLog(@"Value: %@ (%@)", [dictionary objectForKey:key], [[dictionary objectForKey:key] class]);
        }
    }
    return valid;
}

+(BOOL)checkDictionary:(NSDictionary *)dictionary andKey:(NSString *)key{
    BOOL valid = NO;
    
    if([dictionary objectForKey:key])
        valid = YES;
    
    return valid;
}

+(NSMutableArray *)getFavouritesFromClient{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSDictionary *client = [ServiceManager getClientDataFromUserDefaults];
    NSLog(@"getFavouritesFromClient client : %@", client);
    if([client objectForKey:@"home"] && !([[client objectForKey:@"home"] isKindOfClass:[NSNull class]])){
        NSMutableDictionary *dict = [[client objectForKey:@"home"] mutableCopy];
        
        [dict setObject:@{@"image" : @"favHomIcon", @"title" : @"المنزل"} forKey:@"ar"];
        [dict setObject:@{@"image" : @"favHomIcon", @"title" : @"My Home"} forKey:@"en"];
        [dict setObject:@{@"image" : @"favHomIcon", @"title" : @"My Home"} forKey:@"en"];
        [returnArray addObject:dict];
    }else
        [returnArray addObject:@{@"en" : @"Add Your Home", @"ar" : @"اضف المنزل"}];
    
    if([client objectForKey:@"work"] && !([[client objectForKey:@"work"] isKindOfClass:[NSNull class]])){
        NSMutableDictionary *dict = [[client objectForKey:@"work"] mutableCopy];
        
        [dict setObject:@{@"image" : @"facWorkIcon", @"title" : @"العمل"} forKey:@"ar"];
        [dict setObject:@{@"image" : @"facWorkIcon", @"title" : @"My Work"} forKey:@"en"];
        [returnArray addObject:dict];
    }else
        [returnArray addObject:@{@"en" : @"Add Your Work", @"ar" : @"اضف العمل"}];
    
    if([client objectForKey:@"market"] && !([[client objectForKey:@"market"] isKindOfClass:[NSNull class]])){
        NSMutableDictionary *dict = [[client objectForKey:@"market"] mutableCopy];
        
        [dict setObject:@{@"image" : @"favMarkerIcon", @"title" : @"التسوق"} forKey:@"ar"];
        [dict setObject:@{@"image" : @"favMarkerIcon", @"title" : @"My Market"} forKey:@"en"];
        [returnArray addObject:dict];
    }else
        [returnArray addObject:@{@"en" : @"Add Your Market", @"ar" : @"اضف التسوق"}];
    
    if([client objectForKey:@"other"] && !([[client objectForKey:@"other"] isKindOfClass:[NSNull class]])){
        NSMutableDictionary *dict = [[client objectForKey:@"other"] mutableCopy];
        
        [dict setObject:@{@"image" : @"favOtherIcon", @"title" : @"اخرى"} forKey:@"ar"];
        [dict setObject:@{@"image" : @"favOtherIcon", @"title" : @"Other"} forKey:@"en"];
        [returnArray addObject:dict];
    }else
        [returnArray addObject:@{@"en" : @"Add Other", @"ar" : @"اضف اخرى"}];
    NSLog(@"returnArray : %@", returnArray);
    if([returnArray count] > 0)
        return returnArray;
    else
        return nil;
}

+(double)distanceBetweenFirst:(CLLocation *)firstLocation andSecond:(CLLocation *)secondLocation{
    
    CLLocationCoordinate2D firstCoordinates= CLLocationCoordinate2DMake(firstLocation.coordinate.latitude, firstLocation.coordinate.longitude);
    CLLocationCoordinate2D secondCoordinates= CLLocationCoordinate2DMake(secondLocation.coordinate.latitude, secondLocation.coordinate.longitude);
    CLLocationDistance distance = GMSGeometryDistance(firstCoordinates, secondCoordinates);
    if(distance){
        return distance;
    }else{
        CLLocationDistance distance = [firstLocation distanceFromLocation:secondLocation];
        return distance;
    }
}

@end
