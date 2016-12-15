//
//  BlogImageTableViewCell.m
//  TeamTalk
//
//  Created by landu on 15/11/17.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "BlogImageTableViewCell.h"


@interface BlogImageTableViewCell()
{
    UIView *photoView;
    UIImageView *addimgView;
}
@end

@implementation BlogImageTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        [self initPhotoView:nil];
        
    }
    return self;
}

-(void)setBlogModel:(BlogImageModel *)blogModel
{
    if(!blogModel){
        return;
    }
    _blogModel = blogModel;

    [self initPhotoView:blogModel.imgArray];
    [self refreshPhotoViewWithCount:(int)blogModel.imgArray.count];
    
    
    photoView.frame = CGRectMake(8, 10, SCREEN_WIDTH - 20, blogModel.photoViewHeight);
}

-(void)initPhotoView:(NSMutableArray*)array;
{
    float x = SCREEN_WIDTH - 20;
    
    photoView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, x, x/4 * 3)];
    photoView.backgroundColor = [UIColor whiteColor];
    [self addSubview:photoView];
    
    for(int i = 0;i < 3; i++){
        for(int j = 0;j < 4; j++){
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(4 + (x/4 * j),4 + (x/4 * i), (x/4) - 8, (x/4) - 8)];
            imgView.userInteractionEnabled = YES;
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds = YES;
            int index = 4 * i + j;
            imgView.tag = index + 10;
            if(array.count > index){
                imgView.image = [array objectAtIndex:index];
            }
            [photoView addSubview:imgView];
            
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
            [imgView addGestureRecognizer:imageTap];
        }
    }

    
    // 添加图片按钮
    NSInteger index = array.count;
    NSInteger index_x = index/4;
    NSInteger index_y = index%4;
    
    
    addimgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    addimgView.frame = CGRectMake(4 + (x/4 * index_y), 4 + (x/4 * index_x), (x/4) - 8, (x/4) - 8);
    addimgView.image = [UIImage imageNamed:@"add.png"];
    addimgView.userInteractionEnabled = YES;
    [photoView addSubview:addimgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [addimgView addGestureRecognizer:tap];
    
    if(array.count == 9){
        addimgView.alpha = 0;
    }
    else{
        addimgView.alpha = 1;
    }
    
}

-(void)imageTap:(UITapGestureRecognizer*)t
{
    UIImageView *img = (UIImageView*)t.view;
    NSInteger count = img.tag - 10;
    
    
    if([self.delegate respondsToSelector:@selector(clickImage:)]){
        [_delegate clickImage:count - 10];
    }
    
    if (img.image == nil) return;
    
    [CYAvatarBrowser showImage:[[PublishInfoViewController shareInstance] dataArray] AndCount:count AndFirstImage:img];
}

- (void)refreshPhotoViewWithCount:(int)count
{
    float x = SCREEN_WIDTH - 20;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 4; j++) {
            int index = 4 * i + j;
            UIView * v = [photoView viewWithTag:index+10];
            if (count <= index) {
                // 隐藏UIImageView
                v.frame = CGRectZero;
            }else{
                // 显示
                v.frame = CGRectMake(4 + (x/4 * j),4 + (x/4 * i), (x/4) - 8, (x/4) - 8);
            }
        }
    }
}

-(void)tapClick
{
    if(_delegate && [_delegate respondsToSelector:@selector(addImage)]){
        [_delegate addImage];
    }
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
