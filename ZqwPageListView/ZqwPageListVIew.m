//
//  ZqwPageListVIew.m
//  ZqwPageListView
//
//  Created by 朱泉伟 on 15/8/16.
//  Copyright (c) 2015年 ZhuQuanWei. All rights reserved.
//

#import "ZqwPageListVIew.h"

@interface ZqwPageListVIew ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

// 储存可视区域的视图及其index
@property (nonatomic, strong) NSMutableDictionary *visibleListViewsItems;
// 储存可循环的视图
@property (nonatomic, strong) NSMutableSet *dequeueViewPool;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL suppressScrollEvent;
@property (nonatomic, readonly) CGSize pageSize;

@end

@implementation ZqwPageListVIew

#pragma mark -
#pragma mark lazy Load

- (UIScrollView *)scrollView{
    if (nil == _scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.frame;
        _scrollView.delegate = self;
        _scrollView.bounces = _bounces;
        _scrollView.scrollEnabled = _scrollEnabled;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScrollView:)];
        tapGesture.delegate = self;
        [_scrollView addGestureRecognizer:tapGesture];
    }
    return _scrollView;
}

- (BOOL)isDragging
{
    return _scrollView.dragging;
}

- (BOOL)isDecelerating
{
    return _scrollView.decelerating;
}

#pragma mark -
#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _scrollEnabled = YES;
    _bounces = NO;

    self.visibleListViewsItems = [NSMutableDictionary dictionary];
    self.dequeueViewPool = [NSMutableSet set];
    
    [self insertSubview:self.scrollView atIndex:0];
    
    if (self.totalPagesCountBlock) {
        [self reloadData];
    }
}

#pragma mark -
#pragma mark loadView

- (void)layoutSubviews{
    [super layoutSubviews];
    [self updatePageSizeAndCount];
    [self updateScrollViewDimensions];
    [self updateScrollOffset];
    [self loadDequeueViewAndVisibleViewsIfNeeded];
    [self layOutvisibleListViews];
}

- (UIView *)loadViewAtIndex:(NSInteger)index{
    UIView *view = self.loadViewAtIndexBlock(index,[self dequeueView]);
    if (view == nil){
        view = [[UIView alloc] init];
    }
    UIView *oldView = [self itemViewAtIndex:index];
    if (oldView){
        [self queueItemView:oldView];
        [oldView removeFromSuperview];
    }
    
    [self setItemView:view forIndex:index];
    [self setFrameForView:view atIndex:index];
    view.userInteractionEnabled = YES;
    [_scrollView addSubview:view];
    
    return view;
}

- (void)loadDequeueViewAndVisibleViewsIfNeeded{
    CGFloat itemWidth = _pageSize.width;
    if (itemWidth){
        CGFloat width = self.bounds.size.width;
        
        NSInteger startIndex = [self getStartPage];
        NSInteger numberOfVisibleItems = (_scrollView.contentOffset.x/width) == 0.0?1:2;
        
        numberOfVisibleItems = MIN(numberOfVisibleItems, _numberOfPages);
        NSMutableSet *visibleIndices = [NSMutableSet setWithCapacity:numberOfVisibleItems];
        for (NSInteger i = 0; i < numberOfVisibleItems; i++){
            NSInteger index = i + startIndex;
            [visibleIndices addObject:@(index)];
        }
        
        for (NSNumber *number in [_visibleListViewsItems allKeys]){
            if (![visibleIndices containsObject:number]){
                UIView *view = _visibleListViewsItems[number];
                [self queueItemView:view];
                [view removeFromSuperview];
                [_visibleListViewsItems removeObjectForKey:number];
            }
        }
        for (NSNumber *number in visibleIndices){
            UIView *view = _visibleListViewsItems[number];
            if (view == nil){
                [self loadViewAtIndex:[number integerValue]];
            }
        }
    }
}

- (void)layOutvisibleListViews{
    for (UIView *view in self.visibleListViews){
        [self setFrameForView:view atIndex:[self indexOfItemView:view]];
    }
}

- (void)reloadData{
    for (UIView *view in self.visibleListViews){
        [view removeFromSuperview];
    }
    
    self.visibleListViewsItems = [NSMutableDictionary dictionary];
    self.dequeueViewPool = [NSMutableSet set];
    
    [self updatePageSizeAndCount];
    
    [self setNeedsLayout];
}

- (void)updatePageSizeAndCount{
    _numberOfPages = self.totalPagesCountBlock();
    
    CGSize size = self.bounds.size;
    if (!CGSizeEqualToSize(size, CGSizeZero)){
        _pageSize = size;
    }
    else if (_numberOfPages > 0){
        UIView *view = [[self visibleListViews] lastObject] ?: self.loadViewAtIndexBlock(0,[self dequeueView]);
        _pageSize = view.frame.size;
    }
}

#pragma mark -
#pragma mark viewManage

- (UIView *)itemViewAtIndex:(NSInteger)index{
    return _visibleListViewsItems[@(index)];
}

- (void)setItemView:(UIView *)view forIndex:(NSInteger)index{
    ((NSMutableDictionary *)_visibleListViewsItems)[@(index)] = view;
}

- (NSArray *)indexesForVisibleItems{
    return [[_visibleListViewsItems allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)visibleListViews{
    NSArray *indexes = [self indexesForVisibleItems];
    return [_visibleListViewsItems objectsForKeys:indexes notFoundMarker:[NSNull null]];
}

- (NSInteger)indexOfItemView:(UIView *)view{
    NSUInteger index = [[_visibleListViewsItems allValues] indexOfObject:view];
    if (index != NSNotFound){
        return [[_visibleListViewsItems allKeys][index] integerValue];
    }
    return NSNotFound;
}

#pragma mark -
#pragma mark viewLayout

- (void)updateScrollViewDimensions{
    CGSize contentSize = self.frame.size;
    self.scrollView.frame = self.bounds;
    
    contentSize.width = _pageSize.width * _numberOfPages;
    self.scrollView.contentSize = contentSize;
}

- (void)setFrameForView:(UIView *)view atIndex:(NSInteger)index{
    CGPoint center = view.center;
    center.x = (index + 0.5f) * _pageSize.width;
    view.center = center;
}

- (void)updateScrollOffset{
    [self setContentOffsetWithoutEvent:CGPointMake(_scrollView.contentOffset.x, 0.0f)];
}

- (void)setContentOffsetWithoutEvent:(CGPoint)contentOffset
{
    if (!CGPointEqualToPoint(_scrollView.contentOffset, contentOffset))
    {
        BOOL animationEnabled = [UIView areAnimationsEnabled];
        if (animationEnabled) [UIView setAnimationsEnabled:NO];
        _suppressScrollEvent = YES;
        _scrollView.contentOffset = contentOffset;
        _suppressScrollEvent = NO;
        if (animationEnabled) [UIView setAnimationsEnabled:YES];
    }
}

- (NSInteger)currentPageIndex{
    return roundf((float)_scrollView.contentOffset.x / _pageSize.width);
}

- (NSInteger)getStartPage
{
    return floorf((float)_scrollView.contentOffset.x / _pageSize.width);
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex{
    [self.scrollView setContentOffset:CGPointMake(self.frame.size.width*currentPageIndex, 0)];
}

#pragma mark -
#pragma mark View queing

- (void)queueItemView:(UIView *)view{
    if (view){
        [_dequeueViewPool addObject:view];
    }
}

- (UIView *)dequeueView{
    UIView *view = [_dequeueViewPool anyObject];
    if (view){
        [_dequeueViewPool removeObject:view];
    }
    return view;
}

#pragma mark -
#pragma mark scroll

- (void)didScroll{
    [self updateScrollOffset];
    
    [self layOutvisibleListViews];

    [self loadDequeueViewAndVisibleViewsIfNeeded];
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(__unused UIScrollView *)scrollView{
    if (!_suppressScrollEvent){
        _scrolling = NO;
        [self didScroll];
    }
}

- (void)scrollViewWillBeginDragging:(__unused UIScrollView *)scrollView{
    [self didScroll];
}

- (void)scrollViewDidEndDragging:(__unused UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate){
        [self didScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(__unused UIScrollView *)scrollView{
    [self didScroll];
}

#pragma mark -
#pragma mark click

- (void)didTapScrollView:(UITapGestureRecognizer *)tapGesture{
    self.pageViewClickBlock(self,self.currentPageIndex);
}

@end
