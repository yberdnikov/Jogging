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
#import "JSAAddEntryViewController.h"
#import "JSAConstants.h"
#import <MZFormSheetController.h>
#import <NPReachability.h>
#import "JSAFilterViewController.h"
#import "NSDate+dateRanges.h"

static const NSInteger kMaxNumberOfRowsPerFetch = 20;

@interface JSARootViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UILabel *filterRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekStatisticsLabel;
@property (weak, nonatomic) IBOutlet UILabel *noReccordsFoundLabel;

@property (nonatomic,strong) NSMutableArray *contentDataSource;

@property (nonatomic, assign) BOOL isNextDataChunkAvailable;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) NSUInteger lastFetchedRow;

@property (nonatomic, strong) NSDate *filterFromDate;
@property (nonatomic, strong) NSDate *filterToDate;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation JSARootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"My Jogging", nil);
    
    self.contentDataSource = [[NSMutableArray alloc] init];
    self.filterButton.hidden = YES;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
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
    else
    {
        [self loadData:0 withLimit:kMaxNumberOfRowsPerFetch];
        [self updateWeekStatisticsLabel];
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
    
    self.filterRangeLabel.text = nil;
    
    [self.contentDataSource removeAllObjects];
    [self.contentTableView reloadData];
    
    [self presentAuthenticationController];
}

- (IBAction)filterButtonPressed:(UIButton *)sender
{
    JSAFilterViewController *filterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"filterViewController"];
    filterViewController.fromDate = self.filterFromDate;
    filterViewController.toDate = self.filterToDate;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:filterViewController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    formSheet.cornerRadius = 8.0;
    formSheet.presentedFormSheetSize = CGSizeMake(300, 200);
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    formSheet.shouldCenterVertically = YES;
    
    __weak __typeof(MZFormSheetController) *weakFormSheet = formSheet;
    __weak __typeof(self) weakSelf = self;
    __weak __typeof(filterViewController) weakFilterViewController = filterViewController;
    [filterViewController setOnDatesSelected:^(BOOL isCanceled) {
        [weakFormSheet mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        
        if (isCanceled)
            return;
        
        if (weakSelf.filterFromDate != weakFilterViewController.fromDate ||
            weakSelf.filterToDate != weakFilterViewController.toDate)
        {
            weakSelf.filterFromDate = weakFilterViewController.fromDate;
            weakSelf.filterToDate = weakFilterViewController.toDate;
            
            weakSelf.filterRangeLabel.text = [weakSelf filterTimeRangeText];
            
            weakSelf.lastFetchedRow = 0;
            
            [weakSelf loadData:weakSelf.lastFetchedRow withLimit:kMaxNumberOfRowsPerFetch];
            [weakSelf updateWeekStatisticsLabel];
            
            [weakSelf.contentDataSource removeAllObjects];
            [weakSelf.contentTableView reloadData];
        }
    }];

    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

- (IBAction)addNewEntryButtonPressed:(UIButton *)sender
{
    JSAAddEntryViewController *addEntryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addEntryViewController"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:addEntryViewController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    formSheet.cornerRadius = 8.0;
    formSheet.presentedFormSheetSize = CGSizeMake(300, 320);
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    formSheet.shouldCenterVertically = YES;
    
    __weak __typeof(MZFormSheetController) *weakFormSheet = formSheet;
    __weak __typeof(self) weakSelf = self;
    [addEntryViewController setOnDone:^(PFObject *entry) {
        [weakFormSheet mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        
        if (!entry)
            return;
        
        [weakSelf.contentDataSource insertObject:entry atIndex:0];
        [weakSelf.contentTableView reloadData];
        
        [weakSelf updateWeekStatisticsLabel];
    }];
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.filterButton.hidden = (!self.contentDataSource.count && !self.filterToDate && !self.filterFromDate);
    
    if (!self.contentDataSource.count && !self.isLoadingData)
    {
        if (self.filterToDate || self.filterFromDate)
            self.noReccordsFoundLabel.text = NSLocalizedString(@"No records were found", nil);
        else
            self.noReccordsFoundLabel.text = NSLocalizedString(@"Start adding your jogging data", nil);
        
        self.noReccordsFoundLabel.hidden = NO;
        
        return 0;
    }
    
    self.noReccordsFoundLabel.hidden = YES;
    
    NSInteger rowsCount = self.contentDataSource.count;
    if (self.isNextDataChunkAvailable)
        rowsCount++;
    
    return rowsCount;
}

- (UITableViewCell *)indicatorCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IndicatorCell"];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IndicatorCell"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingIndicator setCenter:CGPointMake(CGRectGetWidth(tableView.frame) / 2,  75.0f / 2)];
    [cell addSubview:loadingIndicator];
    
    [loadingIndicator startAnimating];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger quotesCount = self.contentDataSource.count;
    
    if ((indexPath.row == quotesCount) && self.isNextDataChunkAvailable && !self.isLoadingData)
        [self loadData:self.lastFetchedRow withLimit:kMaxNumberOfRowsPerFetch];
    
    if (indexPath.row == quotesCount && self.isLoadingData)
        return [self indicatorCellForTableView:tableView atIndexPath:indexPath];
    
    JSAEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[JSAEntryTableViewCell reuseIdentifier] forIndexPath:indexPath];
    
    cell.entryInfo = self.contentDataSource[indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle)
    {
        case UITableViewCellEditingStyleDelete:
        {
            PFObject *objectToDelete = [self.contentDataSource objectAtIndex:indexPath.row];

            [self.contentDataSource removeObjectAtIndex:indexPath.row];
            [self.contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [objectToDelete deleteEventually];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate methods

- (NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Edit", nil);
}

- (void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSAAddEntryViewController *addEntryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addEntryViewController"];
    addEntryViewController.entry = [self.contentDataSource objectAtIndex:indexPath.row];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:addEntryViewController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    formSheet.cornerRadius = 8.0;
    formSheet.presentedFormSheetSize = CGSizeMake(300, 320);
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    formSheet.shouldCenterVertically = YES;
    
    __weak __typeof(MZFormSheetController) *weakFormSheet = formSheet;
    __weak __typeof(self) weakSelf = self;
    [addEntryViewController setOnDone:^(PFObject *entry) {
        [weakFormSheet mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        
        if (!entry)
            return;
        
        [weakSelf.contentDataSource sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        [weakSelf.contentTableView reloadData];
        
        [weakSelf updateWeekStatisticsLabel];
    }];
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
    [tableView setEditing:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Helpers

- (NSString *)filterTimeRangeText
{
    if (!self.filterFromDate && !self.filterToDate)
        return nil;
    
    return [NSString stringWithFormat:@"%@ - %@", [self.dateFormatter stringFromDate:self.filterFromDate],
            [self.dateFormatter stringFromDate:self.filterToDate]];
}

- (void)updateWeekStatisticsLabel
{
    PFQuery *query = [PFQuery queryWithClassName:@"JSAEntry"];
    [query orderBySortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"date" greaterThanOrEqualTo:@([[NSDate date] startOfThisWeek].timeIntervalSince1970)];

    if (![NPReachability sharedInstance].isCurrentlyReachable)
        [query fromLocalDatastore];
    
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (error || !objects.count)
        {
            weakSelf.weekStatisticsLabel.text = nil;
            
            return;
        }
        
        NSNumber *avgDistance = [objects valueForKeyPath:@"@avg.distance"];
        NSNumber *avgTime = [objects valueForKeyPath:@"@avg.time"];
        
        CGFloat speed = 3600 * avgDistance.floatValue / avgTime.floatValue;
        
        NSString *distanceText = nil;
        if (avgDistance.floatValue < 1.0f)
            distanceText = [NSString stringWithFormat:@"%.0f %@", avgDistance.floatValue * YARDS_IN_MILE, NSLocalizedString(@"yards", nil)];
        else
            distanceText = [NSString stringWithFormat:@"%.2f %@", avgDistance.floatValue, NSLocalizedString(@"miles", nil)];
        
        weakSelf.weekStatisticsLabel.text = [NSString stringWithFormat:@"%@ - %@: %.2f%@, %@: %@",
                                             NSLocalizedString(@"This week", nil),
                                             NSLocalizedString(@"avg speed", nil), speed,
                                             NSLocalizedString(@"m/h", nil),
                                             NSLocalizedString(@"avg distance", nil), distanceText];
    }];
}

#pragma mark - Server API communication

- (void)loadData:(NSUInteger)startRow withLimit:(NSUInteger)limit
{
    self.isLoadingData = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"JSAEntry"];
    [query orderBySortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    if (self.filterFromDate)
        [query whereKey:@"date" greaterThanOrEqualTo:@([self.filterFromDate timeIntervalSince1970])];
    
    if (self.filterToDate)
        [query whereKey:@"date" lessThanOrEqualTo:@([self.filterToDate timeIntervalSince1970])];
    
    query.limit = limit;
    query.skip = startRow;
    
    if (![NPReachability sharedInstance].isCurrentlyReachable)
        [query fromLocalDatastore];
    
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
        weakSelf.isLoadingData = NO;
        
        [SVProgressHUD dismiss];
        
        if (error)
        {
            weakSelf.isNextDataChunkAvailable = NO;
            
            if (!weakSelf.lastFetchedRow)
            {
                [weakSelf.contentDataSource removeAllObjects];
                [weakSelf.contentTableView reloadData];
                
                [UIAlertView showErrorWithMessage:error.localizedDescription handler:nil];
            }
            
            return;
        }
        
        if (objects.count)
        {
            if ([NPReachability sharedInstance].isCurrentlyReachable)
                [PFObject pinAllInBackground:objects];
            
            if (!weakSelf.lastFetchedRow)
            {
                [weakSelf.contentDataSource removeAllObjects];
                [weakSelf.contentTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
            
            [weakSelf.contentDataSource addObjectsFromArray:objects];
            weakSelf.lastFetchedRow += objects.count;
        }
        
        if (objects.count < limit)
            self.isNextDataChunkAvailable = NO;
        else
            self.isNextDataChunkAvailable = YES;
        
        [weakSelf.contentTableView reloadData];
    }];
}

@end
