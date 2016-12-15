//
//  LCConmentInputView.h
//  TeamTalk
//
//  Created by landu on 15/12/7.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HPGrowingTextView.h>

typedef enum
{
    JSInputBarStyleDefault,
    JSInputBarStyleFlat
} JSInputBarStyle;


@protocol LCConmentInputViewDelegate <NSObject>
@optional
- (void)viewheightChanged:(float)height;
- (void)textViewEnterSend;
- (void)textViewChanged;

@end

@interface LCConmentInputView : UIImageView<HPGrowingTextViewDelegate>

@property (strong) HPGrowingTextView *textView;
@property (strong) UIButton *sendButton;
@property (strong) UIButton *emotionbutton;


@property (assign) id<LCConmentInputViewDelegate> delegate;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame delegate:(id<LCConmentInputViewDelegate>)delegate;

#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

+ (CGFloat)textViewLineHeight;
+ (CGFloat)maxLines;
+ (CGFloat)maxHeight;
-(void)setDefaultHeight;
+ (JSInputBarStyle)inputBarStyle;
- (void)willBeginRecord;
- (void)willBeginInput;;
@end
