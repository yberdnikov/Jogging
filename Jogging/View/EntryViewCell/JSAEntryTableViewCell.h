//
//  JSAEntryTableViewCell.h
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/18/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface JSAEntryTableViewCell : UITableViewCell

@property (nonatomic, strong) PFObject *entryInfo;

+ (NSString *)reuseIdentifier;

@end
