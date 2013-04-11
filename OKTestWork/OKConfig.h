//
//  OKConfig.h
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/11/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import <Foundation/Foundation.h>

// Read about config in README.md
@interface OKConfig : NSObject

@property (nonatomic, copy, readonly) NSString *appID;
@property (nonatomic, copy, readonly) NSString *appKey;
@property (nonatomic, copy, readonly) NSString *appSecretKey;
@property (nonatomic, assign, readonly) BOOL useSandbox;
@property (nonatomic, copy, readonly) NSString *logInServer;
@property (nonatomic, assign, readonly) NSInteger friendsPageSize;

+ (OKConfig *)sharedConfig;

@end
