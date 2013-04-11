//
//  OKFriendsViewController.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/10/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKFriendsViewController.h"
#import "OKUserCell.h"
#import "OKUser.h"
#import "OKPersonNaming.h"
#import "OKClient.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <TTTLocalizedPluralString/TTTLocalizedPluralString.h>


#define TABLE_FOOTER_LABEL_FRIENDS_MIN_LIMIT 8
#define MIN_FRIENDS_PAGE_SIZE 8
#define MAX_FRIENDS_PAGE_SIZE 100
#define PAGE_COUNT_TO_LOAD 3


@interface OKFriendsViewController ()
<
    UIActionSheetDelegate
>

@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *spinnerBarButtonItem;

@property (nonatomic, strong) UILabel *tableFooterLabel;
@property (nonatomic, strong) UIActivityIndicatorView *tableFooterSpinner;

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *friendUIDs;
@property (nonatomic, assign) NSInteger friendUIDsOffset;

@property (nonatomic, assign) BOOL firstLoading;
@property (nonatomic, assign) BOOL nextLoading;

@property (nonatomic, strong) AFJSONRequestOperation *nextLoadingRequest;

@property (nonatomic, assign) NSInteger friendsPageSize;

@end


@implementation OKFriendsViewController

- (void)dealloc
{
    [_nextLoadingRequest cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLogOut:)
                                                     name:OKClientDidLogOutNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLogIn:)
                                                     name:OKClientDidLogOutNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)didLogOut:(NSNotification *)notification
{
    [self.nextLoadingRequest cancel];
    self.nextLoadingRequest = nil;
    self.firstLoading = NO;
    self.nextLoading = NO;
    self.friendUIDs = nil;
    self.friends = nil;
    [self.tableView reloadData];
}

- (void)didLogIn:(NSNotification *)notification
{
    [self showTableFooterLabel];
}


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"FriendsTitle", @"");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LogOut", @"")
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(logOutAction:)];

    self.refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                              target:self
                                                                              action:@selector(refreshAction:)];
    self.navigationItem.rightBarButtonItem = self.refreshBarButtonItem;
    
    self.tableView.rowHeight = 73;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.frame = CGRectMake(0, 0, 34, 30);
    [spinner startAnimating];
    self.spinnerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    self.tableFooterSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.tableFooterSpinner.frame = CGRectMake(0, 0, 20, 44);
    [self.tableFooterSpinner startAnimating];
    
    self.tableFooterLabel = [[UILabel alloc] init];
    self.tableFooterLabel.frame = CGRectMake(0, 0, 20, 50);
    self.tableFooterLabel.backgroundColor = [UIColor clearColor];
    self.tableFooterLabel.textColor = OK_WHITE(140, 1.0);
    self.tableFooterLabel.font = [UIFont systemFontOfSize:14];
    self.tableFooterLabel.textAlignment = UITextAlignmentCenter;
    
    self.friendsPageSize = MAX(MIN(MAX_FRIENDS_PAGE_SIZE, [OKConfig sharedConfig].friendsPageSize), MIN_FRIENDS_PAGE_SIZE);
    
    [self showTableFooterLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showTableFooterLabel
{
    if ([self.friends count] == 0) {
        self.tableFooterLabel.text = NSLocalizedString(@"NoFriends", @"");
        self.tableView.tableFooterView = self.tableFooterLabel;
    } else if ([self.friends count] > TABLE_FOOTER_LABEL_FRIENDS_MIN_LIMIT) {
        self.tableFooterLabel.text = TTTLocalizedPluralString([self.friends count], @"Friend", @"");
        self.tableView.tableFooterView = self.tableFooterLabel;
    } else {
        self.tableView.tableFooterView = nil;
    }
}


#pragma mark - Friends

- (NSArray *)orderUsers:(NSArray *)users withUIDs:(NSArray *)uids
{
    NSMutableArray *orderedUsers = [NSMutableArray arrayWithCapacity:[users count]];
    NSDictionary *usersByUID = [OKUser usersByUID:users];
    for (NSString *uid in uids) {
        OKUser *user = usersByUID[uid];
        if (user) {
            [orderedUsers addObject:user];
        }
    }
    return orderedUsers;
}

- (NSArray *)nextLoadingUIDs
{
    if (self.friendUIDsOffset < [self.friendUIDs count]) {
        NSInteger count = [self.friendUIDs count] - self.friendUIDsOffset;
        return [self.friendUIDs subarrayWithRange:NSMakeRange(self.friendUIDsOffset, MIN(self.friendsPageSize, count))];
    } else {
        return @[];
    }
}

- (void)addNextUsers:(NSArray *)users withUIDs:(NSArray *)uids
{
    self.friendUIDsOffset += [uids count];
    NSArray *orderedUsers = [self orderUsers:users withUIDs:uids];
    [self.friends addObjectsFromArray:orderedUsers];
}

- (BOOL)areAllFriendsLoaded
{
    return [self.friendUIDs count] == self.friendUIDsOffset;
}


#pragma mark - First Loading

- (void)startFirstLoading
{
    self.firstLoading = YES;
    [self showRefreshSpinner];
}

- (void)endFirstLoading
{
    self.firstLoading = NO;
    [self hideRefreshSpinner];
}

- (BOOL)canFirstLoad
{
    return !self.firstLoading && [OKClient sharedClient].sessionActive;
}

- (void)triggerFirstLoading
{
    if ([self canFirstLoad]) {
        [self loadFirst];
    }
}

- (void)loadFirst
{
    [self.nextLoadingRequest cancel];
    self.nextLoadingRequest = nil;
    
    [self startFirstLoading];
    
    [[OKClient sharedClient].api friendsGetWithSuccess:^(id JSON) {
        NSMutableArray *uids = [JSON mutableCopy];
        NSArray *firstUIDs = [uids subarrayWithRange:NSMakeRange(0, MIN([uids count], 10))];
        
        [[OKClient sharedClient].api usersGetInfoWithUIDs:firstUIDs fields:[OKUser standardFields] success:^(id JSON) {
            NSArray *unorderedUsers = [OKUser usersWithAttributes:JSON];
            NSArray *orderedUsers = [self orderUsers:unorderedUsers withUIDs:firstUIDs];
            
            self.friendUIDs = uids;
            self.friendUIDsOffset = [firstUIDs count];
            self.friends = [orderedUsers mutableCopy];
            
            if ([self areAllFriendsLoaded]) {
                [self showTableFooterLabel];
            } else {
                self.tableView.tableFooterView = self.tableFooterSpinner;
            }
            
            [self.tableView reloadData];
            [self endFirstLoading];
        } failure:^(NSError *error, id JSON) {
            [self endFirstLoading];
        }];
        
    } failure:^(NSError *error, id JSON) {
        [self endFirstLoading];
    }];
}


#pragma mark - Next Loading

- (BOOL)canLoadNext
{
    return !self.firstLoading && !self.nextLoading && ![self areAllFriendsLoaded] && [OKClient sharedClient].sessionActive;
}

- (void)triggerNextLoading
{
    if ([self canLoadNext]) {
        [self loadNext];
    }
}

- (void)loadNext
{
    self.nextLoading = YES;
    NSArray *uids = [self nextLoadingUIDs];
    
    self.nextLoadingRequest = [[OKClient sharedClient].api usersGetInfoWithUIDs:uids fields:[OKUser standardFields] success:^(id JSON) {
        NSArray *users = [OKUser usersWithAttributes:JSON];
        [self addNextUsers:users withUIDs:uids];
        
        if ([self areAllFriendsLoaded]) {
            [self showTableFooterLabel];
        } else {
            self.tableView.tableFooterView = self.tableFooterSpinner;
        }
        
        [self.tableView reloadData];
        self.nextLoading = NO;
    } failure:^(NSError *error, id JSON) {
        self.nextLoading = NO;
    }];
}


#pragma mark - Refresh Spinner

- (void)showRefreshSpinner
{
    [self.navigationItem setRightBarButtonItem:self.spinnerBarButtonItem animated:YES];
}

- (void)hideRefreshSpinner
{
    [self.navigationItem setRightBarButtonItem:self.refreshBarButtonItem animated:YES];
}


#pragma mark - Actions

- (void)logOutAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"LogOutPrompt", @"")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle:NSLocalizedString(@"LogOut", @"")
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)refreshAction:(id)sender
{
    [self triggerFirstLoading];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [[OKClient sharedClient] logOut];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self canLoadNext]) {
        CGFloat cy = scrollView.contentOffset.y;
        CGFloat ch = scrollView.contentSize.height;
        CGFloat h = scrollView.bounds.size.height;
        
        if (cy + PAGE_COUNT_TO_LOAD * h > ch) {
            [self triggerNextLoading];
        }
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FriendCell";
    OKUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[OKUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    OKUser *user = self.friends[indexPath.row];
    cell.textLabel.text = OKCompositeName(user.firstName, user.lastName, OKPersonCompositeNameFormatFirstNameFirst);
    cell.detailTextLabel.text = user.status;
    [cell.imageView setImageWithURL:[NSURL URLWithString:user.picture3] placeholderImage:[self picturePlaceholderWithUser:user]];
    
    return cell;
}

- (UIImage *)picturePlaceholderWithUser:(OKUser *)user
{
    return (user.gender == OKGenderFemale ? [UIImage imageNamed:@"FemaleStub128"] : [UIImage imageNamed:@"MaleStub128"]);
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
