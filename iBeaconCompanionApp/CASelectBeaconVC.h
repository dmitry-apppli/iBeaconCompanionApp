//
//  CAViewController.h
//  iBeaconCompanionApp
//
//  Created by Dmitry on 11/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>
#import "BeaconTracker.h"

@protocol CASelectBeaconDelegate <NSObject>

@required
- (void) didSelectBeacon: (CLBeacon *)beacon;

@end

@interface CASelectBeaconVC : UITableViewController <UITableViewDelegate, UITableViewDataSource, BeaconTrackerDelegate>

@property (nonatomic, weak) id <CASelectBeaconDelegate> delegate;

@end
