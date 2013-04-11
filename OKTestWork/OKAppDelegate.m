//
//  OKAppDelegate.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/10/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKAppDelegate.h"
#import "OKClient.h"
#import "OKLogInViewController.h"
#import "OKFriendsViewController.h"

@interface OKAppDelegate ()

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIImageView *splash;

@end

@implementation OKAppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        [OKConfig sharedConfig];
    }
    return self;
}


#pragma mark - Splash

- (void)showSplash
{
    self.splash = [[UIImageView alloc] init];
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        self.splash.image = [UIImage imageNamed:@"Default-568h"];
    } else {
        self.splash.image = [UIImage imageNamed:@"Default"];
    }
    
    self.splash.frame = self.window.bounds;
    [self.window addSubview:self.splash];
    
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:0.05];
}

- (void)hideSplash
{
    [UIView animateWithDuration:0.4 animations:^{
        self.splash.alpha = 0;
    } completion:^(BOOL finished) {
        [self.splash removeFromSuperview];
        self.splash = nil;
    }];
}


#pragma mark - Log In View Controller

- (void)presentLogInViewControllerAnimated:(BOOL)animated
{
    OKLogInViewController *logInVC = [[OKLogInViewController alloc] init];
    logInVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:logInVC animated:animated completion:nil];
}

- (void)dismissLogInViewControllerAnimated:(BOOL)animated
{
    if ([self.navigationController.modalViewController isKindOfClass:[OKLogInViewController class]]) {
        [self.navigationController dismissViewControllerAnimated:animated completion:nil];
    }
}


#pragma mark - OKClient Notifications

- (void)didLogIn:(NSNotification *)notification
{
    [self dismissLogInViewControllerAnimated:YES];
}

- (void)didLogOut:(NSNotification *)notification
{
    [self presentLogInViewControllerAnimated:YES];
}


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [OKClient sharedClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogIn:)
                                                 name:OKClientDidLogInNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogOut:)
                                                 name:OKClientDidLogOutNotification
                                               object:nil];
    
    OKFriendsViewController *friendsVC = [[OKFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:friendsVC];
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [self showSplash];
    
    if (![OKClient sharedClient].sessionActive) {
        [self presentLogInViewControllerAnimated:NO];
    }
    
    return YES;
}

@end
