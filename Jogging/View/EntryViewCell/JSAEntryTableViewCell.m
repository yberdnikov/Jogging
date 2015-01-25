//
//  JSAEntryTableViewCell.m
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/18/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "JSAEntryTableViewCell.h"
#import "JSAConstants.h"

@interface JSAEntryTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgTimeLabel;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation JSAEntryTableViewCell

+ (NSString *)reuseIdentifier
{
    return @"entryTableViewCell";
}

- (void)awakeFromNib
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
}

- (void)setEntryInfo:(PFObject *)entryInfo
{
    _entryInfo = entryInfo;
    if (!entryInfo)
        return;
    
    self.dateLabel.text = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[entryInfo[@"date"] doubleValue]]];
    
    CGFloat distance = [entryInfo[@"distance"] floatValue];
    if (distance < 1.0f)
        self.distanceLabel.text = [NSString stringWithFormat:@"%.0f %@", distance * YARDS_IN_MILE, NSLocalizedString(@"yards", nil)];
    else
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f %@", distance, NSLocalizedString(@"miles", nil)];
    
    self.timeLabel.text = [self timeText];
    
    CGFloat milePerHour = 3600 * [entryInfo[@"distance"] floatValue] / [self.entryInfo[@"time"] floatValue];
    
    self.avgTimeLabel.text = [NSString stringWithFormat:@"%.2f %@", milePerHour, NSLocalizedString(@"m/h", nil)];
}

#pragma mark - Helpers

- (NSString *)timeText
{
    NSMutableArray *timeComponents = [[NSMutableArray alloc] init];
    
    NSInteger secconds = [self.entryInfo[@"time"] integerValue];
    NSInteger hours = secconds / 3600;
    
    if (hours)
    {
        secconds = secconds - hours * 3600;
        [timeComponents addObject:[NSString stringWithFormat:@"%ld", (long)hours]];
    }
    
    NSInteger minutes = secconds / 60;
    [timeComponents addObject:[NSString stringWithFormat:@"%.2ld", (long)minutes]];
    
    [timeComponents addObject:[NSString stringWithFormat:@"%.2ld", (long)secconds - minutes * 60]];
    
    return [timeComponents componentsJoinedByString:@":"];
}

@end
