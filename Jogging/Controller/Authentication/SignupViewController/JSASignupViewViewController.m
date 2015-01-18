//
//  JSASignupViewViewController.m
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/18/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "JSASignupViewViewController.h"
#import <TPKeyboardAvoidingScrollView.h>
#import "NSString+Utilities.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>

@interface JSASignupViewViewController ()

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation JSASignupViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Sign Up", nil);
    
    [self decorateUIElements];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Setup

- (void)decorateUIElements
{
    self.emailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, CGRectGetHeight(self.emailTextField.bounds))];
    self.passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, CGRectGetHeight(self.emailTextField.bounds))];
    self.usernameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, CGRectGetHeight(self.emailTextField.bounds))];
    
    self.usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
        [self.view endEditing:YES];
    else
        [self.contentScrollView focusNextTextField];
    
    return YES;
}

#pragma mark - UIButton selectors

- (IBAction)signupButtonPressed:(UIButton *)sender
{
    if (![self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length)
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter valid username", nil) handler:nil];
        return;
    }
    
    if (![self.emailTextField.text isValidEmailFormat])
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter valid email address", nil) handler:nil];
        return;
    }
    
    if (![self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length)
    {
        [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please enter valid password", nil) handler:nil];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self signupUser];
}

#pragma mark - Server API communication

- (void)signupUser
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    PFUser *user = [PFUser user];
    user[@"name"] = self.usernameTextField.text;
    user.username = self.emailTextField.text;
    user.email = self.emailTextField.text;
    user.password = self.passwordTextField.text;
    
    __weak __typeof__(self) weakSelf = self;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        [SVProgressHUD dismiss];
        if (error)
        {
            NSString *errorString = error.userInfo ? [error.userInfo objectForKey:@"error"] : error.localizedDescription;
            [UIAlertView showErrorWithMessage:errorString.length ? errorString : error.localizedDescription handler:nil];
            return;
        }
        
        [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
