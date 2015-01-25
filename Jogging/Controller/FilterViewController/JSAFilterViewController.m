//
//  JSAFilterViewController.m
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/25/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "JSAFilterViewController.h"
#import <ActionSheetPicker-3.0/ActionSheetDatePicker.h>
#import "NSDate+dateRanges.h"

@interface JSAFilterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *fromDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *toDateTextField;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation JSAFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    //[self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    if (self.fromDate)
        self.fromDateTextField.text = [self.dateFormatter stringFromDate:self.fromDate];
    
    if (self.toDate)
        self.toDateTextField.text = [self.dateFormatter stringFromDate:self.toDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton selector

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    if (self.onDatesSelected)
        self.onDatesSelected(YES);
}

- (IBAction)clearButtonPressed:(UIButton *)sender
{
    self.fromDate = self.toDate = nil;
    
    self.fromDateTextField.text = nil;
    self.toDateTextField.text = nil;
}

- (IBAction)applyButtonrPressed:(UIButton *)sender
{
    if (self.onDatesSelected)
        self.onDatesSelected(NO);
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self presentDatePicker:textField];
    
    return NO;
}

#pragma mark - Data selection helpers

- (void)presentDatePicker:(UITextField *)origin
{
    NSString *title = self.fromDateTextField == origin ? NSLocalizedString(@"From Date", nil) : NSLocalizedString(@"To Date", nil);
    NSDate *selectedDate = self.fromDateTextField == origin ? self.fromDate : self.toDate;
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:title
                                                                      datePickerMode:UIDatePickerModeDate
                                                                        selectedDate:selectedDate ? : [NSDate date]
                                                                           doneBlock:^(ActionSheetDatePicker *picker, NSDate *selectedDate, id origin) {
                                                                               
                                                                               if (self.fromDateTextField == origin)
                                                                               {
                                                                                   self.fromDate = [selectedDate startOfDay];
                                                                                   self.fromDateTextField.text = [self.dateFormatter stringFromDate:selectedDate];
                                                                               }
                                                                               else
                                                                               {
                                                                                   self.toDate = [selectedDate endOfDay];
                                                                                   self.toDateTextField.text = [self.dateFormatter stringFromDate:selectedDate];
                                                                               }
                                                                               
                                                                           } cancelBlock:nil origin:origin];
    if (self.toDateTextField == origin && self.fromDate)
        datePicker.minimumDate = self.fromDate;
    
    if (self.fromDateTextField == origin && self.toDate)
        datePicker.maximumDate = self.toDate;
    else
        datePicker.maximumDate = [NSDate date];
    
    [datePicker showActionSheetPicker];
}

@end
