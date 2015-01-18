//
//  JSAResetPasswordViewController.m
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/18/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "JSAResetPasswordViewController.h"
#import "NSString+Utilities.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>

@interface JSAResetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation JSAResetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Reset Password", nil);
    
    [self decorateUIElements];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI Setup

- (void)decorateUIElements
{
    self.emailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, CGRectGetHeight(self.emailTextField.bounds))];
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

#pragma mark - UIButton selectors

- (IBAction)resetPasswordButtonPressed:(UIButton *)sender
{
    if (![self.emailTextField.text isValidEmailFormat])
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter valid email address", nil) handler:nil];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self resetUserPassword];
}

#pragma mark - Server API communication

- (void)resetUserPassword
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    __weak __typeof__(self) weakSelf = self;
    [PFUser requestPasswordResetForEmailInBackground:self.emailTextField.text block:^(BOOL succeeded, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (error)
        {
            NSString *errorString = error.userInfo ? [error.userInfo objectForKey:@"error"] : error.localizedDescription;
            [UIAlertView showErrorWithMessage:errorString.length ? errorString : error.localizedDescription handler:nil];
            return;
        }
        
        [UIAlertView showWithTitle:NSLocalizedString(@"Email Sent", nil) message:NSLocalizedString(@"Follow the instructions in the email to access your password reset page", nil) handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

@end
