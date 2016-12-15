//
//  LCConmentInputView.m
//  TeamTalk
//
//  Created by landu on 15/12/7.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "LCConmentInputView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "UIColor+JSMessagesView.h"
#import "UIView+Addition.h"

#define SEND_BUTTON_WIDTH 78.0f

@interface LCConmentInputView ()<HPGrowingTextViewDelegate>

- (void)setup;
- (void)setupTextView;
@end

@implementation LCConmentInputView
@synthesize sendButton;

#pragma mark - Initialization
-(id)initWithFrame:(CGRect)frame delegate:(id<LCConmentInputViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if(self){
        [self setup];
        _delegate = delegate;
        [self setAutoresizesSubviews:NO];
    }
    
    return self;
}

- (void)dealloc
{
    self.textView = nil;
    self.sendButton = nil;
}

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}

+ (JSInputBarStyle)inputBarStyle
{
    return JSInputBarStyleDefault;
}

#pragma mark - Setup
- (void)setup
{
    self.image = [UIImage inputBar];
    self.backgroundColor = [UIColor whiteColor];
    
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    line.backgroundColor=RGB(188, 188, 188);
    [self addSubview:line];
    
    self.emotionbutton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emotionbutton setBackgroundImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
    //self.emotionbutton.frame=CGRectMake(FULL_WIDTH-36-38, 9.0f, 28.0f, 28.0f);
    self.emotionbutton.frame=CGRectMake(10, 9.0f, 28.0f, 28.0f);
    [self setSendButton:self.emotionbutton];

    
    [self setupTextView];
}

- (void)setupTextView
{
    //    CGFloat width = self.frame.size.width - SEND_BUTTON_WIDTH;
    CGFloat height = [LCConmentInputView textViewLineHeight];
    
    //self.textView = [[HPGrowingTextView  alloc] initWithFrame:CGRectMake(46.0f, 7.0f, self.emotionbutton.frame.origin.x-self.emotionbutton.frame.size.width-30, height)];
    self.textView = [[HPGrowingTextView  alloc] initWithFrame:CGRectMake(50.0f, 7.0f, SCREEN_WIDTH - 80, height)];
    //    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.minHeight = 31;
    self.textView.placeholder = @"评论";
    self.textView.maxNumberOfLines = 5;
    self.textView.animateHeightChange = YES;
    self.textView.animationDuration = 0.25;
    self.textView.delegate = self;
    
    [self.textView.layer setBorderWidth:0.5];
    [self.textView.layer setBorderColor:RGB(188, 188, 188).CGColor];
    [self.textView.layer setCornerRadius:2];
    self.textView.returnKeyType = UIReturnKeySend;
    [self addSubview:self.textView];
}

#pragma mark - HPTextViewDelegate

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqual:@"\n"])
    {
        [self.delegate textViewEnterSend];
        return NO;
    }
    return YES;
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    [self.delegate textViewChanged];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float bottom = self.bottom;
    if ([growingTextView.text length] == 0)
    {
        [self setHeight:height + 13];
    }
    else
    {
        [self setHeight:height + 10];
    }
    [self setBottom:bottom];
    //    [growingTextView setContentInset:UIEdgeInsetsZero];
    //    [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
    //
    //    } completion:^(BOOL finished) {
    //
    //    }];
    [self.delegate viewheightChanged:height];
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return YES;
}

#pragma mark - Setters
- (void)setSendButton:(UIButton *)btn
{
    if(sendButton)
        [sendButton removeFromSuperview];
    
    sendButton = btn;
    [self addSubview:self.sendButton];
}

#pragma mark - Message input view

+ (CGFloat)textViewLineHeight
{
    return 32.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return 5.0f;
}

+ (CGFloat)maxHeight
{
    return ([LCConmentInputView maxLines] + 1.0f) * [LCConmentInputView textViewLineHeight];
}

//- (void)willBeginRecord
//{
//    [self.textView setHidden:YES];
//}
//
//- (void)willBeginInput
//{
//    [self.textView setHidden:NO];
//}
-(void)setDefaultHeight
{
    
}

- (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}




@end
