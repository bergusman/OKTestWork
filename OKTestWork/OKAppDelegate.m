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
        [self didHideSplash];
    }];
}

- (void)didHideSplash
{
}


#pragma mark - OKClient Notifications

- (void)didLogIn:(NSNotification *)notification
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didLogOut:(NSNotification *)notification
{
    OKLogInViewController *logInVC = [[OKLogInViewController alloc] init];
    logInVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:logInVC animated:YES completion:nil];
}


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[OKConfig sharedConfig] loadConfigFromFile:[[NSBundle mainBundle] infoDictionary][@"OKConfigName"]];
    
    [OKClient sharedClient]; // Init OKClient
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogIn:)
                                                 name:OKClientDidLogInNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogOut:)
                                                 name:OKClientDidLogOutNotification
                                               object:nil];
    
    [[UINavigationBar appearance] setTintColor:[UIColor orangeColor]]; // All
    
    OKFriendsViewController *friendsVC = [[OKFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:friendsVC];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [self showSplash];
    
    if (![OKClient sharedClient].sessionActive) {
        OKLogInViewController *logInVC = [[OKLogInViewController alloc] init];
        logInVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentViewController:logInVC animated:NO completion:nil];
    }
    
    return YES;
}

@end
