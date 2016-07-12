//
//  Contact.m
//  Trendy
//
//  Created by NewAgeSMB on 9/21/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "Contact.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "ServerRequest.h"
@interface Contact ()<delegaterequest>{
    
    IBOutlet UITextField *namefield, *emailfield;
    IBOutlet UITextView *commentview;
    IBOutlet UIScrollView *scroll;
    AppDelegate *appdelegate;
    NSString *requesttype;
}

@end

@implementation Contact

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidekeyboards:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    commentview.textColor = [UIColor lightGrayColor];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)submit:(id)sender{
    
    [self.view endEditing:YES];
    if(namefield.text.length>0 && [self validateEmail:namefield.text type:@"space"]  == NO){
        
        
        if(emailfield.text.length>0 && [self validateEmail:emailfield.text type:@"space"]  == NO){
            
            if([self validateEmail:emailfield.text type:@"email"]){
                
                NSString *comment = @"";
                if(![commentview.text isEqualToString:@"Comment"] && [self validateEmail:commentview.text type:@"space"]  == NO){
                    comment = commentview.text;
                    comment = [commentview.text stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                    
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"please enter comments" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [commentview becomeFirstResponder];
                    return;
                }
                ServerRequest *obj = [[ServerRequest alloc] init];
                obj.delegate = self;
                NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"contact\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"name\": \"%@\",\"from_email\": \"%@\",\"message\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,namefield.text,emailfield.text,comment];
                NSLog(@"%@",postdata);
                [obj serverrequest:postdata];
                [self startLoader:@"Loading..."];
                requesttype = @"contact";
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Email address is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [emailfield becomeFirstResponder];
                return;
            }
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
            [alert show];
            [emailfield becomeFirstResponder];
            return;
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [namefield becomeFirstResponder];
        return;
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
    }
}

#pragma mark Textfield Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView1{
    
    if([textView1.text isEqualToString:@"Comment"]){
        textView1.text = NULL;
        textView1.textColor = [UIColor blackColor];
    }
    else{
        textView1.textColor = [UIColor lightGrayColor];
    }
    scroll.contentOffset = CGPointMake(0, textView1.frame.origin.y - 40);
}
- (void)textViewDidEndEditing:(UITextView *)textView1{
    
    if([self validateEmail:textView1.text type:@"space"]  == YES){
        textView1.text = @"Comment";
        
        textView1.textColor = [UIColor lightGrayColor];
    }
    else{
        textView1.textColor = [UIColor blackColor];
    }
    [self.view endEditing:YES];
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)hidekeyboards:(id)sender{
    
    [self.view endEditing:YES];
    scroll.contentOffset = CGPointMake(0, 0);
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
