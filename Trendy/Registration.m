//
//  Registration.m
//  Trendy
//
//  Created by NewAgeSMB on 2/16/16.
//  Copyright (c) 2016 NewAgeSMB. All rights reserved.
//

#import "Registration.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface Registration ()
{
    AppDelegate *appdelegate;
    NSString *requesttype, *genderval;
    IBOutlet UIView *activationView;
    IBOutlet UITextField *activationField;
    IBOutlet UIScrollView *activationScroll;
    CGFloat keyboardheight;
    NSDictionary *userDetails;
    
}
@end

@implementation Registration

- (void)viewDidLoad {
    [super viewDidLoad];
   
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate startUpdatingCurrentLocation];
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
    scroll.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 550);
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidekeyboards:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [scroll addGestureRecognizer:gestureRecognizer];
    UITapGestureRecognizer *gestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidekeyboards:)];
    [activationView addGestureRecognizer:gestureRecognizer1];
    genderval = @"Female";
    activationView.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)genderSelection:(id)sender{
     UIButton *btn = (UIButton *)sender;
    if ([btn.titleLabel.text isEqualToString:@"Male"]) {
        if (btn.selected == YES) {
            btn.selected = NO;
            genderval = @"Female";
            femaleRadioBtn.selected = NO;
        }else {
            btn.selected = YES;
            genderval = @"Male";
            femaleRadioBtn.selected = NO;

        }
    }
    else if ([btn.titleLabel.text isEqualToString:@"Female"]){
        if (btn.selected == YES) {
            btn.selected = NO;
            genderval = @"Female";
            maleRadioBtn.selected = NO;
        }else {
            btn.selected = YES;
            genderval = @"Female";
            maleRadioBtn.selected = NO;
            
        }
        
    }
    /*if(genderbtn.selected == YES){
        
        genderbtn.selected = NO;
        malelabel.textColor = [UIColor colorWithRed:34.0/255 green:37.0/255 blue:38.0/255 alpha:1];
        femalelabel.textColor = [UIColor colorWithRed:179.0/255 green:102.0/255 blue:23.0/255 alpha:1];
        genderval = @"Male";
    }
    else {
        
        genderbtn.selected = YES;
        femalelabel.textColor = [UIColor colorWithRed:34.0/255 green:37.0/255 blue:38.0/255 alpha:1];
        malelabel.textColor = [UIColor colorWithRed:179.0/255 green:102.0/255 blue:23.0/255 alpha:1];
        genderval = @"Female";
    }*/
}


-(IBAction)submit:(id)sender{
    
    [self.view endEditing:YES];
    UITextField *textField;
    NSString *msg;
    if(fName.text.length>0 && [self validateEmail:fName.text type:@"space"]  == NO){
        
        if(lName.text.length>0 && [self validateEmail:lName.text type:@"space"]  == NO){
           
            if((userName.text.length>0 && [self validateEmail:userName.text type:@"space"]  == NO) || (email.text.length>0 && [self validateEmail:email.text type:@"space"]  == NO && [self validateEmail:email.text type:@"email"])){
                
                if(email.text.length>0){
                   
                    if([self validateEmail:email.text type:@"space"]  == NO && [self validateEmail:email.text type:@"email"]){
                        
                    }
                    else{
                        msg = @"Enter valid email address";
                        textField = email;
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [textField becomeFirstResponder];
                        return;
                    }
                }
                    
                    if(password.text.length>5 && [self validateEmail:password.text type:@"space"]  == NO){
                        
                        NSString *namestr = [NSString stringWithFormat:@"%@ %@",fName.text,lName.text];
                        NSString *usernamestr = @"";
                        if(userName.text.length>0)
                           usernamestr = userName.text;
                        NSString *emailstr = @"";
                        if(email.text.length>0)
                            emailstr = email.text;
                        
                        ServerRequest *obj = [[ServerRequest alloc] init];
                        obj.delegate = self;
                        NSString *postdata;
                        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"registration\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"name\": \"%@\",\"user_name\": \"%@\",\"email\": \"%@\",\"password\": \"%@\",\"gender\": \"%@\",\"uType\": \"normal_user\",\"device_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,namestr,usernamestr,emailstr,password.text,genderval,appdelegate.devicetoken];
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
                textField = email;
            }
        }
        else{
            msg = @"Enter your last name";
            textField = lName;
        }
    }
    else{
        msg = @"Enter your first name";
        textField = fName;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [textField becomeFirstResponder];
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
            
            if([requesttype isEqualToString:@"signin"]){
                
                userDetails = [tempdict mutableCopy];
                
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

                        if(userName.text.length>0)
                            [defaults setObject:userName.text forKey:@"username"];
                        else
                            [defaults setObject:email.text forKey:@"username"];
                        
                        [defaults setObject:password.text forKey:@"password"];
                        [defaults synchronize];
                        [appdelegate goToHome:0];
                    }
                }
                
//                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                appdelegate.userid = [tempdict objectForKey:@"user_id"];
//                [defaults setObject:nil forKey:@"fbid"];
//                if(userName.text.length>0)
//                    [defaults setObject:userName.text forKey:@"username"];
//                else
//                    [defaults setObject:email.text forKey:@"username"];
//                
//                [defaults setObject:password.text forKey:@"password"];
//                [defaults setObject:[tempdict objectForKey:@"user_id"] forKey:@"user_id"];
//                [defaults synchronize];
//                if([[tempdict objectForKey:@"active"] isEqualToString:@"Y"])
//                    [appdelegate goToHome:0];
//                else
//                    [self activationView];
            }
            else if([requesttype isEqualToString:@"activation"]){
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                appdelegate.userid = [userDetails objectForKey:@"user_id"];
                [defaults setObject:NULL forKey:@"fbid"];
                [defaults setObject:[userDetails objectForKey:@"user_id"] forKey:@"user_id"];
                [defaults setObject:[userDetails objectForKey:@"userType"] forKey:@"user_type"];
                if(userName.text.length>0)
                    [defaults setObject:userName.text forKey:@"username"];
                else
                    [defaults setObject:email.text forKey:@"username"];
                
                [defaults setObject:password.text forKey:@"password"];
                [defaults synchronize];
                [appdelegate goToHome:0];
            }
            else if([requesttype isEqualToString:@"resend"]){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            //            else if([requesttype isEqualToString:@"signin"]){
            //
            //                [self activationView];
            //            }
            
        }
        else{
            
            if([requesttype isEqualToString:@"signin"]){
                if([[tempdict objectForKey:@"active"] isEqualToString:@"N"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }
            else{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                activationField.text = nil;
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
    scroll.scrollEnabled = NO;
    CGRect keyboardBounds;
    [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    //    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //    NSNumber *curve = [aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    //
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    keyboardheight = keyboardBounds.size.height;
    // NSDictionary* info = [aNotification userInfo];
    
    [UIView animateWithDuration:0.2f animations:^{
        
        //        if(self.view.frame.size.height == 480)
        //            scroll.contentOffset =  CGPointMake(0, scroll.frame.size.height - keyboardBounds.size.height + 65);
        //        else
        if(activationView.hidden == YES){
            if((scroll.frame.size.height - keyboardheight) <= (lasttext.frame.origin.y + lasttext.frame.size.height))
                scroll.contentOffset =  CGPointMake(0, (lasttext.frame.origin.y + lasttext.frame.size.height) - (scroll.frame.size.height - keyboardheight)+1);
            CGRect frame = activationScroll.frame;
            frame.origin.y = activationView.frame.size.height - frame.size.height - keyboardheight;
            activationScroll.frame = frame;
        }
        else{
            CGRect frame = activationScroll.frame;
            frame.origin.y = activationView.frame.size.height - frame.size.height - keyboardheight;
            activationScroll.frame = frame;
        }
        
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    scroll.scrollEnabled = YES;
    // scroll.contentOffset =  CGPointMake(0, 0);
}

#pragma mark Textfield Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    lasttext = textField;
    scroll.scrollEnabled = NO;
    [self setScrollContentOffset];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == fName)
        [lName becomeFirstResponder];
    else if(textField == lName)
        [email becomeFirstResponder];
    else if(textField == email)
        [userName becomeFirstResponder];
    else if(textField == userName)
        [password becomeFirstResponder];
    else if(textField == activationField)
        [textField resignFirstResponder];
    else
        [self hidekeyboards:nil];
    return YES;
}

-(void)setScrollContentOffset{
    
    if((scroll.frame.size.height - keyboardheight) <= (lasttext.frame.origin.y + lasttext.frame.size.height))
        scroll.contentOffset =  CGPointMake(0, (lasttext.frame.origin.y + lasttext.frame.size.height) - (scroll.frame.size.height - keyboardheight)+1);
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)hidekeyboards:(id)sender{
    
    scroll.scrollEnabled = YES;
    scroll.contentOffset = CGPointMake(0, 0);
    [lasttext resignFirstResponder];
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
