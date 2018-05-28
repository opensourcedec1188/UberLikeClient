//
//  ShareViewController.h
//  ShareDropoff
//
//  Created by Mahmoud Amer on 7/9/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface ShareViewController : SLComposeServiceViewController {
    int m_inputItemCount;
    NSString *m_invokeArgs;
}

@end
