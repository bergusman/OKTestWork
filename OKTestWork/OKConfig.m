//
//  OKConfig.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/11/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKConfig.h"

@interface OKConfig ()

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecretKey;
@property (nonatomic, assign) BOOL useSandbox;
@property (nonatomic, copy) NSString *logInServer;
@property (nonatomic, assign) NSInteger friendsPageSize;

@end

@implementation OKConfig

- (void)loadConfigFromFile:(NSString *)fileName
{
    NSURL *configURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfURL:configURL];
    
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
