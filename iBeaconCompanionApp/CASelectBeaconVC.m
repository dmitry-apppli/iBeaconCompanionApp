//
//  CAViewController.m
//  iBeaconCompanionApp
//
//  Created by Dmitry on 11/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import "CASelectBeaconVC.h"
#import "Definitions.h"
#import "CABeaconTableViewCell.h"
#import "NSDictionary.h"

@interface CASelectBeaconVC ()
{
    unsigned int _asyncAction;
	OSSpinLock _asyncActionLock;
}

@property (strong, nonatomic) BeaconTracker *tracker;
@property (strong, nonatomic) NSMutableArray *beaconsToDraw;
@property (strong, nonatomic) IBOutlet UITableView *immediateBeaconsTableView;

@end

@implementation CASelectBeaconVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tracker = [[BeaconTracker alloc] init];
    self.tracker.delegate = self;
    self.immediateBeaconsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.immediateBeaconsTableView.delegate = self;
    self.immediateBeaconsTableView.dataSource = self;
    [self.immediateBeaconsTableView reloadData];
//    [NSTimer scheduledTimerWithTimeInterval:0.3f
//                                     target:self
//                                   selector:@selector(tableRefresh)
//                                   userInfo:nil
//                                    repeats:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

//- (void)tableRefresh
//{
//    [self.immediateBeaconsTableView reloadData];
//}
#pragma mark - Table Update Methods
- (void)immediateAndNearBeaconsReceived: (NSMutableArray *) beacons
{
    self.beaconsToDraw = beacons;
    NSLog(@"Delegate Launched");
    [self.immediateBeaconsTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Number of rows is the number of time zones in the region for the specified section.
    return [self.beaconsToDraw count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // The header for the section is the region name -- get this from the region at the section index.
    if([tableView isEqual:self.immediateBeaconsTableView])
        return [NSString stringWithFormat: @"Beacons in range: %lu", [self.beaconsToDraw count]];
    else
        return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.immediateBeaconsTableView])
    {
        NSString *MyIdentifier = @"immediateBeacons";
        CABeaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil)
        {
            cell = [[CABeaconTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:MyIdentifier];
        }
        
        NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];;
        if(index == [self.beaconsToDraw count])
            index--;
        CLBeacon  *beacon = [self.beaconsToDraw objectAtIndex:index];
        NSString *distance = @"";
        switch (beacon.proximity) {
            case CLProximityNear:
                distance = @"Near";
                cell.proximityTextLabel.text =[NSString stringWithFormat: @"Distance: %@", distance];
                cell.majorMinorTextLabel.text =[NSString stringWithFormat:@"Major: %@ Minor: %@", beacon.major, beacon.minor];
                cell.beaconIDTextLabel.text = [NSString stringWithFormat:@"Beacon ID: -"];
                break;
            case CLProximityImmediate:
            {
                cell.majorMinorTextLabel.text =[NSString stringWithFormat:@"Major: %@ Minor: %@", beacon.major, beacon.minor];
                [self receiveBeaconIDPrintInCell:@[beacon,cell]];
                break;
            }
            default:
                break;
        }
        
        return cell;
    }
    else
        return nil;
}

-(void) receiveBeaconIDPrintInCell:(NSArray *) args
{
    CLBeacon *beacon = args[0];
    CABeaconTableViewCell *cell = args[1];
    NSString * HTTPData = [NSString stringWithFormat:@"UUID=%@&Major=%@&Minor=%@&R=%d", beacon.proximityUUID.UUIDString, [beacon.major stringValue], [beacon.minor stringValue], 2];
    //NSLog(@"%@", HTTPData);
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSDictionary *jsonReply = [BeaconTracker getParsedJSONFromHTTPRequestUsingPOST:SERVER_ADDRESS Data:HTTPData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            if([[jsonReply verifiedObjectForKey:@"result"] isEqualToString:@"success"])
            {
                cell.proximityTextLabel.text =[NSString stringWithFormat: @"Distance: %@", @"Immediate"];
                cell.majorMinorTextLabel.text =[NSString stringWithFormat:@"Major: %@ Minor: %@", beacon.major, beacon.minor];;
                cell.beaconIDTextLabel.text = [NSString stringWithFormat:@"Beacon ID: %@", [jsonReply verifiedObjectForKey:@"BeaconID"]];
                
            }
        });
    });
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    Build a segue string based on the selected cell
    //    NSString *segueString = [NSString stringWithFormat:@"%@Segue",
    //                             [self.tracker.beaconsSet objectAtIndex:indexPath.row]];
    //Since contentArray is an array of strings, we can use it to build a unique
    //identifier for each segue.
    
    //Perform a segue.
    NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];;
    [_delegate didSelectBeacon:[self.beaconsToDraw objectAtIndex:index]];
//    [self performSegueWithIdentifier:@"beaconSegue"
//                              sender:[self.beaconsInRange  objectAtIndex:indexPath.row]];
}

- (void)increaseAsyncAction
{
	OSSpinLockLock(&_asyncActionLock);
	_asyncAction++;
	OSSpinLockUnlock(&_asyncActionLock);
}
- (void)decreaseAsyncAction
{
	OSSpinLockLock(&_asyncActionLock);
	_asyncAction--;
	if (0 == _asyncAction) {
	}
	OSSpinLockUnlock(&_asyncActionLock);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
