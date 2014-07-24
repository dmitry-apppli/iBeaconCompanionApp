//
//  CADetailsViewController.h
//  iBeaconCompanionApp
//
//  Created by Dmitry on 15/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASelectBeaconVC.h"

@interface CADetailsVC : UIViewController <CASelectBeaconDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate>

@end
