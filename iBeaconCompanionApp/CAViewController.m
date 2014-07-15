//
//  CAViewController.m
//  iBeaconCompanionApp
//
//  Created by Dmitry on 11/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import "CAViewController.h"
#import "Definitions.h"
#import "CABeaconTableViewCell.h"

@interface CAViewController ()
{
    unsigned int _asyncAction;
	OSSpinLock _asyncActionLock;
}

@property (strong, nonatomic) BeaconTracker *tracker;
@property (strong, nonatomic) NSMutableArray *beaconsToDraw;
@property (strong, nonatomic) IBOutlet UITableView *immediateBeaconsTableView;

@end

@implementation CAViewController

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
        
//        self.beaconsInRange = [[NSMutableArray alloc] initWithArray:self.tracker.beaconsSet];
        NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];;
        if(index == [self.beaconsToDraw count])
            index--;
        CLBeacon  *beacon = [self.beaconsToDraw objectAtIndex:index];
        //    UILabel *majorMinor = (UILabel*) [cell viewWithTag:1000];
        //    UILabel *rssiLabel = (UILabel*) [cell viewWithTag:1001];
        //    [title setText:[ tableMainTitle objectAtIndex:indexPath.row]];
        //    [summary setText:[ tableSubTitle objectAtIndex:indexPath.row]];
        NSString *distance = @"";
        switch (beacon.proximity) {
            case CLProximityNear:
                distance = @"Near";
                cell.proximityTextLabel.text =[NSString stringWithFormat: @"Distance: %@", distance];
                cell.majorMinorTextLabel.text =[NSString stringWithFormat:@"Major: %@ Minor: %@", beacon.major, beacon.minor];;
                cell.beaconIDTextLabel.text = [NSString stringWithFormat:@"Beacon ID: -"];
                break;
            case CLProximityImmediate:
            {
                [self increaseAsyncAction];
                NSThread* myThread = [[NSThread alloc] initWithTarget:self selector:@selector (receiveBeaconIDPrintInCell:)
                                                               object:@[beacon,cell]];
                [myThread start];  // Actually create the thread
               
                [self decreaseAsyncAction];
                break;
            }
            default:
                break;
        }
        
//        cell.detailTextLabel.text =[NSString stringWithFormat:@"RSSI: %li", beacon.rssi];
//        cell.accuracyLabel.text =[NSString stringWithFormat:@"Accuracy: %f", beacon.accuracy];
        return cell;
    }
    else
        return nil;
}

-(void) receiveBeaconIDPrintInCell:(NSMutableArray *) args
{
    CLBeacon *beacon = args[0];
    CABeaconTableViewCell *cell = args[1];
    NSString * HTTPData = [NSString stringWithFormat:@"UUID=%@&Major=%@&Minor=%@&R=%d", beacon.proximityUUID.UUIDString, [beacon.major stringValue], [beacon.minor stringValue], 2];
    NSLog(@"%@", HTTPData);
    NSDictionary *jsonReply = [BeaconTracker getParsedJSONFromHTTPRequestUsingPOST:SERVER_ADDRESS Data:HTTPData];
    
    if([[jsonReply objectForKey:@"result"] isEqualToString:@"success"])
    {
        cell.proximityTextLabel.text =[NSString stringWithFormat: @"Distance: %@", @"Immediate"];
        cell.majorMinorTextLabel.text =[NSString stringWithFormat:@"Major: %@ Minor: %@", beacon.major, beacon.minor];;
        cell.beaconIDTextLabel.text = [NSString stringWithFormat:@"Beacon ID: %@", [jsonReply objectForKey:@"BeaconID"]];
        
    }
    [NSThread exit];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    Build a segue string based on the selected cell
    //    NSString *segueString = [NSString stringWithFormat:@"%@Segue",
    //                             [self.tracker.beaconsSet objectAtIndex:indexPath.row]];
    //Since contentArray is an array of strings, we can use it to build a unique
    //identifier for each segue.
    
    //Perform a segue.
    
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
