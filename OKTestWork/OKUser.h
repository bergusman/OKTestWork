//
//  OKUser.h
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/10/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    OKGenderNone,
    OKGenderMale,
    OKGenderFemale
} OKGender;

@interface OKUser : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, assign) OKGender gender;
@property (nonatomic, copy) NSString *picture3;
@property (nonatomic, copy) NSString *status;

+ (NSArray *)usersWithAttributes:(NSArray *)attributes;
+ (OKUser *)userWithAttributes:(NSDictionary *)attributes;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (NSArray *)standardFields;

+ (NSDictionary *)usersByUID:(NSArray *)users;

@end
