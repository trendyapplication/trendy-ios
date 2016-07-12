//
//  ServerRequest.h
//  Jzoog
//
//  Created by newagesmb on 4/24/14.
//  Copyright (c) 2014 newagesmb. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppDelegate;
@protocol delegaterequest <NSObject>

-(void) serverresponse:(NSMutableData *)response;

@end

@interface ServerRequest : NSObject{
    
    id<delegaterequest>delegate;
    NSMutableData *webData;
    AppDelegate *appdelegate;
    NSURLConnection *conn;
}

@property (retain, nonatomic) id<delegaterequest>delegate;
-(void)serverrequest:(NSString *)request1;

//-(void)login:(NSString *)type fbinstid:(NSString *)fbinstid username:(NSString *)username; 

-(void)createprofilestep1:(NSDictionary *)bits  file:(NSData *)file username:(NSString *)username email:(NSString*)email phone:(NSString *)phone dob:(NSString *)dob name:(NSString *)name facebook_image_url:(NSString *) facebook_image_url google_image_url:(NSString *)google_image_url edit:(NSString *)edit coach:(BOOL)coach instructn:(NSString *)instructn aboutme:(NSString *)aboutme;

-(void)postrequest:(NSMutableData *)postbody urlstr:(NSString *)urlstr;

@end
