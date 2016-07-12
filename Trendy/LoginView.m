//
//  LoginView.m
//  Trendy
//
//  Created by NewAgeSMB on 2/16/16.
//  Copyright (c) 2016 NewAgeSMB. All rights reserved.
//

#import "LoginView.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "ForgotPassword.h"
@interface LoginView (){
        
    AppDelegate *appdelegate;
    NSString *requesttype;
    IBOutlet UIView *activationView;
    IBOutlet UITextField *activationField;
    IBOutlet UIScrollView *activationScroll;
    NSDictionary *userDetails;
}

@end

@implementation LoginView
@synthesize notactive;
- (void)viewDidLoad {
    [super viewDidLoad];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidekeyboards:)];
    [activationView addGestureRecognizer:gestureRecognizer];
    [self.view addGestureRecognizer:gestureRecognizer];
    if(notactive == YES){
        activationView.hidden = NO;
    }
    else
        activationView.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)login:(id)sender{
    
    [self.view endEditing:YES];
    UITextField *textField;
    NSString *msg;
    if(userName.text.length>0 && [self validateEmail:userName.text type:@"space"]  == NO){
        
        if(password.text.length>5 && [self validateEmail:password.text type:@"space"]  == NO){
            
            ServerRequest *obj = [[ServerRequest alloc] init];
            obj.delegate = self;
            NSString *postdata;
            postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"Login_user\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_name\": \"%@\",\"password\": \"%@\",\"device_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,userName.text,password.text,appdelegate.devicetoken];
            NSLog(@"%@",postdata);
            [obj serverrequest:postdata];
            [self startLoader];
            requesttype = @"signin";
            return;
        }
        else{
            msg = @"Enter a password with at least six characters";
            textField = password;
        }
    }
    else{
        msg = @"Enter a username or valid email address";
        textField = userName;
    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [textField becomeFirstResponder];
}

- (BOOL) validateEmail: (NSString *) candidate type:(NSString *) type {
    if([type isEqualToString:@"email"]){
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        return [emailTest evaluateWithObject:candidate];
    }
    if([type isEqualToString:@"special"]){
        NSString *emailRegex = @"^[a-zA-Z0-9]*$";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        return [emailTest evaluateWithObject:candidate];
    }
    if([type isEqualToString:@"username"]) {
        
        // NSString *string1 = @"The quick brown fox jumped";
        
        NSRange match;
        
        match = [candidate rangeOfString: @"\""];
        
        //NSLog (@"match found at index %lu", match.location);
        
        //NSLog (@"match length = %u", match.length);
        if(match.length>0)
            return YES;
        else{
            match = [candidate rangeOfString: @"\'"];
            
            //NSLog (@"match found at index %lu", match.location);
            
            //NSLog (@"match length = %u", match.length);
            if(match.length>0)
                return YES;
            else
                return NO;
        }
    }
    if([type isEqualToString:@"space"]) {
        NSString *value = [candidate stringByTrimmingCharactersInSet:[NSCharacterSet    whitespaceCharacterSet]];
        // NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        // NSRange range = [candidate rangeOfCharacterFromSet:whitespace];
        if([value length] == 0) {
            // There is whitespace.
            return YES;
        }
        else
            return NO;
    }
    if([type isEqualToString:@"spaceoccur"]) {
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSRange range = [candidate rangeOfCharacterFromSet:whitespace];
        if (range.location != NSNotFound) {
            return YES;
            // There is whitespace.
        }
    }
    return NO;
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
            
            if([requesttype isEqualToString:@"signin"]){
               
                userDetails = [[tempdict objectForKey:@"user"] mutableCopy];
                
                if([[userDetails objectForKey:@"active_flag"] isEqualToString:@"N"]){
                    
                    appdelegate.userid = [userDetails objectForKey:@"user_id"];
                    [self activationView];
                }
                else{
                    
                    if([[userDetails objectForKey:@"active"] isEqualToString:@"N"]){
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                    else
                    {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        appdelegate.userid = [userDetails objectForKey:@"user_id"];
                        [defaults setObject:NULL forKey:@"fbid"];
                        [defaults setObject:[userDetails objectForKey:@"user_id"] forKey:@"user_id"];
                        [defaults setObject:[userDetails objectForKey:@"userType"] forKey:@"user_type"];
                        [defaults setObject:userName.text forKey:@"username"];
                        [defaults setObject:password.text forKey:@"password"];
                        [defaults synchronize];
                        [appdelegate goToHome:0];
                    }
                }
            }
            else if([requesttype isEqualToString:@"activation"]){
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                appdelegate.userid = [userDetails objectForKey:@"user_id"];
                [defaults setObject:NULL forKey:@"fbid"];
                [defaults setObject:[userDetails objectForKey:@"user_id"] forKey:@"user_id"];
                 [defaults setObject:[userDetails objectForKey:@"userType"] forKey:@"user_type"];
                [defaults setObject:userName.text forKey:@"username"];
                [defaults setObject:password.text forKey:@"password"];
                [defaults synchronize];
                [appdelegate goToHome:0];
                
            }
            else if([requesttype isEqualToString:@"resend"]){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        else{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
            if([requesttype isEqualToString:@"signin"]){
                if([[tempdict objectForKey:@"active"] isEqualToString:@"N"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    password.text = nil;
                }
            }
            else{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                activationField.text = nil;
                //                [appdelegate goToHome:0];
            }
            //                [appdelegate goToHome:0];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //        [appdelegate goToHome:0];
    }
}

-(void)activationView{
    
    if(activationView.hidden == YES){
        [activationField becomeFirstResponder];
        activationView.hidden = NO;
    }
    else
        activationView.hidden = YES;
}

-(IBAction)submitActivationCode:(id)sender{
    
    if(activationField.text.length>0){
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata;
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"verify_activation\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"code\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,activationField.text];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader];
        requesttype = @"activation";
    }
}

-(IBAction)reSendActivationCode:(id)sender{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"send_activation\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader];
    requesttype = @"resend";
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // adding donebn to top bar
    CGRect keyboardBounds;
    [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    //    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //    NSNumber *curve = [aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    //
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // NSDictionary* info = [aNotification userInfo];
    
    [UIView animateWithDuration:0.2f animations:^{
        
        //        if(self.view.frame.size.height == 480)
        //            scroll.contentOffset =  CGPointMake(0, scroll.frame.size.height - keyboardBounds.size.height + 65);
        //        else
        if(activationView.hidden == YES){
            
            CGRect frame = activationScroll.frame;
            frame.origin.y = activationView.frame.size.height - frame.size.height - keyboardBounds.size.height;
            activationScroll.frame = frame;
        }
        else{
            CGRect frame = activationScroll.frame;
            frame.origin.y = activationView.frame.size.height - frame.size.height - keyboardBounds.size.height;
            activationScroll.frame = frame;
        }
        
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == userName)
        [password becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return YES;
}

-(IBAction)forgotpassword:(id)sender{
    [self.navigationController pushViewController:[[ForgotPassword alloc] init] animated:YES];
}
-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)hidekeyboards:(id)sender{
    
    [self.view endEditing:YES];
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
