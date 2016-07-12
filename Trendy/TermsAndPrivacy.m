//
//  TermsAndPrivacy.m
//  Trendy
//
//  Created by NewAgeSMB on 9/22/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "TermsAndPrivacy.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
@interface TermsAndPrivacy (){
    
    IBOutlet UIWebView *webview;
    IBOutlet UILabel *titlelabel;
    AppDelegate *appdelegate;
}

@end

@implementation TermsAndPrivacy
@synthesize webtype,loggedIn;
- (void)viewDidLoad {
    [super viewDidLoad];
    titlelabel.text = webtype;
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appdelegate.termshtml && appdelegate.privacyhtml){
        [self setwebview];
    }
    else{
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_cms_datas\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    CGRect frame = webview.frame;
    if(loggedIn == NO)
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - 70;
    else
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - 119;
    webview.frame = frame;
}


-(void)setwebview{
    
    if([webtype isEqualToString:@"PRIVACY POLICY"])
        [webview loadHTMLString:appdelegate.privacyhtml baseURL:nil];
    else if([webtype isEqualToString:@"TERMS OF SERVICES"])
        [webview loadHTMLString:appdelegate.termshtml baseURL:nil];
    
}

-(void) viewDidAppear:(BOOL)animated{
    
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
            appdelegate.privacyhtml = [tempdict objectForKey:@"privacy"];
            appdelegate.termshtml = [tempdict objectForKey:@"terms"];
            [self setwebview];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error%@",error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
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
