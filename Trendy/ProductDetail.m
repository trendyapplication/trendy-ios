//
//  ProductDetail.m
//  Trendy
//
//  Created by NewAgeSMB on 9/8/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "ProductDetail.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SuggestedCell.h"
#import "MHFacebookImageViewer.h"
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"
#import "YALNavigationBar.h"
#import "ReviewCell.h"
#import "ODRefreshControl.h"
#import "ReviewList.h"
#import "ReportCell.h"
#import "DropDown.h"
#import "ProfileView.h"
#import "PostStep1.h"
#import "OccasionDetail.h"
#import "ProductImageCell.h"
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

static NSString *const menuCellIdentifier = @"rotationCell";


@interface ProductDetail ()<YALContextMenuTableViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UIScrollView *scroll;
    IBOutlet UIImageView *productimage, *genderimage, *entryImageView;
    IBOutlet UILabel *productownername, *posteddate, *votecount, *productname, *productprice, *descriptiontitle, *ratecount, *occasionlabel, *postedlocation, *savedstatus, *countlabel;
    IBOutlet UIButton *addtooccationbtn, *upbtn, *downbtn, *reportbtn, *doneBtn, *savebtn, *reloadbtn, *buybtn;
    IBOutlet UITextView *description, *detaildescription;
    IBOutlet UIView *reviewview, *suggestedview, *containerView, *pickersubview, *descriptionview, *descriptiondetailview, *prodctImagesuperview, *prodctdetailssuperview, *voteview;
    IBOutlet UITableView *reviewtable;
    IBOutlet UICollectionView *suggestedtable, *imagecollections;
    AppDelegate *appdelegate;
    NSMutableArray *reviewarray, *suggestedarray;
    CGRect containerviewframe;
    NSMutableDictionary *productdetail;
    NSString *requesttype, *filepath, *vote, *occationid, *occationname;
    IBOutlet UIActivityIndicatorView *loader;
    NSInteger deletedindex;
    IBOutlet UIPickerView *droppicker;
    NSArray *occationarray, *imagearray;
    
    IBOutlet UIView *reportview;
    IBOutlet UITableView *reporttable;
    IBOutlet UITextView *reportdescription;
    IBOutlet UIScrollView *reportscroll;
    NSArray *reportarray;
    NSInteger selectedindex;
    BOOL isreportview, isoccation, otherlocation, viewonly;
    float productimagewidth,rangeval;
    
}

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;

@end

@implementation ProductDetail
@synthesize productid,producttype;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initiateMenuOptions];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    productdetail = [[NSMutableDictionary alloc] init];
    suggestedarray = [[NSMutableArray alloc] init];
    occationarray = [[NSMutableArray alloc] init];
    reportarray = [[NSArray alloc] initWithObjects:@"Inappropriate Post",@"Incorrect Price",@"Does Not Belong",@"Nonfunctional URL",@"Item not Available",@"Other", nil];
    loader.hidden = YES;
    [loader stopAnimating];
    scroll.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 839);
    UINib *cellNib = [UINib nibWithNibName:@"SuggestedCell" bundle:nil];
    [suggestedtable registerNib:cellNib forCellWithReuseIdentifier:@"SuggestedCell"];
    
    UINib *cellNib1 = [UINib nibWithNibName:@"ProductImageCell" bundle:nil];
    [imagecollections registerNib:cellNib1 forCellWithReuseIdentifier:@"ProductImageCell"];
    
    //[imagecollections registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 4, [[UIScreen mainScreen] bounds].size.width - 10, 32)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    textView.returnKeyType = UIReturnKeySend;
    textView.font = [UIFont fontWithName:@"Avenir-Heavy" size:14.0];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor blackColor];
    textView.placeholder = @"Review this item...";
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    textView.userInteractionEnabled = YES;
    
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"comment.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    //   UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    //   entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.image = entryBackground;
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"comment.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
//    imageView.frame = CGRectMake(8, 0, 304, containerView.frame.size.height);
//    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    textView.returnKeyType = UIReturnKeySend;
    //    textView
    // view hierachy
    containerView.backgroundColor = [UIColor clearColor];
    // [containerView addSubview:imageView];
    // [containerView addSubview:entryImageView];
    [containerView addSubview:textView];
    //  [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"send.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"send.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
    //	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //	doneBtn.frame = CGRectMake(containerView.frame.size.width - 64, 8, 45, 26);//45,26
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    //	[doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
//    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
//    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    //[containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self getproductdetail];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidekeyboards:)];
    gestureRecognizer.delegate = self;
//    [scroll addGestureRecognizer:gestureRecognizer];
    [self.view addGestureRecognizer:gestureRecognizer];
    posteddate.adjustsFontSizeToFitWidth = YES;
   // reportview.frame = [[UIScreen mainScreen] bounds];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getproductdetail{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"product_details\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"pdt_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,productid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"detail";
}


-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        if([requesttype isEqualToString:@"detail"]){
            
            productdetail = [[tempdict objectForKey:@"product_details"] mutableCopy];
            rangeval = [[tempdict objectForKey:@"radius"] floatValue];
            filepath = [[tempdict objectForKey:@"filePath"] mutableCopy];
            suggestedarray = [[tempdict objectForKey:@"suugested_items"] mutableCopy];
            imagearray = [[[tempdict objectForKey:@"product_details"] objectForKey:@"image_array"] mutableCopy];
            countlabel.text = [NSString stringWithFormat:@"%d/%lu", 1,(unsigned long)imagearray.count];
            reviewarray = [[productdetail objectForKey:@"reviews"] mutableCopy];
            [self setvalues];
            [imagecollections reloadData];
           // [imagecollections reloadData];
            if([[productdetail objectForKey:@"user_id"] integerValue]  == [appdelegate.userid integerValue]){
                reportbtn.selected = YES;
//                containerView.hidden = YES;
                
            }
            else{
                
                reportbtn.selected = NO;
                containerView.hidden = NO;
            }
            [self setframes];
            [suggestedtable reloadData];
            [reviewtable reloadData];
        }
        else if([requesttype isEqualToString:@"addreviews"] || [requesttype isEqualToString:@"save"] || [requesttype isEqualToString:@"vote"] || [requesttype isEqualToString:@"review_rating"] || [requesttype isEqualToString:@"addtooccasion"] || [requesttype isEqualToString:@"occasions"] || [requesttype isEqualToString:@"trendy_report"] || [requesttype isEqualToString:@"deletepost"] || [requesttype isEqualToString:@"review_delete"]){

            if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
                
                if([requesttype isEqualToString:@"addreviews"]){
                    [self getproductdetail];
                }
                else if([requesttype isEqualToString:@"occasions"]){
                    
                    occationarray = [[tempdict objectForKey:@"occasion_list"] mutableCopy];
                    [droppicker reloadAllComponents];
                    isoccation = YES;
                    DropDown *obj = [[DropDown alloc] init];
                    obj.type = @"occation";
                    obj.droparray = [occationarray mutableCopy];
                    [self.navigationController pushViewController:obj animated:YES];
                }
                else if([requesttype isEqualToString:@"trendy_report"]){
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Report sent successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    selectedindex = 0;
                    [reporttable reloadData];
                    reportdescription.text = @"Enter Other comments here";
                    if(isreportview == YES){
                        [reportview removeFromSuperview];
                        isreportview = NO;
                    }
                    
                }

                else if([requesttype isEqualToString:@"vote"]){
                    
                    NSMutableDictionary *dict = [productdetail mutableCopy];
                    if([vote isEqualToString:@"up"]){
                        [dict setObject:@"up" forKey:@"vote_status"];
                    }
                    else{
                        [dict setObject:@"down" forKey:@"vote_status"];
                    }
                    [dict setObject:[NSString stringWithFormat:@"%d",[[tempdict objectForKey:@"vote_count"] intValue]] forKey:@"vote_count"];
                    productdetail = [dict mutableCopy];
                    [self setvalues];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
                }
                else if([requesttype isEqualToString:@"save"]){
                    
                    NSMutableDictionary *dict = [productdetail mutableCopy];
                    [dict setObject:@"Y" forKey:@"save_status"];
                    productdetail = [dict mutableCopy];
                    [self setvalues];
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];
                }
                else if([requesttype isEqualToString:@"addtooccasion"]){
                    
                    NSMutableDictionary *dict = [productdetail mutableCopy];
                    [dict setObject:occationid forKey:@"occasion_id"];
                    [dict setObject:occationname forKey:@"occasion_name"];
                    productdetail = [dict mutableCopy];
                    [self setvalues];
                }
                else if([requesttype isEqualToString:@"deletepost"]){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if([requesttype isEqualToString:@"review_rating"]){
                    
                    NSMutableDictionary *dict = [[reviewarray objectAtIndex:deletedindex] mutableCopy];
                    [dict setObject:[NSString stringWithFormat:@"%d",[[tempdict objectForKey:@"review_count"] intValue]] forKey:@"reviewRateCount"];
                    [dict setObject:@"YES" forKey:@"vote_status"];
                    [reviewarray replaceObjectAtIndex:deletedindex withObject:dict];
                    if([[tempdict objectForKey:@"review_count"] intValue] == 3){
                       
                        [reviewarray removeObjectAtIndex:deletedindex];
                        [self getproductdetail];
                        
                    }
                    [reviewtable reloadData];
                    
                }
                else if([requesttype isEqualToString:@"review_delete"]){
                    
                    [self getproductdetail];
                }
            }
            else{
                
            }
        }
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void)deleteindex:(NSUInteger)index{
  
    [self getproductdetail];
}

-(void)setvalues{
    
    if([productdetail objectForKey:@"fileNAME"] != [NSNull null]){
        loader.hidden = NO;
        [loader startAnimating];
        NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[productdetail objectForKey:@"fileNAME"]];
        [productimage setupImageViewerWithImageURL:[NSURL URLWithString:[productdetail objectForKey:@"fileNAME"]]];
        [productimage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"recentdefaultimage"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
            
            if(error){
                productimage.image = [UIImage imageNamed:@"recentdefaultimage"];
            }
            else{
                productimage.image = image;
            }
            loader.hidden = YES;
            [loader stopAnimating];
        }];
    }
    else
        productimage.image = [UIImage imageNamed:@"recentdefaultimage"];
    
    if([productdetail objectForKey:@"posted_by"] != [NSNull null]){
        
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        productownername.attributedText = [[NSAttributedString alloc] initWithString:[productdetail objectForKey:@"posted_by"] attributes:underlineAttribute];
    }
    else
        productownername.text = @"";

    buybtn.enabled = YES;
    addtooccationbtn.hidden = NO;
    addtooccationbtn.userInteractionEnabled = YES;
    upbtn.hidden = NO;
    downbtn.hidden = NO;
    votecount.hidden = NO;
    voteview.hidden = NO;
    CGRect frame = productimage.frame;
    frame.size.width = productimagewidth;
    productimage.frame = frame;
    imagecollections.frame = frame;
    suggestedview.hidden = NO;
    containerView.hidden = NO;
    upbtn.enabled = YES;
    downbtn.enabled = YES;
    occasionlabel.hidden = NO;
    
    if([productdetail objectForKey:@"vote_status"] != [NSNull null])
    {
        if([[productdetail objectForKey:@"vote_status"] isEqualToString:@"up"])
        {
            upbtn.enabled = NO;
            downbtn.enabled = YES;
        }
        else if([[productdetail objectForKey:@"vote_status"] isEqualToString:@"down"])
        {
            upbtn.enabled = YES;
            downbtn.enabled = NO;
        }
        else{
            upbtn.enabled = YES;
            downbtn.enabled = YES;
        }
    }
    else{
        upbtn.enabled = YES;
        downbtn.enabled = YES;
    }
    
    if([productdetail objectForKey:@"occasion_id"] != [NSNull null] && [productdetail objectForKey:@"occasion_name"] != [NSNull null] && ![[productdetail objectForKey:@"occasion_name"] isEqualToString:@""]){
        
        occasionlabel.text = [productdetail objectForKey:@"occasion_name"];
        occasionlabel.hidden = NO;
        addtooccationbtn.selected = YES;
        
    }
    else{
        addtooccationbtn.selected = NO;
        addtooccationbtn.hidden = NO;
        occasionlabel.text = @"Add to Occasion";
        
        
    }
//    productimagewidth
    
       otherlocation = NO;
        if([productdetail objectForKey:@"lat"] != [NSNull null] && [productdetail objectForKey:@"long"] != [NSNull null] ){
            
            CLLocation *locA = [[CLLocation alloc] initWithLatitude:[[productdetail objectForKey:@"lat"] doubleValue] longitude:[[productdetail objectForKey:@"long"] doubleValue]];

            CLLocation *locB;
            locB = [[CLLocation alloc] initWithLatitude:appdelegate.nearloclati longitude:appdelegate.nearloclong];
            if(appdelegate.locationManager.location)
            {
                
            }
            else{
                [appdelegate.locationManager startUpdatingLocation];
            }
            CLLocationDistance distance = [locA distanceFromLocation:locB];
    
            if(-rangeval<distance/1000 && rangeval>distance/1000){
              
                otherlocation = NO;
                addtooccationbtn.hidden = NO;
                votecount.textColor = [UIColor colorWithRed:255.0/255 green:127.0/255 blue:0 alpha:1];
            }
            else{
                
                otherlocation = YES;
//                containerView.hidden = YES;
                //addtooccationbtn.hidden = YES;
//                if([occasionlabel.text isEqualToString:@"Add to Occasion"]){
//                    occasionlabel.hidden = YES;
//                    addtooccationbtn.userInteractionEnabled = NO;
//                }
//                else
                    occasionlabel.hidden = NO;
                votecount.textColor = [UIColor grayColor];
                suggestedview.hidden = YES;
                upbtn.enabled = NO;
                downbtn.enabled = NO;
            }
        }
    if([producttype isEqualToString:@"Occasions"]){
        
//        addtooccationbtn.hidden = YES;
//        addtooccationbtn.userInteractionEnabled = NO;
//        if([occasionlabel.text isEqualToString:@"Add to Occasion"])
//            occasionlabel.hidden = YES;
//        else
            occasionlabel.hidden = NO;
        upbtn.hidden = YES;
        downbtn.hidden = YES;
        votecount.hidden = YES;
        voteview.hidden = YES;
        CGRect frame = productimage.frame;
        frame.size.width = [[UIScreen mainScreen] bounds].size.width - 18;
        productimage.frame = frame;
        imagecollections.frame = frame;
    }
    
    
    
    if([productdetail objectForKey:@"posted_locatn"] && [productdetail objectForKey:@"posted_locatn"] != [NSNull null]){
        
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        postedlocation.attributedText = [[NSAttributedString alloc] initWithString:[productdetail objectForKey:@"posted_locatn"] attributes:underlineAttribute];
    }
    else
        postedlocation.text = @"";
    
    if([productdetail objectForKey:@"posted_on"] != [NSNull null]){
        posteddate.text = [productdetail objectForKey:@"posted_on"];
    }
    else
        posteddate.text = @"";
    
    if([productdetail objectForKey:@"brand"] != [NSNull null]){
        productname.text = [productdetail objectForKey:@"brand"];
    }
    else
        productname.text = @"";
    
    if([productdetail objectForKey:@"price"] != [NSNull null]){
//        productprice.text = [NSString stringWithFormat:@"%.2f",[[productdetail objectForKey:@"price"] floatValue]];
        productprice.text = [NSString stringWithFormat:@"$%@",[productdetail objectForKey:@"price"]];
    }
    else
        productprice.text = @"";
    
    if([productdetail objectForKey:@"vote_count"] != [NSNull null]){
        votecount.text = [NSString stringWithFormat:@"%d",[[productdetail objectForKey:@"vote_count"] intValue]];
    }
    else
        votecount.text = @"";
    
    if([productdetail objectForKey:@"opposite_vote"] != [NSNull null]){
        ratecount.text = [NSString stringWithFormat:@"%d/10",[[productdetail objectForKey:@"opposite_vote"] intValue]];
    }
    else
        ratecount.text = @"";
    
    if([productdetail objectForKey:@"gender"] != [NSNull null]){
        
        if([[productdetail objectForKey:@"gender"] isEqualToString:@"male"]){
            
            genderimage.image = [UIImage imageNamed:@"gender1"];
            CGRect frame = genderimage.frame;
            frame.size = CGSizeMake(15, 21);
            genderimage.frame = frame;
            genderimage.center = CGPointMake(ratecount.frame.origin.x - 15/2, ratecount.center.y) ;
        }
        else{
           
            genderimage.image = [UIImage imageNamed:@"gender"];
            CGRect frame = genderimage.frame;
            frame.size = CGSizeMake(14, 22);
            genderimage.frame = frame;
            genderimage.center = ratecount.center;
            genderimage.center = CGPointMake(ratecount.frame.origin.x - 14/2, ratecount.center.y) ;
        }
    }
    else{
        genderimage.image = nil;
    }
    if([productdetail objectForKey:@"product_name"] != [NSNull null]){
        descriptiontitle.text = [productdetail objectForKey:@"product_name"];
    }
    else
        descriptiontitle.text = @"";
    
    if([productdetail objectForKey:@"description"] != [NSNull null] && ![[productdetail objectForKey:@"description"] isEqualToString:@""] && ![[productdetail objectForKey:@"description"] isEqualToString:@"None"]){
        description.text = [productdetail objectForKey:@"description"];
//        detaildescription.text = description.text;
    }
    else{
        description.text = @"";
    }
    
    int userid = 0;
    if([productdetail objectForKey:@"user_id"] != [NSNull null])
        userid = [[productdetail objectForKey:@"user_id"] intValue];
    //        NSLog(@"userid --- %@",[appdelegate.userid intValue]);
    
   

    if([productdetail objectForKey:@"save_status"] != [NSNull null])
    {
        if([[productdetail objectForKey:@"save_status"] isEqualToString:@"Y"])
        {
            savebtn.enabled = NO;
            savedstatus.text = @"Saved";
        }
        else{
            savebtn.enabled = YES;
            savedstatus.text = @"Save";
        }
    }
    else{
        savebtn.enabled = YES;
        savedstatus.text = @"Save";
    }
    if([[productdetail objectForKey:@"user_id"] integerValue]  == [appdelegate.userid integerValue]){
//        containerView.hidden = YES;
        
    }
    else{
        containerView.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
   
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedvalue:) name:@"DROPTABLEVALUE"  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshpush:) name:@"REFRESHPUSH"  object:nil];
    
    if(!productimagewidth){
        productimagewidth = productimage.frame.size.width;
    }
    [reportview removeFromSuperview];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
   
    if(isoccation == NO)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reportview removeFromSuperview];
    [super viewWillDisappear:animated];
}

-(void)setframes{
    
    if(reviewarray.count>0){
        
        reviewview.hidden = NO;
        CGRect frame1 = reviewview.frame;
        if([productdetail objectForKey:@"description"] != [NSNull null] && ![[productdetail objectForKey:@"description"] isEqualToString:@""] && ![[productdetail objectForKey:@"description"] isEqualToString:@"None"])
            frame1.origin.y = descriptionview.frame.origin.y + descriptionview.frame.size.height + 8;
        else
            frame1.origin.y = descriptionview.frame.origin.y;
        
        CGRect reviewtableframe = reviewtable.frame;
        if([[productdetail objectForKey:@"review_count"] intValue] <= 3){

            reviewtableframe.size.height = 62*reviewarray.count;
            reloadbtn.hidden = YES;
            frame1.size.height = reviewtableframe.origin.y + reviewtableframe.size.height + 8;
        }
        else{
            reviewtableframe.size.height = 62*3;
            reloadbtn.hidden = NO;
            CGRect reloadbtnframe = reloadbtn.frame;
            reloadbtnframe.origin.y = reviewtableframe.origin.y + reviewtableframe.size.height + 8;
            reloadbtn.frame = reloadbtnframe;
            frame1.size.height = reloadbtnframe.origin.y + reloadbtnframe.size.height + 8;
        }
        reviewtable.frame = reviewtableframe;
        reviewview.frame = frame1;
        
        CGRect frame2 = containerView.frame;
        frame2.origin.y = reviewview.frame.origin.y + reviewview.frame.size.height + 8;
        containerView.frame = frame2;
        
        CGRect frame3 = suggestedview.frame;
        if(containerView.hidden == NO)
            frame3.origin.y = containerView.frame.origin.y + containerView.frame.size.height + 8;
        else
            frame3.origin.y = containerView.frame.origin.y;
        suggestedview.frame = frame3;
        scroll.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, frame3.origin.y + frame3.size.height + 30);
    }
    else{
        
        reviewview.hidden = YES;
        CGRect frame = containerView.frame;
        if([productdetail objectForKey:@"description"] != [NSNull null] && ![[productdetail objectForKey:@"description"] isEqualToString:@""] && ![[productdetail objectForKey:@"description"] isEqualToString:@"None"])
            frame.origin.y = descriptionview.frame.origin.y + descriptionview.frame.size.height + 8;
        else
            frame.origin.y = descriptionview.frame.origin.y;
        
        containerView.frame = frame;
        
        CGRect frame1 = suggestedview.frame;
        if(containerView.hidden == NO)
            frame1.origin.y = containerView.frame.origin.y + containerView.frame.size.height + 8;
        else
            frame1.origin.y = containerView.frame.origin.y;
        suggestedview.frame = frame1;
        scroll.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, frame1.origin.y + frame1.size.height + 30);
    }
    if(suggestedarray.count>0){
        
        suggestedview.hidden = NO;
        scroll.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, suggestedview.frame.origin.y + suggestedview.frame.size.height + 30);
    }
    else{
        suggestedview.hidden = YES;
        scroll.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, suggestedview.frame.origin.y+38);
        
    }
    
}

#pragma mark - growing text

-(void)resignTextView
{
    
    
    if([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        textView.text=@"";
        [textView resignFirstResponder];
    }
    else
    {
        scroll.scrollEnabled = YES;
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"save_review\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"post_id\": \"%@\",\"review\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,productid,[textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"]];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
        requesttype = @"addreviews";
        textView.text=@"";
        [textView resignFirstResponder];
        
    }
}


- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    NSLog(@"diff -- %f",diff);
    // NSLog(@"growingTextView -- %f",growingTextView.frame.size.height);
    //NSLog(@"height -- %f",height);
    
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
    
    diff = diff * - 1;
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if(descriptiondetailview.hidden == NO)
        descriptiondetailview.hidden = YES;
    if(isreportview == YES){
       
        reportscroll.contentOffset = CGPointMake(0, reportdescription.frame.origin.y - 40);
    }
    else{
        // adding donebn to top bar
        CGRect keyboardBounds;
        [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
        keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        //    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        //    NSNumber *curve = [aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        //
        // Need to translate the bounds to account for rotation.
        keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        //    [UIView animateWithDuration:0.2f animations:^{
        //
        //
        //        CGRect frame = containerView.frame;
        //        //        if (!IS_WIDESCREEN)
        //        //        {
        //        //            frame.origin.y -= kbSize.height-50;
        //        //        }
        //        //        else
        //        //        {
        //        //           // frame.origin.y -= kbSize.height+150;
        //        //  frame.origin.y = 0;
        //        // }
        ////        frame.origin.y = containerView.frame.size.height - (keyboardBounds.size.height + 50);
        //
        //
        ////        containerView.frame = frame;
        ////        reviewtable.frame = CGRectMake(reviewtable.frame.origin.x, 45, reviewtable.frame.size.width, containerView.frame.origin.y - 45);
        ////        if(reviewarray.count>0)
        ////            [reviewtable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:commentsarray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        //    }];
        float diff = [[UIScreen mainScreen] bounds].size.height - 70 - keyboardBounds.size.height;
        if(containerView.frame.origin.y - diff >0)
            diff = containerView.frame.origin.y - diff;
        else
            diff = -1*(containerView.frame.origin.y -diff);
        scroll.contentOffset = CGPointMake(0, diff+45);
        scroll.scrollEnabled = NO;
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(isreportview == YES){
        
        reportscroll.contentOffset = CGPointMake(0, reportdescription.frame.origin.y - 40);
    }
    else{
        
    }
    scroll.scrollEnabled = YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    //    BOOL newLine = [text isEqualToString:@"\n"];
    //    if(newLine)
    //    {
    //        NSLog(@"User started a new line");
    //        NSString *value = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet    whitespaceCharacterSet]];
    //        // NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    //        // NSRange range = [candidate rangeOfCharacterFromSet:whitespace];
    //        if([value length] == 0) {
    //            // There is whitespace.
    //            return NO;
    //        }
    //    }
    BOOL newLine = [text isEqualToString:@"\n"];
    if(newLine)
    {
        [self resignTextView];
        return YES;
    }
    return YES;
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView{
    
    return YES;
}


#pragma mark Textview Delegates
- (void)textViewDidBeginEditing:(UITextView *)textView1{
    
    if([textView1.text isEqualToString:@"Enter Other comments here"]){
        textView1.text = NULL;
//        textView1.textColor = [UIColor blackColor];
    }
    else{
//        textView1.textColor = [UIColor lightGrayColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView1{
    
    if([self validateEmail:textView1.text type:@"space"]  == YES){
        
        textView1.text = @"Enter Other comments here";
//        textView1.textColor = [UIColor lightGrayColor];
    }
    else{
//        textView1.textColor = [UIColor blackColor];
    }
}

- (BOOL) validateEmail: (NSString *) candidate type:(NSString *) type {
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

- (BOOL)textView:(UITextView *)textView1 shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    BOOL newLine = [text isEqualToString:@"\n"];
    if(newLine)
    {
        [textView1 resignFirstResponder];
        reportscroll.contentOffset = CGPointMake(0, 0);
        return YES;
    }
    return YES;
}

/*// UIPickerView...
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [occationarray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [[occationarray objectAtIndex:row] objectForKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    occationid = [[occationarray objectAtIndex:row] objectForKey:@"occasion_id"];
     occationname = [[occationarray objectAtIndex:row] objectForKey:@"name"];
//    addtooccasionfield.text = [[occationarray objectAtIndex:row] objectForKey:@"name"];
//    [addtooccasionfield resignFirstResponder];
//    pickersubview.hidden = YES;
    [pickersubview removeFromSuperview];
    [scroll setContentOffset:CGPointMake(0, 0) animated:NO];
    scroll.scrollEnabled = YES;
    [self addtooccasion];
}*/

-(void)selectedvalue: (NSNotification *) notification
{
    NSDictionary *selecteddict = (NSDictionary *)[notification userInfo];
    if (selecteddict) {
       
        occationid = [selecteddict objectForKey:@"occasion_id"];
        occationname = [selecteddict objectForKey:@"name"];
        [scroll setContentOffset:CGPointMake(0, 0) animated:NO];
        [self addtooccasion];
    }
    isoccation = NO;
}


#pragma mark - Local methods

- (void)initiateMenuOptions {
    
    self.menuTitles = @[@"Repost",
                        @"Report"];
    
    self.menuIcons = [[NSArray alloc] initWithObjects:@"context_posted_item",@"context_rev_items",nil];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
    contextview.hidden = YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //should be called after rotation animation completed
    [self.contextMenuTableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.contextMenuTableView updateAlongsideRotation];
}
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //should be called after rotation animation completed
        [self.contextMenuTableView reloadData];
    }];
    [self.contextMenuTableView updateAlongsideRotation];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == reviewtable){
        
        return 62;
    }
    else if (tableView == reporttable)
    {
        return 33;
    }
    
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == reviewtable)
        return reviewarray.count;
    else if(tableView == reporttable)
        return reportarray.count;
    else
        return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == reviewtable){
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
        NSString *msg = @"";
        if([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"review"] != [NSNull null])
            msg = [[reviewarray objectAtIndex:indexPath.row] objectForKey:@"review"];
        
        if([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"username"] != [NSNull null]){
            
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            cell.reviewownername.attributedText = [[NSAttributedString alloc] initWithString:[[reviewarray objectAtIndex:indexPath.row] objectForKey:@"username"] attributes:underlineAttribute];
        }
        
        cell.reviewtext.text = msg;
        cell.reviewownerbtn.tag = indexPath.row;
        [cell.reviewownerbtn addTarget:self action:@selector(goToReviewOwner:) forControlEvents:UIControlEventTouchUpInside];
        
        if([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] != [NSNull null] && [[[reviewarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] isEqualToString:@"YES"])
            cell.deletebtn.hidden = YES;
        else
            cell.deletebtn.hidden = NO;
        
        if(cell.deletebtn.hidden == YES || otherlocation == YES){
            
            cell.deletebtn.hidden = YES;
        }
        else{
            cell.deletebtn.hidden = NO;
        }
        if([[[reviewarray objectAtIndex:indexPath.row] objectForKey:@"user_id"] integerValue] == [appdelegate.userid integerValue])
            cell.deletebtn.selected = YES;
        else
            cell.deletebtn.selected = NO;
        
        cell.deletebtn.tag = indexPath.row;
        [cell.deletebtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (tableView == reporttable)
    {
        static NSString *cellidentifier =@"cell";
        ReportCell *cell = (ReportCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier];
        
        if(cell==nil)
        {
            NSString *nib = @"ReportCell";
            NSArray *viewObjcts = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
            for(id crntObj in viewObjcts){
                
                if ([crntObj isKindOfClass:[UITableViewCell class]]) {
                    
                    cell = crntObj;
                    break;
                }
            }
        }
        cell.reasonlabel.text = [reportarray objectAtIndex:indexPath.row];
        if(selectedindex == indexPath.row)
            cell.checkedbtn.selected = YES;
        else
            cell.checkedbtn.selected = NO;
        cell.checkedbtn.tag = indexPath.row;
        [cell.checkedbtn addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
        return cell;

    }
    else
    {
        ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
        
        if (cell) {
            cell.backgroundColor = [UIColor greenColor];
            cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
            cell.menuImageView.image = [UIImage imageNamed:[self.menuIcons objectAtIndex:indexPath.row]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
}

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == reporttable){
        selectedindex = indexPath.row;
        [reporttable reloadData];
    }
    else if(tableView == reviewtable){
        [self reviewlist:nil];
    }
    else
    {
        
        [tableView dismisWithIndexPath:indexPath];
        contextbtn.selected = NO;
        if(indexPath.row == 0){
            
        }
        else if(indexPath.row == 1){
            
            [self report:nil];
        }
        
    }
   
}




#pragma mark - UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size;
    if(collectionView == imagecollections)
        size = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 320);
    else if(collectionView == suggestedtable)
        size = CGSizeMake(100, 104);
    return size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == imagecollections)
        return imagearray.count;
    else if(collectionView == suggestedtable)
        return suggestedarray.count;
        return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == imagecollections){
        
        ProductImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductImageCell" forIndexPath:indexPath];

        //cell.collectionImageView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, cell.frame.size.height);
        NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[imagearray objectAtIndex:indexPath.row] objectForKey:@"image_name"]];
//        cell.collectionImageView.contentMode = UIViewContentModeScaleAspectFit;
//        cell.collectionImageView.clipsToBounds = true;
        [cell setContentMode:UIViewContentModeScaleAspectFit];
        [cell sizeToFit];
       // [cell.collectionImageView sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@""]];
        [cell.collectionImageView sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"no_img.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
            
            if(error){
                cell.collectionImageView.image = [UIImage imageNamed:@"recentdefaultimage"];
            }
            else{
                cell.collectionImageView.image = image;
            }
//            cell.activityloader.hidden = YES;
//            [cell.activityloader stopAnimating];
        }];
        cell.swipefullbtn.frame = cell.collectionImageView.frame;
        cell.swipefullbtn.tag = indexPath.row;
        [cell.swipefullbtn addTarget:self action:@selector(zooming:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else{
        
        SuggestedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SuggestedCell" forIndexPath:indexPath];
        //    cell.activityloader.hidden = YES;
        //    [cell.activityloader stopAnimating];
        //            [itemimage sd_setImageWithURL:[NSURL URLWithString:[productdetail objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@""]];
        if([[suggestedarray objectAtIndex:indexPath.row] objectForKey:@"fileNAME"] != [NSNull null]){
            cell.activityloader.hidden = NO;
            [cell.activityloader startAnimating];
            NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[suggestedarray objectAtIndex:indexPath.row] objectForKey:@"fileNAME"]];
            //        [cell.itemImage setupImageViewerWithImageURL:[NSURL URLWithString:urlpath]];
            [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:urlpath] placeholderImage:[UIImage imageNamed:@"no_img.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
                
                if(error){
                    cell.itemImage.image = [UIImage imageNamed:@"recentdefaultimage"];
                }
                else{
                    cell.itemImage.image = image;
                }
                cell.activityloader.hidden = YES;
                [cell.activityloader stopAnimating];
            }];
        }
        
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    if(collectionView == suggestedtable){
        productid = [[suggestedarray objectAtIndex:indexPath.row] objectForKey:@"id"];
        [self getproductdetail];
        scroll.contentOffset = CGPointMake(0, 0);
    }
}


#pragma mark - FGalleryViewControllerDelegate Methods


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    return (int)imagearray.count;
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    if( gallery == localGallery ) {
        return FGalleryPhotoSourceTypeLocal;
    }
    else return FGalleryPhotoSourceTypeNetwork;
}
//- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
//    NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[suggestedarray objectAtIndex:index] objectForKey:@"fileNAME"]];
//    return urlpath;
//}

- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    
    NSString *urlpath = [NSString stringWithFormat:@"%@%@",filepath,[[imagearray objectAtIndex:index] objectForKey:@"image_name"]];
    return urlpath;
}

- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}


- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}
-(IBAction)zooming:(id)sender{
    networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    networkGallery.currentIndex = [sender tag];
    networkGallery.startingIndex = [sender tag];
    NSLog(@"networkGallery.currentIndex==%ld",(long)networkGallery.currentIndex);
    [self.navigationController pushViewController:networkGallery animated:YES];
    
    self.navigationController.navigationBar.hidden=NO;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if(scrollView.tag != 1 && scrollView.tag != 2){
        CGFloat pageWidth = imagecollections.frame.size.width;
        float currentPage = imagecollections.contentOffset.x / pageWidth;
        
        if (0.0f != fmodf(currentPage, 1.0f))
        {
            currentPage = currentPage + 1;
        }
        else
        {
            currentPage = currentPage;
        }
        countlabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)currentPage + 1,(unsigned long)imagearray.count];
    }
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if(tableView == reviewtable){
       
        return 62;
    }
    return 33;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger )section{
   if(tableView == reviewtable)
       return reviewarray.count;
    else
        return reportarray.count;
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == reviewtable){
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
        NSString *msg = @"";
        if([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"review"] != [NSNull null])
            msg = [[reviewarray objectAtIndex:indexPath.row] objectForKey:@"review"];
        
        if([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"username"] != [NSNull null]){
            
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            cell.reviewownername.attributedText = [[NSAttributedString alloc] initWithString:[[reviewarray objectAtIndex:indexPath.row] objectForKey:@"username"] attributes:underlineAttribute];
        }
        
        cell.reviewtext.text = msg;
        cell.reviewownerbtn.tag = indexPath.row;
        [cell.reviewownerbtn addTarget:self action:@selector(goToReviewOwner:) forControlEvents:UIControlEventTouchUpInside];
        
        if([[reviewarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] != [NSNull null] && [[[reviewarray objectAtIndex:indexPath.row] objectForKey:@"vote_status"] isEqualToString:@"YES"])
            cell.deletebtn.hidden = YES;
        else
            cell.deletebtn.hidden = NO;
        
        if(cell.deletebtn.hidden == YES || otherlocation == YES){
           
            cell.deletebtn.hidden = YES;
        }
        else{
            cell.deletebtn.hidden = NO;
        }
        if([[[reviewarray objectAtIndex:indexPath.row] objectForKey:@"user_id"] integerValue] == [appdelegate.userid integerValue])
            cell.deletebtn.selected = YES;
        else
            cell.deletebtn.selected = NO;
        
        cell.deletebtn.tag = indexPath.row;
        [cell.deletebtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        static NSString *cellidentifier =@"cell";
        ReportCell *cell = (ReportCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier];
        
        if(cell==nil)
        {
            NSString *nib = @"ReportCell";
            NSArray *viewObjcts = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
            for(id crntObj in viewObjcts){
                
                if ([crntObj isKindOfClass:[UITableViewCell class]]) {
                    
                    cell = crntObj;
                    break;
                }
            }
        }
        cell.reasonlabel.text = [reportarray objectAtIndex:indexPath.row];
        if(selectedindex == indexPath.row)
            cell.checkedbtn.selected = YES;
        else
            cell.checkedbtn.selected = NO;
        cell.checkedbtn.tag = indexPath.row;
        [cell.checkedbtn addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == reporttable){
        selectedindex = indexPath.row;
        [reporttable reloadData];
    }
    else if(tableView == reviewtable){
        [self reviewlist:nil];
    }
}          */

-(IBAction)profileorlocation:(id)sender{
    
    if([sender tag] == 0){
        
        ProfileView *obj = [[ProfileView alloc] init];
        obj.userid = [productdetail objectForKey:@"user_id"];
        obj.navigated = YES;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if([sender tag] == 1){
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[productdetail objectForKey:@"lat"],@"lat",[productdetail objectForKey:@"long"],@"long",[productdetail objectForKey:@"posted_locatn"],@"location", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:dict];
        [appdelegate.tabBarController.delegate tabBarController:self.tabBarController didSelectViewController:[[appdelegate.tabBarController viewControllers] objectAtIndex:0]];
        appdelegate.tabBarController.selectedIndex = 0;
//        [appdelegate.tabBarController setSelectedIndex:0];
//        [appdelegate.tabBarController.navigationController popToRootViewControllerAnimated:YES];
    }

}

-(IBAction)goToReviewOwner:(id)sender{
   
    ProfileView *obj = [[ProfileView alloc] init];
    obj.userid = [[reviewarray objectAtIndex:[sender tag]] objectForKey:@"user_id"];
    obj.navigated = YES;
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)buy:(id)sender{
    
    if([productdetail objectForKey:@"product_url"] != [NSNull null] && ![[productdetail objectForKey:@"product_url"] isEqualToString:@""]){
        
        //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[productdetail objectForKey:@"product_url"]]];
        
        PostStep1 *obj = [[PostStep1 alloc] init];
        obj.urlstring = [productdetail objectForKey:@"product_url"];
        //    obj.tabBarController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"This product is not available for sales." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(IBAction)vote:(id)sender{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    if([sender tag] ==0){
        vote = @"up";
    }
    else{
        vote = @"down";
    }
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trend_vote\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"vote\": \"%@\",\"post_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,vote,productid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
//    [self startLoader:@"Loading..."];
    requesttype = @"vote";
    
}

-(IBAction)saveproduct:(id)sender{
    
    NSString *url = @"";
    if([productdetail objectForKey:@"product_url"] != [NSNull null])
        url = [productdetail objectForKey:@"product_url"];
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"save_product_user\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"product_id\": \"%@\",\"link\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,productid,url];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"save";

}

-(IBAction)occasion:(id)sender{
    
    if([productdetail objectForKey:@"occasion_id"] != [NSNull null] && [productdetail objectForKey:@"occasion_name"] != [NSNull null] && ![[productdetail objectForKey:@"occasion_name"] isEqualToString:@""]){
        
        OccasionDetail *obj = [[OccasionDetail alloc]init];
        obj.occasionid = [productdetail objectForKey:@"occasion_id"];
        obj.occasionname = [productdetail objectForKey:@"occasion_name"];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[productdetail objectForKey:@"lat"],@"lat",[productdetail objectForKey:@"long"],@"long", nil];
        obj.selectedlocation = [dict mutableCopy];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        float lat, lng;
        lat = appdelegate.locationManager.location.coordinate.latitude;
        lng = appdelegate.locationManager.location.coordinate.longitude;
        if(appdelegate.locationManager.location)
        {
            
        }
        else{
            
            [appdelegate.locationManager startUpdatingLocation];
        }
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_occasion_list\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"lat\": \"%f\",\"long\": \"%f\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,lat,lng];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
        requesttype = @"occasions";
    }
}

-(void)addtooccasion{
    
    NSString *custom = @"N";
    if([occationid isEqualToString:@""]){
        occationid = occationname;
        custom = @"Y";
    }
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"add_to_occation\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"product_id\": \"%@\",\"occasion_id\": \"%@\",\"custom\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,productid,occationid,custom];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"addtooccasion";
    
}

-(IBAction)delete:(id)sender{
    
    deletedindex = [sender tag];
    
    if([[[reviewarray objectAtIndex:[sender tag]] objectForKey:@"user_id"] integerValue] == [appdelegate.userid integerValue]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this review?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
        [alert show];
        alert.tag = 2;
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
- (IBAction)openMenu:(id)sender
{
    if(contextbtn.selected == NO){
        contextbtn.selected = YES;
        contextview.hidden = NO;
        if (!self.contextMenuTableView) {
            self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
            self.contextMenuTableView.animationDuration = 0.15;
            //optional - implement custom YALContextMenuTableView custom protocol
            self.contextMenuTableView.yalDelegate = self;
            
            //register nib
            UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
            [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
        }
        
        // it is better to use this method only for proper animation
        [self.contextMenuTableView showInView:contextview withEdgeInsets:UIEdgeInsetsZero animated:YES];
        
    }
    else{
        contextbtn.selected = NO;
        [self.contextMenuTableView dismisWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        //        contextview.hidden = YES;
    }

}

-(IBAction)report:(id)sender{
  
    if([sender tag] >= 0){
        
        selectedindex = [sender tag];
        [reporttable reloadData];
    }
    
    else if([sender tag] == -1){
        
        if([[productdetail objectForKey:@"user_id"] integerValue]  == [appdelegate.userid integerValue]){
           
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this item?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
            [alert show];
        }
        else{
            isreportview = YES;
            [appdelegate.window addSubview:reportview];
        }
    }
    else{
        [reportdescription resignFirstResponder];
        reportscroll.contentOffset = CGPointMake(0, 0);
        NSString *desc = @"";
        if([reportdescription.text isEqualToString:@"Enter Other comments here"]){
            
        }
        else
            desc = reportdescription.text;
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"trendy_report\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"product_id\": \"%@\",\"content\": \"%@\",\"report_description\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,productid,[reportarray objectAtIndex:selectedindex],desc];
        NSLog(@"%@",postdata);
        [obj serverrequest:postdata];
        [self startLoader:@"Loading..."];
        requesttype = @"trendy_report";
        [reportview removeFromSuperview];
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 2){
        
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
    else{
        
        if(buttonIndex == 0)
            [self deletepost];
    }
}

-(void)deletepost{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"post_delete\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\",\"post_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid,productid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"deletepost";
}

-(IBAction)reviewlist:(id)sender{
    
    if(scroll.scrollEnabled == NO){
        
        scroll.scrollEnabled = YES;
        textView.text=@"";
        [textView resignFirstResponder];
    }
    if([sender tag] == 1){
       
        if(descriptionview.frame.size.height<=34){
            
          /*  CGRect frame = descriptiondetailview.frame;
            CGFloat height = frame.size.height;
            frame.size.height = 0;
            descriptiondetailview.frame = frame;
            descriptiondetailview.hidden = NO;
            [UIView commitAnimations];
            [UIView animateWithDuration:0.5f
                                  delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 CGRect frame = descriptiondetailview.frame;
                                 frame.size.height = height;
                                 descriptiondetailview.frame = frame;
                                 detaildescription.text = description.text;
                             }
                             completion:^(BOOL completed) {
                                 if (completed) {
                                     
                                     detaildescription.text = description.text;
                                 }
                             }];*/
            
            CGFloat fixedWidth = description.frame.size.width;
            CGSize newSize = [description sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
            CGRect newFrame = description.frame;
            newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height+20);
            description.frame = newFrame;
        }
        else{
            
           /* CGRect frame = descriptiondetailview.frame;
            CGFloat height = frame.size.height;
            [UIView commitAnimations];
            [UIView animateWithDuration:0.5f
                                  delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 
                                 CGRect frame = descriptiondetailview.frame;
                                 frame.size.height = 0;
                                 descriptiondetailview.frame = frame;
                                 detaildescription.text = @"";
                             }
                             completion:^(BOOL completed) {
                                 if (completed) {
                                     
                                     CGRect frame = descriptiondetailview.frame;
                                     frame.size.height = height;
                                     descriptiondetailview.frame = frame;
                                     descriptiondetailview.hidden = YES;
                                 }
                             }];*/
            
            CGFloat fixedWidth = description.frame.size.width;
            CGSize newSize = [description sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
            CGRect newFrame = description.frame;
            newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), 34);
            description.frame = newFrame;
            
        }
        
        CGRect newFrame = descriptionview.frame;
        newFrame.size = CGSizeMake(descriptionview.frame.size.width, description.frame.size.height);
        descriptionview.frame = newFrame;
        
        [self setframes];

    }
    else{
        ReviewList *obj = [[ReviewList alloc] init];
        obj.productid = productid;
        obj.deletedelegate = self;
        if(otherlocation == YES)
            obj.viewonly = YES;
        else
            obj.viewonly = NO;
        [self.navigationController pushViewController:obj animated:YES];
    }

}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (([touch.view isDescendantOfView:imagecollections] || [touch.view isDescendantOfView:suggestedtable] || [touch.view isDescendantOfView:contextview] || [touch.view isDescendantOfView:reviewtable]) && scroll.scrollEnabled == YES) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

-(IBAction)hidekeyboards:(id)sender{
    
    if(scroll.scrollEnabled == NO){
        scroll.scrollEnabled = YES;
        scroll.contentOffset = CGPointMake(0, 0);
        textView.text=@"";
        [textView resignFirstResponder];
    }
    [pickersubview removeFromSuperview];
    if(isreportview == YES){
        [reportview removeFromSuperview];
        isreportview = NO;
    }
}

-(void)refreshpush: (NSNotification *) notification
{
    NSString *pdtid=(NSString *)[notification object];
    if ([productid isEqualToString:pdtid]) {
        
        [self getproductdetail];
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
