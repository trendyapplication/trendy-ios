//
//  ServerRequest.m
//  Copyright (c) 2014 newagesmb. All rights reserved.
//

#import "ServerRequest.h"
#import "AppDelegate.h"
@implementation ServerRequest
@synthesize delegate;

-(void)serverrequest:(NSString *)request1{
    
    appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
	if (appdelegate.networkAvailable) {
    
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
        
        NSData *postData = [request1 dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSLog(@"appdelegate.Clienturl==>%@",appdelegate.Clienturl);
        [request setURL:[NSURL URLWithString:appdelegate.Clienturl]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        [request setTimeoutInterval:60.0];
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (conn) {
            webData = [[NSMutableData alloc]init];
        }
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Connect To Internet!!!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [appdelegate displayNetworkAvailability:self];
    }
}

-(void)postrequest:(NSDictionary *)dictionary{
    
    appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (appdelegate.networkAvailable) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
        
        NSError *error = nil;
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        
//        NSData *postData = [request1 dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSLog(@"appdelegate.Clienturl==>%@",appdelegate.Clienturl);
        [request setURL:[NSURL URLWithString:appdelegate.Clienturl]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        [request setTimeoutInterval:20.0];
        
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (conn) {
            webData = [[NSMutableData alloc]init];
        }
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Connect To Internet!!!"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [appdelegate displayNetworkAvailability:self];
    }
}

-(void)createprofilestep1:(NSDictionary *)bits  file:(NSData *)file username:(NSString *)username email:(NSString*)email phone:(NSString *)phone dob:(NSString *)dob name:(NSString *)name facebook_image_url:(NSString *) facebook_image_url google_image_url:(NSString *)google_image_url edit:(NSString *)edit coach:(BOOL)coach instructn:(NSString *)instructn aboutme:(NSString *)aboutme

{

    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSString *str = [appdelegate.Clienturl stringByReplacingOccurrencesOfString:@"-response.php" withString:@"-register.php"];
    NSString * urlString = [NSString stringWithFormat:@"%@/profile_step_1",appdelegate.Clienturl];
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:240.0];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
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
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n%@", appdelegate.userid] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_email\"\r\n\r\n%@", email] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_phone\"\r\n\r\n%@", phone] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_dob\"\r\n\r\n%@", dob] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"name\"\r\n\r\n%@", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image_edit\"\r\n\r\n%@", edit] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"facebook_image_url\"\r\n\r\n%@", facebook_image_url] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"google_image_url\"\r\n\r\n%@", google_image_url] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(coach == YES){
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"coach_instructions\"\r\n\r\n%@", instructn] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"about_me\"\r\n\r\n%@", aboutme] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSLog(@"file ---- %@",[bits objectForKey:@"filename"]);
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", [bits objectForKey:@"filename"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:file]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postbody];
    
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        webData = [NSMutableData data];
    }

}

-(void)postrequest:(NSMutableData *)postbody urlstr:(NSString *)urlstr{
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlstr]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:240.0];
    
    // NSLog(@"appdelegate.uid %@",appdelegate.uid);
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody:postbody];
    
    //NSLog(@"postbody==========>%@",postbody);
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        webData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"webdata==%@",webData);
    [webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
 
    [webData appendData:data];
}
//If there is an error during the transmission, the connection:didFailWithError: method will be called:

-(void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error
{
    NSLog(@"error --- %@",error);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Server time out."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    [connection start];
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STOPLOADER"  object:nil];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
	
	
}
//When the connection has finished and succeeded in downloading the response, the connectionDidFinishLoading: method will be called:

-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
    
    NSLog(@"DONE. Received Bytes: %lu", (unsigned long)[webData length]);
    NSString *jsonString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    NSLog(@"DONE. Received Bytes: %@",jsonString);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.delegate serverresponse:webData];
}
@end
