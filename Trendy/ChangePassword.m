//
//  ChangePassword.m
//  Trendy
//
//  Created by NewAgeSMB on 2/19/16.
//  Copyright (c) 2016 NewAgeSMB. All rights reserved.
//

#import "ChangePassword.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
@interface ChangePassword (){
    
    IBOutlet UITextField *oldPassword, *newPassword, *confirmPassword;
    AppDelegate *appdelegate;
    NSString *requesttype;
    
}

@end

@implementation ChangePassword

- (void)viewDidLoad {
    [super viewDidLoad];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidekeyboards:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)save:(id)sender{
    
    [self.view endEditing:YES];
    UITextField *textField;
    NSString *msg;
    if(oldPassword.text.length>0 && [self validateEmail:oldPassword.text type:@"space"]  == NO){
        
        
        if(newPassword.text.length>5 && [self validateEmail:newPassword.text type:@"space"]  == NO){
            
            if([newPassword.text isEqualToString:confirmPassword.text] ){
                
                
                ServerRequest *obj = [[ServerRequest alloc] init];
                obj.delegate = self;
                NSString *postdata;
                postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"change_password\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"old_password\": \"%@\",\"password\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,oldPassword.text,newPassword.text];
                NSLog(@"%@",postdata);
                [obj serverrequest:postdata];
                [self startLoader];
                requesttype = @"changepass";
                return;
            }
            else{
                msg = @"passwords doesn't match";
                textField = confirmPassword;
                [textField becomeFirstResponder];

            }
        }
        else{
            msg = @"Enter a password with at least six characters";
            textField = newPassword;
            [textField becomeFirstResponder];

        }
    }
    else{
        msg = @"Enter your old password";
        textField = oldPassword;
        [textField becomeFirstResponder];

    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
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
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:newPassword.text forKey:@"password"];
            [defaults synchronize];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            //                [appdelegate goToHome:0];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //        [appdelegate goToHome:0];
    }
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Textfield Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == oldPassword)
        [newPassword becomeFirstResponder];
    else if(textField == newPassword)
        [confirmPassword becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return YES;
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
