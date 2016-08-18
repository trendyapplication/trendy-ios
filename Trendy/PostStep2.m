//
//  PostStep2.m
//  Trendy
//
//  Created by NewAgeSMB on 8/10/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "PostStep2.h"
#import "GalleryCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "RecentOrTrendsFeeds.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MHFacebookImageViewer.h"
#import "DropDown.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface PostStep2 (){
    
    IBOutlet UIScrollView *scroll;
    IBOutlet UICollectionView *itemImageCollectionview;
    IBOutlet UITextField *brandfield,*pricefield,*productnamefield,*producttypefield,*addtooccasionfield, *producturlfield;
    IBOutlet UITextView *description;
    IBOutlet UILabel *malelabel, *femalelabel, *pickertitle, *countlabel;
    IBOutlet UIButton *genderbtn, *camerabtn, *postbtn;
    NSString *requesttype;
    AppDelegate *appdelegate;
    NSString *producttypeid, *occationid, *genderval, *img_url, *dropview, *brandID;
    UIImagePickerController *imagePicker;
    IBOutlet UIImageView *imageView;
    NSData *picData;
    IBOutlet UIView *imagesubview, *pickersubview;
    IBOutlet UIImageView *itemimage;
    IBOutlet UIPickerView *droppicker;
    NSArray *occationarray, *typearray, *brandarray, *maletypearray, *femaletypearray;
    UITextField *lasttext;
    BOOL subids;
    NSDictionary *typedict;
    IBOutlet UIActivityIndicatorView *loader;
    NSMutableIndexSet *selectedarray;
    NSMutableArray *itemimagesarray, *imagedataarray;
    BOOL customimages;
    NSMutableArray *indeximagearray;
    NSString *descriptionString;
}
@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;
@end

@implementation PostStep2
@synthesize productdetail,producturl,genderUser;
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetworkFound:) name:@"NONETWORKFOUND"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLoader:) name:@"STOPLOADER"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedvalue:) name:@"DROPTABLEVALUE"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    loader.hidden = YES;
    [loader stopAnimating];
    occationarray = [[NSArray alloc] init];
    itemimagesarray = [[NSMutableArray alloc] init];
    brandarray = [[NSArray alloc] init];
    selectedarray = [[NSMutableIndexSet alloc] init];
    indeximagearray = [[NSMutableArray alloc] init];
    imagedataarray = [[NSMutableArray alloc] init];
    scroll.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, postbtn.frame.origin.y + postbtn.frame.size.height + 50);
    genderval = @"";
    brandID = @"";
    UINib *cellNib = [UINib nibWithNibName:@"GalleryCell" bundle:nil];
    [itemImageCollectionview registerNib:cellNib forCellWithReuseIdentifier:@"GalleryCell"];
    [self getoccations];
    producttypeid = @"";
    pickersubview.hidden = YES;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidekeyboards:)];
    [scroll addGestureRecognizer:gestureRecognizer];
    //description.text = @"Description";
    descriptionString= @"";
    //description.textColor = [UIColor lightGrayColor];
    producturlfield.enabled = YES;
    if (genderUser.length>2) {
        producttypeid = @"";
        if([genderUser isEqualToString:@"male"]){
            
            genderbtn.selected = YES;
            malelabel.textColor =  [UIColor blackColor];
            femalelabel.textColor = [UIColor blackColor];
            genderval = @"male";
        }
        else {
            
            genderbtn.selected = NO;
            femalelabel.textColor =  [UIColor blackColor];
            malelabel.textColor = [UIColor blackColor];
            genderval = @"female";
        }
        producttypefield.text = @"";

       
    }
    if(producturl.length>2){
        producturlfield.enabled = NO;
        producturlfield.text = producturl;
    }
    if(productdetail){
        
        producturlfield.enabled = NO;
        producturlfield.text = producturl;
        if([productdetail objectForKey:@"brand_name"] != [NSNull null] && ![[productdetail objectForKey:@"brand_name"] isEqualToString:@""] && ![[productdetail objectForKey:@"brand_name"] isEqualToString:@" "])
            brandfield.text = [productdetail objectForKey:@"brand_name"];
        if([productdetail objectForKey:@"description"] != [NSNull null] && ![[productdetail objectForKey:@"description"] isEqualToString:@""]){
            
           // description.text = [[productdetail objectForKey:@"description"]stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            descriptionString= [[productdetail objectForKey:@"description"]stringByReplacingOccurrencesOfString:@"\t" withString:@""];
           // description.textColor = [UIColor blackColor];
        }
        else{
           // description.text = @"Description";
            //description.textColor = [UIColor lightGrayColor];
            descriptionString=@"";
        }
        if([productdetail objectForKey:@"price"] != [NSNull null]){
            if([[productdetail objectForKey:@"price"] length] < 2 && [[productdetail objectForKey:@"price"] boolValue] == 0)
                pricefield.text = @"";
            else if([[productdetail objectForKey:@"price"] boolValue] == 1)
                pricefield.text = @"";
            else
                pricefield.text = [NSString stringWithFormat:@"$%@",[[productdetail objectForKey:@"price"] stringByReplacingOccurrencesOfString:@"$" withString:@""]];
        }
        itemimagesarray = [[productdetail objectForKey:@"image_array"] mutableCopy];
        [itemImageCollectionview reloadData];
        if(customimages == NO)
            countlabel.text = [NSString stringWithFormat:@"%d/%lu", 1,(unsigned long)itemimagesarray.count];
        else
            countlabel.text = [NSString stringWithFormat:@"%d/%lu", 1,(unsigned long)imagedataarray.count];
        loader.hidden = YES;
        [loader stopAnimating];
        if(itemimagesarray.count==0){
            imagesubview.hidden = NO;
            camerabtn.hidden = NO;
//            if([productdetail objectForKey:@"image"] != [NSNull null]){
//                //            [itemimage sd_setImageWithURL:[NSURL URLWithString:[productdetail objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@""]];
//                
//                loader.hidden = NO;
//                [loader startAnimating];
//                [itemimage sd_setImageWithURL:[NSURL URLWithString:[productdetail objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"no_img.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
//                    
//                    if(error){
//                        itemimage.image = nil;
//                        camerabtn.hidden = NO;
//                    }
//                    else{
//                        itemimage.image = image;
//                        img_url = [productdetail objectForKey:@"image"];
//                        camerabtn.hidden = YES;
//                    }
//                    loader.hidden = YES;
//                    [loader stopAnimating];
//                }];
//            }
        }
        else{
            imagesubview.hidden = YES;
            camerabtn.hidden = YES;
        }
    }
    else{
//        if(!producturl)
//            producturl = @"";
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
     [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    [appdelegate.locationManager startUpdatingLocation];

}

-(void) viewDidAppear:(BOOL)animated{
    
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getoccations{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_occasion\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getoccations";
}


-(void)getGender{
    
    ServerRequest *obj = [[ServerRequest alloc] init];
    obj.delegate = self;
    NSString *postdata = [[NSString alloc] initWithFormat:@"{\"function\":\"get_gender\",\"parameters\": {\"v\": \"%@\",\"apv\": \"%@\",\"authKey\": \"%@\",\"sessionKey\": \"%@\",\"user_id\": \"%@\"},\"token\":\"\"}",appdelegate.apiversion,appdelegate.appversion,appdelegate.authkey,appdelegate.sessionid,appdelegate.userid];
    NSLog(@"%@",postdata);
    [obj serverrequest:postdata];
    [self startLoader:@"Loading..."];
    requesttype = @"getGender";
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)genderbtn:(id)sender{
    
    producttypeid = @"";
    if(genderbtn.selected == NO){
        
        genderbtn.selected = YES;
        malelabel.textColor = [UIColor blackColor];
        femalelabel.textColor =[UIColor blackColor];
        genderval = @"male";
    }
    else {
        
        genderbtn.selected = NO;
        femalelabel.textColor =  [UIColor blackColor];
        malelabel.textColor =[UIColor blackColor];
        genderval = @"female";
    }
    producttypefield.text = @"";
}

-(IBAction)dropdownviews:(id)sender{
    
    appdelegate.stop = NO;
    scroll.scrollEnabled = YES;
    [lasttext resignFirstResponder];
    [description resignFirstResponder];
    if([sender tag] == 0){
//        if(pickersubview.hidden == YES){
//            pickersubview.hidden = NO;
//            [scroll setContentOffset:CGPointMake(0, ((UIButton *)sender).frame.origin.y - 211)];
//        }
//        else{
//            pickersubview.hidden = YES;
//            [scroll setContentOffset:CGPointMake(0, 0)];
//        }
//        pickertitle.text = @"Choose product type";
//        dropview = @"product_type";
//        [droppicker reloadAllComponents];
//        CGRect frame = pickersubview.frame;
//        frame.origin.y = [[UIScreen mainScreen] bounds].size.height - 249;
//        pickersubview.frame = frame;
        dropview = @"product_type";
        DropDown *obj = [[DropDown alloc] init];
        obj.type = @"product_type";
        if([dropview isEqualToString:@"occation"])
            obj.droparray = [occationarray mutableCopy];
        else{
            if([genderval isEqualToString:@"male"])
                obj.droparray = [maletypearray mutableCopy];
            else
                obj.droparray = [femaletypearray mutableCopy];
        }
        [self.navigationController pushViewController:obj animated:YES];

    }
    else if([sender tag] == 2){
       
        dropview = @"brand";
        DropDown *obj = [[DropDown alloc] init];
        obj.type = @"brand";
        obj.droparray = [brandarray mutableCopy];        
        [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        //        if(droppicker.hidden == YES)
        dropview = @"occation";
        DropDown *obj = [[DropDown alloc] init];
        obj.type = @"occation";
        if([dropview isEqualToString:@"occation"])
            obj.droparray = [occationarray mutableCopy];
        else{
            if([genderval isEqualToString:@"male"])
                obj.droparray = [maletypearray mutableCopy];
            else
                obj.droparray = [femaletypearray mutableCopy];
        }
        [self.navigationController pushViewController:obj animated:YES];
//        [addtooccasionfield becomeFirstResponder];
        //        dropview = @"occation";
    }
    
    
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(customimages == YES)
        return imagedataarray.count;
    return itemimagesarray.count;
//    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 320);
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    cell.count.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    cell.activityloader.hidden = YES;
    [cell.activityloader stopAnimating];
    cell.checkbtn.hidden = YES;
    if(customimages == NO){
        
        if([itemimagesarray objectAtIndex:indexPath.row]){
            //            [itemimage sd_setImageWithURL:[NSURL URLWithString:[productdetail objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@""]];
            
            cell.checkbtn.hidden = NO;
            cell.deletebtn.hidden = YES;
            if([selectedarray containsIndex:indexPath.row])
                cell.checkbtn.selected = YES;
            else
                cell.checkbtn.selected = NO;
            
            if(itemimagesarray.count == 1)
                cell.checkbtn.hidden = YES;
            else
                cell.checkbtn.hidden = NO;
            
            cell.checkbtn.tag = indexPath.row;
            [cell.checkbtn addTarget:self action:@selector(selectordeselect:) forControlEvents:UIControlEventTouchUpInside];
            
//            cell.checkbtn.hidden = YES;
//            if(itemimagesarray.count > 1)
//                cell.deletebtn.hidden = NO;
//            else
//                cell.deletebtn.hidden = YES;
//            cell.deletebtn.tag = indexPath.row;
//            [cell.deletebtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.activityloader.hidden = NO;
            [cell.activityloader startAnimating];
//            [cell.itemImage setupImageViewerWithImageURL:[NSURL URLWithString:[itemimagesarray objectAtIndex:indexPath.row]]];
            [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:[itemimagesarray objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"no_img.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cachetype, NSURL *imageurl){
                
                if(error){
                    cell.itemImage.image = nil;
                }
                else{
                    cell.itemImage.image = image;
                }
                cell.activityloader.hidden = YES;
                [cell.activityloader stopAnimating];
            }];
            cell.swipefullbtn.frame = cell.itemImage.frame;
            cell.swipefullbtn.tag = indexPath.row;
            [cell.swipefullbtn addTarget:self action:@selector(zooming:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            cell.itemImage.image = nil;
        }
    }
    else{
        
        cell.checkbtn.hidden = YES;
        cell.deletebtn.hidden = NO;
        [cell.itemImage setImage:[UIImage imageWithData:[imagedataarray objectAtIndex:indexPath.row]]];
        cell.activityloader.hidden = YES;
        [cell.activityloader stopAnimating];
        cell.deletebtn.tag = indexPath.row;
        [cell.deletebtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

#pragma mark - FGalleryViewControllerDelegate Methods


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    return (int)itemimagesarray.count;
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
    
    NSString *urlpath = [NSString stringWithFormat:@"%@",[itemimagesarray objectAtIndex:index]];
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
    
    if(scrollView.tag != 5){
        CGFloat pageWidth = itemImageCollectionview.frame.size.width;
        float currentPage = itemImageCollectionview.contentOffset.x / pageWidth;
        
        if (0.0f != fmodf(currentPage, 1.0f))
        {
            currentPage = currentPage + 1;
        }
        else
        {
            currentPage = currentPage;
        }
        
        if(customimages == NO)
            countlabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)currentPage + 1,(unsigned long)itemimagesarray.count];
        else
            countlabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)currentPage + 1,(unsigned long)imagedataarray.count];
    }
}

-(IBAction)selectordeselect:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    if(btn.selected == NO){
        btn.selected = YES;
        [selectedarray addIndex:[sender tag]];
        [indeximagearray addObject:[NSString stringWithFormat:@"%ld", (long)[sender tag]]];
    }
    else{
        btn.selected = NO;
        [selectedarray removeIndex:[sender tag]];
        [indeximagearray removeObject:[NSString stringWithFormat:@"%ld", (long)[sender tag]]];
    }
}

-(IBAction)deleteImage:(id)sender{
    
    if(customimages == NO)
        [itemimagesarray removeObjectAtIndex:[sender tag]];
    else
        [imagedataarray removeObjectAtIndex:[sender tag]];
    [itemImageCollectionview reloadData];
//    if(imagedataarray.count>0)
//        [itemImageCollectionview scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    NSUInteger count;
    if(customimages == NO)
        count = itemimagesarray.count;
    else
        count = imagedataarray.count;

    if([sender tag]>=count)
        countlabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)[sender tag],(unsigned long)count];
    else
        countlabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)[sender tag]+1,(unsigned long)count];
    if(count == 0){
        imagesubview.hidden = NO;
        countlabel.text = @"";
    }
}


// UIPickerView...
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if([dropview isEqualToString:@"occation"])
         return [occationarray count];
    else
        return typearray.count;
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if([dropview isEqualToString:@"occation"])
        return [[occationarray objectAtIndex:row] objectForKey:@"name"];
    else
        return [[typearray objectAtIndex:row] objectForKey:@"name"];
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if([dropview isEqualToString:@"occation"]){
       
        occationid = [[occationarray objectAtIndex:row] objectForKey:@"occasion_id"];
        addtooccasionfield.text = [[occationarray objectAtIndex:row] objectForKey:@"name"];
        [addtooccasionfield resignFirstResponder];
        pickersubview.hidden = YES;
        [scroll setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else{
        producttypeid = [[typearray objectAtIndex:row] objectForKey:@"category_id"];
        producttypefield.text = [[typearray objectAtIndex:row] objectForKey:@"name"];
        NSArray *array = [[typearray objectAtIndex:row] objectForKey:@"submenu"];
        if([array count] > 0){
            
            pickertitle.text = [[typearray objectAtIndex:row] objectForKey:@"description"];
            typearray = [array mutableCopy];
            dropview = @"product_type";
            [droppicker reloadAllComponents];
        }
        else{
            pickersubview.hidden = YES;
        }
        
    }
    scroll.scrollEnabled = YES;
}

-(void)selectedvalue: (NSNotification *) notification
{
    NSDictionary *selecteddict = (NSDictionary *)[notification userInfo];
    if (selecteddict) {
        
        if([dropview isEqualToString:@"occation"]){
            
            occationid = [selecteddict objectForKey:@"occasion_id"];
            addtooccasionfield.text = [selecteddict objectForKey:@"name"];
            [addtooccasionfield resignFirstResponder];
//            pickersubview.hidden = YES;
            [scroll setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        else if([dropview isEqualToString:@"brand"]){
            
            brandID = [selecteddict objectForKey:@"id"];
            brandfield.text = [selecteddict objectForKey:@"brand"];
            //            pickersubview.hidden = YES;
            [scroll setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        else{
            producttypeid = [selecteddict objectForKey:@"category_id"];
            producttypefield.text = [selecteddict objectForKey:@"name"];
        }
        scroll.scrollEnabled = YES;
    }
    
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // adding donebn to top bar
    scroll.scrollEnabled = NO;
    CGRect keyboardBounds;
    [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    //    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //    NSNumber *curve = [aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    //
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // NSDictionary* info = [aNotification userInfo];
    
    [UIView animateWithDuration:0.2f animations:^{
        
        //        if(self.view.frame.size.height == 480)
        //            scroll.contentOffset =  CGPointMake(0, scroll.frame.size.height - keyboardBounds.size.height + 65);
        //        else
        if(lasttext){
            if((scroll.frame.size.height - keyboardBounds.size.height) <= (lasttext.frame.origin.y + lasttext.frame.size.height))
                scroll.contentOffset =  CGPointMake(0, (lasttext.frame.origin.y + lasttext.frame.size.height) - (scroll.frame.size.height - keyboardBounds.size.height)-48);
        }
        else
            scroll.contentOffset =  CGPointMake(0, (description.frame.origin.y + description.frame.size.height) - (scroll.frame.size.height - keyboardBounds.size.height)-39);
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    scroll.scrollEnabled = YES;
   // scroll.contentOffset =  CGPointMake(0, 0);
}

#pragma mark Textfield Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    appdelegate.stop = YES;
//    MHFacebookImageViewer * imageBrowser = [[MHFacebookImageViewer alloc]init];
    lasttext = textField;
    if(textField == addtooccasionfield){
        
        addtooccasionfield.text = NULL;
        occationid = @"";
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = 1;
        pickersubview.hidden = NO;
        pickertitle.text = @"Choose occasion";
        [scroll setContentOffset:CGPointMake(0, 0)];
        dropview = @"occation";
        [droppicker reloadAllComponents];
        CGRect frame = pickersubview.frame;
        frame.origin.y = 150;
        pickersubview.frame = frame;
        scroll.contentOffset = CGPointMake(0, textField.frame.origin.y - 40);
        scroll.scrollEnabled = NO;
    }
    else if(textField == pricefield){

        if(pricefield.text.length>0){
            
            pricefield.text = [pricefield.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
//            pricefield.text = [pricefield.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c",[pricefield.text characterAtIndex:0]] withString:[NSString stringWithFormat:@"$%c",[pricefield.text characterAtIndex:0]]];
            pricefield.text = [NSString stringWithFormat:@"$%@",pricefield.text];
        }
        else
            pricefield.text = @"$";
        //scroll.contentOffset = CGPointMake(0, textField.frame.origin.y - 40);
    }
    else{
        //scroll.contentOffset = CGPointMake(0, textField.frame.origin.y - 40);
        pickersubview.hidden = YES;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField == pricefield){
        
        if(pricefield.text.length>0){
            
            pricefield.text = [pricefield.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
            if(pricefield.text.length>0)
                pricefield.text = [NSString stringWithFormat:@"$%@",pricefield.text];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1{
    
   // [self keyboardWasShown:nil];
  //  scroll.contentOffset =  CGPointMake(0, (description.frame.origin.y + description.frame.size.height) - (scroll.frame.size.height - keyboardBounds.size.height)-39);
    lasttext = nil;
    appdelegate.stop = YES;
    if([textView1.text isEqualToString:@"Description"]){
        textView1.text = NULL;
        textView1.textColor = [UIColor blackColor];
    }
    else{
//        textView1.textColor = [UIColor lightGrayColor];
    }
     scroll.contentOffset = CGPointMake(0, textView1.frame.origin.y - 40);
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView1{
    
    if([self validateEmail:textView1.text type:@"space"]  == YES){
        textView1.text = @"Description";
        
        textView1.textColor = [UIColor lightGrayColor];
    }
    else{
        textView1.textColor = [UIColor blackColor];
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

-(IBAction)photo:(id)sender{
    
    [self selectPhoto];
//    UIActionSheet *sheet = [[UIActionSheet alloc]
//                            initWithTitle:@"Choose an option"
//                            delegate:self
//                            cancelButtonTitle:@"Cancel"
//                            destructiveButtonTitle:nil
//                            otherButtonTitles:@"Take Photo",@"Choose From Library", nil];
//    [sheet showInView:self.view];
//    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self takePhoto];
    }
    if(buttonIndex == 1)
    {
        [self selectPhoto];
    }
}

-(void)takePhoto   // invoke camera in iPhone
{
    imagePicker=[[UIImagePickerController alloc]init];
    imagePicker.delegate=self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [self presentViewController:imagePicker animated:YES completion:NULL];
        //[self presentModalViewController:imagePicker animated:YES];
    }
    
    else
    {
        
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"Sorry your device wont support" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    
    
}

-(void)selectPhoto  // to select photo from photo library
{
    
//    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
//    
//    elcPicker.maximumImagesCount = 100; //Set the maximum number of images to select to 100
//    elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
//    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
//    elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
//    elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
//    
//    elcPicker.imagePickerDelegate = self;
//    
//    [self presentViewController:elcPicker animated:YES completion:nil];
    
    imagePicker=[[UIImagePickerController alloc]init];
    imagePicker.delegate=self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum ;
    
    imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [self presentViewController:imagePicker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
//    viewdidappeared = NO;
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
//    viewdidappeared = NO;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
 
    customimages = YES;
    UIImage *img=[info objectForKey:UIImagePickerControllerEditedImage];
    
    picData = UIImageJPEGRepresentation(img, 1.0);
    [imagedataarray addObject:picData];
    [picker dismissViewControllerAnimated:YES completion:NULL];

    //    image.image =[UIImage imageWithData:self.picData];
//    viewdidappeared = NO;
//    NSLog(@"-width-%f-height-%f",[self scaleAndRotateImage:img].size.width,[self scaleAndRotateImage:img].size.height);
//    itemimage.image =[UIImage imageWithData:picData];
//    camerabtn.hidden = YES;
    
    imagesubview.hidden = YES;
    [itemImageCollectionview reloadData];
    if(imagedataarray.count>0)
        [itemImageCollectionview scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:imagedataarray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    countlabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)imagedataarray.count,(unsigned long)imagedataarray.count];
    
//    [self uploadphoto];
    //    viewdidappeared = NO;
    //    actualimage = [info valueForKey:UIImagePickerControllerOriginalImage];
    //    imageView.image = actualimage;
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    //        if (self.popover.isPopoverVisible) {
    //            [self.popover dismissPopoverAnimated:NO];
    //        }
    //
    //        //        [self updateEditButtonEnabled];
    //
    //       // [self openEditor:nil];
    //    } else {
    //        [picker dismissViewControllerAnimated:YES completion:^{
    //          //  [self openEditor:nil];
    //        }];
    //    }
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    customimages = YES;
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                
//                picData = UIImageJPEGRepresentation([self scaleAndRotateImage:image], 1.0);
                picData = UIImageJPEGRepresentation(image, 1.0);
                [images addObject:picData];
//                [images addObject:image];
                
                
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                picData = UIImageJPEGRepresentation([self scaleAndRotateImage:image], 1.0);
                [images addObject:picData];

//                [images addObject:image];
                
                
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    imagesubview.hidden = YES;
    imagedataarray = images;
    [itemImageCollectionview reloadData];
    if(customimages == NO)
        countlabel.text = [NSString stringWithFormat:@"%d/%lu", 1,(unsigned long)itemimagesarray.count];
    else
        countlabel.text = [NSString stringWithFormat:@"%d/%lu",1,(unsigned long)imagedataarray.count];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)scaleAndRotateImage:(UIImage *)image1 {
    int kMaxResolution = 640; // Or whatever
    
    CGImageRef imgRef = image1.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image1.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

-(IBAction)uploadpost:(id)sender{
    
    if(brandfield.text.length == 0){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter brand name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [brandfield becomeFirstResponder];
        return;
    }
    if(pricefield.text.length == 0 || [pricefield.text isEqualToString:@"$"] || [pricefield.text isEqualToString:@" "]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter price" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [pricefield becomeFirstResponder];
        return;
    }
//    if(productnamefield.text.length == 0){
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter product name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        [productnamefield becomeFirstResponder];
//        return;
//    }
    if([producttypeid isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Select product type" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
//        [productnamefield becomeFirstResponder];
        return;
    }
    NSString *url;
    url = [NSString stringWithFormat:@"%@/treand_new_post",appdelegate.Clienturl];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
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
    
    NSString *userid = @"";
    if(appdelegate.userid){
        userid = appdelegate.userid;
        
    }
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n%@", userid] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
   
    
    if(!producturl || [producturl isEqualToString:@""]){
       
        producturl = producturlfield.text;
        NSString *myURLString = producturlfield.text;
        if ([myURLString.lowercaseString hasPrefix:@"http://www."]) {
            //  myURL = [NSURL URLWithString:myURLString];
        }
        else if ([myURLString.lowercaseString hasPrefix:@"www."]) {
            producturl = [NSString stringWithFormat:@"http://%@",myURLString];
        }
        else if ([myURLString.lowercaseString hasPrefix:@"http://"]) {
            //  myURL = [NSURL URLWithString:myURLString];
        }
        
        NSURL *candidateURL = [NSURL URLWithString:producturl];
        // WARNING > "test" is an URL according to RFCs, being just a path
        // so you still should check scheme and all other NSURL attributes you need
        if (candidateURL && candidateURL.scheme && candidateURL.host) {
            // candidate is a well-formed url with:
            //  - a scheme (like http://)
            //  - a host (like stackoverflow.com)
            
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter a valid product url" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [producturlfield becomeFirstResponder];
            producturl = nil;
            return;
        }
    }
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"product_url\"\r\n\r\n%@", producturl] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"gender\"\r\n\r\n%@", genderval] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *price = [pricefield.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    price = [NSString stringWithFormat:@"%@",price];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"price\"\r\n\r\n%@", price] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *namestr = @"";
//    if(productnamefield.text.length>0)
//        namestr = productnamefield.text;
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"product_name\"\r\n\r\n%@", namestr] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"product_type\"\r\n\r\n%@", producttypeid] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *descrptn = @"";
    if(![descriptionString isEqualToString:@""] && ![descriptionString isEqualToString:@"Description"])
        descrptn = descriptionString;
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"\r\n\r\n%@", descrptn] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    if ( appdelegate.locationManager.location.coordinate.latitude != 0 && appdelegate.locationManager.location.coordinate.longitude != 0 )
    {
    
        NSLog(@"Coordinate valid");
        
        NSLog(@"lat -- %f",appdelegate.locationManager.location.coordinate.latitude);
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lat\"\r\n\r\n%f", appdelegate.locationManager.location.coordinate.latitude] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"lat -- %f",appdelegate.locationManager.location.coordinate.longitude);
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"long\"\r\n\r\n%f", appdelegate.locationManager.location.coordinate.longitude] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *flag = @"N";
        if(picData){
            flag = @"Y";
            img_url = [NSString stringWithFormat:@""];
        }
        else{
            if(selectedarray.count == 0){
                for (UICollectionViewCell *cell in [itemImageCollectionview visibleCells]) {
                    NSIndexPath *indexPath = [itemImageCollectionview indexPathForCell:cell];
                    NSLog(@"%@",indexPath);
                    img_url = [itemimagesarray objectAtIndex:indexPath.row];
                }
            }
            else{
              //  NSArray *typearray1 = [itemimagesarray objectsAtIndexes:selectedarray];
                img_url = [itemimagesarray objectAtIndex:[[indeximagearray objectAtIndex:0] integerValue]];
                for(int i = 1; i<indeximagearray.count; i++){
                    
                    img_url = [NSString stringWithFormat:@"%@&&&###%@",img_url,[itemimagesarray objectAtIndex:[[indeximagearray objectAtIndex:i] integerValue]]];
                }
            }
        }
        if(picData || img_url){
            
        }
        else{
            
            //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Upload a photo" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //        [alert show];
            [self photo:nil];
            return;
        }
        NSString *custom = @"N";
        if([occationid isEqualToString:@""]){
            occationid = addtooccasionfield.text;
            custom = @"Y";
        }
        
        NSString *brand_custom = @"N";
        if([brandID isEqualToString:@""]){
            brandID = brandfield.text;
            brand_custom = @"Y";
        }
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"brand\"\r\n\r\n%@", brandID] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"brand_custom\"\r\n\r\n%@", brand_custom] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"occasion_id\"\r\n\r\n%@", occationid] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"custom\"\r\n\r\n%@", custom] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"flag\"\r\n\r\n%@", flag] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"img_url\"\r\n\r\n%@", img_url] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if(picData){
            
//            [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", @"pic1.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
//            [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//            [postbody appendData:[NSData dataWithData:picData]];
            
            [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"count\"\r\n\r\n%lu", (unsigned long)imagedataarray.count] dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSMutableDictionary *aImageDic = [[NSMutableDictionary alloc] init];
            for(int i=1;i<=imagedataarray.count;i++){
               
                NSString *filename = [NSString stringWithFormat:@"file%d",i];
                [aImageDic setObject:[imagedataarray objectAtIndex:i-1] forKey:filename];
            }
            
            [aImageDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if(obj != nil)
                {
                    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filetype=\"image/png\"; filename=\"pic1.jpg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                    [postbody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    [postbody appendData:[NSData dataWithData:obj]];
                }
            }];
                
        }
        else{

            [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", @""] dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[NSData dataWithData:nil]];
        }
        
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        ServerRequest *obj = [[ServerRequest alloc] init];
        obj.delegate = self;
        [obj postrequest:postbody urlstr:url];
        [self startLoader:@"Saving..."];
        requesttype = @"post";
    }
    else{
        NSLog(@"Coordinate invalid");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location service is not available" message:@"To re-enable, please go to Settings and turn on Location Service for this app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)serverresponse:(NSMutableData *)response{
    
    [self stoploader];
    NSError *jsonParsingError = nil;
    NSDictionary *tempdict = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    NSLog(@"tempdict == %@",tempdict);
    
    if(tempdict){
        if([requesttype isEqualToString:@"post"]){
            if([[tempdict objectForKey:@"status"] isEqualToString:@"true"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH" object:nil];
                for (id controller in [self.navigationController viewControllers])
                {
                    if ([controller isKindOfClass:[RecentOrTrendsFeeds class]])
                    {
                        [self.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[tempdict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }
        }
        else if([requesttype isEqualToString:@"getoccations"]){
            
            occationarray = [[tempdict objectForKey:@"occasion_list"] mutableCopy];
            dropview = @"occation";
            typearray = [[tempdict objectForKey:@"product_list"]  mutableCopy];
            maletypearray = [[tempdict objectForKey:@"male_cat"] mutableCopy];
            femaletypearray = [[tempdict objectForKey:@"female_cat"] mutableCopy];
            brandarray = [[tempdict objectForKey:@"brand_list"] mutableCopy];
//            [droppicker reloadAllComponents];
            if (genderval.length<2) {
                [self getGender];
            }
        }
         else if([requesttype isEqualToString:@"getGender"]){
             genderUser = [[tempdict objectForKey:@"gender"] mutableCopy];
             producttypeid = @"";
             if([genderUser isEqualToString:@"male"]){
                 
                 genderbtn.selected = YES;
                 malelabel.textColor =  [UIColor blackColor];
                 femalelabel.textColor = [UIColor blackColor];
                 genderval = @"male";
             }
             else {
                 
                 genderbtn.selected = NO;
                 femalelabel.textColor =  [UIColor blackColor];
                 malelabel.textColor = [UIColor blackColor];
                 genderval = @"female";
             }
             producttypefield.text = @"";
             
         }
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Database error. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
    appdelegate.stop = NO;
    scroll.scrollEnabled = YES;
    [lasttext endEditing:YES];
    [description resignFirstResponder];
   // scroll.contentOffset = CGPointMake(0, 0);
    scroll.scrollEnabled = YES;
}

-(IBAction)hidekeyboards:(id)sender{
  
    scroll.scrollEnabled = YES;
    appdelegate.stop = NO;
    itemImageCollectionview.exclusiveTouch = YES;
   // scroll.contentOffset = CGPointMake(0, 0);
    [lasttext resignFirstResponder];
    [description resignFirstResponder];
    pickersubview.hidden = YES;
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
