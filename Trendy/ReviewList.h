//
//  ReviewList.h
//  Trendy
//
//  Created by NewAgeSMB on 9/9/15.
//  Copyright (c) 2015 NewAgeSMB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerRequest.h"
@protocol deleteaction <NSObject>

-(void)deleteindex:(NSUInteger)index;

@end

@interface ReviewList : UIViewController<delegaterequest>

@property (retain, nonatomic) NSString *productid;
@property BOOL viewonly;
@property (nonatomic,weak) id<deleteaction>deletedelegate;
@end
