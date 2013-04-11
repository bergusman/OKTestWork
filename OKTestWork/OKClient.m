//
//  OKClient.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/11/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKClient.h"


NSString * const OKClientDidLogInNotification = @"OKClientDidLogInNotification";
NSString * const OKClientDidLogOutNotification = @"OKClientDidLogOutNotification";

#define OKClientSessionKey @"OKClientSessionKey"
#define OKClientSessionSecretKey @"OKClientSessionSecretKey"
#define OKClientSessionServerKey @"OKClientSessionServerKey"


@interface OKClient ()

@property (nonatomic, strong) OKAPI *api;
@property (nonatomic, assign, getter=isSessionActive) BOOL sessionActive;

@end


@implementation OKClient

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.api = [[OKAPI alloc] init];
        self.api.usesSandbox = [OKConfig sharedConfig].useSandbox;
        self.api.server = [OKConfig sharedConfig].logInServer;
        self.api.appKey = [OKConfig sharedConfig].appKey;
        self.api.appSecretKey = [OKConfig sharedConfig].appSecretKey;
        [self restoreSessionFromCache];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(apiDidFailure:)
                                                     name:OKAPIDidFailureNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)apiDidFailure:(NSNotification *)notification
{
    NSError *error = notification.userInfo[OKAPIErrorUserInfoKey];
    if (error.code == OKAPIErrorCodeSessionExpired) {
        [self logOut];
    }
}

- (void)logInWithUserName:(NSString *)userName
                 password:(NSString *)password
                  success:(void (^)(id JSON))success
                  failure:(void (^)(NSError *error, id JSON))failure;
{
    [self.api authLogInWithUserName:userName password:password success:^(id JSON) {
        
        self.api.server = JSON[@"api_server"];
        self.api.sessionKey = JSON[@"session_key"];
        self.api.sessionSecretKey = JSON[@"session_secret_key"];
        self.sessionActive = YES;
        
        [self storeSessionToCache];
        
        if (success) {
            success(JSON);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OKClientDidLogInNotification object:self userInfo:nil];
        
    } failure:^(NSError *error, id JSON) {
        if (failure) {
            failure(error, JSON);
        }
    }];
}

- (void)logOut
{
    self.api.server = [OKConfig sharedConfig].logInServer;
    self.api.sessionKey = nil;
    self.api.sessionSecretKey = nil;
    self.sessionActive = NO;
    [self clearSessionCache];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OKClientDidLogOutNotification object:self userInfo:nil];
}


#pragma mark - Session Cache

// TODO: Wrap cache values to dictionary and store it

- (void)restoreSessionFromCache
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionServer = [userDefaults objectForKey:OKClientSessionServerKey];
    NSString *sessionKey = [userDefaults objectForKey:OKClientSessionKey];
    NSString *sessionSecretKey = [userDefaults objectForKey:OKClientSessionSecretKey];
    if (sessionKey && sessionSecretKey && sessionServer) {
        self.api.server = sessionServer;
        self.api.sessionKey = sessionKey;
        self.api.sessionSecretKey = sessionSecretKey;
        self.sessionActive = YES;
    }
}

- (void)storeSessionToCache
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.api.server forKey:OKClientSessionServerKey];
    [userDefaults setObject:self.api.sessionKey forKey:OKClientSessionKey];
    [userDefaults setObject:self.api.sessionSecretKey forKey:OKClientSessionSecretKey];
    [userDefaults synchronize];
}

- (void)clearSessionCache
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:OKClientSessionServerKey];
    [userDefaults removeObjectForKey:OKClientSessionKey];
    [userDefaults removeObjectForKey:OKClientSessionSecretKey];
    [userDefaults synchronize];
}


#pragma mark - Singleton

+ (OKClient *)sharedClient
{
    static OKClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OKClient alloc] init];
    });
    return _sharedClient;
}

@end
