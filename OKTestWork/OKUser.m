//
//  OKUser.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/10/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKUser.h"


#define GET_ATTRIBUTE(value) ({id __value = (value); (__value != [NSNull null] ? (__value) : nil); })


@implementation OKUser

+ (NSArray *)usersWithAttributes:(NSArray *)attributes
{
    if (![attributes isKindOfClass:[NSArray class]]) {
        return @[];
    }
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:[attributes count]];
    for (NSDictionary *userAttributes in attributes) {
        if ([userAttributes isKindOfClass:[NSDictionary class]]) {
            OKUser *user = [OKUser userWithAttributes:userAttributes];
            [users addObject:user];
        }
    }
    
    return users;
}

+ (OKUser *)userWithAttributes:(NSDictionary *)attributes
{
    return [[OKUser alloc] initWithAttributes:attributes];
}

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        
        self.uid = GET_ATTRIBUTE(attributes[@"uid"]);
        self.firstName = GET_ATTRIBUTE(attributes[@"first_name"]);
        self.lastName = GET_ATTRIBUTE(attributes[@"last_name"]);
        self.status = GET_ATTRIBUTE(attributes[@"current_status"]);
        self.picture3 = GET_ATTRIBUTE(attributes[@"pic_3"]);
        
        // I don't know whether server always return gender
        id gender = attributes[@"gender"];
        if (gender != [NSNull null]) {
            if ([gender isEqualToString:@"female"]) {
                self.gender = OKGenderFemale;
            } else if ([gender isEqualToString:@"male"]) {
                self.gender = OKGenderMale;
            }
        }
        
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<%@:%p; uid = %@; firstName = %@; lastName = %@>",
            [self class],
            self,
            self.uid,
            self.firstName,
            self.lastName];
}

#pragma mark - Utilities

+ (NSArray *)standardFields
{
    return @[@"first_name", @"last_name", @"gender",  @"pic_3", @"current_status"];
}

+ (NSDictionary *)usersByUID:(NSArray *)users
{
    NSMutableDictionary *usersByUID = [NSMutableDictionary dictionaryWithCapacity:[users count]];
    for (OKUser *user in users) {
        usersByUID[user.uid] = user;
    }
    return usersByUID;
}

@end
