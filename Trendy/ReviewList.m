//
//  ReviewList.m
//  Trendy
//
//  Created by NewAgeSMB on 9/9/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "ReviewList.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "ReviewCell.h"
#import "ProfileView.h"

@interface ReviewList (){
    
    IBOutlet UITableView *reviewtable;
    AppDelegate *appdelegate;
    NSInteger deletedindex;
    NSString *requesttype, *filepath;
    NSMutableArray *reviewarray;
}

@end

@implementation ReviewList
@synthesize productid,viewonly;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    reviewarray = [[NSMutableArray alloc] init];
    [self getallreviews];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
}

-(void)getallreviews{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_reviews_full\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"product_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,productid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"reviews";
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        if([requesttype isEqualToString:@"reviews"]){
            reviewarray = [[tempdict objectForKey:@"review"] mutableCopy];
            [reviewtable reloadData];
        }
        else if([requesttype isEqualToString:@"review_rating"]){
        
            if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
                
//                if([requesttype isEqualToString:@"review_rating"]){
                
                    
                    NSMutableDictionary *dict = [[reviewarray objectAtIndex:deletedindex] mutableCopy];
                    [dict setObject:[NSString stringWithFormat:@"%d",[[tempdict objectForKey:@"review_count"] intValue]] forKey:@"reviewRateCount"];
                    [dict setObject:@"YES" forKey:@"vote_status"];
                    [reviewarray replaceObjectAtIndex:deletedindex withObject:dict];
                    if([[tempdict objectForKey:@"review_count"] intValue] == 3){
                        [reviewarray removeObjectAtIndex:deletedindex];
                        
                    }
                    [reviewtable reloadData];
//                }
            }
            else{
                
            }
        }
        else if([requesttype isEqualToString:@"review_delete"]){
           
            if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
                [self.deletedelegate deleteindex:deletedindex];
                [reviewarray removeObjectAtIndex:deletedindex];
                [reviewtable reloadData];
                if(reviewarray.count==0)
                    [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else{
            
        }
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *msg = @"";
    if([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"review"] != [NSNull null])
        msg = [[reviewarray objectAtIndex:indexPath.row] objectForKey:@"review"];
    
    msg = [msg stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    UIFont *font = [UIFont fontWithName:@"Avenir-Heavy" size:13.0];
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:msg
     attributes:@
     {
     NSFontAttributeName: font
     }];
    CGSize messageSize = [attributedText boundingRectWithSize:(CGSize){self.view.frame.size.width - 33, CGFLOAT_MAX}
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                      context:nil].size;
    
    if(messageSize.height<49)
        messageSize.height = 53;
    else
        messageSize.height = (messageSize.height /24 +1)*24;
    return messageSize.height + 24;
    return 90;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger )section{
    
    return reviewarray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellidentifier =@"cell";
    ReviewCell *cell = (ReviewCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if(cell==nil)
    {
        NSString *nib = @"ReviewCell";
        NSArray *viewObjcts = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
        for(id crntObj in viewObjcts){
            
            if ([crntObj isKindOfClass:[UITableViewCell class]]) {
                
                cell = crntObj;
                break;
            }
        }
    }
    cell.reviewtextview.hidden = NO;
    cell.reviewtext.hidden = YES;
    NSString *msg = @"";
    if([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"review"] != [NSNull null])
        msg = [[reviewarray objectAtIndex:indexPath.row] objectForKey:@"review"];
    
    msg = [msg stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    UIFont *font = [UIFont fontWithName:@"Avenir-Heavy" size:13.0];
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:msg
     attributes:@
     {
     NSFontAttributeName: font
     }];
    CGSize messageSize = [attributedText boundingRectWithSize:(CGSize){self.view.frame.size.width - 33, CGFLOAT_MAX}
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                      context:nil].size;
    
    if(messageSize.height<32)
        messageSize.height = 48;
    else
        messageSize.height = (messageSize.height /24 +1)*25;
    
    CGRect commentsframe = cell.reviewtextview.frame;
    commentsframe.size.height = messageSize.height;
    cell.reviewtextview.frame = commentsframe;
    
    //        cell.commentstext.frame = CGRectMake(49, 27, self.view.frame.size.width - 82, messageSize.height);
    
    CGRect commentsbottomviewframe = cell.seperatorimage.frame;
    commentsbottomviewframe.origin.y = messageSize.height + 20;
    cell.seperatorimage.frame = commentsbottomviewframe;
    
    cell.reviewownername.text = [[reviewarray objectAtIndex:indexPath.row] objectForKey:@"username"];
    cell.reviewtextview.text = msg;
    
    
    if(([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] != [NSNull null] && [[[reviewarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] isEqualToString:@"YES"]))
        cell.deletebtn.hidden = YES;
    else
        cell.deletebtn.hidden = NO;
    
    if([[[reviewarray objectAtIndex:indexPath.row] objectForKey:@"user_id"] integerValue] == [appdelegate.userid integerValue]){
        cell.deletebtn.selected = YES;
        cell.deletebtn.hidden = NO;
    }
    else
        cell.deletebtn.selected = NO;
//    cell.deletebtn.tag = indexPath.row;
//    [cell.deletebtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    cell.reviewownerbtn.tag = indexPath.row;
    [cell.reviewownerbtn addTarget:self action:@selector(goToReviewOwner:) forControlEvents:UIControlEventTouchUpInside];
    if(viewonly == NO){
        
        cell.deletebtn.tag = indexPath.row;
        [cell.deletebtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        cell.deletebtn.hidden = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(IBAction)goToReviewOwner:(id)sender{
    
    ProfileView *obj = [[ProfileView alloc] init];
    obj.userid = [[reviewarray objectAtIndex:[sender tag]] objectForKey:@"user_id"];
    obj.navigated = YES;
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)delete:(id)sender{
    
    deletedindex = [sender tag];

    if([[[reviewarray objectAtIndex:[sender tag]] objectForKey:@"user_id"] integerValue] == [appdelegate.userid integerValue]){
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this review?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
        [alert show];
    }
    else{
        
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"review_rating\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"review_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[[reviewarray objectAtIndex:[sender tag]] objectForKey:@"review_id"]];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
        requesttype = @"review_rating";
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 0){
        
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"delete_reviews\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"review_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[[reviewarray objectAtIndex:deletedindex] objectForKey:@"review_id"]];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
        requesttype = @"review_delete";
    }
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
