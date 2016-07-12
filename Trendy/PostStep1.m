//
//  PostStep1.m
//  Trendy
//
//  Created by NewAgeSMB on 8/10/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "PostStep1.h"
#import "PostStep2.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface PostStep1 (){
    
    IBOutlet UIWebView *webview;
    IBOutlet UITextField *urlfield;
    NSString *currentURL;
    NSString *requesttype;
    NSString *genderofUser;
    AppDelegate *appdelegate;
    IBOutlet UIButton *backButton, *overlaybtn;
    float framey;
    BOOL scrolled;
    IBOutlet UIView *alertview;
    
}


@end

@implementation PostStep1

@synthesize urlstring;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!urlstring)
        urlstring = @"http://google.com";
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]]];
    overlaybtn.hidden = NO;
    currentURL = webview.request.URL.absoluteString;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    UIScrollView* scrollView = nil;
    for (UIView* subview in [webview subviews]) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView*)subview;
            scrollView.delegate = self;
            break;
        }
    }
    scrolled = YES;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}

-(void) viewDidAppear:(BOOL)animated{
    
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    overlaybtn.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error%@",error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    overlaybtn.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    currentURL = webview.request.URL.absoluteString;
    urlfield.text = currentURL;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    overlaybtn.hidden = YES;
    if (webview.canGoBack)
    {
        backButton.hidden = NO;
    }
    else
    {
        backButton.hidden = YES;
    }
}

-(IBAction)createnew:(id)sender{
    
    PostStep2 *obj = [[PostStep2 alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)clearfield:(id)sender{
   
    urlfield.text = nil;
//    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
//    currentURL = webview.request.URL.absoluteString;
}

-(IBAction)goback:(id)sender{
    
    if ([webview canGoBack]) {
        [webview goBack];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if(scrollView.contentOffset.y>0 && scrollView.contentOffset.y >= 40) {
//        NSLog(@"--contentOffset.y-- %f",scrollView.contentOffset.y);
        CGRect frame = webview.frame;
        frame.origin.y = 70;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - 126;
        webview.frame = frame;
    }
    else{
        
        CGRect frame = webview.frame;
        frame.origin.y = 120;
        frame.size.height = [[UIScreen mainScreen] bounds].size.height - 176;
        webview.frame = frame;
//        webview.scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

-(IBAction)alertactions:(id)sender{
    
    if([sender tag] == 0){
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            alertview.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished){
            alertview.hidden=YES;
        }];
    }
    else if([sender tag] == 1){
        
        PostStep2 *obj = [[PostStep2 alloc] init];
        obj.genderUser = genderofUser;
        obj.producturl = [urlfield.text mutableCopy];
        [self.navigationController pushViewController:obj animated:YES];
    }
}

#pragma mark Textfield Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
  
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    NSString *myURLString = textField.text;
    NSURL *myURL;
    if ([myURLString.lowercaseString hasPrefix:@"http://www."]) {
        myURL = [NSURL URLWithString:myURLString];
    }
    else if ([myURLString.lowercaseString hasPrefix:@"www."]) {
        myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",myURLString]];
    }
    else if ([myURLString.lowercaseString hasPrefix:@"http://"]) {
        myURL = [NSURL URLWithString:myURLString];
    }
    if(myURL)
        [webview loadRequest:[NSURLRequest requestWithURL:myURL]];
    
    else{
        NSMutableString *searchText = [[NSMutableString alloc] initWithString:@"http://google.com/search?q="];
        [searchText appendString:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:searchText]];
        
        [webview loadRequest:urlRequest];
    }
    overlaybtn.hidden = NO;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    return YES;
}

-(IBAction)poststep2:(id)sender{
    
//    [self createnew:nil];
    if(urlfield.text.length>0){
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trendy_save_link\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"link\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,urlfield.text];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
        requesttype = @"postlink";
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter valid url" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [urlfield becomeFirstResponder];
    }
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        if([requesttype isEqualToString:@"postlink"]){
            
             if([tempdict objectForKey:@"user"]!= [NSNull null]){
                 genderofUser = [NSString stringWithFormat:@"%@",[tempdict objectForKey:@"user"] ];
                 
             }
            if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
                
                if([[tempdict objectForKey:@"image_array"] count] > 0){
                    
                    PostStep2 *obj = [[PostStep2 alloc] init];
                    obj.productdetail = [tempdict mutableCopy];
                    obj.producturl = [urlfield.text mutableCopy];
                    obj.genderUser = genderofUser;
                    [self.navigationController pushViewController:obj animated:YES];
                }
                else{
                   
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Website not yet approved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];
                    [self websiteNotYetApprooved];
                    
                }
            }
            else{
               
                [self websiteNotYetApprooved];
                
            }
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void)websiteNotYetApprooved{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"error_reporting\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"link\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,urlfield.text];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    requesttype = @"reportlink";
    
    alertview.hidden=NO;
    alertview.transform = CGAffineTransformMakeScale(0.05, 0.05);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        alertview.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // do something once the animation finishes, put it here
    }];
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
