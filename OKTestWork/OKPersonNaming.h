//
//  OKPersonNaming.h
//  OKTestWork
//
//  Created by Vitaliy Berg on 12/1/12.
//  Copyright (c) 2012 Vitaliy Berg. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    OKPersonSortByFirstName,
    OKPersonSortByLastName
} OKPersonSortOrdering;

typedef enum {
    OKPersonCompositeNameFormatFirstNameFirst,
    OKPersonCompositeNameFormatLastNameFirst
} OKPersonCompositeNameFormat;

extern NSString *OKCompositeName(NSString *firstName, NSString *lastName, OKPersonCompositeNameFormat compositeFormat);
extern BOOL OKSearchCompare(NSString *firstName, NSString *lastName, NSString *term);
extern NSString *OKSortingName(NSString *firstName, NSString *lastName, OKPersonSortOrdering sortOrdering);
