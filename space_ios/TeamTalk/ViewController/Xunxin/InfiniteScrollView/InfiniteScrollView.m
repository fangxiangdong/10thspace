//
//  InfiniteScrollView.m
//  无限轮播器
//
//  Created by 杨晓明 on 16/5/7.
//  Copyright © 2016年 杨晓明. All rights reserved.
//

#import "InfiniteScrollView.h"
#import "UIImageView+WebCache.h"

#pragma mark - -------
#pragma mark - 展示图片的cell

@interface ImageCell: UICollectionViewCell

@property (weak, nonatomic) UIImageView *imageView;

@end

@implementation ImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end


#pragma mark - -------
#pragma mark - 分割线


@interface InfiniteScrollView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic)   UICollectionView *collectionView;
@property (weak, nonatomic)   NSTimer *timer;
@property (weak, nonatomic)   UIPageControl *pageControl;

@end


// --------
static NSString *const cellID = @"cellID";
static NSInteger MyItemCount = 20;

@implementation InfiniteScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // 创建流水布局
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        
        // 创建添加scrollView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        // 注册cell
        [collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:cellID];
        
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.currentPage = 0;
        pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:14.0/255.0 green:207.0/255.0 blue:49.0/255.0 alpha:1.0];
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        
        
        // 设置占位图片
        self.placeholderImage = [UIImage imageNamed:@"InfiniteScrollView.bundle/placeholder"];
    }
    return self;
}

- (void)setImagesArray:(NSArray *)imagesArray
{
    _imagesArray = imagesArray;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 让图片显示到scrollView的中间
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(MyItemCount * imagesArray.count) / 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        // 页数
        self.pageControl.numberOfPages = imagesArray.count;
    });
    
    // 开始定时器
    [self startTimer];
}

// 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = self.bounds.size;
    
    self.pageControl.frame = CGRectMake(0, self.frame.size.height - 15, self.frame.size.width, 10);
}

#pragma mark - 其它

// 重置位置到中间
- (void)resetPositionToMid
{
    // 滚动完毕时，自动显示最中间的cell
    NSInteger oldItem = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    NSInteger newItem = (MyItemCount * self.imagesArray.count / 2) + (oldItem % self.imagesArray.count);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newItem inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    self.pageControl.currentPage = newItem % 50;
}

#pragma mark - 定时器事件

// 开启定时器
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.5 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    
    // 添加到主运行循环中
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

// 暂停
- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

// 计算下一页
- (void)nextPage
{
    CGPoint offset = self.collectionView.contentOffset;
    offset.x += self.collectionView.frame.size.width;
    
    [self.collectionView setContentOffset:offset animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MyItemCount * self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 从缓存池中取
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    // 让取到的数据始终是在数组图片中的图片
    id data = self.imagesArray[indexPath.item % self.imagesArray.count];
    
    // 判断类型
    if ([data isKindOfClass:[UIImage class]]) {
        cell.imageView.image = data;
    }else if ([data isKindOfClass:[NSURL class]]) {
        [cell.imageView sd_setImageWithURL:data placeholderImage:self.placeholderImage];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

// 点击cell的时候
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 代理做事
    if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didClickImageAtIndex:)]) {
        [self.delegate infiniteScrollView:self didClickImageAtIndex:indexPath.item];
    }
}

// 即将开始拖拽的时候
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 停止定时器
    [self stopTimer];
}

// 停止拖拽的时候
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 开启定时器
    [self startTimer];
}

// 滚动完毕的时候
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 重置位置到中间
    [self resetPositionToMid];
}

// 滚动完成的时候(认为滚动)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 重置位置到中间
    [self resetPositionToMid];
}

@end
