//
//  JSAFilterViewController.h
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/25/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSAFilterViewController : UIViewController

@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;

@property (nonatomic, copy) void (^onDatesSelected)(BOOL cancel);

@end
