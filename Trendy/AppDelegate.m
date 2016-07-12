//
//  AppDelegate.m
//  Trendy
//
//  Created by NewAgeSMB on 8/3/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Reachability.h"
#include <netinet/in.h>
#include <arpa/inet.h>
#import "SimplePinger.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "RecentOrTrendsFeeds.h"
#import "AroundFeeds.h"
#import "Occasion.h"
#import "ProfileView.h"
#import "SocialFeeds.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ProductDetail.h"
#import "SocialFeeds.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize viewcontroller,navigation,Clienturl,window,networkAvailable,tabBarController,apiversion,appversion,sessionid,authkey,devicetoken,userid,locationManager,phoneLocation,cstreampostData,currentLocation,stop,filterdict,countryvalarray,currentviewcontroller,changedlocation,statevalarray,cityvalarray,request,nearloclati,nearloclong,sortedkey,asending,sortedkeyTrends,sortedkeyOccasion,asendingOccasion,asendingTrends,privacyhtml,termshtml,UserGuideAfter,UserGuideBegining;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if (!hostItemToReach) {
        hostItemToReach=@"www.apple.com"; //start off somewhere familiar
    }
    [self mainItemsAfterLaunching];
    [self startUpdatingCurrentLocation];
    sleep(5);
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
#ifdef __IPHONE_8_0
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
#endif
    else{
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound |     UIRemoteNotificationTypeNewsstandContentAvailability;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
        
    }
    
    struct sockaddr_in callAddress;
    callAddress.sin_len = sizeof(callAddress);
    callAddress.sin_family = AF_INET;
    callAddress.sin_port = htons(24);
    callAddress.sin_addr.s_addr = inet_addr([hostItemToReach UTF8String]);
    hostReach = [Reachability reachabilityWithAddress:&callAddress];
    [hostReach startNotifier];
    [self updateInterfaceWithReachability: hostReach];
    
    /* internetReach is an instance of Reachability */
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateInterfaceWithReachability: internetReach];
    
    /* wifiReach is an instance of Reachability */
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    [self updateInterfaceWithReachability: wifiReach];
    
    [self startUpdatingCurrentLocation];
  //self.Clienturl = @"http://192.168.1.254/trendyservice/client";
   // self.Clienturl = @"http://newagesme.com/trendyservice/client";
  self.Clienturl = @"http://54.68.77.215/client";
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![standardUserDefaults objectForKey:@"_APP_COUNT_LIST"]) {
        
        
        
        [standardUserDefaults setObject:@"1" forKey:@"_APP_COUNT_LIST"];
        
        
        
    }
    
    else {
        
        
        
        int count = [[standardUserDefaults objectForKey:@"_APP_COUNT_LIST"] integerValue] +1;
        
        
        
        [standardUserDefaults removeObjectForKey:@"_APP_COUNT_LIST"];
        
        
        
        [standardUserDefaults setObject:[NSNumber numberWithInt:count] forKey:@"_APP_COUNT_LIST"];
        
    }
    //[self customizeInterface];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewcontroller=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    tabBarController = [[UITabBarController alloc] init];
    self.navigation = [[UINavigationController alloc] initWithRootViewController:self.viewcontroller];
    self.navigation.navigationBarHidden = YES;
//    [self goToHome:0];
    self.window.rootViewController=self.navigation;
//     self.window.backgroundColor = [UIColor whiteColor];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.window.frame];
//    imageView.image = [UIImage imageNamed:@"splash"]; // assuming your splash image is "Default.png" or "Default@2x.png"
//    [self.window addSubview:imageView];
//    UIImageView *logoimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 103, 125)];
//    logoimageView.center = self.window.center;
//    logoimageView.image = [UIImage imageNamed:@"logo"]; // assuming your splash image is "Default.png" or "Default@2x.png"
//    [self.window addSubview:logoimageView];
////    [self.window bringSubviewToFront:imageView];
//    [self.window bringSubviewToFront:logoimageView];
//    [UIView transitionWithView:self.window
//                      duration:2.00f
//                       options:UIViewAnimationOptionTransitionNone
//                    animations:^(void){
//                        logoimageView.alpha = 0.0f;
//                        logoimageView.frame = CGRectInset(imageView.frame, -100.0f, -100.0f);
//                    }
//                    completion:^(BOOL finished){
//                        [imageView removeFromSuperview];
//                        [logoimageView removeFromSuperview];
//                        self.window.rootViewController=self.navigation;
//                    }];
    
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Reachability

#pragma mark- Reachability Delegates



- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    
    if(curReach == hostReach)
    {
        
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        
        switch (netStatus)
        
        {
            case NotReachable:
            {
                NSLog(@"A gateway to the host server is down.");
                
                self.networkAvailable=NO;
                break;
                
            }
            case ReachableViaWiFi:
            {
                NSLog(@"A gateway to the host server is working via WIFI.");
                self.networkAvailable=YES;
                break;
                
            }
            case ReachableViaWWAN:
            {
                NSLog(@"A gateway to the host server is working via WWAN.");
                self.networkAvailable=YES;
                break;
                
            }
        }
    }
    if(self.networkAvailable)
    {
        
    }
    else{
        
        
    }
    
}

- (void) displayNetworkAvailability:(id)sender{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Connect To Internet!!!"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    [self simplePingThis:hostItemToReach];
    
    [self updateInterfaceWithReachability: curReach];
}

- (void) simplePingThis:(NSString*) addressToPing
{
    NSLog(@"Going to Ping");
    // dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    backgroundQueue = dispatch_queue_create("com.elbsolutions.simpleping", NULL);
    
    dispatch_async(backgroundQueue, ^{
        
        /* Add the SImplePinger app into here */
        
        
        SimplePinger *mainObj = [[SimplePinger alloc] init];
        //mainObj.stopOnAnyError = true;
        assert(mainObj != nil);
        
        //[mainObj runWithHostName:[NSString stringWithUTF8String:argv[1]]];
        [mainObj runWithHostName:addressToPing];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            NSString *msg = @"";
            if ([mainObj reachedIpAddress]) {
                msg = [NSString stringWithFormat:@"Successful Ping of %@",addressToPing,nil];;
                
            } else {
                
                msg = [NSString stringWithFormat:@"No Response from %@",addressToPing,nil];;
                //
                //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Connect To Internet!!!"  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //                [alert show];
                
            }
            
            //   NSLog(@"%@",msg);
            
            
        });
    });
    
    
}

-(void) mainItemsAfterLaunching
{
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    [self simplePingThis:hostItemToReach];
    
    struct sockaddr_in callAddress;
    callAddress.sin_len = sizeof(callAddress);
    callAddress.sin_family = AF_INET;
    callAddress.sin_port = htons(24);
    callAddress.sin_addr.s_addr = inet_addr([hostItemToReach UTF8String]);
    
    hostReach = [Reachability reachabilityWithAddress:&callAddress];
    
    
    [hostReach startNotifier];
    [self updateInterfaceWithReachability: hostReach];
    
    /* internetReach is an instance of Reachability */
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateInterfaceWithReachability: internetReach];
    
    /* wifiReach is an instance of Reachability */
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    [self updateInterfaceWithReachability: wifiReach];
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSDKAppEvents activateApp];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)startUpdatingCurrentLocation
{
    if(self.locationManager){
        [locationManager startUpdatingLocation];
    }
    else{
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate=self;
        
        //Get user location
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        //Get user location
        
        
        //    [self.locationManager requestAlwaysAuthorization];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        else
            [self.locationManager requestWhenInUseAuthorization];
        [locationManager startUpdatingLocation];
    }
//    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
//    locationManager.distanceFilter=kCLDistanceFilterNone;
////    [locationManager requestWhenInUseAuthorization];
////    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
////        [self.locationManager requestWhenInUseAuthorization];
////    }
//    if(IS_OS_8_OR_LATER) {
//        [self.locationManager requestAlwaysAuthorization];
//    }
//    
//    [locationManager startMonitoringSignificantLocationChanges];
//    [locationManager startUpdatingLocation];
    
    
}

- (void)requestWhenInUseAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusDenied) {
        
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" :   @"location is not enabled";
        NSString *message = @"To use location you must turn on 'While Using the App' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    self.phoneLocation=CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    self.currentLocation=newLocation;
    if (newLocation.horizontalAccuracy <=1000.0f)
    {
        [self.locationManager stopUpdatingLocation];
        NSLog(@"%g %g",newLocation.coordinate.longitude, newLocation.coordinate.latitude);
        
        self.cstreampostData = [NSDictionary dictionaryWithObjectsAndKeys:
                                
                                [NSString stringWithFormat:@"%g",newLocation.coordinate.latitude],@"latitude",
                                [NSString stringWithFormat:@"%g",newLocation.coordinate.longitude],@"longitude", nil];
    }
    [locationManager stopUpdatingLocation];
    NSLog(@"lat:%f long:%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    if(!oldLocation){
        if(self.window.rootViewController != self.navigation)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESHONLOCATION" object:nil];
    }
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:locationManager.location forKey:@"location"];
////    [defaults setObject:[NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude] forKey:@"long"];
//    [defaults synchronize];
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    // Assigning the last object as the current location of the device
//    CLLocation *newcurrentLocation = [locations lastObject];
//    self.currentLocation=newcurrentLocation;
//    
//}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    //    kCLErrorLocationUnknown  = 0,         // location is currently unknown, but CL will keep trying
    //    kCLErrorDenied,                       // Access to location or ranging has been denied by the user
    //    kCLErrorNetwork,                      // general, network-related error
    NSString *alertmsg;
    //show alert for failed gps
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
        alertmsg = @"Turn on location services for this app to get products nearby your location";
    }else if(error.code == kCLErrorLocationUnknown){
        //retry
        alertmsg = @"Location is currently unknown";
    }
    else if(error.code == kCLErrorNetwork){
        //retry
        alertmsg = @"Location is currently unknown, network-related error";
    }
    else{
        alertmsg = @"Location is currently unknown";
    }
    //[self.locationManager stopUpdatingLocation];
    
    NSLog(@"TRACKED");
    
    NSLog(@"%@",error);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:alertmsg message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
//     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if([defaults objectForKey:@"location"])
//        self.currentLocation = [defaults objectForKey:@"location"];
    
}

// ..............device token ..............

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *strWithoutSpaces  = [NSString stringWithFormat:@"%@",deviceToken];
    strWithoutSpaces = [strWithoutSpaces stringByReplacingOccurrencesOfString:@" " withString:@""];
    strWithoutSpaces = [strWithoutSpaces stringByReplacingOccurrencesOfString:@"<" withString:@""];
    self.devicetoken = [strWithoutSpaces stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSString *poststring = [[NSString alloc] initWithFormat:@"{\"function\":\"openSession\",\"parameters\": {\"device_id\": \"%@\"},\"token\":\"\"}",devicetoken];
    NSLog(@"%@",poststring);
    [self requestopensession:poststring];
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    devicetoken = @"4bac17994d549adb50f2f7933da2d660676ff3bd3d3782128bd4ce2749fb0318";
    NSString *str = [NSString stringWithFormat: @"Error: %@", error];
    NSLog(@"%@",str);
    NSString *poststring = [[NSString alloc] initWithFormat:@"{\"function\":\"openSession\",\"parameters\": {\"device_id\": \"%@\"},\"token\":\"\"}",devicetoken];
    NSLog(@"%@",poststring);
    [self requestopensession:poststring];
   
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    // Get push message
    if([userInfo objectForKey:@"aps"]){
        
        
//        [self clearbadgecount];
        NSDictionary *dict = [[userInfo objectForKey:@"aps"] mutableCopy];
        NSLog(@"%@",dict);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESHPUSH" object:nil];
        UIApplicationState state = [application applicationState];
        if (state == UIApplicationStateActive)
        {
            if(userInfo != Nil)
            {
                NSString *message = [dict objectForKey:@"alert"];
                /*if([[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"Like"]){
                    
                 
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
                    
                    [alert show];
                }*/
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
                if([[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"Like"] || [[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"review"]){
                    
//                    ProductDetail *obj = [[ProductDetail alloc] init];
//                    obj.productid = [dict objectForKey:@"id"];
//                    [currentviewcontroller.navigationController pushViewController:obj animated:YES];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESHPUSH" object:[dict objectForKey:@"id"]];
                    
                }
            }
        }
        else{
            
//            NSString *message = [dict objectForKey:@"alert"];
            if([[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"Like"] || [[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"review"]){
                
                ProductDetail *obj = [[ProductDetail alloc] init];
                obj.productid = [dict objectForKey:@"id"];
                [currentviewcontroller.navigationController pushViewController:obj animated:YES];
                
                
            }
            else if([[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"track_request"]){
                
                [self.tabBarController setSelectedIndex:1];
                
            }
            else if([[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"track request approved"] || [[[userInfo objectForKey:@"aps"] objectForKey:@"type"] isEqualToString:@"track_request_public"]){
                
                ProfileView *obj = [[ProfileView alloc] init];
                obj.userid = [dict objectForKey:@"id"];
                obj.navigated = YES;
                [currentviewcontroller.navigationController pushViewController:obj animated:YES];
                
            }
            else{
                
            }
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey:@"badgecount"] intValue];
        }
    }
}

-(void)clearbadgecount{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    //obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"clearBadgeCount\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"device_id\": \"%@\"},\"token\":\"\"}",self.apiversion,self.appversion,self.authkey,self.sessionid,self.devicetoken];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
}

-(void)clearAllFilter{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"clear_filter_all\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",self.apiversion,self.appversion,self.authkey,self.sessionid,self.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    
}

-(void)requestopensession:(NSString *)poststring{
    
    NSData *postData = [poststring dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    request = [[NSMutableURLRequest alloc] init];
    NSLog(@"appdelegate.Clienturl==>%@",self.Clienturl);
    [request setURL:[NSURL URLWithString:self.Clienturl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    NSMutableData *webData = [[NSMutableData alloc]init];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   //                                   webData = nil;
                                   NSLog(@"error:%@", error.localizedDescription);
                               }
                               [webData appendData:data];
                               NSError *jsonParsingError = nil;
                               NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&jsonParsingError];
                               NSLog(@"tempdict == %@",tempdict);
                               //    NSDictionary *tempdict1 = [[tempdict objectForKey:@"data"] JSONValue];
                               //    NSLog(@"tempdict == %@",tempdict1);
                               
                               if(tempdict){
                                   
                                   self.sessionid = [tempdict objectForKey:@"session_id"];
                                   self.authkey = [tempdict objectForKey:@"authkey"];
                                   self.apiversion = [tempdict objectForKey:@"version"];
                                   self.appversion = @"I-1.0";
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"SECUREKEYS"  object:nil];
                               }
                               else{
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [alert show];
                                   
                               }
                           }];
}

-(void)logout{

    self.changedlocation = nil;
    ServerRequest *obj1 = [[ServerRequest alloc] init];
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"logout\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"userID\": \"%@\"},\"token\":\"\"}",self.apiversion,self.appversion,self.authkey,self.sessionid,self.userid];
    NSLog(@"%@",postdata);
    [obj1 serverrequest:postdata];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"user_id"];
    [defaults setObject:nil forKey:@"user_type"];
    [defaults setObject:nil forKey:@"fbid"];
    [defaults setObject:nil forKey:@"username"];
    [defaults setObject:nil forKey:@"password"];
    [self.navigation popToRootViewControllerAnimated:YES];
    self.window.rootViewController = self.navigation;
    self.userid = nil;
    FBSDKLoginManager *obj = [[FBSDKLoginManager alloc] init];
    [obj logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [defaults synchronize];
}

-(void) goToHome:(int)no
{
    self.tabBarController.delegate = self;
    UINavigationController *objnavifirst;
    UINavigationController *objnavisecond;
    UINavigationController *objnavithird;
    UINavigationController *objnavifourth;
    
    
    //first tab
    recentview  =[[RecentOrTrendsFeeds alloc]initWithNibName:@"RecentOrTrendsFeeds" bundle:nil];
    //second tab
    socialview  =[[SocialFeeds alloc]initWithNibName:@"SocialFeeds" bundle:nil];
    //third tab
    occasionview  =[[Occasion alloc]initWithNibName:@"Occasion" bundle:nil];
    //fourth tab
    profileview =[[ProfileView alloc]initWithNibName:@"ProfileView" bundle:nil];
    
    
    
    
    objnavifirst = [[UINavigationController alloc] initWithRootViewController:recentview];
    objnavisecond = [[UINavigationController alloc] initWithRootViewController:socialview];
    objnavithird = [[UINavigationController alloc] initWithRootViewController:occasionview];
    objnavifourth = [[UINavigationController alloc] initWithRootViewController:profileview];
    
    
    
    MainNavArray =[[NSMutableArray alloc] init];
    objnavifirst.navigationBarHidden=YES;
    objnavisecond.navigationBarHidden=YES;
    objnavithird.navigationBarHidden=YES;
    objnavifourth.navigationBarHidden=YES;
    
    [MainNavArray  addObject:objnavifirst];
    [MainNavArray  addObject:objnavisecond];
    [MainNavArray  addObject:objnavithird];
    [MainNavArray  addObject:objnavifourth];
    
    tabBarController.viewControllers =MainNavArray;
    
    self.tabBarController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.window.rootViewController = tabBarController;
    
    
    float TabBtnwidth=(tabBarController.tabBar.frame.size.width/([tabBarController.viewControllers count]));
    float height = tabBarController.tabBar.frame.size.height;
    float diff = TabBtnwidth / 2 ;
    UIImageView *TabBarImg = [[UIImageView alloc]init];//WithFrame:CGRectMake(0,0,320.0,height)];
    UIImage *image;
    float xStartPos=tabBarController.tabBar.frame.origin.x;
    float size;
    image = [UIImage imageNamed: @"headder"];
    TabBarImg.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,height);
    size = 10;
    //diff =
    
    [TabBarImg setImage:image];
    tabBarController.tabBar.tag=10;
    [tabBarController.tabBar addSubview:TabBarImg];
    
    firstTab =[[UIImageView alloc]initWithFrame:CGRectMake(xStartPos,0.0,[[UIScreen mainScreen] bounds].size.width/4,49.0)];
    
    [TabBarImg addSubview:firstTab];
    
    xStartPos=xStartPos+TabBtnwidth;
    
    secondTab=[[UIImageView alloc]initWithFrame:CGRectMake(xStartPos,0.0,[[UIScreen mainScreen] bounds].size.width/4,49.0)];
    
    [TabBarImg addSubview:secondTab];
    
    xStartPos=xStartPos+TabBtnwidth;
    
    thirdTab=[[UIImageView alloc]initWithFrame:CGRectMake(xStartPos,0.0,[[UIScreen mainScreen] bounds].size.width/4,49.0)];
    
    [TabBarImg addSubview:thirdTab];
    
    xStartPos=xStartPos+TabBtnwidth;
    
    
    fourthTab=[[UIImageView alloc]initWithFrame:CGRectMake(xStartPos,0.0,[[UIScreen mainScreen] bounds].size.width/4,49.0)];
    
    [TabBarImg addSubview:fourthTab];
    
    xStartPos=xStartPos+TabBtnwidth;
    
    firstTab.image=[UIImage imageNamed:@"tab1"];
    secondTab.image=[UIImage imageNamed:@"tab2"];
    thirdTab.image=[UIImage imageNamed:@"tab3"];
    fourthTab.image=[UIImage imageNamed:@"tab4"];
  
  
    
   /* UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    
    tabBarItem1.title = @"Home";
    tabBarItem2.title = @"Maps";
    tabBarItem3.title = @"My Plan";
    tabBarItem4.title = @"Settings";
    
    UIImage *unselectedImage1 = [UIImage imageNamed:@"home"];
    UIImage *selectedImage1 = [UIImage imageNamed:@"home_selected"];
    
    [tabBarItem1 setImage: [unselectedImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setSelectedImage: [selectedImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIImage *unselectedImage2 = [UIImage imageNamed:@"maps"];
    UIImage *selectedImage2 = [UIImage imageNamed:@"maps_selected"];
    
    [tabBarItem2 setImage: [unselectedImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setSelectedImage: [selectedImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
    UIImage *unselectedImage3 = [UIImage imageNamed:@"myplan"];
    UIImage *selectedImage3 = [UIImage imageNamed:@"myplan_selected"];
    
    [tabBarItem3 setImage: [unselectedImage3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setSelectedImage: [selectedImage3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UIImage *unselectedImage4 = [UIImage imageNamed:@"settingsCheck"];
    UIImage *selectedImage4 = [UIImage imageNamed:@"settingsCheck_selected"];
    
    [tabBarItem4 setImage: [unselectedImage4 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem4 setSelectedImage: [selectedImage4 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
   */
    
    
    // Change the tab bar background
    
    firstTab.image=[UIImage imageNamed:@"tab1_hover"];
    tabBarController.view.hidden = NO;
    tabBarController.selectedIndex = 0;
}
- (void)customizeInterface
{
    
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected"]];
    
    // Change the title color of tab bar items
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName :  [UIColor whiteColor] }
                                             forState:UIControlStateNormal];
    
    
   
    // doing this results in an easier to read unselected state then the default iOS 7 one
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:153/255.0 green:192/255.0 blue:48/255.0 alpha:1.0] }
                                             forState:UIControlStateSelected];

    
}
-(void)allTabsNotSelected
{
    firstTab.image=[UIImage imageNamed:@"tab1"];
    secondTab.image=[UIImage imageNamed:@"tab2"];
    thirdTab.image=[UIImage imageNamed:@"tab3"];
    fourthTab.image=[UIImage imageNamed:@"tab4"];
    tabBarController.selectedIndex = 0;
}

- (void)tabBarController:(UITabBarController *)tabBarControllers didSelectViewController:(UIViewController *)viewController1
{
    firstTab.image=[UIImage imageNamed:@"tab1"];
    secondTab.image=[UIImage imageNamed:@"tab2"];
    thirdTab.image=[UIImage imageNamed:@"tab3"];
    fourthTab.image=[UIImage imageNamed:@"tab4"];
    
    if (tabBarControllers.selectedIndex == 0)
    {
            if ([viewController1 isKindOfClass:[UINavigationController class]])
            {
                [(UINavigationController *)viewController1 popToRootViewControllerAnimated:NO];
            }
        firstTab.image=[UIImage imageNamed:@"tab1_hover"];
        //        tabBarController.selectedIndex = 0;
        //        firstTab.image=[UIImage imageNamed:@"my_account.png"];
        
    }
    else if (tabBarControllers.selectedIndex == 1)
    {
        /* if ([viewController1 isKindOfClass:[UINavigationController class]])
         {
         [(UINavigationController *)viewController1 popToRootViewControllerAnimated:NO];
         }*/
        secondTab.image=[UIImage imageNamed:@"tab2_hover"];
        //        secondTab.image=[UIImage imageNamed:@"menu.png"];
        
    }
    else if (tabBarControllers.selectedIndex == 2)
    {
        /* if ([viewController1 isKindOfClass:[UINavigationController class]])
         {
         [(UINavigationController *)viewController1 popToRootViewControllerAnimated:NO];
         }*/
        thirdTab.image=[UIImage imageNamed:@"tab3_hover"];
        //        thirdTab.image=[UIImage imageNamed:@"create_combo.png"];
        
    }
    else if (tabBarControllers.selectedIndex == 3)
    {
        /* if ([viewController1 isKindOfClass:[UINavigationController class]])
         {
         [(UINavigationController *)viewController1 popToRootViewControllerAnimated:NO];
         }*/
        fourthTab.image=[UIImage imageNamed:@"tab4_hover"];
        //        fourthTab.image=[UIImage imageNamed:@"munch_ststs.png"];
        
    }    
    
}

@end
