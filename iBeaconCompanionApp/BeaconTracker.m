//
//  BeaconTracker.m
//  iBeaconsEditor
//
//  Created by Dmitry on 07/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import "BeaconTracker.h"
#import "Definitions.h"

@interface BeaconTracker ()
@property (strong, nonatomic) NSTimer *closestBeaconTimer;
@property (strong, nonatomic) CLBeacon *closestBeacon;

@end

@implementation BeaconTracker


- (BeaconTracker *) init{
    if ( (self = [super init]) )
    {
        // your custom initialization
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self initRegion];
        self.immediateBeacons = [[NSMutableArray alloc] init];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
        NSLog(@"initilized");
//        [NSTimer scheduledTimerWithTimeInterval:0.3f
//                                         target:self
//                                       selector:@selector(getClosestBeacon)
//                                       userInfo:nil
//                                        repeats:YES];
    }
    return self;

}
//-(void)getClosestBeacon
//{
//    for(CLBeacon*b in self.immediateBeacons)
//        NSLog(@"Immediate: %@.%@", b.major, b.minor);
//}


- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:ACTIVE_UUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"Andr3y_M"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    NSLog(@"initRegion");
    
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"enter");
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"exit");
}

-(NSMutableArray *)sortBeaconsInOrder: (bool) ascending
{
    NSSortDescriptor *majorSorter = [[NSSortDescriptor alloc] initWithKey:@"major" ascending:ascending];
    NSSortDescriptor *minorSorter = [[NSSortDescriptor alloc] initWithKey:@"minor" ascending:ascending];
    NSSortDescriptor *proximitySorter = [[NSSortDescriptor alloc] initWithKey:@"proximity" ascending:!ascending];
    NSArray *sortDescriptors = @[proximitySorter, majorSorter, minorSorter];
    NSMutableArray *beacons = [[NSMutableArray alloc] initWithArray:[self.immediateBeacons sortedArrayUsingDescriptors:sortDescriptors]];
    return beacons;
}

-(void)removeObjectInArray:(NSMutableArray *)array FromIndexToEnd:(NSUInteger) from toIndex:(NSUInteger) to
{
         id obj = [array objectAtIndex:from];
         [array removeObjectAtIndex:from];
         if (to >= [array count])
         {
             [array addObject:obj];
         } else
         {
             [array insertObject:obj atIndex:to];
         }
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
        self.beaconsSet = [[NSMutableArray alloc] initWithArray:beacons];
    self.immediateBeacons = [[NSMutableArray alloc] init];
    for (CLBeacon *b in self.beaconsSet)
    {
        switch (b.proximity)
        {
            case CLProximityImmediate:
            case CLProximityNear:
                [self.immediateBeacons addObject:b];
                break;
            default:
                break;
        }
    }
    [_delegate immediateAndNearBeaconsReceived:[self sortBeaconsInOrder: NO]];
    NSLog(@"Delegate Called");
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"didStartMonitoringForRegion called");
}

+(NSDictionary *)getParsedJSONFromHTTPRequestUsingPOST:(NSString *)URL Data:(NSString *)HTTPData{
    
    NSLog(@"URL: %@\nRequest type: POST\nData: %@", URL, HTTPData);
    NSString *post = HTTPData;
    
    //HTTPData = [HTTPData stringByAppendingString:[NSString stringWithFormat:@"&APIKey=%@", [self developerKey]]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse *response;
    NSError *error;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    NSDictionary *beaconServerData;
    NSArray* JSONArray = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    for(int i=0; i<[JSONArray count];i++){
        beaconServerData= [JSONArray objectAtIndex:i];
    }
    return beaconServerData;
}

@end
