//
//  BlogImageModel.m
//  TeamTalk
//
//  Created by landu on 15/11/17.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "BlogImageModel.h"

@implementation BlogImageModel


- (void)setImgArray:(NSMutableArray *)imgArray{
    _imgArray = imgArray;
    
    
    switch (_imgArray.count) {
        case 0:
            //_photoViewHeight = 0;
            _photoViewHeight = (SCREEN_WIDTH - 40) /4 * 3 + 12;
            break;
        case 1:
        case 2:
        case 3:
        case 4:
            //_photoViewHeight = (SCREEN_WIDTH - 40) / 4 + 4;
            _photoViewHeight = (SCREEN_WIDTH - 40) /4 * 3 + 12;
            break;
        case 5:
        case 6:
        case 7:
        case 8:
            //_photoViewHeight = (SCREEN_WIDTH - 40) / 2 + 8;
            _photoViewHeight = (SCREEN_WIDTH - 40) /4 * 3 + 12;
            break;
        default:
            _photoViewHeight = (SCREEN_WIDTH - 40) /4 * 3 + 12;
            break;
    }
    //NSLog(@"----- _photoViewHeight == %f",_photoViewHeight);
}


@end
