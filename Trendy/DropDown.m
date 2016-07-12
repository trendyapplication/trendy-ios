//
//  DropDown.m
//  Trendy
//
//  Created by NewAgeSMB on 9/14/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import "DropDown.h"
#import "PostStep2.h"

@interface DropDown (){
    
    IBOutlet UILabel *titlelabel, *noresultslabel;
    IBOutlet UITextField *searchfield;
    NSArray *resultoriginalarray;
    IBOutlet UITableView *droptable;
    IBOutlet UIButton *savebtn;
    float height;
}

@end

@implementation DropDown
@synthesize type,droparray;
- (void)viewDidLoad {
   
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    resultoriginalarray = [droparray mutableCopy];
    if([type isEqualToString:@"brand"])
        titlelabel.text = @"Select brand";
    else if([type isEqualToString:@"product_type"])
        titlelabel.text = @"Select Product Type";
    else if([type isEqualToString:@"occation"])
        titlelabel.text = @"Select occasion";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect keyboardBounds;
    [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    height = keyboardBounds.size.height;
    [self settableframe];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    height = 49.0;
    [self settableframe];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger )section{
    
    return droparray.count;
//    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellidentifier =@"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    if([type isEqualToString:@"brand"])
        cell.textLabel.text = [[droparray objectAtIndex:indexPath.row] objectForKey:@"brand"];
    else
        cell.textLabel.text = [[droparray objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:15.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if([type isEqualToString:@"product_type"]){
        
        NSArray *array = [[droparray objectAtIndex:indexPath.row] objectForKey:@"submenu"];
        if([array count] > 0){
//            droparray = [array mutableCopy];
//            [tableView reloadData];
            
            DropDown *obj = [[DropDown alloc] init];
            obj.type = @"product_type";
            obj.droparray = [array mutableCopy];
            [self.navigationController pushViewController:obj animated:YES];
            return;
        }
    }
    NSDictionary *dict = [droparray objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DROPTABLEVALUE" object:nil userInfo:dict];
    BOOL poped = NO;
    for (id controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[PostStep2 class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            poped = YES;
            break;
        }
    }
    if(poped == NO)
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Textfield Delegates
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //    scroll.contentOffset = CGPointMake(0, 0);
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *searchKey = [textField.text stringByAppendingString:string];
    //arrFilterSearch = nil;
    searchKey = [searchKey stringByReplacingCharactersInRange:range withString:@""];
    NSArray *ary = resultoriginalarray;
    NSLog(@"searchKey....==%@",searchKey);
    if(searchKey.length>0){
        
        if(![type isEqualToString:@"product_type"])
            savebtn.hidden = NO;
        NSArray *syy = [[NSMutableArray alloc] init];
        NSPredicate *predicate;
        if([type isEqualToString:@"brand"])
            predicate = [NSPredicate predicateWithFormat:@"brand BEGINSWITH[cd] %@",searchKey];
        else
            predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@",searchKey];
        syy = [ary filteredArrayUsingPredicate: predicate];
        NSLog(@"syyy....==%@",syy);
        noresultslabel.hidden = YES;
        if(syy.count>0){
            
            droptable.hidden = NO;
            droparray = [syy mutableCopy];
            noresultslabel.hidden = YES;
            //                noResults.hidden = YES;
        }
        else{
            droptable.hidden = YES;
            droparray = nil;
            if([type isEqualToString:@"product_type"])
                noresultslabel.hidden = NO;
        }
    }
    else{
        droptable.hidden = NO;
        droparray = [resultoriginalarray mutableCopy];
        if([type isEqualToString:@"occation"])
            savebtn.hidden = YES;
    }
    if(droparray.count>0)
        noresultslabel.hidden = YES;
    else
        noresultslabel.hidden = NO;
    [droptable reloadData];
    return YES;
}

-(void)settableframe{
    
    CGRect frame = droptable.frame;
    frame.size.height = [[UIScreen mainScreen] bounds].size.height - frame.origin.y - height;
    droptable.frame = frame;
}

-(IBAction)backorsave:(id)sender{
    
    if([sender tag] == 1){
        
        NSString *searchKey = searchfield.text;
        NSArray *ary = resultoriginalarray;
        NSLog(@"searchKey....==%@",searchKey);
        if(searchKey.length>0){
            
            NSArray *syy = [[NSMutableArray alloc] init];
            NSPredicate *predicate;
            
            if([type isEqualToString:@"occation"]){
                
                predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@",searchKey];
            }
            
            else if([type isEqualToString:@"brand"]){
                
                predicate = [NSPredicate predicateWithFormat:@"brand LIKE[c] %@",searchKey];
            }
            
            syy = [ary filteredArrayUsingPredicate: predicate];
            NSLog(@"syyy....==%@",syy);
            if(syy.count>0){
                
                NSDictionary *dict = [syy objectAtIndex:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DROPTABLEVALUE" object:nil userInfo:dict];
            }
            else{
                
                NSDictionary *dict;
                if([type isEqualToString:@"occation"]){
                    dict = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"occasion_id",searchfield.text,@"name", nil];
                }
                
                else if([type isEqualToString:@"brand"]){
                    
                    dict = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"id",searchfield.text,@"brand", nil];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DROPTABLEVALUE" object:nil userInfo:dict];
            }
        }
        else{
            
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
