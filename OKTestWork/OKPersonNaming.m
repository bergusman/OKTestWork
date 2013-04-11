//
//  OKPersonNaming.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 12/1/12.
//  Copyright (c) 2012 Vitaliy Berg. All rights reserved.
//

#import "OKPersonNaming.h"

NSString *OKCompositeName(NSString *firstName, NSString *lastName, OKPersonCompositeNameFormat compositeFormat)
{
    if ([firstName length] > 0 && [lastName length] > 0) {
        if (compositeFormat == OKPersonCompositeNameFormatFirstNameFirst) {
            return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        } else {
            return [NSString stringWithFormat:@"%@ %@", lastName, firstName];
        }
    } else if ([firstName length] > 0) {
        return [NSString stringWithFormat:@"%@", firstName];
    } else if ([lastName length] > 0) {
        return [NSString stringWithFormat:@"%@", lastName];
    }
    return @"";
}

BOOL OKSearchCompare(NSString *firstName, NSString *lastName, NSString *term)
{
    NSComparisonResult result = NSOrderedAscending;
    
    if (firstName) {
        result = [firstName compare:term
                            options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)
                              range:NSMakeRange(0, term.length)];
    }
    
    if (result == NSOrderedSame) {
        return YES;
    } else if (lastName) {
        result = [lastName compare:term
                           options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)
                             range:NSMakeRange(0, term.length)];
        if (result == NSOrderedSame) return YES;
    }
    
    return NO;
}

NSString *OKSortingName(NSString *firstName, NSString *lastName, OKPersonSortOrdering sortOrdering)
{
    if (sortOrdering == OKPersonSortByLastName && [lastName length] > 0) {
        return lastName;
    } else if ([firstName length] > 0) {
        return firstName;
    }
    return @"";
}
