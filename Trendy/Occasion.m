//
//  Occasion.m
//  Trendy
//
//  Created by NewAgeSMB on 8/5/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "Occasion.h"
#import "MBProgressHUD.h"
#import "OccasionCell.h"
#import "AppDelegate.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "OccasionDetail.h"
#import "ODRefresh/ODRefreshControl.h"

@interface Occasion (){
    
    IBOutlet UICollectionView *occasionview;
    NSArray *occasionarray;
    NSString *requesttype, *filepath, *address;
    AppDelegate *appdelegate;
    IBOutlet UILabel *noresultslabel, *filteredlabel;
    IBOutlet UIView *filterview;
    IBOutlet UIButton *filterbtn, *locationbtn;
    IBOutlet UIImageView *filterimage, *locationbgimage;
    
    IBOutlet UIView *locationview, *locationsubview;
    IBOutlet UITextField *countryfield, *cityfield, *statefield;
    IBOutlet UITableView *locationtable;
    NSArray *locationarray, *countryarray, *cityarray, *statearray;
    NSString *locationtype, *country_id, *city_id;
    NSDictionary *selectedlocation;
    BOOL isPageRefresing, refresh;
    NSUInteger selectedcityindex;
}

@end

@implementation Occasion

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"REFRESH"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshonlocation:) name:@"REFRESHONLOCATION"  object:nil];
    UINib *cellNib = [UINib nibWithNibName:@"OccasionCell" bundle:nil];
    [occasionview registerNib:cellNib forCellWithReuseIdentifier:@"OccasionCell"];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    selectedcityindex = -1;
    if(appdelegate.changedlocation){
        
        selectedlocation = [appdelegate.changedlocation mutableCopy];
        [self setlocationviews];
    }
    [self getoccasions];
    [self getlocationdetails];
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:occasionview];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    occasionview.alwaysBounceVertical = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [locationview removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(address || appdelegate.changedlocation){
        
        locationtable.hidden = YES;
        if(refresh == YES && appdelegate.changedlocation){
            locationtable.hidden = YES;
            selectedlocation = [appdelegate.changedlocation mutableCopy];
//            countryfield.text =
//            statefield.text =
//            city_id =
//            cityfield.text  =
            [self setlocationviews];
            locationtable.hidden = YES;
        }
        else if(refresh == NO){
            selectedlocation = [appdelegate.changedlocation mutableCopy];
            
            [self setlocationviews];
        }
        else if(refresh == YES)
            [self getoccasions];
        [self locationsize:address];
        //        [self getrecentfeeds];
        refresh = NO;
    }
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
    
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
        
        if(country_id)
            cityarray = [appdelegate.cityvalarray mutableCopy];
        locationtype = @"city";
        frame.size.height = 200;
        frame1.origin.y = 180;
        
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
        [self getoccasions];
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
        filteredlabel.text = input;
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

-(void)getoccasions{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    if(selectedlocation)
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_occasion_list\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[selectedlocation objectForKey:@"lat"],[selectedlocation objectForKey:@"long"]];
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
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_occasion_list\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%f\",\"long\": \"%f\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,lat,lng];
    }
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getoccasion";
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

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
           
            if([requesttype isEqualToString:@"getoccasion"]){
                if([tempdict objectForKey:@"location"] != [NSNull null])
                    address = [tempdict objectForKey:@"location"];
                [self locationsize:address];
                isPageRefresing = NO;
                occasionarray = [[tempdict objectForKey:@"occasion_list"] mutableCopy];
                filepath = [tempdict objectForKey:@"filePath"];
                [occasionview reloadData];
                if(occasionarray.count==0){
                    noresultslabel.hidden = NO;
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
    
    CGSize size = CGSizeMake(([[UIScreen mainScreen] bounds].size.width - 20) / 3, 141);
    return size;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        
        OccasionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OccasionCell" forIndexPath:indexPath];
        if([[occasionarray objectAtIndex:indexPath.row] objectForKey:@"name"] != [NSNull null])
            cell.brandname.text = [[occasionarray objectAtIndex:indexPath.row] objectForKey:@"name"];
        if([[occasionarray objectAtIndex:indexPath.row] objectForKey:@"image"] != [NSNull null])
        {
            NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[occasionarray objectAtIndex:indexPath.row] objectForKey:@"image"]];

            [cell.occasionImage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"Athletic"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
                
                if(error){
                    cell.occasionImage.image = [UIImage imageNamed:@"Athletic"];
                }
                else{
                    cell.occasionImage.image = image;
                }
            }];
        }
        return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    OccasionDetail *obj = [[OccasionDetail alloc]init];
    obj.occasionid = [[occasionarray objectAtIndex:indexPath.row] objectForKey:@"occasion_id"];
    obj.occasionname = [[occasionarray objectAtIndex:indexPath.row] objectForKey:@"name"];
    obj.selectedlocation = selectedlocation;
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
    [self getoccasions];
    refresh = YES;
    
}


#pragma mark -
#pragma mark - location settings

/*-(IBAction)locationselection:(id)sender{
    
    if([sender tag] == 0){
        
        locationtype = @"country";
        
        if(locationtable.hidden == YES){
            
            if(appdelegate.countryvalarray.count == 0)
                [self getcountries];
            
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
        else
            locationtable.hidden = YES;
        
    }
    else if([sender tag] == 1){
        
        locationtype = @"city";
        if(locationtable.hidden == YES){
            
            if(locationtable.hidden == YES){
                
                if(appdelegate.countryvalarray.count == 0 || !country_id){
                    
                    UIButton *btn = [[UIButton alloc] init];
                    btn.tag = 0;
                    [self locationselection:btn];
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
                    frame.origin.y = cityfield.frame.origin.y + cityfield.frame.size.height + 1;
                    locationtable.frame = frame;
                }
            }
        }
        else
            locationtable.hidden = YES;
    }
    else if([sender tag] == 5){
        
        if(selectedlocation){
            [locationview removeFromSuperview];
            appdelegate.changedlocation = [selectedlocation mutableCopy];
            [self getoccasions];
            
//            address = [NSString stringWithFormat:@"%@/%@",[selectedlocation objectForKey:@"city"],countryfield.text];
            [self locationsize:address];
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Select a location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            UIButton *btn = [[UIButton alloc] init];
            btn.tag = 1;
            [self locationselection:btn];
        }
    }
    else{
        
        if(![locationview isDescendantOfView:appdelegate.window]) {
            [appdelegate.window addSubview:locationview];
        } else {
            [locationview removeFromSuperview];
        }
    }
}*/

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
        
        if(locationtable.hidden == YES){
            
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
        else{
            locationtable.hidden = YES;
            return;
        }

    
    }
    else if([sender tag] == 5){
        
        if(selectedcityindex != -1){
            [locationview removeFromSuperview];
            selectedlocation = [locationarray objectAtIndex:selectedcityindex];
            appdelegate.changedlocation = [selectedlocation mutableCopy];
            appdelegate.statevalarray = [statearray mutableCopy];
            appdelegate.cityvalarray = [cityarray mutableCopy];
            [appdelegate clearAllFilter];
            [self getoccasions];
//            address = [NSString stringWithFormat:@"%@/%@",[selectedlocation objectForKey:@"city"],countryfield.text];
            [self locationsize:address];
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
//        address = [NSString stringWithFormat:@"%@/%@",[selectedlocation objectForKey:@"city"],countryfield.text];
        [self getlocationdetails];
        [self getoccasions];
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
            //[self locationsize:address];
            //            CGSize textsize = [self locationsize:address];
            
        }
    }];
    
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
        locationtype = @"state";
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
