//
//  NSDictionary.m
//  iBeaconTestApp
//
//  Created by Dmitry on 17/07/2014.
//  Copyright (c) 2014 Apppli. All rights reserved.
//

#import "NSDictionary.h"

@implementation NSDictionary (Verified)

- (id)verifiedObjectForKey:(id)aKey
{
    if ([self objectForKey:aKey] && ![[self objectForKey:aKey] isKindOfClass:[NSNull class]]) return [self objectForKey:aKey];
    return nil;
}
@end
