//
//  OKUserCell.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/10/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKUserCell.h"

@implementation OKUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.contentView.bounds.size;
    
    self.imageView.frame = CGRectMake(8, 8, 56, 56);
    self.textLabel.frame = CGRectMake(8 + 56 + 10, 14, size.width - (8 + 56 + 10) - 8, 22);
    self.detailTextLabel.frame = CGRectMake(8 + 56 + 10, 14 + 20, size.width - (8 + 56 + 10) - 8, 22);
}

@end
