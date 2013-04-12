//
//  OKAPI.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/10/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKAPI.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AFNetworking/AFNetworking.h>


NSString * const OKAPIDidFailureNotification = @"OKAPIDidFailureNotification";
NSString * const OKAPIErrorUserInfoKey = @"OKAPIErrorUserInfoKey";
NSString * const OKAPIJSONUserInfoKey = @"OKAPIJSONUserInfoKey";

NSString * const OKAPIErrorDomain = @"OKAPIErrorDomain";

static NSString *md5(NSString *input);

@interface OKAPI ()

@property (nonatomic, strong) NSString *secureServer;
@property (nonatomic, strong) NSString *notSecureServer;

@end


@implementation OKAPI

#pragma mark - Auth

- (AFJSONRequestOperation *)authLogInWithUserName:(NSString *)userName
                                         password:(NSString *)password
                                          success:(void (^)(id JSON))success
                                          failure:(void (^)(NSError *error, id JSON))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userName) params[@"user_name"] = userName;
    if (password) params[@"password"] = password;
    
    return [self goMethodWithName:@"login"
                           module:@"auth"
                           params:params
                          session:NO
                           secure:!self.usesSandbox
                          success:success
                          failure:failure];
}


#pragma mark - Friends

- (AFJSONRequestOperation *)friendsGetWithSuccess:(void (^)(id JSON))success
                                          failure:(void (^)(NSError *error, id JSON))failure
{
    return [self goMethodWithName:@"get"
                           module:@"friends"
                           params:@{}
                          session:YES
                           secure:NO
                          success:success
                          failure:failure];
}


#pragma mark - Users

- (AFJSONRequestOperation *)usersGetInfoWithUIDs:(NSArray *)uids
                                          fields:(NSArray *)fields
                                         success:(void (^)(id JSON))success
                                         failure:(void (^)(NSError *error, id JSON))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (uids) params[@"uids"] = [uids componentsJoinedByString:@","];
    if (fields) params[@"fields"] = [fields componentsJoinedByString:@","];
    params[@"emptyPictures"] = @"true";

    return [self goMethodWithName:@"getInfo"
                           module:@"users"
                           params:params
                          session:YES
                           secure:NO
                          success:success
                          failure:failure];
}


#pragma mark - Server URL

- (void)setServer:(NSString *)server
{
    _server = server;
    
    NSString *serverWithoutScheme = server;
    NSInteger colon = [serverWithoutScheme rangeOfString:@":"].location;
    if (colon != NSNotFound) {
        serverWithoutScheme = [serverWithoutScheme substringFromIndex:colon];
    }
        
    self.secureServer = [@"https" stringByAppendingString:serverWithoutScheme];
    self.notSecureServer = [@"http" stringByAppendingString:serverWithoutScheme];
}


#pragma mark - Common


- (AFJSONRequestOperation *)goMethodWithName:(NSString *)methodName
                                      module:(NSString *)methodModule
                                      params:(NSDictionary *)params
                                     session:(BOOL)useSession
                                      secure:(BOOL)secure
                                     success:(void (^)(id JSON))success
                                     failure:(void (^)(NSError *error, id JSON))failure
{
    NSAssert(self.appKey, @"Miss application key");
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    mutableParams[@"application_key"] = self.appKey;
    
    NSString *signature = nil;
    
    if (useSession) {
        NSAssert(self.sessionKey, @"Miss session key");
        mutableParams[@"session_key"] = self.sessionKey;
        signature = [self signatureWithParams:mutableParams secretKey:self.sessionSecretKey];
    } else {
        signature = [self signatureWithParams:mutableParams secretKey:self.appSecretKey];
    }
    
    mutableParams[@"sig"] = signature;
    
    NSString *queryString = AFQueryStringFromParametersWithEncoding(mutableParams, NSUTF8StringEncoding);
    NSData *queryData = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSString *path = [NSString stringWithFormat:@"api/%@/%@?%@", methodModule, methodName, queryString];
    NSString *path = [NSString stringWithFormat:@"api/%@/%@", methodModule, methodName];
    
    NSString *server = (secure ? self.secureServer : self.notSecureServer);
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:server]];
    
    //NSLog(@"%@", [url absoluteString]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:8];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:queryData];
    
     
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if ([self isErrorJSON:JSON]) {
            [self handleErrorWithError:nil JSON:JSON failure:failure];
            return;
        }
        
        if (success) {
            success(JSON);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self handleErrorWithError:error JSON:JSON failure:failure];
    }];
    
    [requestOperation start];
    return requestOperation;
}

- (BOOL)isErrorJSON:(id)JSON
{
    return [JSON isKindOfClass:[NSDictionary class]] && JSON[@"error_code"];
}

- (NSError *)errorWithJSON:(id)JSON
{
    return [NSError errorWithDomain:OKAPIErrorDomain code:[JSON[@"error_code"] integerValue] userInfo:JSON];
}

- (NSString *)signatureWithParams:(NSDictionary *)params secretKey:(NSString *)secretKey
{
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *signatureString = [NSMutableString stringWithString:@""];
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [signatureString appendFormat:@"%@=%@", obj, params[obj]];
    }];
    [signatureString appendString:secretKey];
    return [md5(signatureString) lowercaseString];
}

- (void)handleErrorWithError:(NSError *)error JSON:(id)JSON failure:(void (^)(NSError *error, id JSON))failure
{
    if (!error) {
        error = [self errorWithJSON:JSON];
    }
    
    if (failure) {
        failure(error, JSON);
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (error) userInfo[OKAPIErrorUserInfoKey] = error;
    if (JSON) userInfo[OKAPIJSONUserInfoKey] = JSON;
        
    [[NSNotificationCenter defaultCenter] postNotificationName:OKAPIDidFailureNotification
                                                        object:self
                                                      userInfo:userInfo];
}

@end


NSString *md5(NSString *input)
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return  output;
}
