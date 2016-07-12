//
//  filterCell.h
//  Trendy
//
//  Created by NewAgeSMB on 9/25/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface filterCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UIButton *expandbtn, *checkbtn, *headerbtn, *subcheckbtn;
@property (weak, nonatomic) IBOutlet UILabel *valuelabel, *subvaluelabel;
@property (weak, nonatomic) IBOutlet UIView *subcellview;
@end
