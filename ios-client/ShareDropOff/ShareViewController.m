//
//  ShareViewController.m
//  ShareDropoff
//
//  Created by Mahmoud Amer on 7/9/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    NSLog(@"dicttt %@", self.contentText);
    NSString * urlString;
    if(self.contentText.length){
        if (!([self.contentText rangeOfString:@"https://"].location == NSNotFound)) {
            NSArray *listItems = [self.contentText componentsSeparatedByString:@"https://"];
            if([listItems count] > 0){
                urlString = [NSString stringWithFormat: @"procabcustomer://?location=https://%@", [listItems objectAtIndex:1]];
            }
        }else{
            urlString = [NSString stringWithFormat: @"procabcustomer://?location=%@", self.contentText];
            urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        NSLog(@"urlString : %@", urlString);
        NSURL * url = [ NSURL URLWithString: urlString ];
        
        NSString *className = @"UIApplication";
        if ( NSClassFromString( className ) )
        {
            id object = [ NSClassFromString( className ) performSelector: @selector( sharedApplication ) ];
            [ object performSelector: @selector( openURL: ) withObject: url ];
        }
        
        // Now let the host app know we are done, so that it unblocks its UI:
        [ super didSelectPost ];
    }
    
//    if (!([self.contentText rangeOfString:@"?q="].location == NSNotFound)) {
//        NSArray *listItems = [self.contentText componentsSeparatedByString:@"?q="];
//        if([listItems count] > 0){
//            NSString *coordinatesString = [listItems objectAtIndex:1];
//
//            
//            NSString * urlString = [NSString stringWithFormat: @"procabcustomer://?location=%@", coordinatesString];
//            
//            NSURL * url = [ NSURL URLWithString: urlString ];
//            
//            NSString *className = @"UIApplication";
//            if ( NSClassFromString( className ) )
//            {
//                id object = [ NSClassFromString( className ) performSelector: @selector( sharedApplication ) ];
//                [ object performSelector: @selector( openURL: ) withObject: url ];
//            }
//            
//            // Now let the host app know we are done, so that it unblocks its UI:
//            [ super didSelectPost ];
//        }
//    }
    
    
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}




@end
