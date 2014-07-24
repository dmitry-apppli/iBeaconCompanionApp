//
//  CADetailsViewController.m
//  iBeaconCompanionApp
//
//  Created by Dmitry on 15/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import "CADetailsVC.h"
#import "CASelectBeaconVC.h"
#import "CAAssociateContentCell.h"
#import "CAAvailableContentCell.h"
#import "Definitions.h"
#import "BeaconTracker.h"
#import "NSDictionary.h"

@interface CADetailsVC ()
@property (strong, nonatomic)  UILabel *beaconDetails;
@property (weak, nonatomic) IBOutlet UIPickerView *contentIDPickerView;

@property (strong, nonatomic) UIView *beaconDetailsView;
@property (strong, nonatomic) UITableView *availableContentTableView;
@property (strong, nonatomic) UITableView *associatedContentTableView;
@property (strong, nonatomic) UISearchBar *availableSearchBar;


@property (strong, nonatomic) NSMutableArray *associatedCPIDs;
@property (strong, nonatomic) NSMutableArray *availableCPIDs;

@property (strong, nonatomic) CLBeacon *beacon;



@end

@implementation CADetailsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.beaconDetailsView = [[UIView alloc] init];
    self.beaconDetails = [[UILabel alloc] init];
    [self.beaconDetailsView addSubview: self.beaconDetails];
    self.availableContentTableView= [[UITableView alloc] init];
    self.associatedContentTableView = [[UITableView alloc] init];
    self.availableContentTableView.dataSource = self;
    self.availableContentTableView.delegate = self;
    self.associatedContentTableView.dataSource = self;
    self.associatedContentTableView.delegate = self;
    
    self.availableSearchBar = [[UISearchBar alloc] init];
    
    self.associatedCPIDs = [[NSMutableArray alloc] initWithArray:@[]];
    self.availableCPIDs = [[NSMutableArray alloc] initWithArray:@[]];

  
    
    
    
    
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.beaconDetailsView setFrame:CGRectMake(0, 20 + self.view.frame.size.height*0.7f, self.view.frame.size.width, self.view.frame.size.height*0.3f)];
    self.beaconDetailsView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25f];
    
    [self.beaconDetails setFrame:CGRectMake(0, 0, 0, 0)];
    self.beaconDetails.text = @"-";
    [self.beaconDetails sizeToFit];
    
    [self.availableContentTableView setFrame:CGRectMake(0, 20, self.view.frame.size.width*0.5f, self.view.frame.size.height*0.7f)];
    self.availableContentTableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15f];
    
    [self.associatedContentTableView setFrame:CGRectMake(self.view.frame.size.width*0.5f, 20, self.view.frame.size.width*0.5f, self.view.frame.size.height*0.7f)];
    self.associatedContentTableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15f];
    
    self.availableSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.availableSearchBar.delegate = self;
    
    self.availableContentTableView.tableHeaderView = self.availableSearchBar;
    
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.availableSearchBar contentsController:self];
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    searchController.delegate = self;
    
    
    
    [self.availableContentTableView addSubview:self.availableSearchBar];
    [self.view addSubview:self.availableContentTableView];
    [self.view addSubview:self.associatedContentTableView];
    [self.view addSubview:self.beaconDetailsView];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString * HTTPData = [NSString stringWithFormat:@"SearchInput=%@&R=%d", searchBar.text, 6];
    
    NSDictionary *jsonData = [BeaconTracker getParsedJSONFromHTTPRequestUsingPOST:SERVER_ADDRESS Data:HTTPData];
    NSLog(@"%@", [jsonData description]);
    self.availableCPIDs = [[NSMutableArray alloc] initWithArray:[[jsonData verifiedObjectForKey:@"CPIDs"] componentsSeparatedByString:@","]];
    
    [self.availableContentTableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Number of rows is the number of time zones in the region for the specified section.
    NSLog(@"%lu   %lu", [self.associatedCPIDs count], [self.availableCPIDs count]);
    if ([tableView isEqual:self.associatedContentTableView] && [self.associatedCPIDs count] != 0)
        return [self.associatedCPIDs count];
    else if ([tableView isEqual:self.availableContentTableView] && [self.availableCPIDs count] != 0)
        return [self.availableCPIDs count];
    else
        return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // The header for the section is the region name -- get this from the region at the section index.
    if([tableView isEqual:self.availableContentTableView])
        return @"available";
    else if([tableView isEqual:self.associatedContentTableView])
        return @"associated";
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *title = @"---";
    
    if([tableView isEqual:self.associatedContentTableView] && [self.associatedCPIDs count] != 0)
    {
        NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
        NSString * HTTPData = [NSString stringWithFormat:@"CPID=%@&R=%d", [self.associatedCPIDs objectAtIndex:index], 7];
        
        NSDictionary *jsonData = [BeaconTracker getParsedJSONFromHTTPRequestUsingPOST:SERVER_ADDRESS Data:HTTPData];
        
        NSLog(@"%@", [jsonData description]);
        title = [jsonData verifiedObjectForKey:@"ContentTitle"];
        
        
    }
    else if ([tableView isEqual:self.availableContentTableView])
    {
        NSString * HTTPData = [NSString stringWithFormat:@"CPID=%@&R=%d", [self.availableCPIDs objectAtIndex:indexPath.row], 7];
        
        NSDictionary *jsonData = [BeaconTracker getParsedJSONFromHTTPRequestUsingPOST:SERVER_ADDRESS Data:HTTPData];
        
        NSLog(@"%@", [jsonData description]);
        title = [jsonData verifiedObjectForKey:@"ContentTitle"];
    }
    else
        title = @"arasdasd";
    
    NSString *MyIdentifier = @"immediateBeacons";
            CAAvailableContentCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
            if (cell == nil)
            {
                cell = [[CAAvailableContentCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:MyIdentifier];
            }
    cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.08f];
    cell.textLabel.text = title;
    return cell;
    
    
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block UIAlertView *alert = [[UIAlertView alloc]
                          init];
    if([tableView isEqual:self.availableContentTableView])
    {
        if(![self.associatedCPIDs containsObject:[self.availableCPIDs objectAtIndex:indexPath.row]])
        {
            NSString * HTTPData = [NSString stringWithFormat:@"UUID=%@&Major=%@&Minor=%@&CPID=%@&R=%d", self.beacon.proximityUUID.UUIDString, [self.beacon.major stringValue], [self.beacon.minor stringValue], [self.availableCPIDs objectAtIndex:indexPath.row], 8];
            
            NSDictionary *jsonData = [BeaconTracker getParsedJSONFromHTTPRequestUsingPOST:SERVER_ADDRESS Data:HTTPData];
            NSLog(@"%@", [jsonData description]);
            if([[jsonData verifiedObjectForKey:@"Result"] isEqualToString:@"Linked"])
            {
                alert = [[UIAlertView alloc]
                                      initWithTitle:@"Added content"
                                      message:nil
                                      delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles: nil];
                [alert show];
                if([self.associatedCPIDs count] != 0)
                    [self.associatedCPIDs addObject:[self.availableCPIDs objectAtIndex:indexPath.row]];
                else
                {
                    self.associatedCPIDs = [[NSMutableArray alloc] initWithArray:@[[self.availableCPIDs objectAtIndex:indexPath.row]]];
                }
            }
        }
        else
        {
            alert = [[UIAlertView alloc]
                                  initWithTitle:@"Already assigned"
                                  message:nil
                                  delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles: nil];
            [alert show];
            
        }
        ;
    }
    else if([tableView isEqual:self.associatedContentTableView])
    {
        NSString * HTTPData = [NSString stringWithFormat:@"UUID=%@&Major=%@&Minor=%@&CPID=%@&R=%d", self.beacon.proximityUUID.UUIDString, [self.beacon.major stringValue], [self.beacon.minor stringValue],[self.associatedCPIDs objectAtIndex:indexPath.row], 8];
        
            NSDictionary *jsonData = [BeaconTracker getParsedJSONFromHTTPRequestUsingPOST:SERVER_ADDRESS Data:HTTPData];
            if([[jsonData verifiedObjectForKey:@"Result"] isEqualToString:@"Unlinked"])
            {
                NSInteger index = indexPath.row;
                [self.associatedCPIDs removeObjectAtIndex:index];
                [self.availableContentTableView reloadData];
                [self.associatedContentTableView reloadData];
                alert = [[UIAlertView alloc]
                                      initWithTitle:@"Unassigned"
                                      message:nil
                                      delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles: nil];
                [alert show];
            }
    }
    
    [self.availableContentTableView reloadData];
    [self.associatedContentTableView reloadData];
    
    
    
    
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) didSelectBeacon:(CLBeacon *)beacon
{
    self.beacon = beacon;
    NSString * HTTPData = [NSString stringWithFormat:@"UUID=%@&Major=%@&Minor=%@&R=%d", beacon.proximityUUID.UUIDString, [beacon.major stringValue], [beacon.minor stringValue], 5];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSDictionary *jsonData = [BeaconTracker getParsedJSONFromHTTPRequestUsingPOST:SERVER_ADDRESS Data:HTTPData];

        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            if(![[jsonData verifiedObjectForKey:@"CPIDs"] isEqualToString:@""])
            {
            self.associatedCPIDs = [[NSMutableArray alloc] initWithArray:[[jsonData verifiedObjectForKey:@"CPIDs"] componentsSeparatedByString:@","]];
            }
            else
                self.associatedCPIDs = nil;
            NSLog(@"%@", [jsonData description]);
            self.beaconDetails.text = [NSString stringWithFormat:@"Major: %@ Minor: %@", beacon.major, beacon.minor];
            [self.associatedContentTableView reloadData];
            [self.beaconDetails sizeToFit];
        });
    });
    
    
    
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.view sizeToFit];
    
    NSLog(@"ROTATE - self.view.frame = %@", NSStringFromCGRect(self.view.frame));
}



+(NSDictionary *)getParsedJSONFromHTTPRequestUsingPOST:(NSString *)URL Data:(NSString *)HTTPData{
    
    //NSLog(@"URL: %@\nRequest type: POST\nData: %@", URL, HTTPData);
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
