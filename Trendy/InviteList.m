//
//  InviteList.m
//  Trendy
//
//  Created by NewAgeSMB on 9/22/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "InviteList.h"
#import "AppDelegate.h"
@interface InviteList (){
    
    NSMutableArray *propertyList;
    NSMutableArray *emailArray;
    IBOutlet UITableView *contacttable;
    NSMutableArray *contactsArray;
    NSArray *selectedemails;
    NSArray *selectedsms;
    AppDelegate *appdelegate;
}

@end

@implementation InviteList
@synthesize type;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([type isEqualToString:@"email"])
        [self inviteFriend:NULL];
    else
        [self message];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    
    appdelegate.currentviewcontroller = self.navigationController.visibleViewController;
}


//-(void)getall{
//   
//    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
//    CNContactStore *addressbook = [[CNContactStore alloc] init];
//    __block BOOL accessGranted = NO;
//   
//    if ([addressbook requestAccessForEntityTyp] != NULL)
//    {
//        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
//        {
//            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//            ABAddressBookRequestAccessWithCompletion(addressbook, ^(bool granted, CFErrorRef error)
//                                                     {
//                                                         accessGranted = granted;
//                                                         dispatch_semaphore_signal(sema);
//                                                     });
//            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//            //            dispatch_release(sema);
//        }
//        else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
//        {
//            
//        }
//        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusDenied)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Access to your contact list is denied." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//            accessGranted = NO;
//        }
//        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusRestricted){
//            accessGranted = NO;
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Access to your contact list is Restricted." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//            
//        }
//        else
//        {
//            
//        }
//        
//    }
//}

#pragma mark -  InviteFriend
- (IBAction)inviteFriend:(id)sender
{
    
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    ABAddressBookRef addressbook = ABAddressBookCreate();
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL)
    {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressbook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         accessGranted = granted;
                                                         dispatch_semaphore_signal(sema);
                                                     });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //            dispatch_release(sema);
        }
        else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        {
            [self pickcontacts];
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusDenied)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Access to your contact list is denied." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            accessGranted = NO;
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusRestricted){
            accessGranted = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Access to your contact list is Restricted." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else
        {
            [self pickcontacts];
        }
        
        
    }
    else
    {
    }
}

-(void)pickcontacts{
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    contactsArray = [[NSMutableArray alloc] init];
    for( CFIndex emailIndex = 0; emailIndex < nPeople; emailIndex++ ) {
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, emailIndex );
        ABMutableMultiValueRef emailRef= ABRecordCopyValue(person, kABPersonEmailProperty);
        int emailCount = ABMultiValueGetCount(emailRef);
        if(!emailCount) {
            CFErrorRef error = nil;
            ABAddressBookRemoveRecord(addressBook, person, &error);
            if (error) NSLog(@"Error: %@", error);
        } else {
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
           // NSString *name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            
            
            NSString *name1 = @"";
            name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *name2 = @"";
            name2 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            NSString *name = @"";
            if(name1.length>1 && name2.length > 1)
                name = [NSString stringWithFormat:@"%@ %@",name1, name2];
            else if(name1.length>1 && name2.length == 0)
                name = [NSString stringWithFormat:@"%@",name1];
            else if(name1.length == 0 && name2.length == 1)
                name = [NSString stringWithFormat:@"%@",name2];

            if (name) {
                NSMutableDictionary *contactDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    name, @"name",
                                                    email, @"email",
                                                    nil];
                [contactsArray addObject:contactDict];
            }
        }
    }
    NSLog(@"contactsArray == %@",contactsArray);
    [contactsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

    contacttable.tag = 1;
    contacttable.hidden = NO;
    [contacttable reloadData];
}


-(void)message{
    
    
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    ABAddressBookRef addressbook = ABAddressBookCreate();
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL)
    {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressbook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         accessGranted = granted;
                                                         dispatch_semaphore_signal(sema);
                                                     });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //            dispatch_release(sema);
        }
        else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        {
            [self messagesent];
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusDenied)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Access to your contact list is denied." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            accessGranted = NO;
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusRestricted){
            accessGranted = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Access to your contact list is Restricted." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else
        {
            [self messagesent];
        }
        
        
    }
}

-(void)messagesent{
    
    NSString* phone = nil;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    contactsArray = [[NSMutableArray alloc] init];
    for( CFIndex emailIndex = 0; emailIndex < nPeople; emailIndex++ ) {
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, emailIndex );
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                         kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            
            for (int i=0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                phone = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
                
                if ([phone isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
                    NSLog(@"iphone:");
                    phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                    //NSString *name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name1 = @"";
                    name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name2 = @"";
                    name2 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    NSString *name = @"";
                    if(name1.length>1 && name2.length > 1)
                        name = [NSString stringWithFormat:@"%@ %@",name1, name2];
                    else if(name1.length>1 && name2.length == 0)
                        name = [NSString stringWithFormat:@"%@",name1];
                    else if(name1.length == 0 && name2.length == 1)
                        name = [NSString stringWithFormat:@"%@",name2];

                    NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:phone,@"mob",name, @"name",nil];
                    [contactsArray addObject:dict12];
                }
                if([phone isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                    
                    phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                  //  NSString *name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    
                    NSString *name1 = @"";
                    name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name2 = @"";
                    name2 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    NSString *name = @"";
                    if(name1.length>1 && name2.length > 1)
                        name = [NSString stringWithFormat:@"%@ %@",name1, name2];
                    else if(name1.length>1 && name2.length == 0)
                        name = [NSString stringWithFormat:@"%@",name1];
                    else if(name1.length == 0 && name2.length == 1)
                        name = [NSString stringWithFormat:@"%@",name2];

                    NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:phone,@"mob",name, @"name",nil];
                    [contactsArray addObject:dict12];
                }
                if([phone isEqualToString:(NSString *)kABHomeLabel]) {
                    
                    phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                   // NSString *name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name1 = @"";
                    name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name2 = @"";
                    name2 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    NSString *name = @"";
                    if(name1.length>1 && name2.length > 1)
                        name = [NSString stringWithFormat:@"%@ %@",name1, name2];
                    else if(name1.length>1 && name2.length == 0)
                        name = [NSString stringWithFormat:@"%@",name1];
                    else if(name1.length == 0 && name2.length == 1)
                        name = [NSString stringWithFormat:@"%@",name2];

                    
                    NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:phone,@"mob",name, @"name",nil];
                    [contactsArray addObject:dict12];
                }
                if([phone isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
                    
                    phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                  //  NSString *name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name1 = @"";
                    name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name2 = @"";
                    name2 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    NSString *name = @"";
                    if(name1.length>1 && name2.length > 1)
                        name = [NSString stringWithFormat:@"%@ %@",name1, name2];
                    else if(name1.length>1 && name2.length == 0)
                        name = [NSString stringWithFormat:@"%@",name1];
                    else if(name1.length == 0 && name2.length == 1)
                        name = [NSString stringWithFormat:@"%@",name2];

                    
                    NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:phone,@"mob",name, @"name",nil];
                    [contactsArray addObject:dict12];
                }
                if([phone isEqualToString:(NSString *)kABWorkLabel]) {
                    
                    phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                  //  NSString *name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name1 = @"";
                    name1 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *name2 = @"";
                    name2 = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    NSString *name = @"";
                    if(name1.length>1 && name2.length > 1)
                        name = [NSString stringWithFormat:@"%@ %@",name1, name2];
                    else if(name1.length>1 && name2.length == 0)
                        name = [NSString stringWithFormat:@"%@",name1];
                    else if(name1.length == 0 && name2.length == 1)
                        name = [NSString stringWithFormat:@"%@",name2];

                    
                    NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:phone,@"mob",name, @"name",nil];
                    [contactsArray addObject:dict12];
                }
                else
                {
                    
                }
                
            }
        }
        else {
            
        }
    }
    [contactsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

    contacttable.tag = 2;
    contacttable.hidden = NO;
    [contacttable reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return contactsArray.count;
    //    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    if(tableView == categorytable){
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PlacesInfoCell"];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"InfoCell"] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(tableView.tag == 1)
        cell.detailTextLabel.text = [[contactsArray objectAtIndex:indexPath.row] objectForKey:@"email"];
    else if(tableView.tag == 2)
        cell.detailTextLabel.text = [[contactsArray objectAtIndex:indexPath.row] objectForKey:@"mob"];
    cell.textLabel.text = [[contactsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    //        cell.textLabel.text = [[categoryarray objectAtIndex:indexPath.row] objectForKey:@"combo_category_name"];
    cell.textLabel.textColor = [UIColor blackColor];
    //    cell.backgroundColor = [UIColor colorWithRed:0.0/255 green:135.0/255 blue:247.0/255 alpha:1];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 1)
        [self email:[[contactsArray objectAtIndex:indexPath.row] objectForKey:@"email"]];
    else
        [self sms:[[contactsArray objectAtIndex:indexPath.row] objectForKey:@"mob"]];
}



- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];// dismissModalViewControllerAnimated:YES];
    //[self.navigationController popViewControllerAnimated: YES];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    emailArray = [[NSMutableArray alloc] init];
    [self displayPerson:person];
    [contacttable reloadData];
    if(emailArray.count>0){
        if(emailArray.count>7)
            contacttable.scrollEnabled = YES;
        else
            contacttable.scrollEnabled = NO;
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This account have no email address and phone numbers." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        contacttable.scrollEnabled = NO;
    }
    NSLog(@"emailArray == %@",emailArray);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

///Users/newagesmb/Desktop/Biju/Jzoog 2/Jzoog.xcodeproj


- (void)displayPerson:(ABRecordRef)person
{
    
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty);
    
    NSString* lname = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonLastNameProperty);
    
    
    //  NSString *email = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonEmailProperty);
    NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
    
    
    ABMultiValueRef emailProp = ABRecordCopyValue(person,kABPersonEmailProperty);
    //    emailArray = ((__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProp));
    NSString *email2 = [((__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProp)) objectAtIndex:0 ];
    NSString* emailtype = nil;
    if (ABMultiValueGetCount(emailProp) > 0) {
        
        for (int i=0; i < ABMultiValueGetCount(emailProp); i++) {
            emailtype = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(emailProp, i);
            if([emailtype isEqualToString:@"iCloud"]){
                NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:(__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailProp, i),@"emailid",@"iCloud",@"type",@"1",@"category",nil];
                [emailArray addObject:dict12];
            }
            else{
                NSArray *aryy = [emailtype componentsSeparatedByString:@"<"];
                NSArray *aryy1 = [[aryy objectAtIndex:1] componentsSeparatedByString:@">"];
                NSString *str = [aryy1 objectAtIndex:0];
                NSLog(@"emailtype : %@",str);
                NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:(__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailProp, i),@"emailid",str,@"type",@"1",@"category",nil];
                [emailArray addObject:dict12];
                if ([emailtype isEqualToString:(NSString*)kABHomeLabel]) {
                    NSLog(@"iphone:");
                    //                    emailtype = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailProp, i);
                    //                noIphoneNumber=NO;
                    //                break;
                }
                else
                {
                    //                emailtype = @"[None]";
                    //                noIphoneNumber=YES;
                }
            }
            
        }
    }
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        
        for (int i=0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            phone = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
            
            if ([phone isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
                NSLog(@"iphone:");
                phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:phone,@"emailid",@"iPhone number",@"type",@"2",@"category",nil];
                [emailArray addObject:dict12];
            }
            else if([phone isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                
                phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                NSDictionary *dict12 = [[NSDictionary alloc] initWithObjectsAndKeys:phone,@"emailid",@"Mobile Number",@"type",@"2",@"category",nil];
                [emailArray addObject:dict12];
            }
            else
            {
                
            }
            
        }
        
        
    }
    else {
        phone = @"[None]";
    }
    
  /*  eMailView.hidden=NO;
    NSString *check;
    check=lname;
    NSString *flName;
    if([lname isKindOfClass:[NSNull class]] || lname ==nil)
    {
        flName=name;
    }
    else
    {
        flName=[NSString stringWithFormat:@"%@ %@",name,lname];
    }
    
    nameLbl2.text = flName;
    mailtolbl.text = email2;
    phoneLbl.text = phone;
    if(imgData)
        image.image =[UIImage imageWithData:imgData];
    else
        image.image = [UIImage imageNamed:@"manimage.png"];
    emailStrng=email2;
    mobile=phone;
    if (image.image==Nil) {
        
        
        image.image =[UIImage imageNamed:@"user.png"];
        
    }
    
    
    if (email2.length <1){
        
        EmailBtn.enabled=NO;
        EmailBtn.hidden = YES;
    }
    else
    {
        EmailBtn.enabled=YES;
        EmailBtn.hidden = NO;
    }
    
    if ([phone isEqualToString:@"[None]"]) {
        phoneLbl.hidden=YES;
        smsBtn.enabled=NO;
        smsBtn.hidden=YES;
    }
    else
    {
        phoneLbl.hidden=NO;
        smsBtn.enabled=YES;
        smsBtn.hidden=NO;
    }*/
    CFRelease(phoneNumbers);
    
}


- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients

{
    //    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    //    [tracker sendEventWithCategory:@"SMS"
    //                        withAction:nil
    //                         withLabel:nil
    //                         withValue:[NSNumber numberWithInt:100]];
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if([MFMessageComposeViewController canSendText])
        
    {
        [controller.navigationBar setTintColor:[UIColor blueColor]];
        [controller.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
        controller.body = bodyOfMessage;
        
        controller.recipients = recipients;
        
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    
}



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result

{
    
    if (result == MessageComposeResultCancelled){
        
        
        [self sent:@"Message cancelled"];
        
        //NSLog(@"Message cancelled");
    }
    
    else if (result == MessageComposeResultSent){
        
        [self sent:@"Message sent"];
        
        
        // NSLog(@"Message sent");
    }
    
    else{
        
        // NSLog(@"Message failed");
        
        [self sent:@"Message Failed"];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)sms:(NSString *)str
{
    NSArray *array = [[NSArray alloc] initWithObjects:str, nil];
    [self sendSMS:@"Check out the TrendyService App...\nhttps://itunes.apple.com/us/app/trendy-style-simplified/id1026863408?ls=1&mt=8" recipientList: [array mutableCopy]];
    
}

- (void)email:(NSString *)str
{
    NSArray *array = [[NSArray alloc] initWithObjects:str, nil];
    if ([MFMailComposeViewController canSendMail])
    {
        
        
        //        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        //        [tracker sendEventWithCategory:@"Email Sent"
        //                            withAction:nil
        //                             withLabel:nil
        //                             withValue:[NSNumber numberWithInt:100]];
        
        
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer.navigationBar setTintColor:[UIColor blueColor]];
        [mailer.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
        
        NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"Avenir-Heavy" size:15], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName,
                                          nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes
                                                    forState:UIControlStateNormal];
        UIImage *navBackgroundImage = [UIImage imageNamed:@"navbg"];
        [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
        
        //        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
        //                                                               [UIColor blueColor], UITextAttributeTextColor,
        //                                                               [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
        //                                                               UITextAttributeTextShadowOffset,
        //                                                               [UIFont fontWithName:@"HelveticaNeue-Medium" size:22.0], UITextAttributeFont, nil]];
        
        
        
        
        
        
        
        
        NSArray *toRecipients = [array mutableCopy];
        [mailer setToRecipients:toRecipients];
        
        
        // NSLog(@"emailStrng %@",emailStrng);
        
        
        
        
        NSString *body;
        
        
        
        body= @"Check out the TrendyService App...\nhttps://itunes.apple.com/us/app/trendy-style-simplified/id1026863408?ls=1&mt=8";
        NSString *emailBody =body;
        [mailer setMessageBody:emailBody isHTML:NO];
        
        
        
        [self presentViewController:mailer animated:YES completion:nil];
        
    }
    else
    {
        [self sent:@"Your device doesn't support the composer sheet"];
        
        
    }
    
}



#pragma mark - MFMailComposeController delegate


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            
            [self sent:@"Email cancelled"];
            
            
            break;
        case MFMailComposeResultSaved:
            
            
            [self sent:@"Email saved"];
            break;
        case MFMailComposeResultSent:
            
            
            [self sent:@"Email Sent"];
            
            //	NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
            
            break;
        case MFMailComposeResultFailed:
            
            
            [self sent:@"Email failed"];
            break;
        default:
            
            
            [self sent:@"Email not sent"];
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

-(void)sent:(NSString *) str{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
    //                                                    message:str
    //                                                   delegate:nil
    //                                          cancelButtonTitle:@"Ok"
    //                                          otherButtonTitles: nil];
    //    [alert show];
    /*  _AlertBlock.hidden=NO;
     _alertTitle.text=str;
     _AlertBg.transform = CGAffineTransformMakeScale(0.01, 0.01);
     [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
     _AlertBg.transform = CGAffineTransformIdentity;
     } completion:^(BOOL finished){
     // do something once the animation finishes, put it here
     }];*/
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:nil];
//    eMailView.hidden = YES;
    
}

- (IBAction)alertOkay:(id)sender {
    
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        _AlertBg.transform = CGAffineTransformMakeScale(0.01, 0.01);
//    } completion:^(BOOL finished){
//        _AlertBlock.hidden=YES;
//        eMailView.hidden = YES;
//    }];
}

- (IBAction)inviteBack:(id)sender
{
//    eMailView.hidden=YES;
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.delegate=self;
    // [picker.navigationBar setTintColor:[UIColor colorWithRed:174/255.0 green:226/255.0 blue:119/255.0 alpha:1.0]];
    //[[UITableView appearance] setBackgroundColor:[UIColor whiteColor]];
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"navbg"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:@"Avenir-Heavy" size:15], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName,
                                      nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes
                                                forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                           
                                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                                           UITextAttributeTextShadowOffset,
                                                           [UIFont fontWithName:@"Avenir-Heavy" size:22.0], UITextAttributeFont, nil]];
    
    
    [self presentViewController:picker animated:YES completion:nil];
    
    UIButton* backButton= [[UIButton alloc]initWithFrame:CGRectMake(9, 25, 35, 35)];
    [backButton setImage:[UIImage imageNamed:@"btnBack.png"] forState:UIControlStateNormal];
    [backButton addTarget:picker.topViewController.navigationItem.leftBarButtonItem.target action:nil forControlEvents:UIControlEventTouchUpInside];
    [picker.navigationBar.superview addSubview:backButton];
    picker.topViewController.navigationItem.leftBarButtonItem=nil;
    
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
