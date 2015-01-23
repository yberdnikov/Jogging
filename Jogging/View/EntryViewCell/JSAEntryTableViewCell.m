//
//  JSAEntryTableViewCell.m
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/18/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "JSAEntryTableViewCell.h"

@interface JSAEntryTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgTimeLabel;

@end

@implementation JSAEntryTableViewCell

+ (NSString *)reuseIdentifier
{
    return @"entryTableViewCell";
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setEntryInfo:(PFObject *)entryInfo
{
    _entryInfo = entryInfo;
    if (!entryInfo)
        return;
}

@end
