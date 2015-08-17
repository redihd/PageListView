//
//  ZqwPageListVIew.h
//  ZqwPageListView
//
//  Created by 朱泉伟 on 15/8/16.
//  Copyright (c) 2015年 ZhuQuanWei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZqwPageListVIew;
typedef UIView *(^LoadViewAtIndexBlock)(NSInteger pageIndex,UIView *dequeueView);
typedef NSInteger(^TotalPagesCountBlock)(void);
typedef void(^PageViewClickBlock)(ZqwPageListVIew *pageListView, NSInteger pageIndex);

@interface ZqwPageListVIew : UIView

@property (nonatomic, readonly) NSInteger numberOfPages;
@property (nonatomic, strong, readonly) NSArray *visibleListViews;
@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, readonly, getter = isDragging) BOOL dragging;
@property (nonatomic, readonly, getter = isDecelerating) BOOL decelerating;
@property (nonatomic, readonly, getter = isScrolling) BOOL scrolling;


@property (nonatomic , copy) LoadViewAtIndexBlock loadViewAtIndexBlock;
@property (nonatomic , copy) TotalPagesCountBlock totalPagesCountBlock;
@property (nonatomic , copy) PageViewClickBlock pageViewClickBlock;

@end
