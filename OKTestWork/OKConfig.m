//
//  OKConfig.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/11/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKConfig.h"

#define OKConfigName @"OKConfigName"

@interface OKConfig ()

@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecretKey;
@property (nonatomic, assign) BOOL useSandbox;
@property (nonatomic, copy) NSString *logInServer;
@property (nonatomic, assign) NSInteger friendsPageSize;

@end

@implementation OKConfig

- (id)init
{
    self = [super init];
    if (self) {
        NSString *configName = [[NSBundle mainBundle] infoDictionary][OKConfigName];
        NSAssert(configName, @"Cannot get config name");
        [self loadConfigFromFile:configName];
    }
    return self;
}

- (void)loadConfigFromFile:(NSString *)fileName
{
    NSURL *configURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfURL:configURL];
    
    self.appID = config[@"Application ID"];
    self.appKey = config[@"Application Key"];
    self.appSecretKey = config[@"Application Secret Key"];
    self.useSandbox = [config[@"Use Sandbox"] boolValue];
    self.logInServer = config[@"LogIn Server"];
    self.friendsPageSize = [config[@"Friends Page Size"] integerValue];
}

#pragma mark - Singleton

+ (OKConfig *)sharedConfig
{
    static OKConfig *_sharedConfig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfig = [[OKConfig alloc] init];
    });
    return _sharedConfig;
}

@end
