//
//  ProfileView.m
//  Trendy
//
//  Created by NewAgeSMB on 8/5/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "ProfileView.h"
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "YALNavigationBar.h"
#import "SuggestedCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ServerRequest.h"
#import "ProductDetail.h"
#import "SettingsView.h"
#import "TrackingList.h"
#import "MHFacebookImageViewer.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

static NSString *const menuCellIdentifier = @"rotationCell";

@interface ProfileView ()<UITableViewDelegate,UITableViewDataSource,YALContextMenuTableViewDelegate,delegaterequest>{
    
    IBOutlet UIView *contextview, *privateview;
    IBOutlet UIButton *contextbtn, *trackbtn,*rewardbtn;
    NSMutableArray *itemsarray;
    IBOutlet UICollectionView *itemsview;
    AppDelegate *appdelegate;
    NSString *requesttype, *filepath;
    NSMutableDictionary *profiledict;
    IBOutlet UIActivityIndicatorView *profileloader;
    IBOutlet UIImageView *profileimage;
    IBOutlet UILabel *trackerscount, *trackingcount, *username, *subtitlelabel, *tracklabel, *noresultslabel,*rewardsLabel;
    BOOL viewloaded;
    UIImagePickerController *imagePicker;
    NSString *fburl;
    IBOutlet UIButton *backbtn, *settingsbtn;
    IBOutlet UILabel *TrendyTallyLbl;
    
}

@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;

@end

@implementation ProfileView
@synthesize userid,picData,navigated;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initiateMenuOptions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    itemsarray = [[NSMutableArray alloc] init];
    UINib *cellNib = [UINib nibWithNibName:@"SuggestedCell" bundle:nil];
    [itemsview registerNib:cellNib forCellWithReuseIdentifier:@"SuggestedCell"];
    // set custom navigationBar with a bigger height
    [self.navigationController setValue:[[YALNavigationBar alloc]init] forKeyPath:@"navigationBar"];
    [self getprofiledetails];
    fburl = @"";
    CGPoint saveCenter = profileimage.center;
//    CGRect newFrame = CGRectMake(profileimage.frame.origin.x, cell.profilecompletionimage.frame.origin.y, 54, 54);
//    profileimage.frame = newFrame;
    profileimage.layer.cornerRadius = 90 / 2.0;
    profileimage.center = saveCenter;
    profileimage.clipsToBounds = YES;
    if([userid integerValue] != [appdelegate.userid integerValue]){
        trackbtn.hidden = NO;
        tracklabel.hidden = NO;
        tracklabel.text = @"Track";
        tracklabel.textColor =[UIColor orangeColor];
        settingsbtn.hidden = YES;
        rewardbtn.hidden = YES;
        rewardsLabel.hidden = YES;
        TrendyTallyLbl.hidden = YES;
        
    }
    else{
        trackbtn.hidden = YES;
        tracklabel.hidden = YES;
        settingsbtn.hidden = NO;
        rewardbtn.hidden = NO;
        rewardsLabel.hidden = NO;
        TrendyTallyLbl.hidden = NO;
       

        
    }
    if(navigated  == YES)
        backbtn.hidden = NO;
    else
        backbtn.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(viewloaded == YES)
        [self getprofiledetails];
    else
        viewloaded = YES;
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
}

-(void)getprofiledetails{

    if(!userid)
        userid = appdelegate.userid;
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_profile_details\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"logged_user_id\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"profile";
}
-(void)getrewards{
    
    if(!userid)
        userid = appdelegate.userid;
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_rewards\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"logged_user_id\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getrewards";
}
-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
            
            if([requesttype isEqualToString:@"profile"]){
                
                profiledict = [tempdict mutableCopy];
                if([profiledict objectForKey:@"fileNAME"] != [NSNull null]){
                   
                    profileloader.hidden = NO;
                    [profileloader startAnimating];
                    NSString *urlpath = [NSString stringWithFormat:@"%@%@.%@",[profiledict objectForKey:@"profile_pic_path"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"user_id"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"img_extension"]];
//                        [profileimage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];

                    [profileimage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"no_img.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
                        
                        if(error){
                            profileimage.image = [UIImage imageNamed:@"recentdefaultimage"];
                        }
                        else{
                            profileimage.image = image;
                        }
                        profileloader.hidden = YES;
                        [profileloader stopAnimating];
                    }];
                }
                if([[profiledict objectForKey:@"tracking_count"] objectForKey:@"tracked_by"] != [NSNull null])
                    trackerscount.text = [[profiledict objectForKey:@"tracking_count"] objectForKey:@"tracked_by"];
                
                if([[profiledict objectForKey:@"tracking_count"] objectForKey:@"tracking"] != [NSNull null])
                    trackingcount.text = [[profiledict objectForKey:@"tracking_count"] objectForKey:@"tracking"];
                
                if([userid integerValue] != [appdelegate.userid integerValue]){
                   
                    trackbtn.hidden = NO;
                    tracklabel.hidden = NO;
                    //tracklabel.text = @"Track";
                    rewardbtn.hidden = YES;
                    rewardsLabel.hidden = YES;
                     TrendyTallyLbl.hidden = YES;
                    
                    
                    
                    trackbtn.userInteractionEnabled = YES;
                    trackbtn.enabled = YES;
                    if([profiledict objectForKey:@"tracking_details"] != [NSNull null]){
                        
                        if([[profiledict objectForKey:@"tracking_details"] isEqualToString:@"not_accepted"]){
                            tracklabel.text = @"Pending";
                            tracklabel.textColor =[UIColor grayColor];
                            trackbtn.userInteractionEnabled = NO;
                        }
                        else if([[profiledict objectForKey:@"tracking_details"] isEqualToString:@"Not Tracking"]){
                            
                            tracklabel.text = @"Track";
                            trackbtn.hidden = NO;
                            tracklabel.textColor =[UIColor orangeColor];
                            rewardbtn.hidden = YES;
                            rewardsLabel.hidden = YES;
                             TrendyTallyLbl.hidden = YES;
                            

                        }
                        else if([[profiledict objectForKey:@"tracking_details"] isEqualToString:@"accept"]){
                            tracklabel.text = @"Tracking";
                            trackbtn.userInteractionEnabled = YES;
                            tracklabel.textColor =[UIColor colorWithRed:44.0/255 green:141.0/255 blue:32.0/255 alpha:1];
                        }
                    }
                    else{
                        tracklabel.text = @"Track";
                        trackbtn.hidden = NO;
                        tracklabel.textColor =[UIColor orangeColor];
                        rewardbtn.hidden = YES;
                        rewardsLabel.hidden = YES;
                         TrendyTallyLbl.hidden = YES;
                       

                    }
                
                    if([[profiledict objectForKey:@"user_detais"] objectForKey:@"profile"] != [NSNull null] && [[[profiledict objectForKey:@"user_detais"] objectForKey:@"profile"] isEqualToString:@"private"] && ![tracklabel.text isEqualToString:@"Tracking"])
                        privateview.hidden = NO;
                    else
                        privateview.hidden = YES;
                }
                else{
                    trackbtn.hidden = YES;
                    tracklabel.hidden = YES;
                    privateview.hidden = YES;
                    rewardbtn.hidden = NO;
                    rewardsLabel.hidden = NO;
                     TrendyTallyLbl.hidden = NO;
                    

                    [self getrewards];
                }
                
                
                
                if([[profiledict objectForKey:@"user_detais"] objectForKey:@"name"] != [NSNull null])
                    username.text = [[profiledict objectForKey:@"user_detais"] objectForKey:@"name"];
                filepath = [profiledict objectForKey:@"post_pic_path"];
                itemsarray = [[profiledict objectForKey:@"posted_items"] mutableCopy];
                [itemsview reloadData];
                subtitlelabel.text = @"Posted Items";
                if(itemsarray.count == 0){
                    noresultslabel.text = @"No items are available";
                    noresultslabel.hidden = NO;
                }
                else
                    noresultslabel.hidden = YES;
            }
            
            else if([requesttype isEqualToString:@"trend_track"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESHLIST" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESHSOCIAL" object:nil];
                trackbtn.userInteractionEnabled = YES;
                if([[profiledict objectForKey:@"tracking_details"] isEqualToString:@"accept"]){
                    
                    tracklabel.text = @"Track";
                    trackbtn.hidden = NO;
                    tracklabel.textColor =[UIColor orangeColor];
                    
                    NSMutableDictionary *dict = [profiledict mutableCopy];
                    [dict setObject:@"Not Tracking" forKey:@"tracking_details"];
                    profiledict = [dict mutableCopy];
                    
                    int count = [trackerscount.text intValue];
                    NSMutableDictionary *dict1 = [[profiledict objectForKey:@"tracking_count"] mutableCopy];
                    [dict1 setObject:[NSString stringWithFormat:@"%d",count - 1] forKey:@"tracked_by"];
                    [profiledict setObject:dict1 forKey:@"tracking_count"];
                }
                else{
                    if([[profiledict objectForKey:@"user_detais"] objectForKey:@"profile"] != [NSNull null] && [[[profiledict objectForKey:@"user_detais"] objectForKey:@"profile"] isEqualToString:@"private"]){
                        
                        tracklabel.text = @"Pending";
                        tracklabel.textColor =[UIColor grayColor];
                        trackbtn.userInteractionEnabled = NO;
                    }
                    else{
                        trackbtn.userInteractionEnabled = YES;
                        tracklabel.text = @"Tracking";
                        tracklabel.textColor =[UIColor greenColor];
                        tracklabel.textColor =[UIColor colorWithRed:44.0/255 green:141.0/255 blue:32.0/255 alpha:1];
                        
                        NSMutableDictionary *dict = [profiledict mutableCopy];
                        [dict setObject:@"accept" forKey:@"tracking_details"];
                        profiledict = [dict mutableCopy];
                        
                        int count = [trackerscount.text intValue];
                        NSMutableDictionary *dict1 = [[profiledict objectForKey:@"tracking_count"] mutableCopy];
                        [dict1 setObject:[NSString stringWithFormat:@"%d",count + 1] forKey:@"tracked_by"];
                        [profiledict setObject:dict1 forKey:@"tracking_count"];
                        
                        if([[profiledict objectForKey:@"tracking_count"] objectForKey:@"tracking"] != [NSNull null])
                            trackingcount.text = [[profiledict objectForKey:@"tracking_count"] objectForKey:@"tracking"];
                    }
                }
                trackerscount.text = [[profiledict objectForKey:@"tracking_count"] objectForKey:@"tracked_by"];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
            }
            else if([requesttype isEqualToString:@"updatephoto"]){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
//                NSString *urlpath = [NSString stringWithFormat:@"%@%@.%@",[profiledict objectForKey:@"profile_pic_path"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"user_id"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"img_extension"]];
                //                        [profileimage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
                profileloader.hidden = NO;
                [profileloader startAnimating];
                
                [profileimage sd_setImageWithURL:[NSURL URLWithString:[tempdict objectForKey:@"img_url"]] placeholderImage:[UIImage imageNamed:@"no_img.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
                    
                    if(error){
                        profileimage.image = [UIImage imageNamed:@"recentdefaultimage"];
                    }
                    else{
                        profileimage.image = image;
                    }
                    profileloader.hidden = YES;
                    [profileloader stopAnimating];
                }];
            }
        else if([requesttype isEqualToString:@"getrewards"]){
           
           rewardsLabel.text = [NSString stringWithFormat:@"%@",[tempdict valueForKey:@"rewards"] ];
            //rewardsLabel.text = [NSString stringWithFormat:@"30"];
            
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

-(IBAction)gotoTracking:(id)sender{
    
    if([sender tag] == 0){
        NSString *reqstatus;
        if([tracklabel.text isEqualToString:@"Tracking"])
            reqstatus = @"un_track";
        else
            reqstatus = @"track";
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trend_track\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"following\": \"%@\",\"request_status\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[[profiledict objectForKey:@"user_detais"] objectForKey:@"user_id"],reqstatus];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
        requesttype = @"trend_track";
    }
    else{
        TrackingList *obj = [[TrackingList alloc] init];
        obj.trackingortrackers = [sender tag] - 1;
        obj.userid = userid;
        [self.navigationController pushViewController:obj animated:YES];
    }
    
}

//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //should be called after rotation animation completed
    [self.contextMenuTableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.contextMenuTableView updateAlongsideRotation];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //should be called after rotation animation completed
        [self.contextMenuTableView reloadData];
    }];
    [self.contextMenuTableView updateAlongsideRotation];
    
}

#pragma mark - IBAction

- (IBAction)presentMenuButtonTapped:(UIBarButtonItem *)sender {
    // init YALContextMenuTableView tableView
    
    if(contextbtn.selected == NO){
        contextbtn.selected = YES;
        contextview.hidden = NO;
        if (!self.contextMenuTableView) {
            self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
            self.contextMenuTableView.animationDuration = 0.15;
            //optional - implement custom YALContextMenuTableView custom protocol
            self.contextMenuTableView.yalDelegate = self;
            
            //register nib
            UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
            [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
        }
        
        // it is better to use this method only for proper animation
        [self.contextMenuTableView showInView:contextview withEdgeInsets:UIEdgeInsetsZero animated:YES];
        
    }
    else{
        contextbtn.selected = NO;
        [self.contextMenuTableView dismisWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        contextview.hidden = YES;
    }
}

#pragma mark - Local methods

- (void)initiateMenuOptions {
    
    self.menuTitles = @[@"Posted Items",
                        @"Reviewed Items",
                        @"Saved Items"];
    
    self.menuIcons = [[NSArray alloc] initWithObjects:@"context_posted_item",@"context_rev_items",@"context_saved_item",nil];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
    contextview.hidden = YES;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
        cell.menuImageView.image = [UIImage imageNamed:[self.menuIcons objectAtIndex:indexPath.row]];        
    }
    
    return cell;
}

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
    contextbtn.selected = NO;
    if(indexPath.row == 0){
        itemsarray = [[profiledict objectForKey:@"posted_items"] mutableCopy];
        subtitlelabel.text = @"Posted Items";
    }
    else if(indexPath.row == 1){
        itemsarray = [[profiledict objectForKey:@"reviewed_items"] mutableCopy];
        subtitlelabel.text = @"Reviewed Items";
        
    }
    else if(indexPath.row == 2){
        itemsarray = [[profiledict objectForKey:@"saved_items"] mutableCopy];
        subtitlelabel.text = @"Saved Items";
    }
    [itemsview reloadData];
    if(itemsarray.count == 0){
        noresultslabel.text = @"No items are available";
        noresultslabel.hidden = NO;
    }
    else
        noresultslabel.hidden = YES;
//    contextview.hidden = YES;
}


-(IBAction)photo:(id)sender{
    
    if([userid integerValue] == [appdelegate.userid integerValue]){
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Choose an option"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Upload From Facebook",@"Take Photo",@"Upload From Camera Roll",@"View Profile Picture", nil];
        
        [sheet showInView:self.view];
    }
    else{
        
        NSString *urlpath = [NSString stringWithFormat:@"%@%@.%@",[profiledict objectForKey:@"profile_pic_path"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"user_id"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"img_extension"]];
        //        [profileimage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
        
        [profileimage imageshow:[NSURL URLWithString:urlpath]];
    }
}

/*-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
////        [self takePhoto];
//        NSString *urlpath = [NSString stringWithFormat:@"%@%@.%@",[profiledict objectForKey:@"profile_pic_path"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"user_id"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"img_extension"]];
////        [profileimage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
//        
//        [profileimage imageshow:[NSURL URLWithString:urlpath]];
    }
    if(buttonIndex == 1)
    {
        [self selectPhoto];
    }
}*/

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 0)
    {
        [self imageFromFacebook];
    }
    else if(buttonIndex == 1)
    {
        [self takePhoto];
    }
    else if(buttonIndex == 2)
    {
        [self selectPhoto];
    }
    else if(buttonIndex == 3)
    {
        NSString *urlpath = [NSString stringWithFormat:@"%@%@.%@",[profiledict objectForKey:@"profile_pic_path"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"user_id"],[[profiledict objectForKey:@"user_detais"] objectForKey:@"img_extension"]];
//        [profileimage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
        
        [profileimage imageshow:[NSURL URLWithString:urlpath]];
    }
}

-(void)imageFromFacebook{
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [self fetchUserInfo];
    }
    else{
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             if (error)
             {
                 // Process error
             }
             else if (result.isCancelled)
             {
                 // Handle cancellations
             }
             else
             {
                 if ([result.grantedPermissions containsObject:@"public_profile"])
                 {
                     NSLog(@"result is:%@",result);
                     [self fetchUserInfo];
                 }
             }
         }];
    }
}

-(void)fetchUserInfo
{
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:@"/me"
                                      parameters:@{@"fields": @"picture"}
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            
            if(error)
                NSLog(@"error---- %@",error);
            else{
                NSLog(@"result---- %@",result);
                NSDictionary *fbprofiledict = (NSDictionary *)result;
                fburl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture??width=320&height=320",[fbprofiledict objectForKey:@"id"]];
                self.picData = nil;
                [self uploadphoto];
            }
            // Handle the result
        }];
    }
}


-(void)takePhoto   // invoke camera in iPhone
{
    imagePicker=[[UIImagePickerController alloc]init];
    imagePicker.delegate=self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [self presentViewController:imagePicker animated:YES completion:NULL];
        //[self presentModalViewController:imagePicker animated:YES];
    }
    
    else
    {
        
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Sorry your device wont support" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    
    
}

-(void)selectPhoto  // to select photo from photo library
{
    imagePicker=[[UIImagePickerController alloc]init];
    imagePicker.delegate=self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum ;
    
    imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [self presentViewController:imagePicker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    //    viewdidappeared = NO;
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    //    viewdidappeared = NO;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *img=[info objectForKey:UIImagePickerControllerEditedImage];
    picData = UIImageJPEGRepresentation([self scaleAndRotateImage:img], 1.0);
    profileimage.image =[UIImage imageWithData:picData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    fburl = @"";
    [self uploadphoto];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image1 {
    int kMaxResolution = 640; // Or whatever
    
    CGImageRef imgRef = image1.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image1.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

-(void)uploadphoto{
    
    viewloaded = NO;
    NSString *url;
    url = [NSString stringWithFormat:@"%@/upload_photo",appdelegate.Clienturl];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"v\"\r\n\r\n%@", appdelegate.apiversion] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"apv\"\r\n\r\n%@", appdelegate.appversion] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"authKey\"\r\n\r\n%@", appdelegate.authkey] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sessionKey\"\r\n\r\n%@", appdelegate.sessionid] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // , flag,file,img_url
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n%@", userid] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"img_url\"\r\n\r\n%@", fburl] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(self.picData){

        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"flag\"\r\n\r\n%@", @"Y"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", @"pic1.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithData:picData]];
    }
    else{
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"flag\"\r\n\r\n%@", @"N"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", @""] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithData:nil]];
    }
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    [obj postrequest:postbody urlstr:url];
    [self startLoader:@"Saving..."];
    requesttype = @"updatephoto";
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return itemsarray.count;
    //        return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = CGSizeMake(([[UIScreen mainScreen] bounds].size.width - 20) / 3, 104);
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SuggestedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SuggestedCell" forIndexPath:indexPath];
    //    cell.activityloader.hidden = YES;
    //    [cell.activityloader stopAnimating];
    //            [itemimage sd_setImageWithURL:[NSURL URLWithString:[productdetail objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@""]];
        if([[itemsarray objectAtIndex:indexPath.row] objectForKey:@"fileNAME"] != [NSNull null]){
            
            cell.activityloader.hidden = NO;
            [cell.activityloader startAnimating];
            NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[itemsarray objectAtIndex:indexPath.row] objectForKey:@"fileNAME"]];
            //        [cell.itemImage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
            [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"no_img.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
                
                if(error){
                    cell.itemImage.image = [UIImage imageNamed:@"recentdefaultimage"];
                }
                else{
                    cell.itemImage.image = image;
                }
                cell.activityloader.hidden = YES;
                [cell.activityloader stopAnimating];
            }];
        }
    else
        cell.itemImage.image = [UIImage imageNamed:@"recentdefaultimage"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if([[[itemsarray objectAtIndex:indexPath.row] objectForKey:@"product"]count]>0){
        ProductDetail *obj = [[ProductDetail alloc] init];
        obj.productid = [[itemsarray objectAtIndex:indexPath.row] objectForKey:@"id"];
        [self.navigationController pushViewController:obj animated:YES];
//    }
}

-(IBAction)settings:(id)sender{
    
    SettingsView *obj = [[SettingsView alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
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
