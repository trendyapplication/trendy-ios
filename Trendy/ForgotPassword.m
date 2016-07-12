//
//  ForgotPassword.m
//  Trendy
//
//  Created by NewAgeSMB on 2/18/16.
//  Copyright (c) 2016 NewAgeSMB. All rights reserved.
//

#import "ForgotPassword.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface ForgotPassword (){
    
    AppDelegate *appdelegate;
    NSString *requesttype;
}

@end

@implementation ForgotPassword

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

-(IBAction)submit:(id)sender{
    
    [self.view endEditing:YES];
    if(emailField.text.length>0 && [self validateEmail:emailField.text type:@"space"]  == NO && [self validateEmail:emailField.text type:@"email"]){
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata;
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"forgot_password\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"email\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,emailField.text];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader];
        requesttype = @"signin";
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter a valid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [emailField becomeFirstResponder];
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



-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
