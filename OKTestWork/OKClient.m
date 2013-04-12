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

static NSString *const OKClientSessionInfoKey = @"OKClientSessionInfo";
static NSString *const OKSessionServer = @"session_server";
static NSString *const OKSessionKey = @"session_key";
static NSString *const OKSessionSecretKey = @"session_secret_key";


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
        
        [self restoreSession];
        
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
    self.api.server = [OKConfig sharedConfig].logInServer;
    
    [self.api authLogInWithUserName:userName password:password success:^(id JSON) {
        
        self.api.server = JSON[@"api_server"];
        self.api.sessionKey = JSON[@"session_key"];
        self.api.sessionSecretKey = JSON[@"session_secret_key"];
        self.sessionActive = YES;
        
        [self storeSession];
        
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
    if (!self.sessionActive) {
        return;
    }
    
    self.sessionActive = NO;
    [self clearSessionInfoCache];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OKClientDidLogOutNotification object:self userInfo:nil];
}


#pragma mark - Session

- (NSDictionary *)sessionInfo
{
    if (self.api.server && self.api.sessionKey && self.api.sessionSecretKey) {
        return @{OKSessionServer: self.api.server,
                 OKSessionKey: self.api.sessionKey,
                 OKSessionSecretKey: self.api.sessionSecretKey
        };
    } else {
        return nil;
    }
}

- (void)restoreSession
{
    NSDictionary *sessionInfo = [self restoreSessionInfoFromCache];
    if (sessionInfo) {
        self.api.server = sessionInfo[OKSessionServer];
        self.api.sessionKey = sessionInfo[OKSessionKey];
        self.api.sessionSecretKey = sessionInfo[OKSessionSecretKey];
        self.sessionActive = YES;
    }
}

- (void)storeSession
{
    [self storeSessionInfoToCache:[self sessionInfo]];
}


#pragma mark - Session Info Cache

- (NSDictionary *)restoreSessionInfoFromCache
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:OKClientSessionInfoKey];
}

- (void)storeSessionInfoToCache:(NSDictionary *)sessionInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sessionInfo forKey:OKClientSessionInfoKey];
    [userDefaults synchronize];
}

- (void)clearSessionInfoCache
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:OKClientSessionInfoKey];
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
