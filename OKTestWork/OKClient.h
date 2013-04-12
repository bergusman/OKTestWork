//
//  OKClient.h
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/11/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKAPI.h"

extern NSString * const OKClientDidLogInNotification;
extern NSString * const OKClientDidLogOutNotification;

// OKClient reads OKConfig, therefore OKCient must be initialized after config loading
@interface OKClient : NSObject

@property (nonatomic, strong, readonly) OKAPI *api;
@property (nonatomic, assign, readonly, getter=isSessionActive) BOOL sessionActive;

+ (OKClient *)sharedClient;

- (void)logInWithUserName:(NSString *)userName
                 password:(NSString *)password
                  success:(void (^)(id JSON))success
                  failure:(void (^)(NSError *error, id JSON))failure;

- (void)logOut;

@end
