//
//  OccasionDetail.m
//  Trendy
//
//  Created by NewAgeSMB on 9/9/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "OccasionDetail.h"
#import "MBProgressHUD.h"
#import "TrendsCell.h"
#import "AppDelegate.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ProductDetail.h"
#import "ODRefresh/ODRefreshControl.h"
#import "FilterView.h"

@interface OccasionDetail ()
{
    IBOutlet UICollectionView *occasionview;
    NSArray *occasionarray;
    NSString *requesttype, *filepath, *address;
    AppDelegate *appdelegate;
    IBOutlet UILabel *occasionlabel, *noresultslabel, *filteredlabel;
    IBOutlet UIView *filterview;
    IBOutlet UIButton *filterbtn, *locationbtn;
    IBOutlet UIImageView *filterimage;
    BOOL isPageRefresing, presented_filter, refresh;
    FilterView *objoffilter;
}
@property (nonatomic) CGFloat previousScrollViewYOffset;

@end

@implementation OccasionDetail
@synthesize occasionid,occasionname,selectedlocation;
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"REFRESH"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshonlocation:) name:@"REFRESHONLOCATION"  object:nil];
    UINib *cellNib = [UINib nibWithNibName:@"TrendsCell" bundle:nil];
    [occasionview registerNib:cellNib forCellWithReuseIdentifier:@"TrendsCell"];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(selectedlocation){
        
    }
    [self getoccasionsfeeds];
    occasionlabel.text = occasionname;
    [self getlocationdetails];
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:occasionview];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    occasionview.alwaysBounceVertical = YES;
    
    objoffilter = [[FilterView alloc] init];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getlocationdetails{
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:appdelegate.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            
            NSString *addressName = [placemark subLocality];
            NSString *city = [placemark locality]; // locality means "city"
            NSString *administrativeArea = [placemark administrativeArea]; // which is "state" in the U.S.A.
            NSLog( @"subLocality is %@ and locality is %@ and administrative area is %@", addressName, city, administrativeArea );
//            address = [NSString stringWithFormat:@"%@/%@",addressName,city];
//            if([placemark locality])
//                address = [NSString stringWithFormat:@"%@",[placemark locality]];
//            else if([placemark subLocality])
//                address = [NSString stringWithFormat:@"%@",[placemark subLocality]];
           // [self locationsize:address];
            //            CGSize textsize = [self locationsize:address];
            
        }
    }];
    
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
    
    //    pageno = 1;
    if(isPageRefresing == NO){
        [self getoccasionsfeeds];
        isPageRefresing = YES;
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(address || appdelegate.changedlocation){
       
        if(refresh == YES){
            if(appdelegate.changedlocation)
                selectedlocation = appdelegate.changedlocation;
            [self getoccasionsfeeds];
        }
        [self locationsize:address];
        refresh = NO;
        //        [self getrecentfeeds];
    }
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
}

-(void)viewDidDisappear:(BOOL)animated{
//    CGRect frameatreset= self.occasionTopView.frame;
//    frameatreset.origin.y=0.0;
//    self.occasionTopView.frame= frameatreset;
//    CGRect frameatreset1= occasionview.frame;
//    frameatreset1.origin.y= self.occasionTopView.frame.origin.y + self.occasionTopView.frame.size.height;
//    occasionview.frame= frameatreset1;
//    occasionlabel.alpha= 1;
//    
//    
//    [occasionview setContentOffset:CGPointMake(0, 0) animated:YES];
    
    
}
-(void)getoccasionsfeeds{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    if(selectedlocation)
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_product_occasion\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\",\"occasion_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[selectedlocation objectForKey:@"lat"],[selectedlocation objectForKey:@"long"],occasionid];
    else{
        float lat, lng;
        lat = appdelegate.locationManager.location.coordinate.latitude;
        lng = appdelegate.locationManager.location.coordinate.longitude;
        if(appdelegate.locationManager.location)
        {
            
        }
        else{
            
            [appdelegate.locationManager startUpdatingLocation];
        }
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_product_occasion\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%f\",\"long\": \"%f\",\"occasion_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,lat,lng,occasionid];
    }
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"recentfeeds";
}

-(void)locationsize:(NSString *)input{
    
//    if(appdelegate.changedlocation)
//        input = [NSString stringWithFormat:@"%@/%@",[selectedlocation objectForKey:@"city"],[selectedlocation objectForKey:@"country_name"]];
    if(input.length>0){
        UIFont *font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0];
        NSAttributedString *attributedText =
        [[NSAttributedString alloc]
         initWithString:input
         attributes:@
         {
         NSFontAttributeName: font
         }];
        CGSize locationsize = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, 26}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil].size;
        
        if(locationsize.width>[[UIScreen mainScreen] bounds].size.width - 100)
            locationsize.width = [[UIScreen mainScreen] bounds].size.width - 100;
        filteredlabel.text = input;
        filteredlabel.adjustsFontSizeToFitWidth = YES;
        filteredlabel.frame = CGRectMake(0, 10, locationsize.width, 26);
        filterimage.frame = CGRectMake(locationsize.width + 3, 12, 17, 22);
        CGRect framelocation = filterview.frame;
        framelocation.size.width = locationsize.width + 20;
        filterview.frame = framelocation;
        filterview.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, framelocation.origin.y+(framelocation.size.height)/2);
        locationbtn.frame = CGRectMake(0, 0, framelocation.size.width, 45);
    }
    //    return locationsize;
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
            
            isPageRefresing = NO;
            occasionarray = [[tempdict objectForKey:@"product_list"] mutableCopy];
            if([tempdict objectForKey:@"location"] != [NSNull null])
                address = [tempdict objectForKey:@"location"];
            [self locationsize:address];
            filepath = [tempdict objectForKey:@"filePath"];
            if(appdelegate.sortedkeyOccasion.length>0){
                NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:appdelegate.sortedkeyOccasion ascending:appdelegate.asendingOccasion comparator:^(id obj1, id obj2) {
                    
                    if ([obj1 floatValue] > [obj2 floatValue]) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    if ([obj1 floatValue] < [obj2 floatValue]) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                }];
                NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[occasionarray sortedArrayUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]]];
                occasionarray = [sortedArray mutableCopy];
                
            }
            [occasionview reloadData];
            if(occasionarray.count==0){
                noresultslabel.hidden = NO;
                noresultslabel.text = [NSString stringWithFormat:@"No results found."];
            }
            else
                noresultslabel.hidden = YES;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(IBAction)filtersettings:(id)sender{
    
    if(presented_filter == NO){
        
        //        obj.view.backgroundColor = [UIColor clearColor];
        objoffilter.delegate = self;
        objoffilter.btnstate = @"selected";
        NSDictionary *locationdict;
        if(selectedlocation)
            locationdict = [selectedlocation copy];
        //[selectedlocation objectForKey:@"lat"],[selectedlocation objectForKey:@"long"];
        else
            
            locationdict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",appdelegate.locationManager.location.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",appdelegate.locationManager.location.coordinate.longitude ],@"long", nil];
        objoffilter.locationdetails = [locationdict copy];
        objoffilter.filtertype = @"occasion";
        objoffilter.occasion_id = occasionid;
        objoffilter.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:objoffilter animated:YES completion:nil];
        //        [appdelegate.window addSubview:filtersettingsview];
        //        filtersettingsview.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        presented_filter = YES;
    }
    else{
        
    }
}

-(void)dismissed:(NSString *)status{
    
    if([status isEqualToString:@"add"]){
        
        
        [objoffilter dismissViewControllerAnimated:YES completion:^{
            self.tabBarController.tabBar.hidden = NO;
            presented_filter = NO;
            [self back:nil];
        }];
        
    }
    else if([status isEqualToString:@"dismiss"]){
        
        self.tabBarController.tabBar.hidden = NO;
        [objoffilter dismissViewControllerAnimated:YES completion:^{
            
            presented_filter = NO;
            refresh = YES;
            [self getoccasionsfeeds];
        }];
        
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView ==occasionview ) {
        CGRect frame = self.occasionTopView.frame;
        CGFloat size = frame.size.height - 21;
        CGFloat framePercentageHidden = ((0 - frame.origin.y) / (frame.size.height - 1));
        CGFloat scrollOffset = scrollView.contentOffset.y;
        CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
        CGFloat scrollHeight = scrollView.frame.size.height;
        CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
            if(translation.y > 0)
            {
                NSLog(@"test");
                frame.origin.y = 0;
            } else
            {
                // react to dragging up
            }

        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            frame.origin.y = -size;
        } else {
            frame.origin.y = MIN(0, MAX(-size, frame.origin.y - scrollDiff));
        }
        
        [self.occasionTopView setFrame:frame];
        CGRect frame1=occasionview.frame;
        frame1.origin.y =self.occasionTopView.frame.origin.y +self.occasionTopView.frame.size.height;
        CGRect obvFrame=self.occassionBottomView.frame;
        frame1.size.height= obvFrame.origin.y- frame1.origin.y;

        occasionview.frame =frame1;
        
        [self updateBarButtonItems:(1 - framePercentageHidden)];
        self.previousScrollViewYOffset = scrollOffset;
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView ==occasionview ) {
        [self stoppedScrolling];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (scrollView ==occasionview ) {
        if (!decelerate) {
            [self stoppedScrolling];
        }
    }
    
}

- (void)stoppedScrolling
{
    CGRect frame = self.occasionTopView.frame;
    if (frame.origin.y < 0) {
        [self animateNavBarTo:-(frame.size.height - 21)];
    }
    else{
        CGRect frame1=occasionview.frame;
        frame1.origin.y =self.occasionTopView.frame.origin.y +self.occasionTopView.frame.size.height;
        CGRect obvFrame=self.occassionBottomView.frame;
        frame1.size.height= obvFrame.origin.y- frame1.origin.y;
        occasionview.frame =frame1;
    }
}

- (void)updateBarButtonItems:(CGFloat)alpha
{
    //    [self.topbarview.frameleftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
    //        item.customView.alpha = alpha;
    //    }];
    //    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
    //        item.customView.alpha = alpha;
    //    }];
    //  self.recentBtn.alpha = alpha;
    
    occasionlabel.alpha =alpha;
    self.occasionTopView.tintColor = [self.occasionTopView.tintColor colorWithAlphaComponent:alpha];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.occasionTopView.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.occasionTopView setFrame:frame];
        
        CGRect frame1=occasionview.frame;
        frame1.origin.y =self.occasionTopView.frame.origin.y +self.occasionTopView.frame.size.height;
        CGRect obvFrame=self.occassionBottomView.frame;
        frame1.size.height= obvFrame.origin.y- frame1.origin.y;
        
        occasionview.frame =frame1;

        [self updateBarButtonItems:alpha];
    }];
   
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    return needarray.count;
    return occasionarray.count;
    //    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = CGSizeMake(([[UIScreen mainScreen] bounds].size.width - 20) / 3, 155);
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    TrendsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TrendsCell" forIndexPath:indexPath];
    if([[occasionarray objectAtIndex:indexPath.row] objectForKey:@"price"] != [NSNull null])
//        cell.pricelabel.text = [NSString stringWithFormat:@"$%.2f",[[[occasionarray objectAtIndex:indexPath.row] objectForKey:@"price"] floatValue]];
        cell.pricelabel.text = [NSString stringWithFormat:@"$%@",[[occasionarray objectAtIndex:indexPath.row] objectForKey:@"price"]];
    if([[occasionarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"] != [NSNull null] && [[[occasionarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"] intValue] != 100)
        cell.bgimage.image = [UIImage imageNamed:@"bg1"];
    else
        cell.bgimage.image = [UIImage imageNamed:@"bg2"];
    //cell.brandlabel.hidden = NO;
    if([[occasionarray objectAtIndex:indexPath.row] objectForKey:@"brand"] != [NSNull null])
        cell.brandlabel.text = [[occasionarray objectAtIndex:indexPath.row] objectForKey:@"brand"];
    if([[occasionarray objectAtIndex:indexPath.row] objectForKey:@"fileName"] != [NSNull null])
    {
        NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[occasionarray objectAtIndex:indexPath.row] objectForKey:@"fileNAME"]];
        //            [cell.Trendmage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
        [cell.Trendmage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"recentdefaultimage"]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ProductDetail *obj = [[ProductDetail alloc] init];
    obj.producttype = @"Occasions";
    obj.productid = [[occasionarray objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:obj animated:YES];
}


-(void)refresh:(NSNotification *) notification
{
    refresh = YES;
    if(notification.object){
        NSString *str = (NSString *)notification.object;
        if([str isEqualToString:@"currentloc"])
            selectedlocation = nil;
        
    }
    //    if(trendview.hidden == YES)
    //        [self getrecentfeeds];
    //    else
    //        [self gettrendsfeeds];
}

-(void)refreshonlocation:(NSNotification *) notification
{
    [self getoccasionsfeeds];
    refresh = YES;
    
}


-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)noNetworkFound: (NSNotification *) notification
{
    
    NSString *status=(NSString *)[notification object];
    if (![status boolValue]) {
        
        [self stoploader];
    }
    
}

-(void)startLoader:(NSString *)title
{
    MBProgressHUD *objOfHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    objOfHUD.labelText = title;
    
}
-(void) stoploader{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)stopLoader:(NSNotification *) notification{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
