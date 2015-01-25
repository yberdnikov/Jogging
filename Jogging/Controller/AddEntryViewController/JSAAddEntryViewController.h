//
//  JSAAddEntryViewController.h
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/20/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface JSAAddEntryViewController : UIViewController

@property (nonatomic, strong) PFObject *entry;
@property (nonatomic, copy) void(^onDone)(PFObject *entry);

@end
