//
//  SocialFeeds.m
//  Trendy
//
//  Created by NewAgeSMB on 8/7/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "SocialFeeds.h"
#import "SocialCell.h"
#import "ServerRequest.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "ODRefresh/ODRefreshControl.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MHFacebookImageViewer.h"
#import "ProductDetail.h"
#import "TrackingCell.h"
#import "ProfileView.h"
#import "CustomBadge.h"
#import "NotificationCell.h"

@interface SocialFeeds ()<delegaterequest>{
    
    IBOutlet UICollectionView *socialCollectionview;
    NSString *requesttype;
    AppDelegate *appdelegate;
    NSMutableArray *socialarray, *socialoriginalarray;
    IBOutlet UILabel *filteredlabel, *noresultslabel, *nouserlabel, *nonotificatnlabel;
    IBOutlet UIImageView *filterimage;
    IBOutlet UIView *filterview;
    NSString *addressName, *city, *administrativeArea, *address, *filepath, *userfilepath,*filePath_post, *vote;
    NSInteger selectedindex;
    IBOutlet UIButton *filterbtn, *locationbtn;
    BOOL refresh,isPageRefresing;
    
    IBOutlet UIView *locationview;
    IBOutlet UITextField *countryfield, *cityfield;
    IBOutlet UITableView *locationtable;
    NSArray *locationarray;
    NSString *locationtype;
    IBOutlet UIView *searchview,*searchresultsview, *notificationview;
    IBOutlet UITableView *searchtable, *notificationstable;
    IBOutlet UITextField *searchField;
    NSArray *searcharray, *searchoriginalarray, *notificationsarray;
    CustomBadge *badge;
    IBOutlet UIButton *notificatnbtn;
    BOOL refreshnotifications, gotpush, loaded;
    int numberOfCellInRow;
}
@property (nonatomic) CGFloat previousScrollViewYOffset;
@end

@implementation SocialFeeds

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"REFRESHPUSH"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"REFRESHSOCIAL"  object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINib *cellNib = [UINib nibWithNibName:@"SocialCell" bundle:nil];
    [socialCollectionview registerNib:cellNib forCellWithReuseIdentifier:@"SocialCell"];
    socialarray = [[NSMutableArray alloc] init];
    [self getsocialfeeds];

    //    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
//    [geoCoder reverseGeocodeLocation:appdelegate.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
//        for (CLPlacemark * placemark in placemarks) {
//            addressName = [placemark name];
//            city = [placemark locality]; // locality means "city"
//            administrativeArea = [placemark administrativeArea]; // which is "state" in the U.S.A.
//            NSLog( @"name is %@ and locality is %@ and administrative area is %@", addressName, city, administrativeArea );
//            address = [NSString stringWithFormat:@"%@/%@",addressName,city];
//            [self locationsize:address];
//            //            CGSize textsize = [self locationsize:address];
//            
//        }
//    }];
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:socialCollectionview];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tag = 0;
    socialCollectionview.alwaysBounceVertical = YES;
    
    ODRefreshControl *refreshControl1 = [[ODRefreshControl alloc] initInScrollView:notificationstable];
    [refreshControl1 addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    refreshControl1.tag = 1;
    notificationstable.alwaysBounceVertical = YES;
    
    refreshnotifications = NO;
   
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
    if(refresh == YES){
        [self getsocialfeeds];
        refresh = NO;
    }
    if(refreshnotifications == YES){
        
        [self notifications:nil];
        refreshnotifications = NO;
    }
    
    NSString *count = [NSString stringWithFormat:@"%ld",(long)[UIApplication sharedApplication].applicationIconBadgeNumber];
    if([count integerValue] != 0){
        
        if([badge isDescendantOfView:self.socialTopview]) {
            
            [badge removeFromSuperview];
            badge = nil;
        }
        
        badge = [CustomBadge customBadgeWithString:count];
        CGPoint point = CGPointMake(23, 24);
        CGSize badgesize = CGSizeMake(badge.frame.size.width, badge.frame.size.height);
        CGRect rect = CGRectMake(point.x, point.y, badgesize.width, badgesize.height);
        [badge setFrame:rect];
        [self.socialTopview addSubview:badge];
    }
  
}
-(void)viewDidDisappear:(BOOL)animated{
//    CGRect frameatreset= self.socialTopview.frame;
//    frameatreset.origin.y=0.0;
//    self.socialTopview.frame= frameatreset;
//    CGRect frameatreset1= socialCollectionview.frame;
//    frameatreset1.origin.y= self.socialTopview.frame.origin.y + self.socialTopview.frame.size.height;
//    socialCollectionview.frame= frameatreset1;
//   notificatnbtn.alpha= 1;
//   
//    
//    [socialCollectionview setContentOffset:CGPointMake(0, 0) animated:YES];
    
    
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
        if(refreshControl.tag == 0)
            [self getsocialfeeds];
        else
            [self getallnotifications];
        isPageRefresing = YES;
    }
    
    
}
-(void)locationsize:(NSString *)input{
    
//    if(appdelegate.changedlocation)
//        input = [NSString stringWithFormat:@"%@/%@",[selectedlocation objectForKey:@"city"],[selectedlocation objectForKey:@"country_name"]];
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
    filteredlabel.text = address;
    filteredlabel.frame = CGRectMake(0, 10, locationsize.width, 26);
    filterimage.frame = CGRectMake(locationsize.width + 3, 12, 17, 22);
    CGRect framelocation = filterview.frame;
    framelocation.size.width = locationsize.width + 20;
    filterview.frame = framelocation;
    filterview.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, framelocation.origin.y+(framelocation.size.height)/2);
    locationbtn.frame = CGRectMake(0, 0, framelocation.size.width, 45);
    //    return locationsize;
}

-(void)getsocialfeeds{
    
    float lat, lng;
    lat = appdelegate.locationManager.location.coordinate.latitude;
    lng = appdelegate.locationManager.location.coordinate.longitude;
    if(appdelegate.locationManager.location)
    {
        
    }
    else{
        
        [appdelegate.locationManager startUpdatingLocation];
    }
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"social\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%f\",\"long\": \"%f\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,lat,lng];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"socialfeeds";
}

-(void)searchuser:(NSString *)str{

    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"search_user\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"key_word\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,str];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"searchuser";
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
           
            if([requesttype isEqualToString:@"socialfeeds"]){
                
                isPageRefresing = NO;
                socialarray = [[tempdict objectForKey:@"social_list"] mutableCopy];
                socialoriginalarray = [socialarray mutableCopy];
                filepath = [tempdict objectForKey:@"filePath"];
                [socialCollectionview reloadData];
                if([[tempdict objectForKey:@"notification_unread_count"] integerValue]>0)
                {
                    if([badge isDescendantOfView:self.socialTopview]) {

                        [badge removeFromSuperview];
                        badge = nil;
                    }
                    badge = [CustomBadge customBadgeWithString:[tempdict objectForKey:@"notification_unread_count"]];
                    CGPoint point = CGPointMake(23, 24);
                    CGSize badgesize = CGSizeMake(badge.frame.size.width, badge.frame.size.height);
                    CGRect rect = CGRectMake(point.x, point.y, badgesize.width, badgesize.height);
                    [badge setFrame:rect];
                    [self.socialTopview addSubview:badge];
                }
                else if([badge isDescendantOfView:self.socialTopview]) {
                    [badge removeFromSuperview];
                    badge = nil;
                }
                if(socialarray.count==0){
                    noresultslabel.hidden = NO;
                    //                    noresultslabel.text = [NSString stringWithFormat:@"No recent items found."];
                    noresultslabel.text = [NSString stringWithFormat:@"No results found."];
                }
                else
                    noresultslabel.hidden = YES;
            }
            else if([requesttype isEqualToString:@"searchuser"]){
                
                searchoriginalarray = [[tempdict objectForKey:@"data"] mutableCopy];
                userfilepath = [tempdict objectForKey:@"filePath"];
                searcharray = [searchoriginalarray mutableCopy];
                [searchtable reloadData];
                if(searcharray.count==0){
                    nouserlabel.hidden = NO;
                    nouserlabel.text = [NSString stringWithFormat:@"No users found."];
                    searchtable.hidden = YES;
                }
                else{
                    nouserlabel.hidden = YES;
                    searchtable.hidden = NO;
                }
                [self setsearchtableframe];
//                    isPageRefresing = NO;
//                    socialarray = [[tempdict objectForKey:@"social_list"] mutableCopy];
//                    socialoriginalarray = [socialarray mutableCopy];
//                    filepath = [tempdict objectForKey:@"filePath"];
//                    [socialCollectionview reloadData];
//
                }
            else if([requesttype isEqualToString:@"notifications"]){
                
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                isPageRefresing = NO;
                notificationsarray = [[tempdict objectForKey:@"notifications"] mutableCopy];
                userfilepath = [tempdict objectForKey:@"filePath"];
                filePath_post = [tempdict objectForKey:@"filePath_post"];
                [notificationstable reloadData];
                loaded = YES;
                if(notificationsarray.count==0){
                    nonotificatnlabel.hidden = NO;
                    nonotificatnlabel.text = [NSString stringWithFormat:@"No results found."];
                }
                else
                    nonotificatnlabel.hidden = YES;
                if([badge isDescendantOfView:self.socialTopview]) {
                    [badge removeFromSuperview];
                    badge = nil;
                }
            }
            else if([requesttype isEqualToString:@"track_response"]){
                
//                [self notifications:nil];
                [self getallnotifications];
            }
            
            else{
                
                NSMutableDictionary *dict = [[socialarray objectAtIndex:selectedindex] mutableCopy];
                int count = [[[socialarray objectAtIndex:selectedindex] objectForKey:@"vote_count"] intValue];
                if([vote isEqualToString:@"up"]){
                    count = count + 1;
                    [dict setObject:@"up" forKey:@"vote_status"];
                }
                else{
                    count = count - 1;
                    [dict setObject:@"down" forKey:@"vote_status"];
                }
                [dict setObject:[NSString stringWithFormat:@"%d",[[tempdict objectForKey:@"vote_count"] intValue]] forKey:@"vote_count"];
                [socialarray replaceObjectAtIndex:selectedindex withObject:dict];
                [socialCollectionview reloadData];
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

-(IBAction)notifications:(id)sender{
    
    [self.view endEditing:YES];
    searchresultsview.hidden = YES;
    if(notificationview.hidden == YES){
        
        notificationview.hidden = NO;
        if(loaded == NO){
            [self getallnotifications];
            return;
        }
        if(refreshnotifications == NO && gotpush == NO){
            
        }
        else{
            
            [self getallnotifications];
        }
        
    }
    else{
        
        notificationview.hidden = YES;
    }
}

-(void)getallnotifications{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"notifications\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"notifications";
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    return needarray.count;
    if(collectionView == socialCollectionview)
        return socialarray.count;
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            numberOfCellInRow=3;
        }
        CGFloat cellWidth =  [[UIScreen mainScreen] bounds].size.width/numberOfCellInRow;
        return CGSizeMake(cellWidth-10, cellWidth-10);
    }

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    CGSize size;
//    if(collectionView == socialCollectionview)
//        size = CGSizeMake(([[UIScreen mainScreen] bounds].size.width - 16) / 2, 130);
//    
//    return size;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == socialCollectionview){
        SocialCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SocialCell" forIndexPath:indexPath];
        
//        if([[socialarray objectAtIndex:indexPath.row] objectForKey:@"review_count"] != [NSNull null])
//            
//            cell.reviewcount.text = [NSString stringWithFormat:@"%d Reviews",[[[socialarray objectAtIndex:indexPath.row] objectForKey:@"review_count"] intValue]];
       
        if([[socialarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"] != [NSNull null]){
            
            cell.likecount.text = [NSString stringWithFormat:@"%d",[[[socialarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"]intValue]];
            
            if([[[socialarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"]intValue]<20)
                cell.likecount.textColor = [UIColor orangeColor];
//                cell.likecount.textColor = [UIColor colorWithRed:58.0/255 green:172.0/255 blue:43.0/255 alpha:1];
            
            else if([[[socialarray objectAtIndex:indexPath.row] objectForKey:@"vote_count"]intValue]>=20)
                
                cell.likecount.textColor = [UIColor colorWithRed:58.0/255 green:172.0/255 blue:43.0/255 alpha:1];
//                cell.likecount.textColor = [UIColor colorWithRed:58.0/255 green:172.0/255 blue:43.0/255 alpha:1];
            else
                cell.likecount.textColor = [UIColor colorWithRed:255.0/255 green:127.0/255 blue:0.0/255 alpha:1];
        }
        
        
        if([[socialarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] != [NSNull null])
        {
            if([[[socialarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] isEqualToString:@"up"])
            {
                cell.plusbtn.enabled = NO;
                cell.minusbtn.enabled = NO;
            }
            else if([[[socialarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] isEqualToString:@"down"])
            {
                cell.plusbtn.enabled = NO;
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
        
        if([[socialarray objectAtIndex:indexPath.row] objectForKey:@"user_name"] != [NSNull null]){
            
        //    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        //    cell.namelabel.attributedText = [[NSAttributedString alloc] initWithString:[[socialarray objectAtIndex:indexPath.row] objectForKey:@"user_name"] attributes:underlineAttribute];
          //  cell.BottomNameLbl.attributedText= [[NSAttributedString alloc] initWithString:[[socialarray objectAtIndex:indexPath.row] objectForKey:@"user_name"] attributes:underlineAttribute];
            cell.BottomNameLbl.text = [NSString stringWithFormat:@"%@",[[socialarray objectAtIndex:indexPath.row] objectForKey:@"user_name"]];

        }
        
        else{
            //  cell.namelabel.text = @"";
            
        }
        
        
        if([[socialarray objectAtIndex:indexPath.row] objectForKey:@"fileNAME"] != [NSNull null])
        {
            NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[socialarray objectAtIndex:indexPath.row] objectForKey:@"fileNAME"]];

            [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"recentdefaultimage"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
                
                if(error){
                    cell.itemImage.image = [UIImage imageNamed:@"recentdefaultimage"];
                }
                else{
                    cell.itemImage.image = image;
                }
            }];
        }
        
//        if([[socialarray objectAtIndex:indexPath.row] objectForKey:@"current_location"] != [NSNull null] && [[[socialarray objectAtIndex:indexPath.row] objectForKey:@"current_location"] isEqualToString:@"Y"]){
//            
//            cell.subview.hidden = NO;
//            CGRect itemimageframe = cell.itemImage.frame;
//            NSLog(@"--cell.subview.frame.origin.y - 8 --- %f",cell.subview.frame.origin.x - 8);
//            itemimageframe.size.width = cell.subview.frame.origin.x - 8;
////            cell.itemImage.frame = itemimageframe;
//            [cell.itemImage setFrame:itemimageframe];
//        }
//        else{
        
            cell.subview.hidden = YES;
//            CGRect itemimageframe = cell.itemImage.frame;
//            itemimageframe.size.width = cell.frame.size.width - 16;
//            cell.itemImage.frame = itemimageframe;
//        }
        
        cell.plusbtn.tag = indexPath.row;
        cell.minusbtn.tag = -(indexPath.row+1);
        [cell.plusbtn addTarget:self action:@selector(vote:) forControlEvents:UIControlEventTouchUpInside];
        [cell.minusbtn addTarget:self action:@selector(vote:) forControlEvents:UIControlEventTouchUpInside];
        cell.namebtn.tag = indexPath.row;
        [cell.namebtn addTarget:self action:@selector(profile:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ProductDetail *obj = [[ProductDetail alloc] init];
    if(collectionView == socialCollectionview)
        obj.productid = [[socialarray objectAtIndex:indexPath.row] objectForKey:@"post_id"];
    obj.producttype = @"Social";
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)profile:(id)sender{
   
    ProfileView *obj = [[ProfileView alloc] init];
    obj.userid = [[socialarray objectAtIndex:[sender tag]] objectForKey:@"following"];
    obj.navigated = YES;
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)vote:(id)sender{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postid;
    if([sender tag]>=0){
        vote = @"up";
        postid = [[socialarray objectAtIndex:[sender tag]] objectForKey:@"id"];
        selectedindex = [sender tag];
    }
    else{
        vote = @"down";
        postid = [[socialarray objectAtIndex:(-1*([sender tag] + 1))] objectForKey:@"id"];
        selectedindex = -1*([sender tag] + 1);
    }
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trend_vote\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"vote\": \"%@\",\"post_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,vote,postid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
//    [self startLoader:@"Loading..."];
    requesttype = @"vote";
}

-(void)refresh: (NSNotification *) notification
{
    refresh = YES;
    gotpush = YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView ==socialCollectionview ) {
        CGRect frame = self.socialTopview.frame;
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
                NSLog(@"test loaded");

                // react to dragging up
            }

        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            frame.origin.y = -size;
        } else {
            frame.origin.y = MIN(0, MAX(-size, frame.origin.y - scrollDiff));
        }
        
        [self.socialTopview setFrame:frame];
        CGRect frame1=socialCollectionview.frame;
        frame1.origin.y =self.socialTopview.frame.origin.y +self.socialTopview.frame.size.height;

        CGRect sbvFrame=self.socialBottomView.frame;
        frame1.size.height= sbvFrame.origin.y- frame1.origin.y;
        socialCollectionview.frame =frame1;
        
        [self updateBarButtonItems:(1 - framePercentageHidden)];
        self.previousScrollViewYOffset = scrollOffset;
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView ==socialCollectionview ) {
        [self stoppedScrolling];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (scrollView ==socialCollectionview ) {
        if (!decelerate) {
            [self stoppedScrolling];
        }
    }
    
}

- (void)stoppedScrolling
{
    CGRect frame = self.socialTopview.frame;
    if (frame.origin.y < 0) {
        [self animateNavBarTo:-(frame.size.height - 21)];
    }
    else{
        CGRect frame1=socialCollectionview.frame;
        frame1.origin.y =self.socialTopview.frame.origin.y +self.socialTopview.frame.size.height;
        CGRect sbvFrame=self.socialBottomView.frame;
        frame1.size.height= sbvFrame.origin.y- frame1.origin.y;


        socialCollectionview.frame =frame1;
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
    notificatnbtn.alpha= alpha;

    self.socialTopview.tintColor = [self.socialTopview.tintColor colorWithAlphaComponent:alpha];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.socialTopview.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.socialTopview setFrame:frame];
        CGRect frame1=socialCollectionview.frame;
        frame1.origin.y =self.socialTopview.frame.origin.y +self.socialTopview.frame.size.height;
        CGRect sbvFrame=self.socialBottomView.frame;
        frame1.size.height= sbvFrame.origin.y- frame1.origin.y;

        socialCollectionview.frame =frame1;
        
        
        [self updateBarButtonItems:alpha];
    }];
}

#pragma mark - location settings

-(IBAction)locationselection:(id)sender{
    
    if([sender tag] == 0){
        
    }
    else if([sender tag] == 1){
        
    }
    else if([sender tag] == 2){
        
    }
    else{
        
        if(![locationview isDescendantOfView:appdelegate.window]) {
            [appdelegate.window addSubview:locationview];
        } else {
            [locationview removeFromSuperview];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger )section{
    
    if(tableView == searchtable)
        return searcharray.count;
    else if(tableView == notificationstable)
        return notificationsarray.count;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == notificationstable){
        if([[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"type"] != [NSNull null] && [[[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"track_request"])
            return 100.0;
        else
            return 68.0;
    }
    else if(tableView == searchtable)
        return 64.0;
    return 0.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == searchtable){
        
        static NSString *cellidentifier =@"cell";
        TrackingCell *cell = (TrackingCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier];
        
        if(cell==nil)
        {
            NSString *nib = @"TrackingCell";
            NSArray *viewObjcts = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
            for(id crntObj in viewObjcts){
                
                if ([crntObj isKindOfClass:[UITableViewCell class]]) {
                    
                    cell = crntObj;
                    break;
                }
            }
        }
        
        CGPoint saveCenter = cell.userImage.center;
        cell.userImage.layer.cornerRadius = 58 / 2.0;
        cell.userImage.center = saveCenter;
        cell.userImage.clipsToBounds = YES;
        
        //        cell.trackingBtn.tag = indexPath.row;
        //        [cell.trackingBtn addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        cell.trackingLabel.text = @"";
        cell.trackingBtn.hidden = YES;
        
        //        if([[[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"following_user"] objectForKey:@"user_id"] integerValue] != [appdelegate.userid integerValue]){
        //
        //            if([[trackingarray objectAtIndex:indexPath.row] objectForKey:@"request_status"] != [NSNull null]){
        //
        //                if([[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"request_status"] isEqualToString:@"not_accepted"])
        //                    cell.trackingLabel.text = @"Requested";
        //                else if([[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"request_status"] isEqualToString:@"Not Tracking"]){
        //
        //                    cell.trackingLabel.text = @"Track";
        //                    [cell.trackingBtn addTarget:self action:@selector(track:) forControlEvents:UIControlEventTouchUpInside];
        //                }
        //                else if([[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"request_status"] isEqualToString:@"accept"]){
        //                    cell.trackingLabel.text = @"";
        //                    cell.trackingBtn.hidden = YES;
        //                }
        //            }
        //
        //            else{
        //                cell.trackingLabel.text = @"Track";
        //                [cell.trackingBtn addTarget:self action:@selector(track:) forControlEvents:UIControlEventTouchUpInside];
        //            }
        //        }
        //        else{
        //
        //            cell.trackingLabel.text = @"";
        //            cell.trackingBtn.hidden = YES;
        //        }
        //        //        [cell.trackingBtn addTarget:self action:@selector(track:) forControlEvents:UIControlEventTouchUpInside];
        //
        //
                if([[searcharray objectAtIndex:indexPath.row] objectForKey:@"name"]  != [NSNull null]){
        
                    cell.userName.text = [[searcharray objectAtIndex:indexPath.row] objectForKey:@"name"];
                }
        
        //
        NSString *urlpath = [NSString stringWithFormat:@"%@%@.%@",userfilepath,[[searcharray objectAtIndex:indexPath.row] objectForKey:@"user_id"],[[searcharray objectAtIndex:indexPath.row] objectForKey:@"img_extension"]];
        
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"recentdefaultimage"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
            
            if(error){
                cell.userImage.image = [UIImage imageNamed:@"recentdefaultimage"];
            }
            else{
                cell.userImage.image = image;
            }
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(tableView == notificationstable){
       
        static NSString *cellidentifier =@"cell";
        NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier];
        
        if(cell==nil)
        {
            NSString *nib = @"NotificationCell";
            NSArray *viewObjcts = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
            for(id crntObj in viewObjcts){
                
                if ([crntObj isKindOfClass:[UITableViewCell class]]) {
                    
                    cell = crntObj;
                    break;
                }
            }
        }
        CGPoint saveCenter = cell.userImage.center;
        cell.userImage.layer.cornerRadius = 58 / 2.0;
        cell.userImage.center = saveCenter;
        cell.userImage.clipsToBounds = YES;
        if([[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"from_userName"] != [NSNull null])
            cell.userName.text = [[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"from_userName"];
        else
            cell.userName.text = @"";
        cell.notificationLabel.hidden = NO;
        
        if([[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"message"] != [NSNull null])
            cell.notificationLabel.text = [[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"message"];
        else
            cell.notificationLabel.text = @"";
        cell.acceptBtn.hidden = YES;
        cell.acceptlabel.hidden = YES;
        cell.rejectBtn.hidden = YES;
        cell.rejectlabel.hidden = YES;
        cell.requestview.hidden = YES;
        CGRect frame = cell.seperatorimage.frame;
        frame.origin.y = 67.0;
        if([[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"type"] != [NSNull null]){
            
            if([[[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"track_request"]){
                frame.origin.y = 99.0;
                cell.acceptBtn.hidden = NO;
                cell.acceptlabel.hidden = NO;
                cell.rejectBtn.hidden = NO;
                cell.rejectlabel.hidden = NO;
                cell.acceptBtn.tag = indexPath.row;
                [cell.acceptBtn addTarget:self action:@selector(accept:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.rejectBtn.tag = indexPath.row;
                [cell.rejectBtn addTarget:self action:@selector(reject:) forControlEvents:UIControlEventTouchUpInside];
               // [cell.notificationLabel sizeToFit];
                cell.requestview.hidden = NO;
            }
        }
        cell.seperatorimage.frame = frame;
        NSString *urlpath = [[NSString alloc]init];
           if([[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"type"] != [NSNull null])
        {
            if([[[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"vote"]){
                urlpath = [NSString stringWithFormat:@"%@%@",filePath_post,[[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"post_image"]];
                 cell.userName.text = @"";
            }
            else{
                urlpath = [NSString stringWithFormat:@"%@%@.%@",userfilepath,[[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"from_user_id"],[[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"img_extension"]];
                
                
                
            }
        }
       
        
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"recentdefaultimage"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
            
            if(error){
                cell.userImage.image = [UIImage imageNamed:@"recentdefaultimage"];
            }
            else{
                cell.userImage.image = image;
            }
        }];
        
        if([[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"status"] != [NSNull null] && [[[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"status"] isEqualToString:@"unread"])
            cell.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1];
        else
            cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    else{
        
        static NSString *cellidentifier =@"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
        
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
        if([locationtype isEqualToString:@"country"])
            cell.textLabel.text = [[locationarray objectAtIndex:indexPath.row] objectForKey:@"brand"];
        else
            cell.textLabel.text = [[locationarray objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == searchtable){
        
        [self.view endEditing:YES];
        ProfileView *obj = [[ProfileView alloc] init];
        obj.userid = [[searcharray objectAtIndex:indexPath.row] objectForKey:@"user_id"];
        obj.navigated = YES;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if(tableView == notificationstable){
        
        ServerRequest *obj = [[ServerRequest alloc] init];
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"notification_read\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"notification_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"id"]];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
//        [self startLoader:@"Loading..."];
        requesttype = @"notification_read";
        refreshnotifications = YES;
        notificationview.hidden = YES;
        if([[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"post_id"] != [NSNull null]){
            
            ProductDetail *obj = [[ProductDetail alloc] init];
            obj.productid = [[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"post_id"];
            obj.producttype = @"Social";
            [self.navigationController pushViewController:obj animated:YES];
        }
        else{
            
            ProfileView *obj = [[ProfileView alloc] init];
            obj.userid = [[notificationsarray objectAtIndex:indexPath.row] objectForKey:@"from_user_id"];
            obj.navigated = YES;
            [self.navigationController pushViewController:obj animated:YES];
        }
    }
    else{
        if([locationtype isEqualToString:@"country"]){
            
        }
    }
    //    NSDictionary *dict = [locationarray objectAtIndex:indexPath.row];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"DROPTABLEVALUE" object:nil userInfo:dict];
    //    [self.navigationController popViewControllerAnimated:YES];
}

-(void)track_response:(NSString *)status user_id:(NSString *)userid notificationid:(NSString *)notificationid{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"track_response\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"logged_user_id\": \"%@\",\"status\": \"%@\",\"notification_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,userid,appdelegate.userid,status,notificationid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"track_response";
}

-(IBAction)accept:(id)sender{
    
    [self track_response:@"accept" user_id:[[notificationsarray objectAtIndex:[sender tag]] objectForKey:@"from_user_id"] notificationid:[[notificationsarray objectAtIndex:[sender tag]] objectForKey:@"id"]];
    
}

-(IBAction)reject:(id)sender{
    
    [self track_response:@"reject" user_id:[[notificationsarray objectAtIndex:[sender tag]] objectForKey:@"from_user_id"] notificationid:[[notificationsarray objectAtIndex:[sender tag]] objectForKey:@"id"]];
}



#pragma mark Textfield Delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if([textField.text isEqualToString:@"Search User"])
        textField.text = NULL;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *searchKey = [textField.text stringByAppendingString:string];
    //arrFilterSearch = nil;
    searchKey = [searchKey stringByReplacingCharactersInRange:range withString:@""];
    
    if(searchKey.length==1){
        
        [self searchuser:searchKey];
    }
    
    else{
       
        NSArray *ary = searchoriginalarray;
        NSLog(@"searchKey....==%@",searchKey);
        NSPredicate *predicate;
        NSArray *syy = [[NSMutableArray alloc] init];
        
        
        //        predicate = [NSPredicate predicateWithFormat:@"following_user.%K BEGINSWITH[cd] %@",@"name"];
        
        predicate = [NSPredicate predicateWithFormat:@"%K contains[cd]%@",@"name",searchKey];
        
        //        NSArray *filtered = [array filteredArrayUsingPredicate:];
        
        syy = [ary filteredArrayUsingPredicate: predicate];
        
        NSLog(@"syyy....==%@",syy);
        if(syy.count>0){
            
            searcharray = [syy mutableCopy];
            nouserlabel.hidden = YES;
            searchtable.hidden = NO;
        }
        else{
            
            nouserlabel.hidden = NO;
            nouserlabel.text = [NSString stringWithFormat:@"No users found."];
            searcharray = nil;
            searchtable.hidden = YES;
        }
        [searchtable reloadData];
        [self setsearchtableframe];
    }    
    return YES;
}

-(void)setsearchtableframe{
   
    CGRect frame = searchtable.frame;
    if(searcharray.count*64<searchtable.superview.frame.size.height - 44)
        frame.size.height = searcharray.count *64;
    else
        frame.size.height = searchtable.superview.frame.size.height - 44;
    searchtable.frame = frame;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    searchField.text=@"";
    socialarray = [searchoriginalarray mutableCopy];
    [searchtable reloadData];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [searchField resignFirstResponder];
    [searchtable reloadData];
    return YES;
}

- (IBAction)search:(id)sender {
    
    if([sender tag] == 1){
        
       [self textFieldShouldReturn:searchField];
    }
    else{
        
        if([sender tag] == 0){
            if(searchresultsview.hidden == YES){
                searchresultsview.hidden = NO;
            }
            else{
                searchresultsview.hidden = YES;
            }
        }
        else
            searchresultsview.hidden = YES;
        
    }
    notificationview.hidden = YES;
    [self.view endEditing:YES];
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
