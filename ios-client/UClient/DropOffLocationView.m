//
//  ChooseLocationView.m
//  Ego
//
//  Created by Mahmoud Amer on 7/24/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "DropOffLocationView.h"

@implementation DropOffLocationView
@synthesize mainTableView = _mainTableView;

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        [self customInit];
    }
    
    return self;
}

-(void)customInit{
    [[NSBundle mainBundle] loadNibNamed:@"DropOffLocationView" owner:self options:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"DefaultTableViewCell" bundle:nil];
    [_mainTableView registerNib:cellNib forCellReuseIdentifier:@"defaultCell"];
    
    selectedIconColor = [UIColor colorWithRed:0.0/255 green:172.0/255 blue:250.0/255 alpha:1.0f];
    notSelectedIconColor = [UIColor colorWithRed:174.0/255 green:174.0/255 blue:174.0/255 alpha:1.0f];
    [_favWorkIcon setTintColor:notSelectedIconColor];
    
    _placesClient = [GMSPlacesClient sharedClient];

    // Set up the autocomplete filter.
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    
    CLLocationCoordinate2D neBoundsCorner = CLLocationCoordinate2DMake(RIYADH_NE_CORNER_LATITUDE, RIYADH_NE_CORNER_LONGITUDE);
    CLLocationCoordinate2D swBoundsCorner = CLLocationCoordinate2DMake(RIYADH_SW_CORNER_LATITUDE, RIYADH_SW_CORNER_LONGITUDE);
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:neBoundsCorner coordinate:swBoundsCorner];
    // Create the fetcher.
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds filter:filter];
    _fetcher.delegate = self;
    
    //Select Mode
    selectMode = 1; //1 for default options --- 2 for searching
    
    //TextField delegate
    [_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    //Default options array
    selectingOptions = [[NSArray alloc] initWithObjects:
                        @{@"title":NSLocalizedString(@"MFC_selectingOptions_1", @""), @"icon":@"setPinIcon"},
                        @{@"title":NSLocalizedString(@"MFC_selectingOptions_2", @""), @"icon":@"tellDriverIcon"},
                        nil];
    //Reload TableView
    [_mainTableView reloadData];
    
    
    //Favourites Click to dismiss
    singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFavourites)];
    
    //Handle top view and buttom view animations
    
    [_topView setHidden:YES];
    [_buttomView setHidden:YES];
    
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
    CGRect topFrame = _topView.frame;
    CGRect fieldContainerViewFrame = _fieldContainerView.frame;
    CGRect buttomFrame = _buttomView.frame;
    CGRect tableViewFrame = _mainTableView.frame;
    CGRect closeBtnFrame = _closeBtn.frame;
    
    _topView.frame = CGRectMake(topFrame.origin.x, topFrame.origin.y, topFrame.size.width, 0);
    _closeBtn.frame = CGRectMake(_closeBtn.frame.origin.x, -_closeBtn.frame.size.height, _closeBtn.frame.size.width, _closeBtn.frame.size.height);
    _fieldContainerView.frame = CGRectMake(fieldContainerViewFrame.origin.x, 0, topFrame.size.width, 0);
    _buttomView.frame = CGRectMake(buttomFrame.origin.x, self.frame.size.height, buttomFrame.size.width, 0);
    _mainTableView.frame = CGRectMake(tableViewFrame.origin.x, 0, tableViewFrame.size.width, self.frame.size.height);
    
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [_topView setHidden:NO];
                         _topView.frame = topFrame;
                         _fieldContainerView.frame = fieldContainerViewFrame;
                         _closeBtn.frame = closeBtnFrame;
                         
                     }completion:^(BOOL finished){
                         [_mainTableView reloadData];
                         UIBezierPath *shadowPath = [UIHelperClass setViewShadow:_topView edgeInset:UIEdgeInsetsMake(-1.0f, -1.0f, -1.0f, -1.0f) andShadowRadius:5.0f];
                         _topView.layer.shadowPath = shadowPath.CGPath;
                     }];
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [_buttomView setHidden:NO];
                         _buttomView.frame = buttomFrame;
                         _mainTableView.frame = tableViewFrame;
                         [self bringSubviewToFront:_topView];
                         
                     }completion:^(BOOL finished){}];
    
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (selectMode) {
        case 1:
            return [selectingOptions count];
            break;
        case 2:
            return [resultsArray count];
            break;
        default:
            return [resultsArray count];
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showLoadingView:NO];
    static NSString *MyIdentifier = @"defaultcell";
    DefaultTableViewCell *cell = (DefaultTableViewCell *)[_mainTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DefaultTableViewCell" owner:self options:nil];
        cell = defaultCell;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.delegate = self;
    
    if(selectMode == 1){//Default Options (selectMode = 1)
        [cell.leftImgView setImage:[UIImage imageNamed:[[selectingOptions objectAtIndex:indexPath.row] objectForKey:@"icon"]]];
        cell.titleLBL.text = [[selectingOptions objectAtIndex:indexPath.row] objectForKey:@"title"];
        [cell.rightFavBtn setHidden:YES];
        [cell.addressLabel setHidden:YES];
        if(indexPath.row == (selectingOptions.count - 1))
            [cell.separatorView setHidden:YES];
        cell.titleLBL.center = CGPointMake(cell.titleLBL.center.x, 30.5);
    }else{//Searching
        GMSAutocompletePrediction* prediction = [resultsArray objectAtIndex:indexPath.row];
        cell.titleLBL.text = prediction.attributedPrimaryText.string;
        cell.addressLabel.text = prediction.attributedFullText.string;
        [cell.rightFavBtn setHidden:NO];
        cell.rightFavBtn.tag = indexPath.row;
        [cell.leftImgView setImage:[UIImage imageNamed:@"tableLocationIcon"]];
        [cell.separatorView setHidden:NO];
        if(indexPath.row == (resultsArray.count - 1))
            [cell.separatorView setHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
    if(selectMode == 1){//Searching places
        switch (indexPath.row) {
            case 0:
                [self.delegate setChosenLocation:@{@"map" : @"yes"}];
                break;
            case 1:
                [self.delegate setChosenLocation:@{@"skipped" : @"yes"}];
                break;
            default:
                break;
                
        }
        [self closeBtnAction];
    }else{
        GMSAutocompletePrediction* result = [resultsArray objectAtIndex:indexPath.row];
        //Get selected address details
        NSLog(@"place details : %@", result);
        [_placesClient lookUpPlaceID:result.placeID callback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
            
            if (place != nil) {
                // Destination Selection
                NSArray *coordinatesArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", place.coordinate.latitude], [NSString stringWithFormat:@"%f", place.coordinate.longitude], nil];
                NSDictionary *locationData = @{@"coordinates" : coordinatesArray, @"type" : @"Point", @"addressString" : result.attributedFullText.string, @"titleString" : result.attributedPrimaryText.string};
                [self.delegate setChosenLocation:locationData];
                [self closeBtnAction];
            }
        }];
        
    }
}

#pragma mark - Cell Delegate
-(void)setFavourite:(int)selectedRow{
    placeToAddToFav = [resultsArray objectAtIndex:selectedRow];
    [_searchTextField resignFirstResponder];
    [self showFavouriteView:YES];
}

#pragma mark - Textfields delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidChange :(UITextField *)textField{
    if(textField == _searchTextField){
        if(textField.text.length > 1){
            selectMode = 2;
            [self showLoadingView:YES];
            [_fetcher sourceTextHasChanged:textField.text];
        }else{
            selectMode = 1;
            [_mainTableView reloadData];
            if(textField.text.length == 0)
                [_searchTextField resignFirstResponder];
        }
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

#pragma mark - GMSAutocompleteFetcherDelegate
- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    [self showLoadingView:NO];
    [resultsArray removeAllObjects];
    resultsArray = [[NSMutableArray alloc] init];
    for (GMSAutocompletePrediction *prediction in predictions) {
        [resultsArray addObject:prediction];
    }
    [_mainTableView reloadData];
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    
}

#pragma mark - Actions

- (IBAction)closeBtnAction {
    _topView.layer.shadowOpacity = 0.0f;
    CGRect topFrame = _topView.frame;
    CGRect fieldContainerViewFrame = _fieldContainerView.frame;
    CGRect closeBtnFrame = _closeBtn.frame;
    CGRect buttomFrame = _buttomView.frame;
    [UIView animateWithDuration:0.4
                          delay: 0.0
                        options: UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         _topView.frame = CGRectMake(topFrame.origin.x, topFrame.origin.y, topFrame.size.width, 0);
                         _fieldContainerView.frame = CGRectMake(fieldContainerViewFrame.origin.x, -fieldContainerViewFrame.origin.y, topFrame.size.width, 0);
                         _fieldContainerView.alpha = 0.0f;
                         _closeBtn.frame = CGRectMake(closeBtnFrame.origin.x, -_closeBtn.frame.size.height, 0, _closeBtn.frame.size.height);
                         _buttomView.frame = CGRectMake(buttomFrame.origin.x, self.frame.size.height, buttomFrame.size.width, 0);
                     }completion:^(BOOL finished){
                         [self.delegate dismissView];
                     }];
}

#pragma mark - Favourites
-(void)showFavouriteView:(BOOL)show{
    
    if(show){
        [_favouritesContainerView removeGestureRecognizer:singleFingerTap];
        [_favouritesContainerView addGestureRecognizer:singleFingerTap];
        
        _favouritesContainerView.alpha = 0.0f;
        [_favouritesContainerView setHidden:NO];
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             _favouritesContainerView.alpha = 1.0f;
                         }completion:^(BOOL finished){
                             
                         }];
    }else{
        [UIView animateWithDuration:0.2
                              delay: 0.0
                            options: UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             _favouritesContainerView.alpha = 0.0f;
                         }completion:^(BOOL finished){
                             [_favouritesContainerView setHidden:YES];
                         }];
    }
}
-(void)dismissFavourites{
    [self showFavouriteView:NO];
}


- (IBAction)favWorkAction:(UIButton *)sender {
    [_favWorkIcon setTintColor:selectedIconColor];
    [_favHomeIcon setTintColor:notSelectedIconColor];
    [_favOtherIcon setTintColor:notSelectedIconColor];
    [_favMarketIcon setTintColor:notSelectedIconColor];
    [self getPlaceCoordinate:@"work"];
}

- (IBAction)favHomeAction:(UIButton *)sender {
    [_favWorkIcon setTintColor:notSelectedIconColor];
    [_favHomeIcon setTintColor:selectedIconColor];
    [_favOtherIcon setTintColor:notSelectedIconColor];
    [_favMarketIcon setTintColor:notSelectedIconColor];
    [self getPlaceCoordinate:@"home"];
}

- (IBAction)favMarketAction:(UIButton *)sender {
    [_favWorkIcon setTintColor:notSelectedIconColor];
    [_favHomeIcon setTintColor:notSelectedIconColor];
    [_favOtherIcon setTintColor:notSelectedIconColor];
    [_favMarketIcon setTintColor:selectedIconColor];
    [self getPlaceCoordinate:@"market"];
}

- (IBAction)favOtherAction:(UIButton *)sender {
    [_favWorkIcon setTintColor:notSelectedIconColor];
    [_favHomeIcon setTintColor:notSelectedIconColor];
    [_favOtherIcon setTintColor:selectedIconColor];
    [_favMarketIcon setTintColor:notSelectedIconColor];
    [self getPlaceCoordinate:@"other"];
}

-(void)getPlaceCoordinate:(NSString *)type{
    [_placesClient lookUpPlaceID:placeToAddToFav.placeID callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSArray *coordinatesArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", place.coordinate.latitude], [NSString stringWithFormat:@"%f", place.coordinate.longitude], nil];
            [[self delegate] goToFavouritesControllerWithType:type andLocation:coordinatesArray];
        }
    }];
    [self dismissFavourites];
}

-(void)addFavouriteInBackground:(NSString *)type{
    @autoreleasepool {
        [_placesClient lookUpPlaceID:placeToAddToFav.placeID callback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
            
            if (place != nil) {
                // Destination Selection
                NSArray *coordinatesArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", place.coordinate.latitude], [NSString stringWithFormat:@"%f", place.coordinate.longitude], nil];
                NSDictionary *parameters = @{@"location" : coordinatesArray, @"type" : type};
                [RidesServiceManager addFavourites:parameters :^(NSDictionary *response){
                    [self performSelectorOnMainThread:@selector(finishaddFavouriteInBackground:) withObject:response waitUntilDone:NO];
                }];
            }
        }];
        
    }
}

-(void)finishaddFavouriteInBackground:(NSDictionary *)response{
    NSLog(@"finishaddFavouriteInBackground response : %@", response);
    [self.delegate showLoading:NO];
    if(response){
        if([response objectForKey:@"data"]){
            [ServiceManager saveLoggedInClientData:[response objectForKey:@"data"] andAccessToken:nil];
        }
    }
}

#pragma mark - Loading View
-(void)showLoadingView:(BOOL)show{
    if(show) {
        [loadingView removeFromSuperview];
        loadingView = nil;
        loadingView = [[LoadingCustomView alloc] initWithFrame:self.bounds andAnimatorY:_topView.frame.size.height];
        [self addSubview:loadingView];
        [self bringSubviewToFront:loadingView];
    }else{
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
}

@end
