//
//  RootViewController.h
//  TestDataProtection
//
//  Created by Joshua Vickery on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController

@property(nonatomic,retain) NSString *fileProtectionValue;
@property(nonatomic,retain) NSString *fileContents;

@end
