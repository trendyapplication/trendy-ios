//
//  ViewController.m
//  Trendy
//
//  Created by NewAgeSMB on 8/3/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "TermsAndPrivacy.h"
#import "LoginView.h"
#import "Registration.h"
#import "InterView.h"

@interface ViewController (){
    
    IBOutlet UITextView *titletext;
    BOOL gotkeys;
    IBOutlet UIView *overlayview;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate startUpdatingCurrentLocation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
//    FBSDKLoginManagerzz *obj = [[FBSDKLoginManager alloc] init];
//    [obj logOut];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyvalues:) name:@"SECUREKEYS"  object:nil];
        [self performSelector:@selector(autologin) withObject:nil afterDelay:0.5];
    
  //  NSString *title = [NSString stringWithFormat:@"# By Signing up you agree to the #<name>Terms of Service & Privacy Policy#"];
//    [ self buildAgreeTextViewFromString:NSLocalizedString(title,
//                                                          @"PLEASE NOTE: please translate \"terms of service\" and \"privacy policy\" as well, and leave the #<ts># and #<tag># around your translations just as in the English version of this message.") textview:cell.titiletext];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [ self buildAgreeTextViewFromString:NSLocalizedString(@"By Signing up you agree to the #<ts>terms of service# & #<tag>privacy policy#",
//                                                              @"PLEASE NOTE: please translate \"terms of service\" and \"privacy policy\" as well, and leave the #<ts># and #<tag># around your translations just as in the English version of this message.") textview:titletext];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)buildAgreeTextViewFromString:(NSString *)localizedString textview:(UITextView *)textview;
{
    // 1. Split the localized string on the # sign:
    NSArray *localizedStringPieces = [localizedString componentsSeparatedByString:@"#"];
    
    // 2. Loop through all the pieces:
    NSUInteger msgChunkCount = localizedStringPieces ? localizedStringPieces.count : 0;
    CGPoint wordLocation = CGPointMake(0.0, 0.0);
    for (NSUInteger i = 0; i < msgChunkCount; i++)
    {
        NSString *chunk = [localizedStringPieces objectAtIndex:i];
        if ([chunk isEqualToString:@""])
        {
            continue;     // skip this loop if the chunk is empty
        }
        
        // 3. Determine what type of word this is:
        BOOL istsLink = [chunk hasPrefix:@"<ts>"];
        BOOL istagLink  = [chunk hasPrefix:@"<tag>"];
        BOOL isLink = (BOOL)(istsLink || istagLink);
        
        // 4. Create label, styling dependent on whether it's a link:
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"OpenSans" size:14];
        label.text = chunk;
        label.tag = textview.tag;
        label.userInteractionEnabled = isLink;
        float ypoint = 8;
        if (isLink)
        {
            label.textColor = [UIColor blackColor];
            label.highlightedTextColor = [UIColor blackColor];
            label.font = [UIFont fontWithName:@"OpenSans" size:14];
            // 5. Set tap gesture for this clickable text:
            SEL selectorAction = istsLink ? @selector(tapOntsLink:) : @selector(tapOntagLink:);
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:selectorAction];
            [label addGestureRecognizer:tapGesture];
            
            
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"My Messages"];
            [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                              value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                              range:(NSRange){0,[attString length]}];
            label.attributedText = attString;
            
            // Trim the markup characters from the label:
            if (istsLink) label.text = [label.text stringByReplacingOccurrencesOfString:@"<ts>" withString:@""];
            if (istagLink)  label.text = [label.text stringByReplacingOccurrencesOfString:@"<tag>" withString:@""];
        }
        else
        {
            label.textColor = [UIColor colorWithRed:173/255.0f green:172/255.0f blue:172/255.0f alpha:1.0];
            ypoint = 9;
        }
        
        // 6. Lay out the labels so it forms a complete sentence again:
        
        // If this word doesn't fit at end of this line, then move it to the next
        // line and make sure any leading spaces are stripped off so it aligns nicely:
        
        [label sizeToFit];
        
        if (textview.frame.size.width < wordLocation.x + label.bounds.size.width)
        {
            wordLocation.x = 0.0;                       // move this word all the way to the left...
            wordLocation.y += label.frame.size.height;  // ...on the next line
            
            // And trim of any leading white space:
            NSRange startingWhiteSpaceRange = [label.text rangeOfString:@"^\\s*"
                                                                options:NSRegularExpressionSearch];
            if (startingWhiteSpaceRange.location == 0)
            {
                label.text = [label.text stringByReplacingCharactersInRange:startingWhiteSpaceRange
                                                                 withString:@""];
                [label sizeToFit];
            }
        }
        
        // Set the location for this label:
        label.frame = CGRectMake(wordLocation.x+6,
                                 wordLocation.y+ypoint,
                                 label.frame.size.width,
                                 label.frame.size.height);
        // Show this label:
        [textview addSubview:label];
        
        // Update the horizontal position for the next word:
        wordLocation.x += label.frame.size.width;
    }
}

- (void)tapOntsLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
      //  NSLog(@"--tag---%ld",(long)tapGesture.view.tag);
        NSLog(@"User tapped on ts");
      //  NSLog(@"---index -- %ld",(long)[[tapGesture view] tag]);
        
    }
}

- (void)tapOntagLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
      //  NSLog(@"--tag---%ld",(long)tapGesture.view.tag);
        NSLog(@"User tapped on the tag");
      //  NSLog(@"---index -- %ld",(long)[[tapGesture view] tag]);
    }
}*/

-(void)keyvalues: (NSNotification *) notification
{
    gotkeys = YES;
    
//    [self autologin];
}

-(void)autologin{
   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"user_id"]){
        appdelegate.userid = [defaults objectForKey:@"user_id"];
        [appdelegate goToHome:0];
        overlayview.hidden = YES;
    }
    else{
        overlayview.hidden = YES;
        if([defaults objectForKey:@"fbid"]){
           
            ServerRequest *obj = [[ServerRequest alloc] init];
            obj.delegate = self;
            NSString *postdata;
            NSString *fbid = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"fbid"]];
            //    postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"login_with_fb\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"fb_unique_id\": \"%@\",\"device_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,[defaults objectForKey:@"fbid"],appdelegate.devicetoken];
            
            postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"login_with_fb\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"fb_unique_id\": \"%@\",\"device_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,fbid,appdelegate.devicetoken];
            NSLog(@"%@",postdata);
            [obj serverrequest:postdata];
            [self startLoader];
            requesttype = @"signin";
        }
        else if([defaults objectForKey:@"username"] && [defaults objectForKey:@"password"]){
            
            ServerRequest *obj = [[ServerRequest alloc] init];
            obj.delegate = self;
            NSString *postdata;
            postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"Login_user\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_name\": \"%@\",\"password\": \"%@\",\"device_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,[defaults objectForKey:@"username"],[defaults objectForKey:@"password"],appdelegate.devicetoken];
            NSLog(@"%@",postdata);
            [obj serverrequest:postdata];
            [self startLoader];
            requesttype = @"signin";
        }
    }
}

-(void)signup{
    
    if(fbprofiledict){
        NSString *str = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture??width=320&height=320",[fbprofiledict objectForKey:@"id"]];
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata;
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"fb_registration\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"fb_unique_id\": \"%@\",\"name\": \"%@\",\"user_email\": \"%@\",\"user_gender\": \"%@\",\"fburl\": \"%@\",\"uType\": \"fbaccount\",\"device_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,[fbprofiledict objectForKey:@"id"],[fbprofiledict objectForKey:@"name"],@"",[fbprofiledict objectForKey:@"gender"],str,appdelegate.devicetoken];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader];
        requesttype = @"signup";
    }
    else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:@"fbid"];
        [defaults synchronize];
        [self fblogin:nil];
    }
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
            
            //            appdelegate.userdetails = [tempdict mutableCopy];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //            if([requesttype isEqualToString:@"login"]){
            appdelegate.userid = [tempdict objectForKey:@"user_id"];
            [defaults setObject:[tempdict objectForKey:@"fb_unique_id"] forKey:@"fbid"];
            [defaults setObject:[tempdict objectForKey:@"user_id"] forKey:@"user_id"];
            [defaults setObject:[tempdict objectForKey:@"userType"] forKey:@"user_type"];
            [defaults synchronize];
            [appdelegate goToHome:0];
            
            //            }
        }
        else{
            
            if([requesttype isEqualToString:@"signin"]){
               
                if([[tempdict objectForKey:@"active"] isEqualToString:@"N"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                else
                    [self signup];
            }
            else{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
//                [appdelegate goToHome:0];
            }
            
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
//        [appdelegate goToHome:0];        
    }
}

-(IBAction)termsnprivacy:(id)sender{
   
    TermsAndPrivacy *obj = [[TermsAndPrivacy alloc] init];
    if([sender tag] == 0)
        obj.webtype = @"TERMS OF SERVICES";
    else
        obj.webtype = @"PRIVACY POLICY";
    obj.loggedIn = NO;
    [self.navigationController pushViewController:obj animated:YES];

}

-(IBAction)fblogin:(id)sender{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"fbid"]){
        if ([FBSDKAccessToken currentAccessToken]) {
            
            [self fetchUserInfo];
        }
        else{
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            [login logInWithReadPermissions:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
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
    else
        [self autologin];
}

-(void)fetchUserInfo
{
//    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection,
//     id result,
//     NSError *error) {
//         
//         if(error)
//             NSLog(@"error---- %@",error);
//         else
//             NSLog(@"result---- %@",result);
//         // Handle the result
//     }];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:@"/me"
                                      parameters:@{@"fields": @"picture,email,birthday,gender,name"}
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            
            if(error)
                NSLog(@"error---- %@",error);
            else{
                NSLog(@"result---- %@",result);
                fbprofiledict = (NSDictionary *)result;
                ServerRequest *obj = [[ServerRequest alloc] init];
                obj.delegate = self;
                NSString *postdata;
                postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"login_with_fb\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"fb_unique_id\": \"%@\",\"device_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,[fbprofiledict objectForKey:@"id"],appdelegate.devicetoken];
                NSLog(@"%@",postdata);
                [obj serverrequest:postdata];
                [self startLoader];
                requesttype = @"signin";
            }
            // Handle the result
        }];
    }
}

-(IBAction)login:(id)sender{
    
    [self.navigationController pushViewController:[[LoginView alloc] init] animated:YES];
}

-(IBAction)signUp:(id)sender{
    [self.navigationController pushViewController:[[Registration alloc] init] animated:YES];
}

-(void)noNetworkFound: (NSNotification *) notification
{
    NSString *status=(NSString *)[notification object];
    if (![status boolValue]) {
        
        [self stoploader];
    }
    
}

-(void)startLoader
{
    MBProgressHUD *objOfHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    objOfHUD.labelText = @"Loading...";
    
}
-(void) stoploader{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)stopLoader:(NSNotification *) notification{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


@end
