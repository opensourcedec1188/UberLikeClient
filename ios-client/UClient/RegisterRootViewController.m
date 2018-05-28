//
//  RegisterRootViewController.m
//  Ego
//
//  Created by MacBookPro on 2/28/17.
//  Copyright © 2017 Amer. All rights reserved.
//  This controller is the root of the UIPageViewController that holds the 3 controllers of registeration process
//

#import "RegisterRootViewController.h"

@interface RegisterRootViewController ()

@end

@implementation RegisterRootViewController

static int CONFIRM_MOBILE_INDEX = 0;
static int FULL_REGISTER_INDEX = 1;
static int PASSWORD_REGISTER_INDEX = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Initiate page view controller from storyboard UIPageViewController
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = nil;
    self.pageViewController.delegate = nil;
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
        
    //Change the size of page view controller
    self.pageViewController.view.frame = self.view.bounds;
    [self setScrollEnabled:NO forPageViewController:self.pageViewController];
    
    //Initiate the 3 registeration ViewControllers
    UIStoryboard *projectStoryboard = [UIStoryboard storyboardWithName:@"PreLogin" bundle:[NSBundle mainBundle]];

    //ConfirmMobileViewController
    ConfirmMobileViewController *confirmMobile = [projectStoryboard instantiateViewControllerWithIdentifier:@"confirmMobController"];
    confirmMobile.requestParameters = [_requestParameters mutableCopy];
    confirmMobile.delegate = self;
    //RegisterViewController
    RegisterViewController *fullRegisterData = [projectStoryboard instantiateViewControllerWithIdentifier:@"fullRegisterData"];
    fullRegisterData.delegate = self;
    //password register
    PasswordRegisterViewController *passwordRegisterData = [projectStoryboard instantiateViewControllerWithIdentifier:@"passwordRegisterData"];
    passwordRegisterData.delegate = self;
    
    //Controllers array
    myViewControllers = @[confirmMobile, fullRegisterData, passwordRegisterData];
    //Current Page index
    pageIndex = CONFIRM_MOBILE_INDEX;
    
    //Pass the first ViewController to UIPageViewController (must be an array)
    UIViewController *startingViewController = [self viewControllerAtIndex:CONFIRM_MOBILE_INDEX];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Adding PageViewController to the current view
    [self addChildViewController:_pageViewController];
    [self.containerView addSubview:_pageViewController.view];//TEMP
    [self.pageViewController didMoveToParentViewController:self];
    
}

#pragma mark - Popups
-(void)moveViewForTextFields:(float)newY andShow:(BOOL)show{
//    if(show){
//        //This was self.view not self.containerView
//        if(self.containerViewConstraint.constant == 8){
//            self.containerViewConstraint.constant = -containerOriginY;
//            [UIView animateWithDuration:0.5f animations:^{
//                [self.view layoutIfNeeded];
//            }];
//        }
//        
//    }else{
//        if(self.containerViewConstraint.constant < 8){
//            self.containerViewConstraint.constant = 8;
//            [UIView animateWithDuration:0.3f animations:^{
//                [self.view layoutIfNeeded];
//            }];
//        }
//    }
}

/* Method disables UIPageViewController scrolling */
- (void)setScrollEnabled:(BOOL)enabled forPageViewController:(UIPageViewController*)pageViewController
{
    for (UIView *view in pageViewController.view.subviews) {
        if ([view isKindOfClass:UIScrollView.class]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            [scrollView setScrollEnabled:enabled];
            return;
        }
    }
}

/* Method returns the next ViewController to display */
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([myViewControllers count] == 0) || (index >= [myViewControllers count])) {
        return nil;
    }
    pageIndex = index;
    NSLog(@"viewControllerAtIndex index : %ld", (long)pageIndex);
    return [myViewControllers objectAtIndex:index];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSUInteger index = pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [myViewControllers count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - PageViewController Navigation
/* Method takes ViewController and direction to navigate to it */
-(void)moveToPageAtIndex:(NSUInteger)index andDirection:(UIPageViewControllerNavigationDirection )direction
{
    
    UIViewController *currentViewController = [self viewControllerAtIndex:index];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:direction animated:YES completion:nil];
    
}

#pragma mark - Confirm Mobile Controller Delegate
-(void)moveToRegisterController:(NSDictionary *)requestParams
{
    if(requestParams){
        [self moveToPageAtIndex:FULL_REGISTER_INDEX andDirection:UIPageViewControllerNavigationDirectionForward];
        
        RegisterViewController *currentViewController = (RegisterViewController *)[self viewControllerAtIndex:FULL_REGISTER_INDEX];
        currentViewController.requestParameters = [requestParams mutableCopy];
        
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

-(void)backToEnterMobileController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Full Register Controller Delegate

#pragma mark - Confirm Mobile Controller Delegate
-(void)moveToPasswordRegistration:(NSDictionary *)requestParams
{
    if(requestParams){
        [self moveToPageAtIndex:PASSWORD_REGISTER_INDEX andDirection:UIPageViewControllerNavigationDirectionForward];
        
        PasswordRegisterViewController *currentViewController = (PasswordRegisterViewController *)[self viewControllerAtIndex:PASSWORD_REGISTER_INDEX];
        currentViewController.requestParameters = [requestParams mutableCopy];
        
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

-(void)backToConfirmMobileController
{
    [self moveToPageAtIndex:CONFIRM_MOBILE_INDEX andDirection:UIPageViewControllerNavigationDirectionReverse];
}
-(void)showRootLoadingView{
    [self showLoadingView:YES];
}
-(void)hideRootLoadingView{
    [self showLoadingView:NO];
}

#pragma mark - Password Registration 
-(void)backToRegisterController{
    [self moveToPageAtIndex:FULL_REGISTER_INDEX andDirection:UIPageViewControllerNavigationDirectionReverse];
}

/* PageControl Indicator click action */
- (IBAction)pageControlIndicatorChangeAction:(UIPageControl *)sender {
    BOOL shouldNavigate = NO;
    NSUInteger index = pageIndex;
    //If pageControl current page less than the current displayed page index
    //User is trying to go back -- Gooo
    if(sender.currentPage < pageIndex){
        switch (index) {
            case 0:
                
                break;
            case 1:
                shouldNavigate = YES;
                index --;
                break;
            case 2:
                shouldNavigate = YES;
                index --;
                break;
                
            default:
                break;
        }
        if(shouldNavigate){
            [self moveToPageAtIndex:index andDirection:UIPageViewControllerNavigationDirectionReverse];
        }
    }
    //Else, pageControl current page is higher that the current displayed page index
    //User is trying to go forward, Freeze and keep the page control as it is
    else{
        sender.currentPage = index;
    }

}
/* Back Button Action */
- (IBAction)backAction:(UIButton *)sender {
    BOOL returnToLogin = NO;
    NSUInteger index = pageIndex;
    
    switch (pageIndex) {
        case 0:
            //If current page index == 0, Back to login page
            returnToLogin = YES;
            break;
        case 1:
            //If current page index == 1, Should return to ConfirmMobileViewController
            returnToLogin = YES;
            index --;
            break;
        case 2:
            //If current page index == 2, Should return to ConfirmMobileViewController
            returnToLogin = NO;
            index --;
            break;
            
        default:
            break;
    }
    
    if(!returnToLogin)
        [self moveToPageAtIndex:index andDirection:UIPageViewControllerNavigationDirectionReverse];
    else
       [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LoadingView
-(void)showLoadingView:(BOOL)show{
    if(show){
        loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.8;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        indicator.center = loadingView.center;
        indicator.color = [UIColor whiteColor];
        [indicator startAnimating];
        [loadingView addSubview:indicator];
        
        [self.view addSubview:loadingView];
        [self.view bringSubviewToFront:loadingView];
    }else{
        [loadingView removeFromSuperview];
    }
}

@end
