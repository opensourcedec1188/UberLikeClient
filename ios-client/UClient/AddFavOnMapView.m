//
//  AddFavOnMapView.m
//  Ego
//
//  Created by Mahmoud Amer on 8/3/17.
//  Copyright © 2017 Amer. All rights reserved.
//

#import "AddFavOnMapView.h"

@implementation AddFavOnMapView

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
    [[NSBundle mainBundle] loadNibNamed:@"AddFavOnMapView" owner:self options:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"DefaultTableViewCell" bundle:nil];
    [_mainTableView registerNib:cellNib forCellReuseIdentifier:@"defaultCell"];
    
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
    
    //TextField delegate
    [_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    //Handle top view and buttom view animations
    [_topView setHidden:YES];
    [_buttomView setHidden:YES];
    
    [self addSubview:self.CONTENTVIEW];
    self.CONTENTVIEW.frame = self.bounds;
    
    CGRect topFrame = _topView.frame;
    CGRect fieldContainerViewFrame = _fieldContainerView.frame;
    CGRect buttomFrame = _buttomView.frame;
    CGRect tableViewFrame = _mainTableView.frame;
    
    _topView.frame = CGRectMake(topFrame.origin.x, topFrame.origin.y, topFrame.size.width, 0);
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
                     }completion:^(BOOL finished){
                         [_searchTextField becomeFirstResponder];
                     }];
    [_mainTableView setHidden:YES];
    
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([resultsArray count] > 0)
        return 61;
    else
        return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"defaultcell";
    DefaultTableViewCell *cell = (DefaultTableViewCell *)[_mainTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DefaultTableViewCell" owner:self options:nil];
        cell = defaultCell;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    GMSAutocompletePrediction* prediction = [resultsArray objectAtIndex:indexPath.row];
    cell.titleLBL.text = prediction.attributedPrimaryText.string;
    cell.addressLabel.text = prediction.attributedFullText.string;
    [cell.leftImgView setImage:[UIImage imageNamed:@"tableLocationIcon"]];
    [cell.separatorView setHidden:NO];
    [cell.rightFavBtn setHidden:YES];
    if(indexPath.row == (resultsArray.count - 1))
        [cell.separatorView setHidden:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([resultsArray count] > 0){
        [self endEditing:YES];
        GMSAutocompletePrediction* result = [resultsArray objectAtIndex:indexPath.row];
        NSLog(@"selected %@", result);
        //Get selected address details
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
                [self hideMe];
            }
        }];
    }else{
        [[self delegate] setChosenLocation:@{@"type" : @"map"}];
        [self hideMe];
    }
    
}

#pragma mark - Textfields delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidChange :(UITextField *)textField{
    if(textField == _searchTextField){
        if(textField.text.length > 1){
            [_fetcher sourceTextHasChanged:textField.text];
            [_mainTableView setHidden:NO];
        }else{
            [_mainTableView setHidden:YES];
            
            if(textField.text.length == 0){
                
                [resultsArray removeAllObjects];
                [_searchTextField resignFirstResponder];
            }
        }
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

#pragma mark - GMSAutocompleteFetcherDelegate
- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    
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
    [self hideMe];
}

-(void)hideMe {
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
                         _fieldContainerView.frame = CGRectMake(fieldContainerViewFrame.origin.x, 0, topFrame.size.width, 0);
                         _closeBtn.frame = CGRectMake(closeBtnFrame.origin.x, 0, 0, 0);
                         _searchTextField.frame = CGRectMake(_searchTextField.frame.origin.x, 0, 0, 0);
                         _fieldContainerView.frame = CGRectMake(_fieldContainerView.frame.origin.x, 0, 0, 0);
                         _buttomView.frame = CGRectMake(buttomFrame.origin.x, self.frame.size.height, buttomFrame.size.width, 0);
                     }completion:^(BOOL finished){
                         [self.delegate dismissView];
                     }];
}

@end
