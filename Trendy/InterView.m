//
//  InterView.m
//  Trendy
//
//  Created by NewAgeSMB on 4/19/16.
//  Copyright © 2016 NewAgeSMB. All rights reserved.
//

#import "InterView.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface InterView ()
{
      AppDelegate *appdelegate;
}
@end

@implementation InterView
@synthesize webtype;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib..
     CGRect frame = webview.frame;
    if ([self.IsIntroducing isEqualToString:@"Y"]) {
//       
//        CGRect dismisbtnFrame = DismissBtn.frame;
//        dismisbtnFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - 50;
//        DismissBtn.frame = dismisbtnFrame;
//        
//        CGRect DismissGreenBtnframe = DismissGreenBtn.frame;
//        DismissGreenBtnframe.origin.y = [[UIScreen mainScreen] bounds].size.height - 50;
//        DismissGreenBtn.frame = dismisbtnFrame;
        
        BackBtn.hidden = YES;
       
        webview.frame = frame;
        DismissBtn.hidden = NO;
        DismissGreenBtn.hidden = NO;
        self.IsIntroducing=@"N";
        webtype =@"UserGuideBegining";
    }
    else{
        
        if ( [[UIScreen mainScreen] bounds].size.height > 667) {
             frame.size.height = [[UIScreen mainScreen] bounds].size.height - 270;
        }else if ( [[UIScreen mainScreen] bounds].size.height == 667){
            frame.size.height = [[UIScreen mainScreen] bounds].size.height - 200;
        }
        else if ( [[UIScreen mainScreen] bounds].size.height < 568) {
            frame.size.height = [[UIScreen mainScreen] bounds].size.height - 40;
        }
        else {
            frame.size.height = [[UIScreen mainScreen] bounds].size.height - 113;
        }
        webview.frame = frame;
         DismissBtn.hidden = YES;
        DismissGreenBtn.hidden = YES;
         webtype =@"UserGuideAfter";
    }
    if(appdelegate.UserGuideAfter && appdelegate.UserGuideBegining){
        [self setwebview];
    }
    else{
          appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"pages\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
    }

    [self setwebview];
  }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
 [TutorialTxtView  scrollRangeToVisible:NSMakeRange(0, 1)];

}

-(void)setwebview{
    
    NSMutableString *searchText = [[NSMutableString alloc] initWithString:@"http://google.com/search?q="];
  
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:searchText]];
    
    [webview loadRequest:urlRequest];

    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([webtype isEqualToString:@"UserGuideBegining"]){
        
       
        
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:appdelegate.UserGuideBegining]];
        
        [webview loadRequest:urlRequest];
    }
        //[webview loadHTMLString:appdelegate.UserGuideBegining baseURL:nil];
    else if([webtype isEqualToString:@"UserGuideAfter"]){
        
        
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:appdelegate.UserGuideAfter]];
        
        [webview loadRequest:urlRequest];

    }
        //[webview loadHTMLString:appdelegate.UserGuideAfter baseURL:nil];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
            appdelegate.UserGuideBegining = [tempdict objectForKey:@"page1"];
            appdelegate.UserGuideAfter = [tempdict objectForKey:@"page2"];
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

-(void)noNetworkFound: (NSNotification *) notification
{
    
    NSString *status=(NSString *)[notification object];
    if (![status boolValue]) {
        
        [self stoploader];
    }
    
}

- (IBAction)BackClkd:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)SkipClkd:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
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
