//
//  DownsideFavouritesView.m
//  Ego
//
//  Created by Mahmoud Amer on 9/17/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

#import "DownsideFavouritesView.h"

@implementation DownsideFavouritesView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame nearbyArray:(NSArray *)nearbyArray recentPlacesArray:(NSArray *)recentPlacesArray{
    _nearByPlacesArray = nearbyArray;
    _recentPlacesArray = recentPlacesArray;
    self = [super initWithFrame:frame];
    
    if(self){
        [self customInit];
    }
    
    return self;
}

-(void)customInit{
    [[NSBundle mainBundle] loadNibNamed:@"DownsideFavouritesView" owner:self options:nil];
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
    UIBezierPath *favShadowPath = [UIHelperClass setViewShadow:_favViewContainer edgeInset:UIEdgeInsetsMake(-1.0f, 1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
    _favViewContainer.layer.shadowPath = favShadowPath.CGPath;
    
    UIBezierPath *nearbyShadowPath = [UIHelperClass setViewShadow:_nearbyFavContainer edgeInset:UIEdgeInsetsMake(-1.0f, 0, -1.0f, -1.0f) andShadowRadius:5.0f];
    _nearbyFavContainer.layer.shadowPath = nearbyShadowPath.CGPath;
    
    UIBezierPath *recentShadowPath = [UIHelperClass setViewShadow:_recentViewContainer edgeInset:UIEdgeInsetsMake(-1.0f, 0, -1.0f, -1.0f) andShadowRadius:5.0f];
    _recentViewContainer.layer.shadowPath = recentShadowPath.CGPath;
}

#pragma mark - Down Favourites Work
- (IBAction)showFavouritesAction:(UIButton *)sender {
    _favouritesArray = [HelperClass getFavouritesFromClient];
    if((!fullCardsShown || (currentFavIndex != 1)) && (_favouritesArray.count > 0)){
        //Reload scroll view based on source
        [self showFullDownView:YES andFor:1];
        [self showDownViewWithType:1];
    }else{
        [self setDownIconsNotSelectedWithIconSelected:nil andLabel:nil andDownImage:@""];
        [self showFullDownView:NO andFor:1];
    }
}

- (IBAction)showNearbyAction:(UIButton *)sender {
    if((!fullCardsShown || (currentFavIndex != 2)) && (_nearByPlacesArray.count > 0)){
        //Reload scroll view based on source
        [self showFullDownView:YES andFor:2];
        [self showDownViewWithType:2];
    }else{
        [self setDownIconsNotSelectedWithIconSelected:nil andLabel:nil andDownImage:@""];
        [self showFullDownView:NO andFor:2];
    }
}

- (IBAction)showRecentAction:(UIButton *)sender {
    if((!fullCardsShown || (currentFavIndex != 3)) && (_recentPlacesArray.count > 0)){
        //Reload scroll view based on source
        [self showFullDownView:YES andFor:3];
        [self showDownViewWithType:3];
    }else{
        [self setDownIconsNotSelectedWithIconSelected:nil andLabel:nil andDownImage:@""];
        [self showFullDownView:NO andFor:3];
    }
}
-(void)showDownViewWithType:(int)type {
    [self reloadScrollView:type];
    switch (type) {
        case 1:
            [self setDownIconsNotSelectedWithIconSelected:_favoutriteIconImgView andLabel:_downFavouriteLabel andDownImage:@"favSelectedIcon"];
            break;
        case 2:
            [self setDownIconsNotSelectedWithIconSelected:_downNearbyIconImgView andLabel:_downNearbyLabel andDownImage:@"nearbySelectdIconImage"];
            break;
        case 3:
            [self setDownIconsNotSelectedWithIconSelected:_downRecentIconImgView andLabel:_downRecentLabel andDownImage:@"recentSelectdIconImage"];
            break;
            
        default:
            break;
    }
}

-(void)setDownIconsNotSelectedWithIconSelected:(UIImageView *)iconSelected andLabel:(UILabel *)labelSelected andDownImage:(NSString *)selectedImageName{
    [_favoutriteIconImgView setImage:[UIImage imageNamed:@"downFavouriteIcon"]];
    
    [_downNearbyIconImgView setImage:[UIImage imageNamed:@"downNearbyIcon"]];
    
    [_downRecentIconImgView setImage:[UIImage imageNamed:@"downRecentIcon"]];
    
    [iconSelected setImage:[UIImage imageNamed:selectedImageName]];
}

-(void)showFullDownView:(BOOL)show andFor:(int)itemsToShow // 1 -> favourites // 2 -> Nearby // 3 -> Recent
{
    fullCardsShown = show;
    currentFavIndex = itemsToShow;
    float height = _smallCardsContainerView.frame.origin.y + _smallCardsContainerView.frame.size.height + _cardsScrollView.frame.size.height + 10;
    if(!show){
        height = _smallCardsContainerView.frame.origin.y + _smallCardsContainerView.frame.size.height;
        [self setDownIconsNotSelectedWithIconSelected:nil andLabel:nil andDownImage:nil];
    }
    
    [[self delegate] showFullDownsideView:show withHeight:height];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    self.CONTENTVIEW.frame = CGRectMake(self.CONTENTVIEW.frame.origin.x, self.CONTENTVIEW.frame.origin.y, self.CONTENTVIEW.frame.size.width, height);
}

-(void)enableAllBtns:(BOOL)enable{
    [_showFavsBtn setEnabled:enable];
    [_showNearbyBtn setEnabled:enable];
    [_showRecentBtn setEnabled:enable];
}

-(void)reloadScrollView:(int)source{
    for(UIView *subview in [_cardsScrollView subviews]){
        [subview removeFromSuperview];
    }
    [_cardsScrollView scrollRectToVisible:_cardsScrollView.frame animated:NO];
    float viewWidth = _cardsScrollView.frame.size.width/1.47;
    NSArray *currentArray = [[NSArray alloc] init];
    NSString *titleKey = @"title";
    NSString *addressKey = [[HelperClass getDeviceLanguage] isEqualToString:@"ar"] ? @"arabicAddress" : @"englishAddress";
    NSString *type = @"favourite";
    if(source == 1){
        currentArray = [HelperClass getFavouritesFromClient];
        type = @"favourite";
    }else if (source == 2){
        currentArray = _nearByPlacesArray;
        titleKey = @"name";
        addressKey = @"address";
        type = @"nearby";
    }else{
        currentArray = _recentPlacesArray;
        titleKey = @"address";
        type = @"recent";
    }
    NSLog(@"currentArray : %@", currentArray);
    if(currentArray && ([currentArray count] > 0)){
        for (int i = 0; i < [currentArray count]; i++) {
            
            CGFloat xOrigin = (i * viewWidth) + (10*(i+1));
            NearbyRecentCardView *favView = [[NearbyRecentCardView alloc] initWithFrame:CGRectMake(xOrigin, 0, viewWidth, _cardsScrollView.frame.size.height)];
            if(source == 1){
                if([[[currentArray objectAtIndex:i] objectForKey:[HelperClass getDeviceLanguage]] isKindOfClass:[NSString class]]){ //Empty Fav
                    //Empty One
                    [favView setEmpty];
                    favView.emptyTitleLabel.text = [[currentArray objectAtIndex:i] objectForKey:[HelperClass getDeviceLanguage]];
                    favView.addFavBtn.tag = i;
                    favView.delegate = self;
                }else{
                    favView.titleLabel.text = [[[currentArray objectAtIndex:i] objectForKey:[HelperClass getDeviceLanguage]] objectForKey:titleKey];
                    if([[[currentArray objectAtIndex:i] objectForKey:[HelperClass getDeviceLanguage]] objectForKey:addressKey])
                        favView.descriptionLabel.text = [[[currentArray objectAtIndex:i] objectForKey:[HelperClass getDeviceLanguage]] objectForKey:addressKey];
                    
                    if([[[currentArray objectAtIndex:i] objectForKey:[HelperClass getDeviceLanguage]] objectForKey:@"image"])
                        favView.placeImageView.image = [UIImage imageNamed:[[[currentArray objectAtIndex:i] objectForKey:[HelperClass getDeviceLanguage]] objectForKey:@"image"]];
                    favView.placeImageView.contentMode = UIViewContentModeCenter;
                    favView.favButton.tag = i;
                    favView.type = type;
                    favView.delegate = self;
                }
            }else{
                if([[currentArray objectAtIndex:i] isKindOfClass:[NSString class]]){
                    //Empty One
                    [favView setEmpty];
                    favView.emptyTitleLabel.text = [currentArray objectAtIndex:i];
                    favView.addFavBtn.tag = i;
                    favView.delegate = self;
                }else{
                    favView.titleLabel.text = [[currentArray objectAtIndex:i] objectForKey:titleKey];
                    if([[currentArray objectAtIndex:i] objectForKey:addressKey])
                        favView.descriptionLabel.text = [[currentArray objectAtIndex:i] objectForKey:addressKey];
                    
                    if([[currentArray objectAtIndex:i] objectForKey:@"image"])
                        favView.placeImageView.image = [UIImage imageNamed:[[currentArray objectAtIndex:i] objectForKey:@"image"]];
                    favView.placeImageView.contentMode = UIViewContentModeCenter;
                    favView.favButton.tag = i;
                    favView.type = type;
                    favView.delegate = self;
                }
            }
            
            [_cardsScrollView addSubview:favView];
            
            favView.layer.cornerRadius = 4;
            UIBezierPath *favViewShadowPath = [UIHelperClass setViewShadow:favView edgeInset:UIEdgeInsetsMake(-1.0f, 0.0f, -1.0f, 0.0f) andShadowRadius:4.0f];
            favView.layer.shadowPath = favViewShadowPath.CGPath;
        }
        CGFloat sizeWidth = ((viewWidth + 10) * [currentArray count]);
        _cardsScrollView.contentSize = CGSizeMake(sizeWidth, _cardsScrollView.frame.size.height);
        _cardsScrollView.clipsToBounds = NO;
        
        //RTL Scroll
        if([[HelperClass getDeviceLanguage] isEqualToString:@"ar"]){
            _cardsScrollView.transform = CGAffineTransformMakeRotation(M_PI);
            for(UIView *subview in [_cardsScrollView subviews]){
                subview.transform =  CGAffineTransformMakeRotation(M_PI);
            }
        }
    }
}

#pragma mark - NearbyCardDelegate
-(void)setFavouriteAsDropOff:(int)selectedFavouriteIndex{
    [self showFullDownView:NO andFor:0];
    [[self delegate] setFavouriteAsDropOff:selectedFavouriteIndex];
}
-(void)setNearByAsDropoff:(int)selectedIndex{
    [self showFullDownView:NO andFor:0];
    [[self delegate] setNearByAsDropoff:selectedIndex];
}
-(void)setRecentAsDropoff:(int)selectedIndex{
    [self showFullDownView:NO andFor:0];
    [[self delegate] setRecentAsDropoff:selectedIndex];
}
-(void)goToAddFavouritedWithKey:(int)key{
    [self showFullDownView:NO andFor:0];
    [[self delegate] goToAddFavouritedWithKey:key];
}

@end
