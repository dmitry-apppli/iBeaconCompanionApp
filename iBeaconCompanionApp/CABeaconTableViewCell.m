//
//  CABeaconTableViewCell.m
//  iBeaconCompanionApp
//
//  Created by Dmitry on 15/07/2014.
//  Copyright (c) 2014 Apppli ltd. All rights reserved.
//

#import "CABeaconTableViewCell.h"

@implementation CABeaconTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
