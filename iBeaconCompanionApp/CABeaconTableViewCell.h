//
//  CABeaconTableViewCell.h
//  iBeaconCompanionApp
//
//  Created by Dmitry on 15/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CABeaconTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *majorMinorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *proximityTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *beaconIDTextLabel;

@end
