//
//  TrackingList.m
//  Trendy
//
//  Created by NewAgeSMB on 9/24/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "TrackingList.h"
#import "TrackingCell.h"
#import "AppDelegate.h"
#import "ServerRequest.h"
#import "MBProgressHUD.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ProfileView.h"

@interface TrackingList ()<delegaterequest>{
    
    IBOutlet UITableView *trackingtable;
    IBOutlet UITextField *searchField;
    NSMutableArray *trackaroundarray, *trackingarray, *tracksearcharray;
    AppDelegate *appdelegate;
    NSString *requesttype, *filepath;
    IBOutlet UILabel *noresultslabel, *tittlelabel;
    NSInteger trackindex;
    BOOL refresh;
}

@end

@implementation TrackingList
@synthesize trackingortrackers,userid;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshlist:) name:@"REFRESHLIST"  object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    trackaroundarray = [[NSMutableArray alloc] init];
    tracksearcharray = [[NSMutableArray alloc] init];
    trackingarray = [[NSMutableArray alloc] init];
    [self gettrackers];
    if(trackingortrackers == 1)
        tittlelabel.text = @"Tracking";
    else
        tittlelabel.text = @"Trackers";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
    if(refresh == YES){
        [self gettrackers];
        refresh = NO;
    }
}

-(void)gettrackers{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    if(trackingortrackers == 1)
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"tacking_list\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"logged_user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,userid,appdelegate.userid];
    else
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trackers_list\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"logged_user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,userid,appdelegate.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"tracklist";
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
          
            if([requesttype isEqualToString:@"tracklist"]){
                filepath = [tempdict objectForKey:@"filePath"];
                trackaroundarray = [[tempdict objectForKey:@"list"] mutableCopy];
                trackingarray = [trackaroundarray mutableCopy];
                [trackingtable reloadData];
                if(trackingarray.count>0)
                    noresultslabel.hidden = YES;
                else
                    noresultslabel.hidden = NO;
            }
            else if([requesttype isEqualToString:@"trend_track"]){
                
              [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESHSOCIAL" object:nil];
                [self gettrackers];
//                if(trackingortrackers == 1){
//                    [trackingarray removeObjectAtIndex:trackindex];
//                }
//                else{
//                    NSMutableDictionary *dict = [[trackingarray objectAtIndex:trackindex] mutableCopy];
//                    if([[dict objectForKey:@"request_status"] isEqualToString:@"accept"]){
//                        
//                        [dict setObject:@"Not Tracking" forKey:@"request_status"];
//                    }
//                    else if([[dict objectForKey:@"following_user"] objectForKey:@"profile"] != [NSNull null] && [[[dict objectForKey:@"following_user"] objectForKey:@"profile"] isEqualToString:@"private"])
//                        [dict setObject:@"not_accepted" forKey:@"request_status"];
//                    else
//                        [dict setObject:@"accept" forKey:@"request_status"];
//                    [trackingarray replaceObjectAtIndex:trackindex withObject:dict];
//                }
//                [trackingtable reloadData];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}


-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger )section{
    
   // return 10;
    return trackingarray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier =@"cell";
    TrackingCell *cell = (TrackingCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if(cell==nil)
    {
        NSString *nib = @"TrackingCell";
        NSArray *viewObjcts = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
        for(id crntObj in viewObjcts){
            
            if ([crntObj isKindOfClass:[UITableViewCell class]]) {
                
                cell = crntObj;
                break;
            }
        }
    }
    
    CGPoint saveCenter = cell.userImage.center;
    cell.userImage.layer.cornerRadius = 58 / 2.0;
    cell.userImage.center = saveCenter;
    cell.userImage.clipsToBounds = YES;
//    cell.reasonlabel.text = [reportarray objectAtIndex:indexPath.row];
//    if(selectedindex == indexPath.row)
//        cell.checkedbtn.selected = YES;
//    else
//        cell.checkedbtn.selected = NO;
//    cell.checkedbtn.tag = indexPath.row;
//    [cell.checkedbtn addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
    cell.trackingBtn.tag = indexPath.row;
    [cell.trackingBtn addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    cell.trackingLabel.text = @"";
    cell.trackingBtn.hidden = NO;
    
    if([[[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"following_user"] objectForKey:@"user_id"] integerValue] != [appdelegate.userid integerValue]){
       
        if([[trackingarray objectAtIndex:indexPath.row] objectForKey:@"request_status"] != [NSNull null]){
            
            if([[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"request_status"] isEqualToString:@"not_accepted"]){
                cell.trackingLabel.text = @"Pending";
                cell.trackingLabel.textColor =[UIColor grayColor];
            }
            else if([[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"request_status"] isEqualToString:@"Not Tracking"]){
                
                cell.trackingLabel.text = @"Track";
                cell.trackingLabel.textColor =[UIColor orangeColor];
                [cell.trackingBtn addTarget:self action:@selector(track:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"request_status"] isEqualToString:@"accept"]){
                cell.trackingLabel.text = @"Tracking";
                cell.trackingLabel.textColor =[UIColor colorWithRed:44.0/255 green:141.0/255 blue:32.0/255 alpha:1];
                [cell.trackingBtn addTarget:self action:@selector(track:) forControlEvents:UIControlEventTouchUpInside];
                //cell.trackingBtn.hidden = YES;
            }
            else{
                cell.trackingLabel.text = @"Track";
                cell.trackingLabel.textColor =[UIColor orangeColor];
                [cell.trackingBtn addTarget:self action:@selector(track:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        else{
            cell.trackingLabel.text = @"Track";
            cell.trackingLabel.textColor =[UIColor orangeColor];
            [cell.trackingBtn addTarget:self action:@selector(track:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else{
        
        cell.trackingLabel.text = @"";
        cell.trackingBtn.hidden = YES;
    }
//        [cell.trackingBtn addTarget:self action:@selector(track:) forControlEvents:UIControlEventTouchUpInside];
        

    if([[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"following"] intValue] != 0){
       
        cell.userName.text = [[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"following_user"] objectForKey:@"name"];
        
        NSString *urlpath = [NSString stringWithFormat:@"%@%@.%@",filepath,[[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"following_user"] objectForKey:@"user_id"],[[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"following_user"] objectForKey:@"img_extension"]];
        
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"recentdefaultimage"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
            
            if(error){
                cell.userImage.image = [UIImage imageNamed:@"recentdefaultimage"];
            }
            else{
                cell.userImage.image = image;
            }
        }];
    }
    else{
        cell.userName.text = NULL;
        cell.userImage.image = [UIImage imageNamed:@"recentdefaultimage"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProfileView *obj = [[ProfileView alloc] init];
    obj.userid = [[[trackingarray objectAtIndex:indexPath.row] objectForKey:@"following_user"] objectForKey:@"user_id"];
    obj.navigated = YES;
    [self.navigationController pushViewController:obj animated:YES];

}

-(IBAction)track:(id)sender{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *reqstatus;
    if([[[trackingarray objectAtIndex:[sender tag]] objectForKey:@"request_status"] isEqualToString:@"accept"])
    reqstatus = @"un_track";
    else
        reqstatus = @"track";
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trend_track\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"following\": \"%@\",\"request_status\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[[[trackingarray objectAtIndex:[sender tag]] objectForKey:@"following_user"] objectForKey:@"user_id"],reqstatus];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"trend_track";
}

-(IBAction)accept:(id)sender{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"track_approval\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"followed_by\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[[[trackingarray objectAtIndex:[sender tag]] objectForKey:@"following_user"] objectForKey:@"user_id"]];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"trackers";
}

#pragma mark Textfield Delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if([textField.text isEqualToString:@"Search User"])
        textField.text = NULL;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *searchKey = [textField.text stringByAppendingString:string];
    //arrFilterSearch = nil;
    searchKey = [searchKey stringByReplacingCharactersInRange:range withString:@""];
    
    if([searchKey isEqualToString:@""]){
        trackingarray = [trackaroundarray mutableCopy];
        [trackingtable reloadData];
        if(trackingarray.count>0){
            noresultslabel.hidden = YES;
        }
        else{
            noresultslabel.hidden = NO;
        }
    }
    
    else{
        
        NSArray *ary = trackaroundarray;
        NSLog(@"searchKey....==%@",searchKey);
        NSPredicate *predicate;
        NSArray *syy = [[NSMutableArray alloc] init];
        
        
//        predicate = [NSPredicate predicateWithFormat:@"following_user.%K BEGINSWITH[cd] %@",@"name"];
        
        predicate = [NSPredicate predicateWithFormat:@"%K.%K BEGINSWITH[cd] %@",@"following_user",@"name",searchKey];
        
//        NSArray *filtered = [array filteredArrayUsingPredicate:];
        
        syy = [ary filteredArrayUsingPredicate: predicate];
        
        NSLog(@"syyy....==%@",syy);
        if(syy.count>0){
            
            trackingarray = [syy mutableCopy];
            noresultslabel.hidden = YES;
        }
        else{
            noresultslabel.hidden = NO;
            trackingarray = nil;
        }
        [trackingtable reloadData];
        
    }
    
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    searchField.text=@"";
    trackingarray = [trackaroundarray mutableCopy];
    [trackingtable reloadData];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [searchField resignFirstResponder];
    [trackingtable reloadData];
    return YES;
}

- (IBAction)search:(id)sender {
    
    [self textFieldShouldReturn:searchField];
}

-(void)searchusers:(NSString *)search{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"tacking_list\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"profile";
}

-(void)refreshlist: (NSNotification *) notification
{
    refresh = YES;
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
