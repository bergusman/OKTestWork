//
//  OKAPI.h
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/10/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFJSONRequestOperation.h>


extern NSString * const OKAPIDidFailureNotification;
extern NSString * const OKAPIErrorUserInfoKey;
extern NSString * const OKAPIJSONUserInfoKey;

extern NSString * const OKAPIErrorDomain;

typedef enum {
    OKAPIErrorCodeUnknown = 1,
    OKAPIErrorCodeService = 2,
    OKAPIErrorCodeMethod = 3,
    OKAPIErrorCodeRequest = 4,
    OKAPIErrorCodeAPIKey = 101,
    OKAPIErrorCodeSessionExpired = 102,
    OKAPIErrorCodeSessionKey = 103,
    OKAPIErrorCodeSignature = 104,
    OKAPIErrorCodeUserID = 110,
    OKAPIErrorCodeAuthLogin = 401,
    OKAPIErrorCodeAuthLoginCaptcha = 402,
    OKAPIErrorCodeSessionRequired = 453,
    OKAPIErrorCodeFriendRestriction = 455,
    OKAPIErrorCodeSystem = 9999
} OKAPIErrorCode;


@interface OKAPI : NSObject

@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecretKey;
@property (nonatomic, copy) NSString *sessionKey;
@property (nonatomic, copy) NSString *sessionSecretKey;

@property (nonatomic, assign) BOOL usesSandbox;

#pragma mark - Auth

- (AFJSONRequestOperation *)authLogInWithUserName:(NSString *)userName
                                         password:(NSString *)password
                                          success:(void (^)(id JSON))success
                                          failure:(void (^)(NSError *error, id JSON))failure;

#pragma mark - Friends

- (AFJSONRequestOperation *)friendsGetWithSuccess:(void (^)(id JSON))success
                                          failure:(void (^)(NSError *error, id JSON))failure;

#pragma mark - Users

- (AFJSONRequestOperation *)usersGetInfoWithUIDs:(NSArray *)uids
                                          fields:(NSArray *)fields
                                         success:(void (^)(id JSON))success
                                         failure:(void (^)(NSError *error, id JSON))failure;

@end
