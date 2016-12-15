//
//  CYAvatarBrowser.m
//  TeamTalk
//
//  Created by landu on 15/11/23.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "CYAvatarBrowser.h"

@implementation CYAvatarBrowser

+(void)showImage:(NSMutableArray *)imgArray AndCount:(NSInteger)count AndFirstImage:(UIImageView *)firstImage
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0;
    [window addSubview:backgroundView];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.pagingEnabled = YES;
    scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * count, 0);
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * imgArray.count, 0);
    scrollView.alpha = 0;
    [backgroundView addSubview:scrollView];
    
    UIImage *image1;
    for (int i = 0; i < imgArray.count; i ++) {
        image1 = [imgArray objectAtIndex:i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, (SCREEN_HEIGHT-image1.size.height*SCREEN_WIDTH/image1.size.width)/2, SCREEN_WIDTH, image1.size.height*SCREEN_WIDTH/image1.size.width)];
        imageView.image = image1;
        [scrollView addSubview:imageView];
    }
    
    CGRect oldframe=[firstImage convertRect:firstImage.bounds toView:window];
    UIImage *image = firstImage.image;
    UIImageView *imgView=[[UIImageView alloc]initWithFrame:oldframe];
    imgView.image = firstImage.image;
    imgView.tag = 1;
    [backgroundView addSubview:imgView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imgView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        scrollView.alpha = 1;
        imgView.alpha = 0;
    }];
    
}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    
    [backgroundView removeFromSuperview];
    backgroundView.alpha = 0;
    
//    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
//    [UIView animateWithDuration:0.3 animations:^{
//        imageView.frame=oldframe;
//        backgroundView.alpha=0;
//    } completion:^(BOOL finished) {
//        [backgroundView removeFromSuperview];
//    }];
}

@end
