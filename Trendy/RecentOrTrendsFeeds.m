//
//  RecentOrTrendsFeeds.m
//  Trendy
//
//  Created by NewAgeSMB on 8/5/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "RecentOrTrendsFeeds.h"
#import "PostStep1.h"
#import "RecentCell.h"
#import "TrendsCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "MHFacebookImageViewer.h"
#import "ProductDetail.h"
#import "ODRefresh/ODRefreshControl.h"
#import "Contact.h"
#import "InterView.h"

@interface RecentOrTrendsFeeds (){
    
    IBOutlet UIImageView *tabimage1, *tabimage2, *filterimage, *locationbgimage;
    IBOutlet UILabel *tablabel1, *tablabel2,*filteredlabel, *noresultslabel;
    IBOutlet UICollectionView *recentCollectionview, *trendCollectionview;
    IBOutlet UIView *recentview, *trendview, *filterview;
    NSString *requesttype;
    AppDelegate *appdelegate;
    NSMutableArray *recentarray, *trendarray;
    NSString *addressName, *city, *administrativeArea, *address, *filepath, *vote;
    NSInteger selectedindex;
    IBOutlet UIButton *filterbtn, *locationbtn;
    BOOL refresh;
    
    IBOutlet UIView *filtersettingsview;
    FilterView *objoffilter;
    BOOL presented_filter,isPageRefresing, otherlocation;
    
    IBOutlet UIView *locationview, *locationsubview;
    IBOutlet UITextField *countryfield, *cityfield, *statefield;
    IBOutlet UITableView *locationtable;
    NSArray *locationarray, *countryarray, *cityarray, *statearray;
    NSString *locationtype, *country_id, *city_id;
    NSDictionary *selectedlocation;
    float rangeval;
    NSUInteger selectedcityindex;
    CGRect framedoriginal;
    
}
@property (nonatomic) CGFloat previousScrollViewYOffset;

@end

@implementation RecentOrTrendsFeeds

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"REFRESH"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshonlocation:) name:@"REFRESHONLOCATION"  object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate startUpdatingCurrentLocation];
    UINib *cellNib = [UINib nibWithNibName:@"RecentCell" bundle:nil];
    [recentCollectionview registerNib:cellNib forCellWithReuseIdentifier:@"RecentCell"];
    
    UINib *cellNib1 = [UINib nibWithNibName:@"TrendsCell" bundle:nil];
    [trendCollectionview registerNib:cellNib1 forCellWithReuseIdentifier:@"TrendsCell"];
    objoffilter = [[FilterView alloc] init];
    recentarray = [[NSMutableArray alloc] init];
    trendarray = [[NSMutableArray alloc] init];
    if(appdelegate.changedlocation){
        
        selectedlocation = [appdelegate.changedlocation mutableCopy];
        [self setlocationviews];
    }
    [self getrecentfeeds];
    [self getlocationdetails];
    selectedcityindex = -1;
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:recentCollectionview];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    ODRefreshControl *refreshControl1 = [[ODRefreshControl alloc] initInScrollView:trendCollectionview];
    [refreshControl1 addTarget:self action:@selector(dropViewDidBeginRefreshing1:) forControlEvents:UIControlEventValueChanged];
    recentCollectionview.alwaysBounceVertical = YES;
    trendCollectionview.alwaysBounceVertical = YES;
    [self configureLabelSlider];
     // Do any additional setup after loading the view from its nib.
    framedoriginal =recentCollectionview.frame;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    
    NSLog(@"%@",[standardUserDefaults objectForKey:@"_APP_COUNT_LIST"]);
    if ([[standardUserDefaults objectForKey:@"_APP_COUNT_LIST"] isEqual:@"1"]) {
        
        
        InterView *obj = [[InterView alloc] init];
        obj.IsIntroducing=@"Y";
      //  self.hidesBottomBarWhenPushed = YES;
      
        [self.navigationController pushViewController:obj animated:YES];
        
       // self.hidesBottomBarWhenPushed=NO;

        
        
        
        
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        int count = [[standardUserDefaults objectForKey:@"_APP_COUNT_LIST"] integerValue] +1;
        
        
        
        [standardUserDefaults removeObjectForKey:@"_APP_COUNT_LIST"];
        
        
        
        [standardUserDefaults setObject:[NSNumber numberWithInt:count] forKey:@"_APP_COUNT_LIST"];
        
        
    }

   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getlocationdetails{
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:appdelegate.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            
            addressName = [placemark subLocality];
            city = [placemark locality]; // locality means "city"
            administrativeArea = [placemark administrativeArea]; // which is "state" in the U.S.A.
            NSLog( @"subLocality is %@ and locality is %@ and administrative area is %@", addressName, city, administrativeArea );
//            address = [NSString stringWithFormat:@"%@/%@",addressName,city];
//            if([placemark locality])
//                address = [NSString stringWithFormat:@"%@",[placemark locality]];
//            else if([placemark subLocality])
//                address = [NSString stringWithFormat:@"%@",[placemark subLocality]];
          //  [self locationsize:address];
            //            CGSize textsize = [self locationsize:address];
            
        }
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    
    if(address || appdelegate.changedlocation){
       
        locationtable.hidden = YES;
        if(refresh == YES && otherlocation == NO){
            selectedlocation = appdelegate.changedlocation;
            [self setlocationviews];
            
        }
        else{
//            selectedlocation = nil;
            [self setlocationviews];
        }
        [self locationsize:address];
        otherlocation = NO;
    }
    self.tabBarController.tabBar.hidden = NO;
    [locationview removeFromSuperview];
    if(refresh == YES){
        if(trendview.hidden == YES)
            [self getrecentfeeds];
        else
            [self gettrendsfeeds];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    
//        [self getrecentfeeds];
        [self updateSliderLabels];        
        if([self.view respondsToSelector:@selector(setTintColor:)])
        {
            self.view.tintColor = [UIColor orangeColor];
        }
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
   

   }

-(void)viewDidDisappear:(BOOL)animated{
//    CGRect frameatreset= self.topbarview.frame;
//    frameatreset.origin.y=0.0;
//    self.topbarview.frame= frameatreset;
//    CGRect frameatreset1= recentview.frame;
//    frameatreset1.origin.y= self.topbarview.frame.origin.y + 107;
//    recentview.frame= frameatreset1;
//    CGRect frameatreset2= trendview.frame;
//    frameatreset2.origin.y= self.topbarview.frame.origin.y + 107;
//    trendview.frame= frameatreset2;
//    self.recentBtn.alpha= 1;
//    self.lblRecent.alpha= 1;
//    self.lblTrends.alpha =1;
//
//    [recentCollectionview setContentOffset:CGPointMake(0, 0) animated:YES];
//    [trendCollectionview setContentOffset:CGPointMake(0, 0) animated:YES];
//    [recentCollectionview setContentOffset:CGPointMake(0, recentCollectionview.frame.origin.y) animated:YES];
//    [trendCollectionview setContentOffset:CGPointMake(0, trendCollectionview.frame.origin.y) animated:YES];
    

}
- (void)viewDidUnload{
    NSLog(@"drfdgfg");
}

-(void)setlocationviews{
    
    if([selectedlocation objectForKey:@"country"] != [NSNull null])
        country_id = [selectedlocation objectForKey:@"country"];
    if([selectedlocation objectForKey:@"country_name"] != [NSNull null])
        countryfield.text = [selectedlocation objectForKey:@"country_name"];
    if([selectedlocation objectForKey:@"state"] != [NSNull null])
        statefield.text = [selectedlocation objectForKey:@"state"];
    if([selectedlocation objectForKey:@"id"] != [NSNull null])
        city_id = [selectedlocation objectForKey:@"id"];
    if([selectedlocation objectForKey:@"city"] != [NSNull null])
        cityfield.text  = [selectedlocation objectForKey:@"city"];
    CGRect frame = locationbgimage.frame;
    CGRect frame1 = locationsubview.frame;
    if([country_id isEqualToString:@"3"]){
        
        locationtype = @"state";
        frame.size.height = 248;
        frame1.origin.y = 228;
        statearray = [appdelegate.statevalarray mutableCopy];
        cityarray = [appdelegate.cityvalarray mutableCopy];
    }
    else{
        locationtype = @"city";
        frame.size.height = 200;
        frame1.origin.y = 180;
        cityarray = [appdelegate.cityvalarray mutableCopy];
        
    }
    locationbgimage.frame = frame;
    locationsubview.frame = frame1;
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
        [self getrecentfeeds];
        isPageRefresing = YES;
    }
    
    
}

- (void)dropViewDidBeginRefreshing1:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
    
    //    pageno = 1;
    if(isPageRefresing == NO){
        [self gettrendsfeeds];
        isPageRefresing = YES;
    }
   
}


-(void)locationsize:(NSString *)input{
    
    if(appdelegate.changedlocation)
        input = [NSString stringWithFormat:@"%@",[appdelegate.changedlocation objectForKey:@"city"]];
//        input = [NSString stringWithFormat:@"%@/%@",[appdelegate.changedlocation objectForKey:@"city"],[appdelegate.changedlocation objectForKey:@"country_name"]];
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

-(void)getrecentfeeds{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    if(selectedlocation)
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trendy_recent\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[selectedlocation objectForKey:@"lat"],[selectedlocation objectForKey:@"long"]];
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
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trendy_recent\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%f\",\"long\": \"%f\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,lat,lng];
    }
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"recentfeeds";
}

-(void)gettrendsfeeds{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    if(selectedlocation)
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trendy_trends\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[selectedlocation objectForKey:@"lat"],[selectedlocation objectForKey:@"long"]];
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
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trendy_trends\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%f\",\"long\": \"%f\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,lat,lng];
    }
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"trendsfeeds";
    
}

-(void)getcountries{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_country\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getcountries";
}

-(void)getstates{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_state\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"country_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,country_id];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getstates";
    
}

-(void)getcitiesfromstates{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_city_state\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"state\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,statefield.text];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getcitiesstates";
    
}

-(void)getcities{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_city\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"country_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,country_id];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getcities";
    
}

-(void)getsettings{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_settings\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getsettings";
}


//-()
-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
            
            if([requesttype isEqualToString:@"recentfeeds"]){
                
                if([[tempdict objectForKey:@"user_status"] isEqualToString:@"Y"]){
                   
                    isPageRefresing = NO;
                    recentarray = [[tempdict objectForKey:@"recent_posts"] mutableCopy];
                    if([tempdict objectForKey:@"radius"] != [NSNull null])
                        rangeval = [[tempdict objectForKey:@"radius"] floatValue];
                    if([tempdict objectForKey:@"location"] != [NSNull null])
                        address = [tempdict objectForKey:@"location"];
                    [self locationsize:address];
                    if(selectedlocation){
                        
                    }
                    else{
                        appdelegate.nearloclati = [[tempdict objectForKey:@"lat"] floatValue];
                        appdelegate.nearloclong = [[tempdict objectForKey:@"longitude"] floatValue];
                    }
                    filepath = [tempdict objectForKey:@"filePath"];
                    if(appdelegate.sortedkey.length>0){
                        
//                        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:appdelegate.sortedkey ascending:appdelegate.asending];
////                        [NSSortDescriptor sortDescriptorWithKey:appdelegate.sortedkey
////                                                                                     ascending:appdelegate.asending];
//                        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
//                        NSArray *sortedArray = [recentarray sortedArrayUsingDescriptors:sortDescriptors];
//                        recentarray = [sortedArray mutableCopy];
                        
                        NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:appdelegate.sortedkey ascending:appdelegate.asending comparator:^(id obj1, id obj2) {
                            
                            if ([obj1 floatValue] > [obj2 floatValue]) {
                                return (NSComparisonResult)NSOrderedDescending;
                            }
                            if ([obj1 floatValue] < [obj2 floatValue]) {
                                return (NSComparisonResult)NSOrderedAscending;
                            }
                            return (NSComparisonResult)NSOrderedSame;
                        }];
                        NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[recentarray sortedArrayUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]]];
                        recentarray = [sortedArray mutableCopy];
                        
                    }
                    [recentCollectionview reloadData];
                    if(recentarray.count==0){
                        noresultslabel.hidden = NO;
                        //                    noresultslabel.text = [NSString stringWithFormat:@"No recent items found."];
                        noresultslabel.text = [NSString stringWithFormat:@"No results found."];
                    }
                    else
                        noresultslabel.hidden = YES;
                    
                }
                else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [appdelegate logout];
                }
            }
            else if([requesttype isEqualToString:@"trendsfeeds"]){
                
                isPageRefresing = NO;
                if([tempdict objectForKey:@"location"] != [NSNull null])
                    address = [tempdict objectForKey:@"location"];
                [self locationsize:address];
                if(selectedlocation){
                    
                }
                else{
                    appdelegate.nearloclati = [[tempdict objectForKey:@"lat"] floatValue];
                    appdelegate.nearloclong = [[tempdict objectForKey:@"longitude"] floatValue];
                }
                trendarray = [[tempdict objectForKey:@"recent_posts"] mutableCopy];
                filepath = [tempdict objectForKey:@"filePath"];
                
                if(appdelegate.sortedkeyTrends.length>0){
                    NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:appdelegate.sortedkeyTrends ascending:appdelegate.asendingTrends comparator:^(id obj1, id obj2) {
                        
                        if ([obj1 floatValue] > [obj2 floatValue]) {
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        if ([obj1 floatValue] < [obj2 floatValue]) {
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    }];
                    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[trendarray sortedArrayUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]]];
                    trendarray = [sortedArray mutableCopy];
                    
                }
                [trendCollectionview reloadData];
                if(trendarray.count==0){
                    noresultslabel.hidden = NO;
//                    noresultslabel.text = [NSString stringWithFormat:@"Currently have no trends"];
                    noresultslabel.text = [NSString stringWithFormat:@"No results found."];
                }
                else
                    noresultslabel.hidden = YES;
            }
            else if([requesttype isEqualToString:@"getcountries"]){
               
                countryarray = [[tempdict objectForKey:@"country"] mutableCopy];
                locationarray = [countryarray mutableCopy];
                [locationtable reloadData];
                locationtable.hidden = NO;
                CGRect frame = locationtable.frame;
                frame.origin.y = countryfield.frame.origin.y + countryfield.frame.size.height + 1;
                locationtable.frame = frame;
                appdelegate.countryvalarray = [countryarray mutableCopy];
                if(locationarray.count>0)
                    [locationtable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
            }
            else if([requesttype isEqualToString:@"getstates"]){
                
                locationtype = @"state";
                statearray = [tempdict objectForKey:@"state"];
                
                locationarray = [statearray mutableCopy];
                [locationtable reloadData];
                locationtable.hidden = NO;
                CGRect frame = locationtable.frame;
                frame.origin.y = statefield.frame.origin.y + statefield.frame.size.height + 1;
                locationtable.frame = frame;
                if(locationarray.count>0)
                    [locationtable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
            }
            else if([requesttype isEqualToString:@"getcities"] || [requesttype isEqualToString:@"getcitiesstates"]){
                
                locationtype = @"city";
                cityarray = [tempdict objectForKey:@"city"];
                locationarray = [cityarray mutableCopy];
                [locationtable reloadData];
                locationtable.hidden = NO;
                CGRect frame = locationtable.frame;
                frame.origin.y = locationsubview.frame.origin.y + cityfield.frame.size.height + 1;
                locationtable.frame = frame;
                if(locationarray.count>0)
                    [locationtable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
            }
            
            else{
                
                NSMutableDictionary *dict = [[recentarray objectAtIndex:selectedindex] mutableCopy];
                int count = [[[recentarray objectAtIndex:selectedindex] objectForKey:@"vote_count"] intValue];
                if([vote isEqualToString:@"up"]){
                    count = count + 1;
                    [dict setObject:@"up" forKey:@"vote_status"];
                }
                else{
                    count = count - 1;
                    [dict setObject:@"down" forKey:@"vote_status"];
                }
                [dict setObject:[NSString stringWithFormat:@"%d",[[tempdict objectForKey:@"vote_count"] intValue]] forKey:@"vote_count"];
                [recentarray replaceObjectAtIndex:selectedindex withObject:dict];
                [recentCollectionview reloadData];
            }
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

-(IBAction)tabselection:(id)sender{
    
    if([sender tag] == 0){
        
        if(refresh == YES){
            [self getrecentfeeds];
            refresh = NO;
        }
//        filterbtn.hidden = NO;
        tabimage1.hidden = NO;
        tabimage2.hidden = YES;
        tablabel1.textColor = [UIColor colorWithRed:176.0/255 green:92.0/255 blue:36.0/255 alpha:1];
        tablabel2.textColor = [UIColor colorWithRed:34.0/255 green:37.0/255 blue:38.0/255 alpha:1];
        recentview.hidden = NO;
        trendview.hidden = YES;
        [recentCollectionview reloadData];
        if(recentarray.count==0){
            noresultslabel.hidden = NO;
//            noresultslabel.text = [NSString stringWithFormat:@"No recent items found."];
            noresultslabel.text = [NSString stringWithFormat:@"No results found."];
        }
        else
            noresultslabel.hidden = YES;
    }
    else if([sender tag] == 1){
        if(trendarray.count==0 || refresh == YES){
            [self gettrendsfeeds];
            refresh = NO;
        }
//        filterbtn.hidden = YES;
        tabimage1.hidden = YES;
        tabimage2.hidden = NO;
        tablabel2.textColor = [UIColor colorWithRed:176.0/255 green:92.0/255 blue:36.0/255 alpha:1];
        tablabel1.textColor = [UIColor colorWithRed:34.0/255 green:37.0/255 blue:38.0/255 alpha:1];
        recentview.hidden = YES;
        trendview.hidden = NO;
        [trendCollectionview reloadData];
        if(trendarray.count==0){
            noresultslabel.hidden = NO;
//            noresultslabel.text = [NSString stringWithFormat:@"Currently have no trends"];
            noresultslabel.text = [NSString stringWithFormat:@"No results found."];
        }
        else
            noresultslabel.hidden = YES;
    }
}

-(IBAction)poststep1:(id)sender{
   
    PostStep1 *obj = [[PostStep1 alloc] init];
//    obj.tabBarController.hidesBottomBarWhenPushed = YES;    
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)filtersettings:(id)sender{
    
    if(presented_filter == NO){
        
        NSDictionary *locationdict;
        if(selectedlocation)
            locationdict = [selectedlocation copy];
        //[selectedlocation objectForKey:@"lat"],[selectedlocation objectForKey:@"long"];
        else
            
            locationdict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",appdelegate.locationManager.location.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",appdelegate.locationManager.location.coordinate.longitude],@"long", nil];
        objoffilter.locationdetails = [locationdict copy];
//        obj.view.backgroundColor = [UIColor clearColor];
        objoffilter.delegate = self;
        objoffilter.btnstate = @"default";
        if(trendview.hidden == YES)
            objoffilter.filtertype = @"recent";
        else
            objoffilter.filtertype = @"trends";
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
            [self poststep1:nil];
        }];
        
    }
    else if([status isEqualToString:@"dismiss"]){
        
        self.tabBarController.tabBar.hidden = NO;
        [objoffilter dismissViewControllerAnimated:YES completion:^{
            
            presented_filter = NO;
            refresh = YES;
            if(trendview.hidden == YES)
                [self getrecentfeeds];
            else
                [self gettrendsfeeds];
        }];
    }
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    return needarray.count;
    if(collectionView == recentCollectionview)
        return recentarray.count;
    else if(collectionView == trendCollectionview)
        return trendarray.count;
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size;
    if(collectionView == recentCollectionview)
        size = CGSizeMake(([[UIScreen mainScreen] bounds].size.width - 16) / 2, 130);
    else if(collectionView == trendCollectionview)
        size = CGSizeMake(([[UIScreen mainScreen] bounds].size.width - 20) / 3, 155);
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == recentCollectionview){
        
        RecentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecentCell" forIndexPath:indexPath];
        if([[recentarray objectAtIndex:indexPath.row] objectForKey:@"review_count"] != [NSNull null])
            cell.reviewcount.text = [NSString stringWithFormat:@"%d Reviews",[[[recentarray objectAtIndex:indexPath.row] objectForKey:@"review_count"] intValue]];
        if([[recentarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"] != [NSNull null]){
            cell.likecount.text = [NSString stringWithFormat:@"%d",[[[recentarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"]intValue]];
            if([[[recentarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"]intValue]>=20)
                cell.likecount.textColor = [UIColor colorWithRed:58.0/255 green:172.0/255 blue:43.0/255 alpha:1];
                else
                    cell.likecount.textColor = [UIColor colorWithRed:255.0/255 green:127.0/255 blue:0.0/255 alpha:1];
        }
        
        
        if([[recentarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] != [NSNull null])
        {
            if([[[recentarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] isEqualToString:@"up"])
            {
                cell.plusbtn.enabled = NO;
                cell.minusbtn.enabled = YES;
            }
            else if([[[recentarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] isEqualToString:@"down"])
            {
                cell.plusbtn.enabled = YES;
                cell.minusbtn.enabled = NO;
            }
            else{
                cell.plusbtn.enabled = YES;
                cell.minusbtn.enabled = YES;
            }
        }
        else{
            cell.plusbtn.enabled = YES;
            cell.minusbtn.enabled = YES;
        }
        
        if(selectedlocation && [selectedlocation objectForKey:@"lat"] != [NSNull null] && [selectedlocation objectForKey:@"long"] != [NSNull null] ){
            
            CLLocation *locA = [[CLLocation alloc] initWithLatitude:[[selectedlocation objectForKey:@"lat"] doubleValue] longitude:[[selectedlocation objectForKey:@"long"] doubleValue]];
            CLLocation *locB;
            locB = [[CLLocation alloc] initWithLatitude:appdelegate.nearloclati longitude:appdelegate.nearloclong];
            if(appdelegate.locationManager.location)
            {
                
            }
            else{
               // locB = appdelegate.currentLocation;
                [appdelegate.locationManager startUpdatingLocation];
            }
            
            CLLocationDistance distance = [locA distanceFromLocation:locB];
            
            if(-rangeval<distance/1000 && rangeval>distance/1000){
                
                cell.plusbtn.enabled = YES;
                cell.minusbtn.enabled = YES;
            }
            else{
                cell.plusbtn.enabled = NO;
                cell.minusbtn.enabled = NO;
            }
        }
        
        if([[recentarray objectAtIndex:indexPath.row] objectForKey:@"fileName"] != [NSNull null])
        {
            NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[recentarray objectAtIndex:indexPath.row] objectForKey:@"fileName"]];
//            [cell.itemImage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
            [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"recentdefaultimage"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
                
                if(error){
                    cell.itemImage.image = [UIImage imageNamed:@"recentdefaultimage"];
                }
                else{
                    cell.itemImage.image = image;
                }
            }];
        }
        cell.plusbtn.tag = indexPath.row;
        cell.minusbtn.tag = -(indexPath.row+1);
        [cell.plusbtn addTarget:self action:@selector(vote:) forControlEvents:UIControlEventTouchUpInside];
        [cell.minusbtn addTarget:self action:@selector(vote:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else{
        
        TrendsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TrendsCell" forIndexPath:indexPath];
        if([[trendarray objectAtIndex:indexPath.row] objectForKey:@"price"] != [NSNull null]){
//            cell.pricelabel.text = [NSString stringWithFormat:@"$%d",[[[trendarray objectAtIndex:indexPath.row] objectForKey:@"price"] intValue]];
            cell.pricelabel.text =  [NSString stringWithFormat:@"$%@",[[trendarray objectAtIndex:indexPath.row] objectForKey:@"price"]];
            
        }
        if([[trendarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"] != [NSNull null] && [[[trendarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"] intValue] < 50)
            cell.bgimage.image = [UIImage imageNamed:@"bg1"];
        else
            cell.bgimage.image = [UIImage imageNamed:@"bg2"];
        cell.brandlabel.hidden = YES;
        if([[trendarray objectAtIndex:indexPath.row] objectForKey:@"fileName"] != [NSNull null])
        {
            NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[trendarray objectAtIndex:indexPath.row] objectForKey:@"fileName"]];
//            [cell.Trendmage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
            [cell.Trendmage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@""]];
        }
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ProductDetail *obj = [[ProductDetail alloc] init];
    if(collectionView == recentCollectionview)
        obj.productid = [[recentarray objectAtIndex:indexPath.row] objectForKey:@"id"];
    if(collectionView == trendCollectionview)
        obj.productid = [[trendarray objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)vote:(id)sender{
   
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postid;
    if([sender tag]>=0){
        vote = @"up";
        postid = [[recentarray objectAtIndex:[sender tag]] objectForKey:@"id"];
        selectedindex = [sender tag];
    }
    else{
        vote = @"down";
        postid = [[recentarray objectAtIndex:(-1*([sender tag] + 1))] objectForKey:@"id"];
        selectedindex = -1*([sender tag] + 1);
    }
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trend_vote\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"vote\": \"%@\",\"post_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,vote,postid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
//    [self startLoader:@"Loading..."];
    requesttype = @"vote";
}

-(void)refresh:(NSNotification *) notification
{
    
    if(notification.object){
        
        if([notification.object isKindOfClass:[NSString class]]){
           
            NSString *str = (NSString *)notification.object;
            if([str isEqualToString:@"currentloc"])
                selectedlocation = nil;
        }
        else{
            selectedlocation = notification.object;
            address = [selectedlocation objectForKey:@"location"];
            appdelegate.changedlocation = nil;
            otherlocation = YES;
        }
    }
    refresh = YES;
    
}

-(void)refreshonlocation:(NSNotification *) notification
{
    if(trendview.hidden == YES)
        [self getrecentfeeds];
    else
        [self gettrendsfeeds];
    refresh = YES;
    
}


#pragma mark - UIScrollViewDelegate

//- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView {
//    //logic here
//   // NSLog(@"%@",activeScrollView);
//    
//}
//- (void)scrollViewDidScroll:(UIScrollView *)callerScrollView
//{
//    BOOL isScrolling = (trendCollectionview.isDragging || trendCollectionview.isDecelerating);
//
//    if (callerScrollView == recentCollectionview)
//    {
//        NSLog(@"collection view is scrolled");
//        
//    }
//      if (self.lastContentOffset > callerScrollView.contentOffset.y)
//    {
//      //  NSLog(@"Scrolling Up");
//        if (isScrolling){
//            // Your code here.....
//            //self.topbarview.hidden = NO;
//        }
//        
//    }
//    else if (self.lastContentOffset < callerScrollView.contentOffset.y)
//    {
//      //  NSLog(@"Scrolling Down");
//        if (isScrolling){
//            // Your code here.....
//           // self.topbarview.hidden = YES;
//        }
//    }
//    
//    self.lastContentOffset = callerScrollView.contentOffset.y;
//}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView ==recentCollectionview || scrollView ==trendCollectionview ) {
        CGRect frame = self.topbarview.frame;
       
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
        [self.topbarview setFrame:frame];
        
        
        if(scrollView == trendCollectionview){
            
            CGRect frame2=trendview.frame;
           
            frame2.origin.y =self.topbarview.frame.origin.y +self.topbarview.frame.size.height;
            CGRect rtframe2= self.rtBottomView.frame;
            frame2.size.height= rtframe2.origin.y- frame2.origin.y;
          
            trendview.frame =frame2;
        }
        else if (scrollView == recentCollectionview) {
            
            CGRect frame1=recentview.frame;
           
            frame1.origin.y =self.topbarview.frame.origin.y +self.topbarview.frame.size.height;
            CGRect rtframe= self.rtBottomView.frame;
            frame1.size.height= rtframe.origin.y- frame1.origin.y;
           
            recentview.frame =frame1;
        }
        
        

        [self updateBarButtonItems:(1 - framePercentageHidden)];
        self.previousScrollViewYOffset = scrollOffset;

    }
   }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   if (scrollView ==recentCollectionview || scrollView ==trendCollectionview ) {
       [self stoppedScrolling];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
     if (scrollView ==recentCollectionview || scrollView ==trendCollectionview ) {
        if (!decelerate) {
            [self stoppedScrolling];
        }
    }
    
}

- (void)stoppedScrolling
{
    CGRect frame = self.topbarview.frame;
    if (frame.origin.y < 0) {
        [self animateNavBarTo:-(frame.size.height - 21)];
           }
    else{
        
        CGRect frame1=recentview.frame;
        frame1.origin.y =self.topbarview.frame.origin.y +self.topbarview.frame.size.height;
        CGRect rtframe= self.rtBottomView.frame;
        frame1.size.height= rtframe.origin.y- frame1.origin.y;
        recentview.frame =frame1;
        
        
        CGRect frame2=trendview.frame;
        frame2.origin.y =self.topbarview.frame.origin.y +self.topbarview.frame.size.height;
        CGRect rtframe2= self.rtBottomView.frame;
        frame2.size.height= rtframe2.origin.y- frame2.origin.y;
        trendview.frame= frame2;

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
    self.recentBtn.alpha= alpha;
    self.lblRecent.alpha= alpha;
    self.lblTrends.alpha =alpha;
    self.topbarview.tintColor = [self.topbarview.tintColor colorWithAlphaComponent:alpha];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.topbarview.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.topbarview setFrame:frame];
        
        CGRect frame1=recentview.frame;
        frame1.origin.y =self.topbarview.frame.origin.y +self.topbarview.frame.size.height;
        CGRect rtframe= self.rtBottomView.frame;
        frame1.size.height= rtframe.origin.y- frame1.origin.y;
        recentview.frame =frame1;
        
        
        
        CGRect frame2=trendview.frame;
        frame2.origin.y =self.topbarview.frame.origin.y +self.topbarview.frame.size.height;
        CGRect rtframe2= self.rtBottomView.frame;
        frame2.size.height= rtframe2.origin.y- frame2.origin.y;
        trendview.frame=frame2;

      
        
        [self updateBarButtonItems:alpha];
    }];
    

  
}
#pragma mark - Label  Slider

- (void) configureLabelSlider
{
//    self.labelSlider.backgroundColor = [UIColor orangeColor];
    self.labelSlider.minimumValue = 0;
    self.labelSlider.maximumValue = 100;
    
    self.labelSlider.lowerValue = 0;
    self.labelSlider.upperValue = 100;
    
    self.labelSlider.minimumRange = 10;
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    
    CGPoint lowerCenter;
    lowerCenter.x = (self.labelSlider.lowerCenter.x + self.labelSlider.frame.origin.x);
    lowerCenter.y = (self.labelSlider.center.y - 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (self.labelSlider.upperCenter.x + self.labelSlider.frame.origin.x);
    upperCenter.y = (self.labelSlider.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.upperValue];
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}

#pragma mark -
#pragma mark - location settings 

-(IBAction)locationselection:(id)sender{
    
    if([sender tag] == 0){
        
        locationtype = @"country";
        
        if(locationtable.hidden == YES){
            
            if(appdelegate.countryvalarray.count == 0){
                [self getcountries];
                return;
            }
            
            else{
                countryarray = [appdelegate.countryvalarray mutableCopy];
                locationarray = [countryarray mutableCopy];
                locationtable.hidden = NO;
                [locationtable reloadData];
                CGRect frame = locationtable.frame;
                frame.origin.y = countryfield.frame.origin.y + countryfield.frame.size.height + 1;
                locationtable.frame = frame;
            }
        }
        else{
            locationtable.hidden = YES;
            return;
        }
        
    }
    else if([sender tag] == 1){

        locationtype = @"city";
        if(locationtable.hidden == YES){
                
                if(appdelegate.countryvalarray.count == 0 || !country_id){
                    
                    UIButton *btn = [[UIButton alloc] init];
                    btn.tag = 0;
                    [self locationselection:btn];
                    return;
                }
                else{
                    if([country_id isEqualToString:@"3"] && statearray.count == 0){
                       
                        UIButton *btn = [[UIButton alloc] init];
                        btn.tag = 2;
                        [self locationselection:btn];
                        return;
                        
                    }
                    else{
                       
                        locationarray = [cityarray mutableCopy];
                        [locationtable reloadData];
                        if(cityarray.count == 0){
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There is no cities in your selected country." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            return;
                        }
                        
                        locationtable.hidden = NO;
                        CGRect frame = locationtable.frame;
                        frame.origin.y = locationsubview.frame.origin.y + cityfield.frame.size.height + 1;
                        locationtable.frame = frame;
                    }
                }
            }
        else{
            locationtable.hidden = YES;
            return;
        }
    }
    else if([sender tag] == 2){
        
        if(appdelegate.countryvalarray.count == 0 || !country_id){
            
            UIButton *btn = [[UIButton alloc] init];
            btn.tag = 0;
            [self locationselection:btn];
            return;
        }
        else{
            locationtype = @"state";
            locationarray = [statearray mutableCopy];
            [locationtable reloadData];
            if(statearray.count == 0){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There is no states in your selected country." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            locationtable.hidden = NO;
            CGRect frame = locationtable.frame;
            frame.origin.y = statefield.frame.origin.y + statefield.frame.size.height + 1;
            locationtable.frame = frame;
        }
    }
    else if([sender tag] == 5){
        
        if(selectedcityindex != -1){
            [locationview removeFromSuperview];
            [appdelegate clearAllFilter];
            selectedlocation = [locationarray objectAtIndex:selectedcityindex];
            appdelegate.changedlocation = [selectedlocation mutableCopy];
            appdelegate.statevalarray = [statearray mutableCopy];
            appdelegate.cityvalarray = [cityarray mutableCopy];
            if(trendview.hidden == YES)
                [self getrecentfeeds];
            else
                [self gettrendsfeeds];
//            address = [NSString stringWithFormat:@"%@/%@",[selectedlocation objectForKey:@"city"],countryfield.text];
            [self locationsize:address];
            refresh = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
            return;
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Select a location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            UIButton *btn = [[UIButton alloc] init];
            btn.tag = 1;
            [self locationselection:btn];
            return;
        }
    }
    else if([sender tag] == 6){
        
        [appdelegate.locationManager startUpdatingLocation];
        [locationview removeFromSuperview];
        [appdelegate clearAllFilter];
        selectedlocation = nil;
        selectedcityindex = -1;
        appdelegate.changedlocation = nil;
        if(trendview.hidden == YES)
            [self getrecentfeeds];
        else
            [self gettrendsfeeds];
//        address = [NSString stringWithFormat:@"%@/%@",[selectedlocation objectForKey:@"city"],countryfield.text];
        [self getlocationdetails];
        refresh = YES;
        country_id = nil;
        countryfield.text = nil;
        city_id = nil;
        cityfield.text = nil;
        if(locationtable.hidden == NO)
            locationtable.hidden = YES;
        NSString *current = @"currentloc";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:current];
        return;
        
        
    }
    else{
        
        if(![locationview isDescendantOfView:appdelegate.window]) {
            [appdelegate.window addSubview:locationview];
        } else {
            [locationview removeFromSuperview];
        }
        return;
    }
    [locationtable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger )section{
    
    return locationarray.count;
    //    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier =@"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    if([locationtype isEqualToString:@"country"])
        cell.textLabel.text = [[locationarray objectAtIndex:indexPath.row] objectForKey:@"name"];
    else if([locationtype isEqualToString:@"state"])
        cell.textLabel.text = [[statearray objectAtIndex:indexPath.row] objectForKey:@"state"];
    else
        cell.textLabel.text = [[locationarray objectAtIndex:indexPath.row] objectForKey:@"city"];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([locationtype isEqualToString:@"country"]){
        
        country_id = [[locationarray objectAtIndex:indexPath.row] objectForKey:@"id"];
        countryfield.text = [[locationarray objectAtIndex:indexPath.row] objectForKey:@"name"];
        CGRect frame = locationbgimage.frame;
        CGRect frame1 = locationsubview.frame;

        if([country_id isEqualToString:@"3"]){
            
            locationtype = @"state";
            frame.size.height = 248;
            frame1.origin.y = 228;
            [self getstates];
        }
        else{
            [self getcities];
            locationtype = @"city";
            frame.size.height = 200;
            frame1.origin.y = 180;

        }
        locationbgimage.frame = frame;
        locationsubview.frame = frame1;
        statefield.text = nil;
        city_id = @"";
        cityfield.text = @"";
//        selectedlocation = nil;
        selectedcityindex = -1;
        locationtable.hidden = YES;
    }
    else if([locationtype isEqualToString:@"state"]){
        
        statefield.text = [[statearray objectAtIndex:indexPath.row] objectForKey:@"state"];
        [self getcitiesfromstates];
        locationtype = @"city";
        city_id = @"";
        cityfield.text = @"";
//        selectedlocation = nil;
        selectedcityindex = -1;
        locationtable.hidden = YES;
    }
    else{
        
        city_id = [[locationarray objectAtIndex:indexPath.row] objectForKey:@"id"];
        cityfield.text = [[locationarray objectAtIndex:indexPath.row] objectForKey:@"city"];
        locationtable.hidden = YES;
//        selectedlocation = [locationarray objectAtIndex:indexPath.row];
        selectedcityindex = indexPath.row;
    }
//    NSDictionary *dict = [locationarray objectAtIndex:indexPath.row];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"DROPTABLEVALUE" object:nil userInfo:dict];
//    [self.navigationController popViewControllerAnimated:YES];
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
    MBProgressHUD *objOfHUD;
    if(![locationview isDescendantOfView:appdelegate.window])
        objOfHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    else
        objOfHUD = [MBProgressHUD showHUDAddedTo:locationview animated:YES];
    objOfHUD.labelText = title;
    
}
-(void) stoploader{
    
    if(![locationview isDescendantOfView:appdelegate.window])
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    else
        [MBProgressHUD hideHUDForView:locationview animated:YES];
}
-(void)stopLoader:(NSNotification *) notification{
    
    if(![locationview isDescendantOfView:appdelegate.window])
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    else
        [MBProgressHUD hideHUDForView:locationview animated:YES];
}

@end
