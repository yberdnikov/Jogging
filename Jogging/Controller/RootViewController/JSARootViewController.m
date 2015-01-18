//
//  JSARootViewController.m
//  Jogging
//
//  Created by Yuriy Berdnikov on 1/18/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "JSARootViewController.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>
#import "JSAEntryTableViewCell.h"

@interface JSARootViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation JSARootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"My Jogging", nil);
    
    [self.contentTableView registerNib:[UINib nibWithNibName:@"JSAEntryTableViewCell" bundle:nil] forCellReuseIdentifier:[JSAEntryTableViewCell reuseIdentifier]];
    self.contentTableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentAuthenticationController];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User authentication

- (void)presentAuthenticationController
{
    UINavigationController *authenticationController = [self.storyboard instantiateViewControllerWithIdentifier:@"authenticationNavigationController"];
    authenticationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:authenticationController animated:NO completion:nil];
}

#pragma mark - UIButton selectors

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
    [PFUser logOut];
    
    [self presentAuthenticationController];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSAEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[JSAEntryTableViewCell reuseIdentifier] forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
