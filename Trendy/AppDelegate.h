//
//  AppDelegate.h
//  Trendy
//
//  Created by NewAgeSMB on 8/3/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

@class ViewController;
@class Reachability;

@class RecentOrTrendsFeeds;
@class SocialFeeds;
@class Occasion;
@class ProfileView;
@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,CLLocationManagerDelegate>{
    
    // for Reachability
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    NSString *hostItemToReach;
    dispatch_queue_t backgroundQueue;
    RecentOrTrendsFeeds *recentview;
    SocialFeeds *socialview;
    Occasion *occasionview;
    ProfileView *profileview;
    NSMutableArray *MainNavArray;
    UIImageView *firstTab;
    UIImageView *secondTab;
    UIImageView *thirdTab;
    UIImageView *fourthTab;
    UILabel *firstTablabel;
    UILabel *secondtablabel;
    UILabel *thirdTablabel;
    UILabel *fourthtablabel;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigation;
@property (strong, nonatomic) ViewController *viewcontroller;
@property(nonatomic,retain)NSString *Clienturl;

//for sessionid, authkey, apiversion...
@property (nonatomic, retain) NSString *sessionid;
@property (nonatomic, retain) NSString *authkey;
@property (nonatomic, retain) NSString *apiversion;
@property (nonatomic, retain) NSString *appversion;
@property (nonatomic, retain) NSString *devicetoken;
@property (strong, nonatomic) UIViewController *currentviewcontroller;

@property (strong, nonatomic) NSString *userid;
@property BOOL stop;

@property (strong, nonatomic) NSString *sortedkey, *sortedkeyTrends, *sortedkeyOccasion;
@property BOOL asending, asendingTrends, asendingOccasion;

@property (strong, nonatomic) NSDictionary *filterdict, *changedlocation;
@property (strong, nonatomic) NSArray *countryvalarray, *statevalarray, *cityvalarray;;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSMutableURLRequest *request;
-(void) goToHome:(int)no;

//Terms n Privacy...
@property (nonatomic, retain) NSString *privacyhtml, *termshtml,*UserGuideBegining,*UserGuideAfter;

// for Reachability
@property (nonatomic,assign) BOOL networkAvailable;
-(void)updateInterfaceWithReachability: (Reachability*) curReach;
-(void)displayNetworkAvailability:(id)sender;

//location fetching...
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *currentLocation;
@property (assign, nonatomic) CLLocationCoordinate2D phoneLocation;
@property (nonatomic,retain)NSDictionary *cstreampostData;
@property float nearloclati, nearloclong;
-(void)startUpdatingCurrentLocation;
-(void)logout;
-(void)clearAllFilter;
@end

