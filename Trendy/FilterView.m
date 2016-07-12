//
//  FilterView.m
//  Trendy
//
//  Created by NewAgeSMB on 9/28/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "FilterView.h"
#import "filterCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface FilterView (){
    
    IBOutlet UIView *typeview, *typeexpandview, *brandview, *brandexpandview, *popularityview, *popularityexpandview, *priceview, *priceexpandview, *clearview;
    IBOutlet UIButton *typeexpandbtn, *brandbtn, *popularitybtn, *pricebtn, *addbtn, *popularityHLBtn, *popularityLHBtn, *priceHLBtn, *priceLHBtn;
    IBOutlet UITableView *typetable, *brandtable;
    int typeexpandval,brandexpandval,popularityexpandval,priceexpandval;
    IBOutlet UIScrollView *scroll;
    IBOutlet UILabel *clearlabel, *noresultslabel;
    NSMutableArray *selectedtypearray, *typeoriginalarray, *typearray, *brandarray, *brandoriginalarray, *indexarray,*selectedbrandarray, *typeparentarray, *typechildarray;
    NSString *requesttype;
    AppDelegate *appdelegate;
    NSMutableDictionary *dict;
//    NSMutableIndexSet *selectedbrandarray;
    NSInteger selectedsection, prevselectedsection;
    NSMutableDictionary *typeselectiondict;
    int typeindex,checkforHL;
    NSString *sortingname;
    BOOL sortingasending, tablecells;
    UIToolbar* numberToolbar;
    UITextField *lasttext;
    IBOutlet UIImageView *filterbgImage;
}

@end

@implementation FilterView
@synthesize delegate,btnstate,searchfield,locationdetails,filtertype,occasion_id;
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    selectedbrandarray = [[NSMutableArray alloc] init];
    selectedtypearray = [[NSMutableArray alloc] init];
    typeparentarray = [[NSMutableArray alloc] init];
    typechildarray = [[NSMutableArray alloc] init];
    indexarray = [[NSMutableArray alloc] init];
    typeselectiondict = [[NSMutableDictionary alloc] init];
    selectedsection = -1;
//    scroll.contentSize = CGSizeMake(199, 525);
    self.view.backgroundColor = [UIColor clearColor];
  //  [self configureLabelSlider];
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    clearlabel.attributedText = [[NSAttributedString alloc] initWithString:@"Clear all" attributes:underlineAttribute];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidekeyboards:)];
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
//    if(!appdelegate.filterdict)
//        [self getfiltervalues];
//    else{
//        
//    }
    if([btnstate isEqualToString:@"selected"]){
        addbtn.selected = YES;
        popularityexpandview.hidden = YES;
        popularityview.hidden = YES;
    }
    else{
        addbtn.selected = NO;
        popularityexpandview.hidden = YES;
        popularityview.hidden = NO;
    }
    [typetable registerNib:[UINib nibWithNibName:@"filterCell" bundle:nil] forCellReuseIdentifier:@"CustomIdentifier"];
//    [self setframes];
    // Do any additional setup after loading the view from its nib.
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
}


-(void)doneWithNumberPad{
  
//    NSString *numberFromTheKeyboard = numberTextField.text;
//
    
    BOOL update = NO;
    NSString *msg;
    if(lasttext == self.votelowerLabel){
        
        int lowerval = [self.votelowerLabel.text intValue];
        int upperval = (int)self.popularitySlider.upperValue;
        if(lowerval < upperval && lowerval>= (int)self.popularitySlider.minimumValue){
            self.popularitySlider.lowerValue = [self.votelowerLabel.text intValue];
            update = YES;
        }
        else{
            msg = @"Please set the value between the lower range and the upper range";
        }
    }
    else if(lasttext == self.voteupperLabel){
        
        int upperval = [self.voteupperLabel.text intValue];
        int lowerval = (int)self.popularitySlider.lowerValue;
        if(lowerval < upperval && upperval<= (int)self.popularitySlider.maximumValue){
            
            self.popularitySlider.upperValue = [self.voteupperLabel.text intValue];
            
            update = YES;
        }
        else{
            msg = @"Please set the value between the lower range and the upper range";
        }
        
    }
    else if(lasttext == self.pricelowerLabel){
        
        
        int lowerval = [self.pricelowerLabel.text intValue];
        int upperval = (int)self.priceSlider.upperValue;
        if(lowerval < upperval && lowerval>= (int)self.priceSlider.minimumValue){
            self.priceSlider.lowerValue = [self.pricelowerLabel.text intValue];
            
            update = YES;
        }
        else{
            msg = @"Please set the value between the lower range and the upper range";
        }
    }
    else if(lasttext == self.priceupperLabel){
        
        int upperval = [self.priceupperLabel.text intValue];
        int lowerval = (int)self.priceSlider.lowerValue;
        if(lowerval < upperval && upperval<= (int)self.priceSlider.maximumValue){
            
            self.priceSlider.upperValue = [self.priceupperLabel.text intValue];
            
            update = YES;
        }
        else{
            msg = @"Please set the value between the lower range and the upper range";
        }
    }
    else if(lasttext.tag == 5){
        
        return;
    }
    if(update == YES){
        [self updateSliderLabels];
        [self savefiltervalues];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self updateSliderLabels];
    }
    [lasttext resignFirstResponder];
    if(scroll.scrollEnabled == NO){
        [self.view endEditing:YES];
        scroll.scrollEnabled = YES;
        scroll.contentOffset = CGPointMake(0, 0);
        [lasttext resignFirstResponder];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    tablecells = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderchanged:) name:@"ENDSLIDER"  object:nil];
    if([btnstate isEqualToString:@"selected"])
        addbtn.selected = YES;
    else
        addbtn.selected = NO;
    typearray = nil;
    typeparentarray = nil;
    typechildarray = nil;
    brandarray = nil;
    selectedtypearray = nil;
    selectedbrandarray = nil;
    selectedsection = -1;
    typeindex = 0;
    checkforHL = 0;
    typeexpandval = 0;
    brandexpandval = 0;
    popularityexpandval = 0;
    priceexpandval = 0;
    self.popularitySlider.minimumValue = 0;
    self.popularitySlider.maximumValue = 100;
    self.priceSlider.minimumValue = 0;
    self.priceSlider.maximumValue = 100;
    self.votelowerLabel.text = @"";
    self.voteupperLabel.text = @"";
    self.pricelowerLabel.text = @"";
    self.priceupperLabel.text = @"";
    typeexpandbtn.selected = NO;
    typeexpandview.hidden = YES;
    brandbtn.selected = NO;
    brandexpandview.hidden = YES;
    popularitybtn.selected = NO;
    popularityexpandview.hidden = YES;
    pricebtn.selected = NO;
    priceexpandview.hidden = YES;
    [self setframes];
    if([filtertype isEqualToString:@"recent"]){
        sortingasending = appdelegate.asending;
        sortingname = appdelegate.sortedkey;
    }
    else if([filtertype isEqualToString:@"trends"]){
        sortingasending = appdelegate.asendingTrends;
        sortingname = appdelegate.sortedkeyTrends;
    }
    else if([filtertype isEqualToString:@"occasion"]){
        sortingasending = appdelegate.asendingOccasion;
        sortingname = appdelegate.sortedkeyOccasion;
    }
    if([sortingname isEqualToString:@"vote_count"]){
        if(sortingasending == YES)
            [self highestLowest:popularityLHBtn];
        else
            [self highestLowest:popularityHLBtn];
    }
    else if([sortingname isEqualToString:@"price"]){
        if(sortingasending == YES)
            [self highestLowest:priceLHBtn];
        else
            [self highestLowest:priceHLBtn];
    }
    else
        [self highestLowest:nil];
//    if(!appdelegate.filterdict){
//    }
//    else{
//        
//        dict = [appdelegate.filterdict mutableCopy];
//        typearray = [[dict objectForKey:@"type_list"] mutableCopy];
//        typeoriginalarray = [[dict objectForKey:@"type_list"] mutableCopy];
//        brandarray = [[dict objectForKey:@"brand_list"] mutableCopy];
//        brandoriginalarray = [brandarray mutableCopy];
//    }
    [self getfiltervalues];
//    [typetable reloadData];
//    [brandtable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    
    searchfield.text = nil;
//    self.popularitySlider.minimumValue = 0;
//    self.popularitySlider.maximumValue = 100;
//    
//    self.popularitySlider.lowerValue = 0;
//    self.popularitySlider.upperValue = 100;
//    
//    self.popularitySlider.minimumRange = 1;
//    
//    //priceslider....
//    self.priceSlider.minimumValue = 0;
//    self.priceSlider.maximumValue = 100;
//    
//    self.priceSlider.lowerValue = 0;
//    self.priceSlider.upperValue = 100;
//    self.priceSlider.minimumRange = 1;
}

-(void)getfiltervalues{
    
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    if([filtertype isEqualToString:@"recent"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_filter\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    else if([filtertype isEqualToString:@"trends"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_filter_trend\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    else if([filtertype isEqualToString:@"occasion"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_filter_occasion\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"occasion_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,occasion_id,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"get_filter";
}

-(void)clearfilter{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    if([filtertype isEqualToString:@"recent"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"clear_filter\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    else if([filtertype isEqualToString:@"trends"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"clear_filter_trend\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    else if([filtertype isEqualToString:@"occasion"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"clear_filter_occasion\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"clear_filter";
    popularityHLBtn.selected = NO;
    popularityLHBtn.selected = NO;
    priceHLBtn.selected = NO;
    priceLHBtn.selected = NO;
    sortingname = @"";
    sortingasending = NO;
}

-(void)savefiltervalues{


    
    NSString *typejoinedString = @"";
    if(selectedtypearray.count>0)
        typejoinedString = [selectedtypearray componentsJoinedByString:@","];
    
    NSLog(@"joinedString is %@", typejoinedString);
    

    
    NSString *brandjoinedString = @"";
    if(selectedbrandarray.count>0)
        brandjoinedString = [selectedbrandarray componentsJoinedByString:@","];
    
    NSLog(@"joinedString is %@", brandjoinedString);
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    
    if([filtertype isEqualToString:@"recent"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"filter\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"type\": \"%@\",\"brand\": \"%@\",\"pop_start\": \"%@\",\"pop_end\": \"%@\",\"price_start\": \"%@\",\"price_end\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,typejoinedString,brandjoinedString,self.votelowerLabel.text,self.voteupperLabel.text,self.pricelowerLabel.text,self.priceupperLabel.text,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    
    else if([filtertype isEqualToString:@"trends"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"filter_trend\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"type\": \"%@\",\"brand\": \"%@\",\"pop_start\": \"%@\",\"pop_end\": \"%@\",\"price_start\": \"%@\",\"price_end\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,typejoinedString,brandjoinedString,self.votelowerLabel.text,self.voteupperLabel.text,self.pricelowerLabel.text,self.priceupperLabel.text,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    
    else if([filtertype isEqualToString:@"occasion"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"filter_occasion\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"type\": \"%@\",\"brand\": \"%@\",\"pop_start\": \"%@\",\"pop_end\": \"%@\",\"price_start\": \"%@\",\"price_end\": \"%@\",\"occasion_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,typejoinedString,brandjoinedString,self.votelowerLabel.text,self.voteupperLabel.text,self.pricelowerLabel.text,self.priceupperLabel.text,occasion_id,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"savefilter";
}
-(void)filterupdate:(NSString *)selectedValueinFilter{
    
    NSString *sel_type;
        NSString *pasingString;
    if ([selectedValueinFilter isEqualToString:@"TypeisSelected"]) {
        sel_type =@"category";
    }
    else if ([selectedValueinFilter isEqualToString:@"BrandisSelected"]){
         sel_type =@"brand";
    }
    
    NSString *typejoinedString = @"";
    
    
        
        if(selectedtypearray.count>0)
            typejoinedString = [selectedtypearray componentsJoinedByString:@","];
        
        NSLog(@"joinedString is %@", typejoinedString);
      

        
    

    NSString *brandjoinedString = @"";
    if ([sel_type isEqualToString:@"brand"]) {
        
        if(selectedbrandarray.count>0)
            brandjoinedString = [selectedbrandarray componentsJoinedByString:@","];
        
        NSLog(@"joinedString is %@", brandjoinedString);
        pasingString =brandjoinedString;
        
    }

    
    
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata;
    
    if([filtertype isEqualToString:@"recent"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"filter_live\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"sel_type\": \"%@\",\"category\": \"%@\",\"brand\": \"%@\",\"pop_start\": \"%@\",\"pop_end\": \"%@\",\"price_start\": \"%@\",\"price_end\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,sel_type,typejoinedString,brandjoinedString,self.votelowerLabel.text,self.voteupperLabel.text,self.pricelowerLabel.text,self.priceupperLabel.text,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    
    else if([filtertype isEqualToString:@"trends"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"filter_live_trend\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"sel_type\": \"%@\",\"category\": \"%@\",\"brand\": \"%@\",\"pop_start\": \"%@\",\"pop_end\": \"%@\",\"price_start\": \"%@\",\"price_end\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,sel_type,typejoinedString,brandjoinedString,self.votelowerLabel.text,self.voteupperLabel.text,self.pricelowerLabel.text,self.priceupperLabel.text,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    
    else if([filtertype isEqualToString:@"occasion"])
        postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"filter_live_toccasion\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"sel_type\": \"%@\",\"category\": \"%@\",\"brand\": \"%@\",\"pop_start\": \"%@\",\"pop_end\": \"%@\",\"price_start\": \"%@\",\"price_end\": \"%@\",\"occasion_id\": \"%@\",\"lat\": \"%@\",\"long\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,sel_type,typejoinedString,brandjoinedString,self.votelowerLabel.text,self.voteupperLabel.text,self.pricelowerLabel.text,self.priceupperLabel.text,occasion_id,[locationdetails objectForKey:@"lat"],[locationdetails objectForKey:@"long"]];
    
//    NSLog(@"%@",postdata);
//    [obj serverrequest:postdata];
//    [self startLoader:@"Loading..."];
//    requesttype = @"filter_live_trend";
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        
        if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
            
            if([requesttype isEqualToString:@"get_filter"]){
               
                appdelegate.filterdict = [tempdict mutableCopy];
                dict = [appdelegate.filterdict mutableCopy];
                typearray = [[tempdict objectForKey:@"type_list"] mutableCopy];
                typeoriginalarray = [[tempdict objectForKey:@"type_list"] mutableCopy];
                brandarray = [[tempdict objectForKey:@"brand_list"] mutableCopy];
                brandoriginalarray = [brandarray mutableCopy];
                NSMutableArray *setbrandarray = [[[tempdict objectForKey:@"filter_data"] objectForKey:@"brand_array"] mutableCopy];
                NSMutableArray *settypearray = [[[tempdict objectForKey:@"filter_data"] objectForKey:@"type_array"] mutableCopy];
                for (int i = 0; i<settypearray.count; i++) {
                    
                    if(selectedtypearray.count == 0)
                        selectedtypearray = [[NSMutableArray alloc] init];
                    [selectedtypearray addObject:[NSString stringWithFormat:@"%ld",(long)[[[settypearray objectAtIndex:i] objectForKey:@"type_id"] integerValue]]];
                    
                }
                
                for (int i = 0; i<setbrandarray.count; i++) {
                    
                    if(selectedbrandarray.count == 0)
                        selectedbrandarray = [[NSMutableArray alloc] init];
                    [selectedbrandarray addObject:[NSString stringWithFormat:@"%ld",(long)[[[setbrandarray objectAtIndex:i] objectForKey:@"brand_id"] integerValue]]];
                    
                }
                [typetable reloadData];
                [brandtable reloadData];
                [self configureLabelSlider];
                [self updateSliderLabels];
                [self setframes];
            }
            else if([[tempdict objectForKey:@"function_name"] isEqualToString:@"filter_live_trend"]){
                appdelegate.filterdict = [tempdict mutableCopy];
                dict = [appdelegate.filterdict mutableCopy];
                typearray = [[tempdict objectForKey:@"type_list"] mutableCopy];
                typeoriginalarray = [[tempdict objectForKey:@"type_list"] mutableCopy];
                brandarray = [[tempdict objectForKey:@"brand_list"] mutableCopy];
                brandoriginalarray = [brandarray mutableCopy];
                NSMutableArray *setbrandarray = [[[tempdict objectForKey:@"filter_data"] objectForKey:@"brand_array"] mutableCopy];
                NSMutableArray *settypearray = [[[tempdict objectForKey:@"filter_data"] objectForKey:@"type_array"] mutableCopy];
                for (int i = 0; i<settypearray.count; i++) {
                    
                    if(selectedtypearray.count == 0)
                        selectedtypearray = [[NSMutableArray alloc] init];
                    [selectedtypearray addObject:[NSString stringWithFormat:@"%ld",(long)[[[settypearray objectAtIndex:i] objectForKey:@"type_id"] integerValue]]];
                    
                }
                
                for (int i = 0; i<setbrandarray.count; i++) {
                    
                    if(selectedbrandarray.count == 0)
                        selectedbrandarray = [[NSMutableArray alloc] init];
                    [selectedbrandarray addObject:[NSString stringWithFormat:@"%ld",(long)[[[setbrandarray objectAtIndex:i] objectForKey:@"brand_id"] integerValue]]];
                    
                }
                [typetable reloadData];
                [brandtable reloadData];
                [self configureLabelSlider];
                [self updateSliderLabels];
                [self setframes];
                
                
                
            }
            else if([requesttype isEqualToString:@"clear_filter"]){
                
                
                selectedtypearray = nil;
                selectedbrandarray = nil;
                typeparentarray = nil;
                typechildarray = nil;
                typeindex = 0;
                selectedsection = -1;
                //                [typechildarray removeAllObjects];
                searchfield.text = nil;
                brandarray = [brandoriginalarray mutableCopy];
                [typetable reloadData];
                [brandtable reloadData];
                self.popularitySlider.lowerValue = self.popularitySlider.minimumValue;
                self.popularitySlider.upperValue = self.popularitySlider.maximumValue;
                self.priceSlider.lowerValue = self.priceSlider.minimumValue;
                self.priceSlider.upperValue = self.priceSlider.maximumValue;
                [self updateSliderLabels];
                [self setframes];
            }
            else if([[tempdict objectForKey:@"function_name"] isEqualToString:@"save_filter"]){
                
                if([filtertype isEqualToString:@"recent"] || [filtertype isEqualToString:@"occasion"] ||[filtertype isEqualToString:@"trends"]){
                    appdelegate.filterdict = [tempdict mutableCopy];
                    dict = [appdelegate.filterdict mutableCopy];
                    typearray = [[tempdict objectForKey:@"type_list"] mutableCopy];
                    typeoriginalarray = [[tempdict objectForKey:@"type_list"] mutableCopy];
                    brandarray = [[tempdict objectForKey:@"brand_list"] mutableCopy];
                    brandoriginalarray = [brandarray mutableCopy];
                    NSMutableArray *setbrandarray = [[[tempdict objectForKey:@"filter_data"] objectForKey:@"brand_array"] mutableCopy];
                    NSMutableArray *settypearray = [[[tempdict objectForKey:@"filter_data"] objectForKey:@"type_array"] mutableCopy];
                    for (int i = 0; i<settypearray.count; i++) {
                        
                        if(selectedtypearray.count == 0)
                            selectedtypearray = [[NSMutableArray alloc] init];
                        [selectedtypearray addObject:[NSString stringWithFormat:@"%ld",(long)[[[settypearray objectAtIndex:i] objectForKey:@"type_id"] integerValue]]];
                        
                    }
                    
                    for (int i = 0; i<setbrandarray.count; i++) {
                        
                        if(selectedbrandarray.count == 0)
                            selectedbrandarray = [[NSMutableArray alloc] init];
                        [selectedbrandarray addObject:[NSString stringWithFormat:@"%ld",(long)[[[setbrandarray objectAtIndex:i] objectForKey:@"brand_id"] integerValue]]];
                        
                    }
                    [typetable reloadData];
                    [brandtable reloadData];
                    [self configureLabelSlider];
                    [self updateSliderLabels];
                    [self setframes];
                    
               }
                
                
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

-(IBAction)filterchoiceselection:(id)sender{
    
    [self.view endEditing:YES];
    scroll.scrollEnabled = YES;
    if([sender tag] == 0){
        
        if(typeexpandbtn.selected == NO){
            typeexpandval = 1;
            typeexpandbtn.selected = YES;
            typeexpandview.hidden = NO;
        }
        else{
            
            typeexpandval = 0;
            typeexpandbtn.selected = NO;
            typeexpandview.hidden = YES;
        }
    }
    else if([sender tag] == 1){
        
        if(brandbtn.selected == NO){
            
            brandexpandval = 1;
            brandbtn.selected = YES;
            brandexpandview.hidden = NO;
        }
        else{
            
            brandexpandval = 0;
            brandbtn.selected = NO;
            brandexpandview.hidden = YES;
        }
    }
    else if([sender tag] == 2){
        
        if(popularitybtn.selected == NO){
            
            popularityexpandval = 1;
            popularitybtn.selected = YES;
            popularityexpandview.hidden = NO;
        }
        else{
            
            popularityexpandval = 0;
            popularitybtn.selected = NO;
            popularityexpandview.hidden = YES;
        }
    }
    else if([sender tag] == 3){
        
        if(pricebtn.selected == NO){
            
            priceexpandval = 1;
            pricebtn.selected = YES;
            priceexpandview.hidden = NO;
        }
        else{
            
            priceexpandval = 0;
            pricebtn.selected = NO;
            priceexpandview.hidden = YES;
        }
    }
    else if([sender tag] == 4){
        [self clearfilter];
    }
    [self setframes];
}

-(void)setframes{
    
    CGRect typeframe = typeview.frame;
    
    CGRect typeexpandframe = typeexpandview.frame;
    
    NSInteger arraycount;
        if(typeindex == 0)
            arraycount = typearray.count;
        else
            arraycount = typeparentarray.count;
    if(tablecells == YES){
        
        if(typeindex == 0)
            arraycount = arraycount + typeparentarray.count;
        else if(typeindex == 1 )
            arraycount = arraycount + typechildarray.count;
        
    }
    
    if(35 * arraycount<=210)
        typeexpandframe.size.height = 35 * arraycount;
    else
        typeexpandframe.size.height = 210;
    
    CGRect brandframe = brandview.frame;
    
    CGRect brandexpandframe = brandexpandview.frame;
    if(35 * brandarray.count<=209)
        brandexpandframe.size.height = 35 * brandarray.count + 35;
    else
        brandexpandframe.size.height = 244;
    
    CGRect popularityframe = popularityview.frame;
    CGRect popularityexpandframe = popularityexpandview.frame;
    
    CGRect priceframe = priceview.frame;
    CGRect priceexpandframe = priceexpandview.frame;
    
    float typeexpandframe_y,brandframe_y,brandexpandframe_y,popularityframe_y,popularityexpandframe_y,priceframe_y,priceexpandframe_y,clearviewframe_y;
    
    typeframe.origin.y = 0.0;
    typeexpandframe_y = typeframe.origin.y + typeframe.size.height;
    if(typeexpandval == 1)
        brandframe_y = typeexpandframe_y + typeexpandframe.size.height;
    else
        brandframe_y = typeexpandframe_y;
    
    brandexpandframe_y = brandframe_y + brandframe.size.height;
    if(brandexpandval == 1)
        popularityframe_y = brandexpandframe_y + brandexpandframe.size.height;
    else
        popularityframe_y = brandexpandframe_y;
    
    popularityexpandframe_y = popularityframe_y + popularityframe.size.height;
    if(popularityexpandval == 1)
        priceframe_y = popularityexpandframe_y + popularityexpandframe.size.height;
    else
        priceframe_y = popularityexpandframe_y;
    
    if([btnstate isEqualToString:@"selected"]){
       
        if(brandexpandval == 1)
            priceframe_y = brandexpandframe_y + brandexpandframe.size.height;
        else
            priceframe_y = brandexpandframe_y;
    }
    
    priceexpandframe_y = priceframe_y + priceframe.size.height;
    
    if(priceexpandval == 1)
        clearviewframe_y = priceexpandframe_y + priceexpandframe.size.height;
    else
        clearviewframe_y = priceexpandframe_y;
    
    typeexpandframe.origin.y = typeexpandframe_y;
    brandframe.origin.y = brandframe_y;
    brandexpandframe.origin.y = brandexpandframe_y;
    popularityframe.origin.y = popularityframe_y;
    popularityexpandframe.origin.y = popularityexpandframe_y;
    priceframe.origin.y = priceframe_y;
    priceexpandframe.origin.y = priceexpandframe_y;
    
//    if(priceexpandval == 1)
//        priceframe_y = popularityexpandframe_y + popularityexpandframe.size.height;
//    else
//        priceframe_y = popularityexpandframe_y;
    
    typeview.frame = typeframe;
    typeexpandview.frame = typeexpandframe;
    brandview.frame = brandframe;
    brandexpandview.frame = brandexpandframe;
    popularityview.frame = popularityframe;
    popularityexpandview.frame = popularityexpandframe;
    priceview.frame = priceframe;
    priceexpandview.frame = priceexpandframe;
    CGRect filterbgframe = filterbgImage.frame;
    CGRect clearviewframe = clearview.frame;
    if(priceexpandframe.origin.y + priceexpandframe.size.height < [[UIScreen mainScreen] bounds].size.height - 100){
        clearviewframe.origin.y = scroll.frame.size.height - 40;
        clearview.frame = clearviewframe;
        scroll.contentSize = CGSizeMake(199, [[UIScreen mainScreen] bounds].size.height - 75);
    }
    else{
        clearviewframe.origin.y = clearviewframe_y + 5;
        clearview.frame = clearviewframe;
        scroll.contentSize = CGSizeMake(199, clearviewframe.origin.y + clearviewframe.size.height);
    }
    if(clearviewframe.origin.y + clearviewframe.size.height < [[UIScreen mainScreen] bounds].size.height - scroll.frame.origin.y)
        filterbgframe.size.height = [[UIScreen mainScreen] bounds].size.height - scroll.frame.origin.y;
    else
        filterbgframe.size.height = clearviewframe.origin.y + clearviewframe.size.height;
    filterbgImage.frame = filterbgframe;
    
}

-(IBAction)dismiss:(id)sender{
    
    if([sender tag] == 0){
        
        [self.delegate dismissed:@"add"];
    }
    else{
//        [self savefiltervalues];
        [self.delegate dismissed:@"dismiss"];
    }
    if([filtertype isEqualToString:@"recent"]){
        
        appdelegate.asending = sortingasending;;
        appdelegate.sortedkey = sortingname;
    }
    else if([filtertype isEqualToString:@"trends"]){
        
//        sortingasending = appdelegate.asendingTrends;
//        sortingname = appdelegate.sortedkeyTrends;
        
        appdelegate.asendingTrends = sortingasending;;
        appdelegate.sortedkeyTrends = sortingname;
    }
    else if([filtertype isEqualToString:@"occasion"]){
        
//        sortingasending = appdelegate.asendingOccasion;
//        sortingname = appdelegate.sortedkeyOccasion;
        
        appdelegate.asendingOccasion = sortingasending;;
        appdelegate.sortedkeyOccasion = sortingname;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if(tableView == typetable){
        if(typeindex == 0)
            return typearray.count;
        else
            return typeparentarray.count;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(tableView == typetable){
        
        filterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomIdentifier"];
        
        if(typeindex == 0){
            
            cell.valuelabel.text = [[typearray objectAtIndex:section] objectForKey:@"name"];
            cell.checkbtn.hidden = NO;
            if([[[typearray objectAtIndex:section] objectForKey:@"parent_array"] count]>0)
            {
                
                cell.headerbtn.hidden = NO;
                cell.headerbtn.tag = section;
                [cell.headerbtn addTarget:self action:@selector(typeexpand:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                
                cell.subcellview.backgroundColor = [UIColor whiteColor];
                cell.headerbtn.hidden = YES;
            }
            cell.checkbtn.tag = [[[typearray objectAtIndex:section] objectForKey:@"category_id"] integerValue];
            [cell.checkbtn addTarget:self action:@selector(typeselectiononheader:) forControlEvents:UIControlEventTouchUpInside];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",[NSString stringWithFormat:@"%ld",(long)[[[typearray objectAtIndex:section] objectForKey:@"category_id"] integerValue]]];
            NSArray *temarray = [selectedtypearray filteredArrayUsingPredicate: predicate];
            //            NSLog(@"temarray....==%@",temarray);
            if(temarray.count>0)
                cell.checkbtn.selected = YES;
            else
                cell.checkbtn.selected = NO;
        }
        else if(typeindex == 1){
            
            cell.valuelabel.text = [[typeparentarray objectAtIndex:section] objectForKey:@"name"];
            cell.checkbtn.hidden = NO;
            if([[typeparentarray objectAtIndex:section] objectForKey:@"type_array"] && [[[typeparentarray objectAtIndex:section] objectForKey:@"type_array"] count]>0)
            {
                cell.headerbtn.hidden = NO;
                cell.headerbtn.tag = section;
                [cell.headerbtn addTarget:self action:@selector(typeexpand:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                
                cell.subcellview.backgroundColor = [UIColor whiteColor];
                cell.headerbtn.hidden = YES;
            }
            cell.checkbtn.tag = [[[typeparentarray objectAtIndex:section] objectForKey:@"category_id"] integerValue];
            [cell.checkbtn addTarget:self action:@selector(typeselectiononheader:) forControlEvents:UIControlEventTouchUpInside];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",[NSString stringWithFormat:@"%ld",(long)[[[typeparentarray objectAtIndex:section] objectForKey:@"category_id"] integerValue]]];
            NSArray *temarray = [selectedtypearray filteredArrayUsingPredicate: predicate];
            //            NSLog(@"temarray....==%@",temarray);
            if(temarray.count>0)
                cell.checkbtn.selected = YES;
            else
                cell.checkbtn.selected = NO;
            
        }
        cell.subcellview.backgroundColor = [UIColor lightGrayColor];
        
        
        return cell;
        
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger )section{
    
    if(tableView == typetable){
        
        if(typeindex == 0 && selectedsection == section)
            return [typeparentarray count];
        else if(typeindex == 1 && selectedsection == section)
            return [typechildarray count];
        else
            return 0;
    }
    else if(tableView == brandtable)
        return brandarray.count;
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellidentifier =@"cell";
    filterCell *cell = (filterCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if(cell==nil)
    {
        NSString *nib = @"filterCell";
        NSArray *viewObjcts = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
        for(id crntObj in viewObjcts){
            
            if ([crntObj isKindOfClass:[UITableViewCell class]]) {
                
                cell = crntObj;
                break;
            }
        }
    }
    
    if(tableView == typetable){
        
        cell.subcellview.hidden = NO;
        
        if(typeindex == 0)
            cell.subvaluelabel.text = [[typeparentarray objectAtIndex:indexPath.row] objectForKey:@"name"];
        else
            cell.subvaluelabel.text = [[typechildarray objectAtIndex:indexPath.row] objectForKey:@"name"];
        
//            cell.subvaluelabel.text = [[[[typearray objectAtIndex:selectedsection] objectForKey:@"submenu"] objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        cell.subcellview.backgroundColor = [UIColor whiteColor];
        NSArray *temarray;
        if(typeindex == 0){
            

            if([[typeparentarray objectAtIndex:indexPath.row] objectForKey:@"type_array"] && [[[typeparentarray objectAtIndex:indexPath.row] objectForKey:@"type_array"] count]>0){
                
                cell.subcellview.backgroundColor = [UIColor lightGrayColor];
                cell.expandbtn.hidden = NO;
                cell.expandbtn.tag = indexPath.row;
                [cell.expandbtn addTarget:self action:@selector(typesubexpand:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                
                cell.expandbtn.hidden = YES;
                
            }
            cell.subcheckbtn.hidden = NO;
            cell.subcheckbtn.tag = [[[typeparentarray objectAtIndex:indexPath.row] objectForKey:@"category_id"] integerValue];
            [cell.subcheckbtn addTarget:self action:@selector(typeselection:) forControlEvents:UIControlEventTouchUpInside];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",[NSString stringWithFormat:@"%ld",(long)[[[typeparentarray objectAtIndex:indexPath.row] objectForKey:@"category_id"] integerValue]]];
            temarray = [selectedtypearray filteredArrayUsingPredicate: predicate];
            
        }
        else{
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",[NSString stringWithFormat:@"%ld",(long)[[[typechildarray objectAtIndex:indexPath.row] objectForKey:@"category_id"] integerValue]]];
            temarray = [selectedtypearray filteredArrayUsingPredicate: predicate];
            cell.subcheckbtn.tag = [[[typechildarray objectAtIndex:indexPath.row] objectForKey:@"category_id"] integerValue];
        }
        
        

        if(temarray.count>0)
            cell.subcheckbtn.selected = YES;
        else
            cell.subcheckbtn.selected = NO;
    

        [cell.subcheckbtn addTarget:self action:@selector(typeselection:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    else{
        
        cell.subcellview.hidden = YES;
        cell.headerbtn.hidden = YES;
        cell.backgroundColor = [UIColor whiteColor];
        cell.valuelabel.text = [[brandarray objectAtIndex:indexPath.row] objectForKey:@"brand"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",[NSString stringWithFormat:@"%ld",(long)[[[brandarray objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue]]];
        NSArray *temarray = [selectedbrandarray filteredArrayUsingPredicate: predicate];
//        NSLog(@"temarray....==%@",temarray);
        if(temarray.count>0)
            cell.checkbtn.selected = YES;
        else
            cell.checkbtn.selected = NO;
        
//        if ([selectedbrandarray containsIndex:indexPath.row]) {
//            cell.checkbtn.selected = YES;
//        }
//        else
//            cell.checkbtn.selected = NO;
        cell.checkbtn.tag = [[[brandarray objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
        [cell.checkbtn addTarget:self action:@selector(brandselection:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

-(IBAction)typeexpand:(id)sender{
    
    
    if(selectedsection == [sender tag]){
        selectedsection = -1;
        indexarray = nil;
        if(typeindex == 1)
            typeindex = 0;
        tablecells = NO;
        [typetable reloadData];
    }
    else{
        tablecells = YES;
        selectedsection = [sender tag];
        if(typeindex == 1){
            selectedsection = -1;
            typeindex = 0;
            typeparentarray = nil;
            
        }
        else{
            typeparentarray = [[typearray objectAtIndex:selectedsection] objectForKey:@"parent_array"];
            [indexarray addObject:[NSString stringWithFormat:@"%ld",(long)selectedsection]];
        }
        [typetable reloadData];
        if ([typeparentarray count]>0)
            [typetable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:selectedsection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [self setframes];
//    [self savefiltervalues];
}

-(IBAction)typesubexpand:(id)sender{
    
    if(selectedsection == [sender tag]){
        
        typeindex = 1;
        if([[typeparentarray objectAtIndex:[sender tag]] objectForKey:@"type_array"] && [[[typeparentarray objectAtIndex:[sender tag]] objectForKey:@"type_array"] count]>0){
            
            typechildarray = [[[typeparentarray objectAtIndex:[sender tag]] objectForKey:@"type_array"] mutableCopy];
        }
        prevselectedsection = selectedsection;
        selectedsection = [sender tag];
        [indexarray addObject:[NSString stringWithFormat:@"%ld",(long)selectedsection]];
        [typetable reloadData];
        if ([typechildarray count]>0)
            [typetable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:selectedsection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
//        if(indexarray.count>0)
//            selectedsection = [[indexarray objectAtIndex:indexarray.count - 1] integerValue];
//        [typetable reloadData];
//        [indexarray removeLastObject];
//        if ([[[typearray objectAtIndex:selectedsection] objectForKey:@"submenu"]count]>0)
//            [typetable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:selectedsection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else{
        
        typeindex = 1;
        if([[typeparentarray objectAtIndex:[sender tag]] objectForKey:@"type_array"] && [[[typeparentarray objectAtIndex:[sender tag]] objectForKey:@"type_array"] count]>0){
            
            typechildarray = [[[typeparentarray objectAtIndex:[sender tag]] objectForKey:@"type_array"] mutableCopy];
        }
        prevselectedsection = selectedsection;
        selectedsection = [sender tag];
        [indexarray addObject:[NSString stringWithFormat:@"%ld",(long)selectedsection]];
        [typetable reloadData];
        if ([typechildarray count]>0)
            [typetable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:selectedsection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [self setframes];
   // [typetable reloadData];
    //    [self savefiltervalues];
}

-(IBAction)typeselection:(id)sender{
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
    NSArray *temarray = [selectedtypearray filteredArrayUsingPredicate: predicate];
//    NSLog(@"temarray....==%@",temarray);
    if(temarray.count>0)
        [selectedtypearray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
    else{
        
        if(selectedtypearray.count == 0)
            selectedtypearray = [[NSMutableArray alloc] init];
        [selectedtypearray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
    }
    [self filterupdate:@"TypeisSelected"];
    [self savefiltervalues];
    [typetable reloadData];
}

-(IBAction)typeselectiononheader:(id)sender{
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
    NSArray *temarray = [selectedtypearray filteredArrayUsingPredicate: predicate];
//    NSLog(@"temarray....==%@",temarray);
    if(temarray.count>0){
        [selectedtypearray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
        NSInteger searchId = [sender tag];
        NSUInteger index2;
        if(typeindex == 0){
            //return typearray.count;{
            index2 = [typearray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                BOOL found = [[item objectForKey:@"category_id"] intValue] == searchId;
                return found;
            }];
        }
        else{
            index2 = [typeparentarray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                BOOL found = [[item objectForKey:@"category_id"] intValue] == searchId;
                return found;
            }];
        }
        //  return typeparentarray.count;
        
        
        if (index2 != NSNotFound) {
            // First matching item at index2.
            if(typeindex == 0){
                
                NSArray *newtemparray = [[typearray objectAtIndex:index2] objectForKey:@"parent_array"];
                for (int i = 0; i<newtemparray.count; i++) {
                    
                    [selectedtypearray removeObject:[NSString stringWithFormat:@"%ld",(long)[[[newtemparray objectAtIndex:i] objectForKey:@"category_id"] integerValue]]];
                    
                    NSArray *newtempsubarray = [[newtemparray objectAtIndex:i] objectForKey:@"type_array"];
                    for(int j = 0; j<newtempsubarray.count;j++){
                        [selectedtypearray removeObject:[NSString stringWithFormat:@"%ld",(long)[[[newtempsubarray objectAtIndex:j] objectForKey:@"category_id"] integerValue]]];
                    }
                }
            }
            else{
                
                NSArray *newtemparray = [[typeparentarray objectAtIndex:index2] objectForKey:@"type_array"];
                for (int i = 0; i<newtemparray.count; i++) {
                    
                    [selectedtypearray removeObject:[NSString stringWithFormat:@"%ld",(long)[[[newtemparray objectAtIndex:i] objectForKey:@"category_id"] integerValue]]];
                }
            }
        }
        else {
            
        }
    }
    else{
        
        if(selectedtypearray.count == 0)
            selectedtypearray = [[NSMutableArray alloc] init];
        [selectedtypearray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
        NSInteger searchId = [sender tag];
        NSUInteger index2;
        if(typeindex == 0){
            //return typearray.count;{
            index2 = [typearray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                BOOL found = [[item objectForKey:@"category_id"] intValue] == searchId;
                return found;
            }];
        }
        else{
            index2 = [typeparentarray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                BOOL found = [[item objectForKey:@"category_id"] intValue] == searchId;
                return found;
            }];
        }
          //  return typeparentarray.count;
        
        
        if (index2 != NSNotFound) {
            // First matching item at index2.
            if(typeindex == 0){
               
                NSArray *newtemparray = [[typearray objectAtIndex:index2] objectForKey:@"parent_array"];
                for (int i = 0; i<newtemparray.count; i++) {
                    
                    [selectedtypearray removeObject:[NSString stringWithFormat:@"%ld",(long)[[[newtemparray objectAtIndex:i] objectForKey:@"category_id"] integerValue]]];
                    [selectedtypearray addObject:[NSString stringWithFormat:@"%ld",(long)[[[newtemparray objectAtIndex:i] objectForKey:@"category_id"] integerValue]]];
                    NSArray *newtempsubarray = [[newtemparray objectAtIndex:i] objectForKey:@"type_array"];
                    for(int j = 0; j<newtempsubarray.count;j++){
                        [selectedtypearray removeObject:[NSString stringWithFormat:@"%ld",(long)[[[newtempsubarray objectAtIndex:j] objectForKey:@"category_id"] integerValue]]];
                        [selectedtypearray addObject:[NSString stringWithFormat:@"%ld",(long)[[[newtempsubarray objectAtIndex:j] objectForKey:@"category_id"] integerValue]]];
                    }
                }
            }
            else{
               
                NSArray *newtemparray = [[typeparentarray objectAtIndex:index2] objectForKey:@"type_array"];
                for (int i = 0; i<newtemparray.count; i++) {
                    
                    [selectedtypearray removeObject:[NSString stringWithFormat:@"%ld",(long)[[[newtemparray objectAtIndex:i] objectForKey:@"category_id"] integerValue]]];
                    [selectedtypearray addObject:[NSString stringWithFormat:@"%ld",(long)[[[newtemparray objectAtIndex:i] objectForKey:@"category_id"] integerValue]]];
                }
            }
        }
        else {
            
        }
        
    }
    [self filterupdate:@"TypeisSelected"];
     [self savefiltervalues];
    typearray = [typeoriginalarray mutableCopy];
    [typetable reloadData];
}

-(IBAction)brandselection:(id)sender{
    
//    if ([selectedbrandarray containsIndex:[sender tag]]) {
//        [selectedbrandarray removeIndex:[sender tag]];
//    }
//    else
//        [selectedbrandarray addIndex:[sender tag]];
//    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@",[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
    NSArray *temarray = [selectedbrandarray filteredArrayUsingPredicate: predicate];
//    NSLog(@"temarray....==%@",temarray);
    if(temarray.count>0)
        [selectedbrandarray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
    else{
        if(selectedbrandarray.count == 0)
            selectedbrandarray = [[NSMutableArray alloc] init];
        [selectedbrandarray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
    }
    
    [brandtable reloadData];
    [self filterupdate:@"BrandisSelected"];
    [self savefiltervalues];
}

#pragma mark - highest-lowest - price/popularity
-(IBAction)highestLowest:(id)sender{
    
    // popularityHLBtn.selected = NO;
    //  popularityLHBtn.selected = NO;
    // priceHLBtn.selected = NO;
    priceLHBtn.selected = NO;
    UIButton *btn = (UIButton *)sender;
    if(btn){
        if([sender tag] == 0){
            
            if([sortingname isEqualToString:@"vote_count"]){
                if (checkforHL>0) {
                    
                    if(sortingasending == NO){
                        sortingname =@"";
                        popularityHLBtn.selected = NO;
                        
                        popularityLHBtn.selected = NO;
                        priceHLBtn.selected = NO;
                        priceLHBtn.selected = NO;
                        
                    }else{
                        sortingasending = NO;
                        sortingname = @"vote_count";
                        popularityHLBtn.selected = YES;
                        
                        popularityLHBtn.selected = NO;
                        priceHLBtn.selected = NO;
                        priceLHBtn.selected = NO;
                        
                    }
                    
                    
                }
                else{
                    checkforHL++;
                    sortingasending = NO;
                    sortingname = @"vote_count";
                    popularityHLBtn.selected = YES;
                    
                    popularityLHBtn.selected = NO;
                    priceHLBtn.selected = NO;
                    priceLHBtn.selected = NO;
                    
                }
                
                
            }
            else{
                sortingasending = NO;
                sortingname = @"vote_count";
                popularityHLBtn.selected = YES;
                
                popularityLHBtn.selected = NO;
                priceHLBtn.selected = NO;
                priceLHBtn.selected = NO;
            }
            
        }
        else if([sender tag] == 1){
            if([sortingname isEqualToString:@"vote_count"]){
                if (checkforHL>0) {
                    
                    if(sortingasending == YES){
                        sortingasending = NO;
                        sortingname =@"";
                        popularityLHBtn.selected = NO;
                        
                        popularityHLBtn.selected = NO;
                        priceHLBtn.selected = NO;
                        priceLHBtn.selected = NO;
                    }
                    else{
                        sortingasending = YES;
                        sortingname = @"vote_count";
                        popularityLHBtn.selected = YES;
                        
                        popularityHLBtn.selected = NO;
                        priceHLBtn.selected = NO;
                        priceLHBtn.selected = NO;
                    }
                    
                    
                }
                else{
                    checkforHL++;
                    sortingasending = YES;
                    sortingname = @"vote_count";
                    popularityLHBtn.selected = YES;
                    
                    popularityHLBtn.selected = NO;
                    priceHLBtn.selected = NO;
                    priceLHBtn.selected = NO;
                    
                    
                }
                
                
            }
            else{
                sortingasending = YES;
                sortingname = @"vote_count";
                popularityLHBtn.selected = YES;
                
                popularityHLBtn.selected = NO;
                priceHLBtn.selected = NO;
                priceLHBtn.selected = NO;
                
            }
            
        }
        else if([sender tag] == 2){
            if([sortingname isEqualToString:@"price"]){
                if (checkforHL>0) {
                    if(sortingasending == NO){
                        sortingname =@"";
                        priceHLBtn.selected = NO;
                        
                        popularityHLBtn.selected = NO;
                        popularityLHBtn.selected = NO;
                        priceLHBtn.selected = NO;
                        
                    }
                    else{
                        sortingasending = NO;
                        sortingname = @"price";
                        priceHLBtn.selected = YES;
                        
                        popularityHLBtn.selected = NO;
                        popularityLHBtn.selected = NO;
                        priceLHBtn.selected = NO;
                    }
                }
                else{
                    checkforHL++;
                    sortingasending = NO;
                    sortingname = @"price";
                    priceHLBtn.selected = YES;
                    
                    popularityHLBtn.selected = NO;
                    popularityLHBtn.selected = NO;
                    priceLHBtn.selected = NO;
                }
                
                
            }
            else{
                sortingasending = NO;
                sortingname = @"price";
                priceHLBtn.selected = YES;
                
                popularityHLBtn.selected = NO;
                popularityLHBtn.selected = NO;
                priceLHBtn.selected = NO;
                
            }
            
        }
        else if([sender tag] == 3){
            if([sortingname isEqualToString:@"price"]){
                if (checkforHL>0) {
                    if(sortingasending == YES){
                        
                        sortingasending = NO;
                        sortingname =@"";
                        priceLHBtn.selected = NO;
                        popularityLHBtn.selected = NO;
                        popularityHLBtn.selected = NO;
                        priceHLBtn.selected = NO;
                    }else{
                        sortingasending = YES;
                        sortingname = @"price";
                        priceLHBtn.selected = YES;
                        
                        popularityLHBtn.selected = NO;
                        popularityHLBtn.selected = NO;
                        priceHLBtn.selected = NO;
                        
                    }
                }
                else{
                    checkforHL++;
                    sortingasending = YES;
                    sortingname = @"price";
                    priceLHBtn.selected = YES;
                    
                    popularityLHBtn.selected = NO;
                    popularityHLBtn.selected = NO;
                    priceHLBtn.selected = NO;
                    
                }
                
                
            }
            else{
                sortingasending = YES;
                sortingname = @"price";
                priceLHBtn.selected = YES;
                
                popularityLHBtn.selected = NO;
                popularityHLBtn.selected = NO;
                priceHLBtn.selected = NO;
            }
        }
        
    }
    //if(btn.selected == NO)
    //    btn.selected = YES;
    //else
    //btn.selected = NO;
    
}



#pragma mark -
#pragma mark - Label  Slider

- (void) configureLabelSlider
{
    
    //popularitySlider....
    self.popularitySlider.minimumRange = 1;
    
    //priceslider....    
    self.priceSlider.minimumRange = 1;


    if(dict){
        //popularitySlider....
        if([[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"pop_min"] && [[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"pop_min"] != [NSNull null]){
            

            int myInt = [[[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"pop_min"] intValue];
            self.popularitySlider.minimumValue=myInt;

        }
        else
            self.popularitySlider.minimumValue = 0.0;
        
        if([[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"pop_max"] && [[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"pop_max"] != [NSNull null]){
            
            float a = [[[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"pop_max"] floatValue];
            int myInt = roundf(a);
            if(roundf([[[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"pop_min"] floatValue]) == myInt)
                self.popularitySlider.maximumValue = myInt + 1;
            else
                self.popularitySlider.maximumValue=myInt;

        }
        
        if(self.popularitySlider.maximumValue == self.popularitySlider.minimumValue)
            self.popularitySlider.maximumValue = self.popularitySlider.maximumValue + 1;
        
        if([[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] != [NSNull null] && [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] integerValue] != 0 && [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_end"] integerValue] != 0){
            
            if([[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] floatValue]<=self.popularitySlider.minimumValue || [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] floatValue]>=self.popularitySlider.maximumValue)
                self.popularitySlider.lowerValue = self.popularitySlider.minimumValue;
            else
                self.popularitySlider.lowerValue = [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] floatValue];
            
            
        }
        else if([[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] != [NSNull null] && [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] integerValue] == 0 && [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_end"] integerValue] != 0)
        {
            if([[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] floatValue]<=self.popularitySlider.minimumValue || [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] floatValue]>=self.popularitySlider.maximumValue)
                self.popularitySlider.lowerValue = self.popularitySlider.minimumValue;
            else
                self.popularitySlider.lowerValue = [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] floatValue];
        }
        
        else
            self.popularitySlider.lowerValue = self.popularitySlider.minimumValue;
        
        if([[dict objectForKey:@"filter_data"] objectForKey:@"pop_end"] != [NSNull null]){
            
         
           
            if([[[dict objectForKey:@"filter_data"] objectForKey:@"pop_end"] floatValue]>=self.popularitySlider.maximumValue || [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_end"] floatValue] <= self.popularitySlider.minimumValue)
                self.popularitySlider.upperValue = self.popularitySlider.maximumValue;
            else
                self.popularitySlider.upperValue = [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_end"] floatValue];
            
        }
        else
            self.popularitySlider.upperValue = self.popularitySlider.maximumValue;
       
        
        
        
        
        
        
        //priceslider....
        if([[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"min_price"] && [[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"min_price"] != [NSNull null]){
            
            float a = [[[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"min_price"] floatValue];
//            int myInt = roundf(a);
            self.priceSlider.minimumValue= a;
        }
        else
            self.priceSlider.minimumValue = 0.0;
        
        if([[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"max_price"] && [[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"max_price"] != [NSNull null]){
           
            float a1 = [[[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"max_price"] floatValue];
            int myInt1 = roundf(a1);
            if(myInt1<a1)
                myInt1 = myInt1 + 1;
            if(roundf([[[dict objectForKey:@"min_max_price_popularity"] objectForKey:@"min_price"] floatValue]) == myInt1)
                self.priceSlider.maximumValue = myInt1+1;
            else
                self.priceSlider.maximumValue = myInt1;
        }
        else
            self.priceSlider.maximumValue = self.priceSlider.minimumValue + 1;
        
        if([[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] != [NSNull null]){
            
//            self.priceSlider.lowerValue = [[[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] floatValue];
            
            if([[[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] floatValue]<=self.priceSlider.minimumValue || [[[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] floatValue]>=self.priceSlider.maximumValue )
                self.priceSlider.lowerValue = self.priceSlider.minimumValue;
            else
                self.priceSlider.lowerValue = [[[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] floatValue];
            
        }
        else
            self.priceSlider.lowerValue = self.priceSlider.minimumValue;
        
        if([[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] != [NSNull null] ){
            
            if([[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] != [NSNull null] && [[[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] integerValue] == 0 && [[[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] integerValue] == 0)
                
                self.priceSlider.upperValue = self.priceSlider.maximumValue;
            
            else{
               
                if([[[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] floatValue]>= self.priceSlider.maximumValue || [[[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] floatValue] <= self.priceSlider.minimumValue)
                    self.priceSlider.upperValue = self.priceSlider.maximumValue;
                else
                    self.priceSlider.upperValue = [[[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] floatValue];
            }
            
        }
        else{
          self.priceSlider.upperValue = self.priceSlider.maximumValue;
        }
        
        if([[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] != [NSNull null] && [[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] != [NSNull null] ){
           
            if([[[dict objectForKey:@"filter_data"] objectForKey:@"price_start"] integerValue] == 0 && [[[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] integerValue] == 0){
            
                self.priceSlider.lowerValue = self.priceSlider.minimumValue;
                self.priceSlider.upperValue = self.priceSlider.maximumValue;
           }
            
        }
        if([[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] != [NSNull null] && [[dict objectForKey:@"filter_data"] objectForKey:@"pop_end"] != [NSNull null] ){
            
            if([[[dict objectForKey:@"filter_data"] objectForKey:@"pop_start"] integerValue] == 0 && [[[dict objectForKey:@"filter_data"] objectForKey:@"pop_end"] integerValue] == 0){
                
                self.popularitySlider.lowerValue = self.popularitySlider.minimumValue;
                self.popularitySlider.upperValue = self.popularitySlider.maximumValue;
            }
            
        }
        
//        if([[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] != [NSNull null] && [[[dict objectForKey:@"filter_data"] objectForKey:@"price_end"] integerValue] == 0 && self.priceSlider.upperValue == self.priceSlider.lowerValue)
//            self.priceSlider.upperValue = self.priceSlider.maximumValue;
        
//        if(self.popularitySlider.upperValue == self.popularitySlider.lowerValue)
//            self.popularitySlider.upperValue = self.popularitySlider.maximumValue;
//        
//        if(self.popularitySlider.minimumValue>self.popularitySlider.lowerValue)
//            self.popularitySlider.lowerValue = self.popularitySlider.minimumValue;
//        if(self.popularitySlider.maximumValue<self.popularitySlider.upperValue)
//            self.popularitySlider.upperValue = self.popularitySlider.maximumValue;
//        
//        if(self.priceSlider.minimumValue>self.priceSlider.lowerValue)
//            self.priceSlider.lowerValue = self.priceSlider.minimumValue;
//        if(self.priceSlider.maximumValue<self.priceSlider.upperValue)
//            self.priceSlider.upperValue = self.priceSlider.maximumValue;
        
//        if(self.priceSlider.maximumValue != self.priceSlider.minimumValue)
//            self.priceSlider.maximumValue = self.priceSlider.maximumValue + 1;
//        
//        if(self.popularitySlider.maximumValue != self.popularitySlider.minimumValue)
//            self.popularitySlider.maximumValue = self.popularitySlider.maximumValue + 1;
//            self.priceupperLabel.text = [NSString stringWithFormat:@"%d", (int)self.priceSlider.upperValue];
//        else
//            self.priceupperLabel.text = [NSString stringWithFormat:@"%d", (int)self.priceSlider.upperValue + 1];
    }
    else{
        
        //popularitySlider....
        self.popularitySlider.minimumValue = 0;
        self.popularitySlider.maximumValue = 100;
        
        self.popularitySlider.lowerValue = 0;
        self.popularitySlider.upperValue = 100;
        
        self.popularitySlider.minimumRange = 1;
        
        //priceslider....
        self.priceSlider.minimumValue = 0;
        self.priceSlider.maximumValue = 100;
        
        self.priceSlider.lowerValue = 0;
        self.priceSlider.upperValue = 100;
        
        self.priceSlider.minimumRange = 1;
    }
    
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    
    //popularitySlider....
    self.votelowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.popularitySlider.lowerValue];
    
    self.voteupperLabel.text = [NSString stringWithFormat:@"%d", (int)self.popularitySlider.upperValue];
    
    //priceslider....
    self.pricelowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.priceSlider.lowerValue];
    
    self.priceupperLabel.text = [NSString stringWithFormat:@"%d", (int)self.priceSlider.upperValue];
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}

-(void)sliderchanged:(NSNotification *) notification
{
    [self savefiltervalues];
}

#pragma mark Textfield Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
   
    if(textField.tag == 5)
        scroll.contentOffset = CGPointMake(0, textField.superview.frame.origin.y + textField.frame.origin.y - 10);
    else
        scroll.contentOffset = CGPointMake(0, textField.superview.frame.origin.y +textField.frame.origin.y - 150);
    scroll.scrollEnabled = NO;
    if(!textField.inputAccessoryView && textField.tag != 5)
        textField.inputAccessoryView = numberToolbar;
    lasttext = textField;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
   
//    BOOL update = NO;
//    NSString *msg;
//    if(textField == self.votelowerLabel){
//        
//        int lowerval = [self.votelowerLabel.text intValue];
//        int upperval = (int)self.popularitySlider.upperValue;
//        if(lowerval < upperval && lowerval>= (int)self.popularitySlider.minimumValue){
//            self.popularitySlider.lowerValue = [self.votelowerLabel.text intValue];
//            update = YES;
//        }
//        else{
//            msg = @"Please set the value between the lower range and the upper range";
//        }
//    }
//    else if(textField == self.voteupperLabel){
//        
//        int upperval = [self.voteupperLabel.text intValue];
//        int lowerval = (int)self.popularitySlider.lowerValue;
//        if(lowerval < upperval && upperval<= (int)self.popularitySlider.maximumValue){
//            
//            self.popularitySlider.upperValue = [self.voteupperLabel.text intValue];
//            
//             update = YES;
//        }
//        else{
//            msg = @"Please set the value between the lower range and the upper range";
//        }
//        
//    }
//    else if(textField == self.pricelowerLabel){
//        
//        
//        int lowerval = [self.pricelowerLabel.text intValue];
//        int upperval = (int)self.priceSlider.upperValue;
//        if(lowerval < upperval && lowerval>= (int)self.priceSlider.minimumValue){
//            self.priceSlider.lowerValue = [self.pricelowerLabel.text intValue];
//            
//             update = YES;
//        }
//        else{
//            msg = @"Please set the value between the lower range and the upper range";
//        }
//    }
//    else if(textField == self.priceupperLabel){
//        
//        int upperval = [self.priceupperLabel.text intValue];
//        int lowerval = (int)self.priceSlider.lowerValue;
//        if(lowerval < upperval && upperval<= (int)self.priceSlider.maximumValue){
//            
//            self.priceSlider.upperValue = [self.priceupperLabel.text intValue];
//            
//             update = YES;
//        }
//        else{
//            msg = @"Please set the value between the lower range and the upper range";
//        }
//    }
//    else if(textField.tag == 5){
//       
//        return;
//    }
//    if(update == YES){
//        [self updateSliderLabels];
//        [self savefiltervalues];
//    }
//    else{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        [self updateSliderLabels];
//    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField.tag != 5)
        [self updateSliderLabels];
       // [textField resignFirstResponder];
    else
        textField.text = nil;
    noresultslabel.hidden = YES;
    brandarray = [brandoriginalarray mutableCopy];
    [brandtable reloadData];
    scroll.contentOffset = CGPointMake(0, 0);
    scroll.scrollEnabled = YES;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField.tag == 5){
        NSString *searchKey = [textField.text stringByAppendingString:string];
        //arrFilterSearch = nil;
        searchKey = [searchKey stringByReplacingCharactersInRange:range withString:@""];
        NSMutableArray *ary = brandoriginalarray;
        NSLog(@"searchKey....==%@",searchKey);
        if(searchKey.length>0){
            NSArray *syy = [[NSMutableArray alloc] init];
            NSPredicate *predicate;
            predicate = [NSPredicate predicateWithFormat:@"brand contains[cd] %@",searchKey];
            syy = [ary filteredArrayUsingPredicate: predicate];
            NSLog(@"syyy....==%@",syy);
            noresultslabel.hidden = YES;
            brandarray = [syy mutableCopy];
            if(syy.count>0){
                
            }
            else{
                noresultslabel.hidden = NO;
                
            }
            [brandtable reloadData];
        }
        else{
            brandarray = [brandoriginalarray mutableCopy];
            [brandtable reloadData];
            noresultslabel.hidden = YES;
            
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (([touch.view isDescendantOfView:typetable] || [touch.view isDescendantOfView:brandtable]) && scroll.scrollEnabled == YES) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

-(IBAction)hidekeyboards:(id)sender
{
    
    if(scroll.scrollEnabled == NO){
        
        [self.view endEditing:YES];
        scroll.scrollEnabled = YES;
        scroll.contentOffset = CGPointMake(0, 0);
        [lasttext resignFirstResponder];
        if(lasttext.tag != 5)
            [self updateSliderLabels];
        else
            lasttext.text = nil;
    }
    if(lasttext.tag == 5)
    {
        noresultslabel.hidden = YES;
        brandarray = [brandoriginalarray mutableCopy];
        [brandtable reloadData];
    }
    
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
    [self stoploader];
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
