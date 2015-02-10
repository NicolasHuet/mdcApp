//
//  PRELocalDBTools.h
//  MDC
//
//  Created by Nicolas Huet on 11/07/13.
//  Copyright (c) 2013 Present. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDCAppDelegate.h"

@interface PRELocalDBTools : NSObject

- (void) instantiateLocalDB;

- (void) updateTypeClientTable;
- (void) updateClientsTable:(NSString *)repID;
- (void) updateCommandesTable:(NSString *)repID;

- (void) performSyncWithLogin;

@end
