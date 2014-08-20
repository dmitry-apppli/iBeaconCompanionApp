//
//  BeaconTracker.h
//  iBeaconsEditor
//
//  Created by Dmitry on 07/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@protocol BeaconTrackerDelegate <NSObject>

@optional

- (void)immediateAndNearBeaconsReceived: (NSMutableArray *) beacons;

@end

@interface BeaconTracker : NSObject <CLLocationManagerDelegate>


@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic, readonly) NSMutableArray *beaconsSet;
@property (strong, nonatomic) NSMutableArray *immediateBeacons;

@property (nonatomic, weak) id <BeaconTrackerDelegate> delegate;

-(NSMutableArray *)sortedBeaconsInOrder: (bool) ascending;
+(NSDictionary *)getParsedJSONFromHTTPRequestUsingPOST:(NSString *)URL Data:(NSString *)HTTPData;
@end
