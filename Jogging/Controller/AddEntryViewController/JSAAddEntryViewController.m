//
//  JSAAddEntryViewController.m
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/20/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "JSAAddEntryViewController.h"
#import <ActionSheetPicker-3.0/ActionSheetDatePicker.h>
#import <ActionSheetPicker-3.0/ActionSheetCustomPicker.h>
#import "JSAConstants.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>
#import "MZFormSheetController+SVProgressHUD.h"

@interface JSAAddEntryViewController () <ActionSheetCustomPickerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *distanceTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;

@property (nonatomic, strong) NSDate *joggingDate;
@property (nonatomic, assign) NSInteger joggingDistMiles;
@property (nonatomic, assign) NSInteger joggingDistYards;

@property (nonatomic, assign) NSInteger joggingTimeHours;
@property (nonatomic, assign) NSInteger joggingTimeMinutes;
@property (nonatomic, assign) NSInteger joggingTimeSecconds;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) ActionSheetCustomPicker *distancePicker;
@property (nonatomic, strong) ActionSheetCustomPicker *timePicker;

@end

@implementation JSAAddEntryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    
    if (self.entry)
    {
        self.titleLabel.text = NSLocalizedString(@"Edit entry", nil);
        [self populateViewWithDataEntry];
    }
    
    [self decorateUIElements];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI related

- (void)decorateUIElements
{
    [@[self.distanceTextField, self.timeTextField, self.dateTextField] enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, CGRectGetHeight(textField.bounds))];
        textField.leftViewMode = UITextFieldViewModeAlways;
    }];
}

- (void)populateViewWithDataEntry
{
    //jogging distance
    CGFloat distance = [self.entry[@"distance"] doubleValue];
    self.joggingDistMiles = (NSInteger)distance;
    self.joggingDistYards = (distance - self.joggingDistMiles) / MILE_IN_YARDS;
    
    self.distanceTextField.text = [self distanceText];
    
    //jogging time
    double joggingTime = [self.entry[@"time"] doubleValue];
    
    self.joggingTimeHours = joggingTime / 3600;
    joggingTime = joggingTime - self.joggingTimeHours * 3600;
    
    self.joggingTimeMinutes = joggingTime / 60;
    joggingTime = joggingTime - self.joggingTimeMinutes * 60;
    
    self.joggingTimeSecconds = joggingTime;
    
    self.timeTextField.text = [self joggingTimeText];
    
    //jogging date
    self.joggingDate = [NSDate dateWithTimeIntervalSince1970:[self.entry[@"date"] doubleValue]];
    self.dateTextField.text = [self.dateFormatter stringFromDate:self.joggingDate];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.dateTextField == textField)
        [self presentDatePicker:textField];
    else if (self.distanceTextField == textField)
        [self presentDistancePicker:textField];
    else
        [self presentTimePicker:textField];
    
    return NO;
}

#pragma mark - UIButton selectors

- (IBAction)closeButtonPressed:(UIButton *)sender
{
    if (self.onDone)
        self.onDone(nil);
}

- (IBAction)saveButtonPressed:(UIButton *)sender
{
    if (!self.joggingDistMiles && !self.joggingDistYards)
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter jogging distance", nil) handler:nil];
        return;
    }
    
    if (!self.joggingTimeHours && !self.joggingTimeMinutes && !self.joggingTimeSecconds)
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter jogging time", nil) handler:nil];
        return;
    }
    
    if (!self.joggingDate)
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter jogging date", nil) handler:nil];
        return;
    }
    
    [self saveUserJoggingData];
}

#pragma mark - Save data

- (void)saveUserJoggingData
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    if (!self.entry)
    {
        self.entry = [PFObject objectWithClassName:@"JSAEntry"];
        [self.entry pinInBackground];
    }
    
    self.entry[@"date"] = @([self.joggingDate timeIntervalSince1970]);
    self.entry[@"distance"] = @(self.joggingDistMiles + self.joggingDistYards * MILE_IN_YARDS);
    self.entry[@"time"] = @(self.joggingTimeHours * 3600 + self.joggingTimeMinutes * 60 + self.joggingTimeSecconds);
    self.entry[@"user"] = [PFUser currentUser];
    
    __weak __typeof(self) weakSelf = self;
    [self.entry saveEventually:^(BOOL succeeded, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (error)
        {
            [UIAlertView showErrorWithMessage:error.localizedDescription handler:nil];
            return;
        }
        
        if (self.onDone)
            self.onDone(weakSelf.entry);
    }];
}

#pragma mark - Data selection helpers

- (void)presentDatePicker:(UIView *)origin
{
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(@"Select a Date", nil)
                                                                      datePickerMode:UIDatePickerModeDate
                                                                        selectedDate:self.joggingDate ? : [NSDate date]
                                                                              target:self
                                                                              action:@selector(dateWasSelected:element:)
                                                                              origin:origin];
    datePicker.maximumDate = [NSDate date];
    
    [datePicker showActionSheetPicker];
}

- (void)presentDistancePicker:(UIView *)origin
{
    self.distancePicker = [ActionSheetCustomPicker showPickerWithTitle:NSLocalizedString(@"Select Distance", nil) delegate:self showCancelButton:YES origin:origin];
}

- (void)presentTimePicker:(UIView *)origin
{
    self.timePicker = [ActionSheetCustomPicker showPickerWithTitle:NSLocalizedString(@"Select Time", nil) delegate:self showCancelButton:YES origin:origin];
}

#pragma mark - ActionSheetDatePicker selector

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    self.joggingDate = selectedDate;
    self.dateTextField.text = [self.dateFormatter stringFromDate:selectedDate];
}

#pragma mark - ActionSheetCustomPicker selector

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    if (self.timePicker == actionSheetPicker)
        [self timeWasSelected:(UIPickerView *)actionSheetPicker.pickerView];
    else
        [self distanceWasSelected:(UIPickerView *)actionSheetPicker.pickerView];
}

- (void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    self.distancePicker = nil;
    self.timePicker = nil;
}

#pragma mark - UIPickerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.distancePicker.pickerView == pickerView)
        return 4;
    
    return 6;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.distancePicker.pickerView == pickerView)
        return [self distancePickerView:pickerView numberOfRowsInComponent:component];
    
    return [self timePickerView:pickerView numberOfRowsInComponent:component];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.distancePicker.pickerView == pickerView)
        return [self distancePickerView:pickerView titleForRow:row forComponent:component];
    
    return [self timePickerView:pickerView titleForRow:row forComponent:component];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (self.timePicker.pickerView == pickerView)
        return [self timePickerView:pickerView widthForComponent:component];
    
    return [self distancePickerView:pickerView widthForComponent:component];
}

#pragma mark - UIViewPicker helpers

- (NSInteger)timePickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            return 23; //hours
            
        case 1:
            return 1;
            
        case 2:
            return 59; //minutes
            
        case 3:
            return 1;
            
        case 4:
            return 59; //secconds
            
        case 5:
            return 1; //secconds
            
        default:
            return 0;
    }
}

- (NSInteger)distancePickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            return MAX_DISTANCE_MI;
            
        case 1:
            return 1;
            
        case 2:
            return YARDS_IN_MILE - 1;
            
        case 3:
            return 1;
            
        default:
            return 0;
    }
}

- (NSString *)timePickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        case 2:
        case 4:
            return @(row).stringValue;
            
        case 1:
            return NSLocalizedString(@"h", nil);
            
        case 3:
            return NSLocalizedString(@"m", nil);
            
        case 5:
            return NSLocalizedString(@"s", nil);

        default:
            return 0;
    }
}

- (NSString *)distancePickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        case 2:
            return @(row).stringValue;
            
        case 1:
            return NSLocalizedString(@"miles", nil);
            
        case 3:
            return NSLocalizedString(@"yards", nil);
            
        default:
            return 0;
    }
}

- (CGFloat)timePickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        case 2:
        case 4:
            return CGRectGetWidth(pickerView.bounds) / 4 - 20.0f;
            
        case 1:
        case 3:
        case 5:
            return 40.0f;
            
        default:
            return 0;
    }
}

- (CGFloat)distancePickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        case 2:
            return CGRectGetWidth(pickerView.bounds) / 4;
            
        case 1:
        case 3:
            return CGRectGetWidth(pickerView.bounds) / 5;
            
        default:
            return 0;
    }
}

- (void)distanceWasSelected:(UIPickerView *)pickerView
{
    self.joggingDistMiles = [pickerView selectedRowInComponent:0];
    self.joggingDistYards = [pickerView selectedRowInComponent:2];
    
    self.distanceTextField.text = [self distanceText];
    
    self.distancePicker = nil;
}

- (void)timeWasSelected:(UIPickerView *)pickerView
{
    self.joggingTimeHours = [pickerView selectedRowInComponent:0];
    self.joggingTimeMinutes = [pickerView selectedRowInComponent:2];
    self.joggingTimeSecconds = [pickerView selectedRowInComponent:4];
    
    self.timeTextField.text = [self joggingTimeText];
    
    self.timePicker = nil;
}

#pragma mark - UI helpers

- (NSString *)distanceText
{
    NSMutableString *distanceText = [[NSMutableString alloc] init];
    
    if (self.joggingDistMiles)
    {
        [distanceText appendFormat:@"%ld %@", (long)self.joggingDistMiles,
         self.joggingDistMiles > 1 ? NSLocalizedString(@"miles", nil) : NSLocalizedString(@"mile", nil)];
    }
    
    if (self.joggingDistYards)
    {
        [distanceText appendFormat:@"%@%ld %@", distanceText.length ? @" " : @"", (long)self.joggingDistYards,
         self.joggingDistYards > 1 ? NSLocalizedString(@"yards", nil) : NSLocalizedString(@"yard", nil)];
    }
    
    return distanceText;
}

- (NSString *)joggingTimeText
{
    NSMutableArray *timeComponents = [[NSMutableArray alloc] init];
    
    if (self.joggingTimeHours)
        [timeComponents addObject:[NSString stringWithFormat:@"%2ld %@", (long)self.joggingTimeHours, NSLocalizedString(@"h", nil)]];
    
    if (self.joggingTimeMinutes)
        [timeComponents addObject:[NSString stringWithFormat:@"%2ld %@", (long)self.joggingTimeMinutes, NSLocalizedString(@"m", nil)]];
    
    if (self.joggingTimeSecconds)
        [timeComponents addObject:[NSString stringWithFormat:@"%2ld %@", (long)self.joggingTimeSecconds, NSLocalizedString(@"s", nil)]];
    
    return timeComponents.count ? [timeComponents componentsJoinedByString:@" "] : nil;
}

@end
