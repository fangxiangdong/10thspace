//
//  ActionTableViewCell.m
//  TeamTalk
//
//  Created by landu on 15/12/2.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "ActionTableViewCell.h"

@implementation ActionTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        self.backgroundColor = RGB(240, 240, 240);
        
    }
    return self;
}

@end
