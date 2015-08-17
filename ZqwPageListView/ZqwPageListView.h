//
//  ZqwPageListVIew.h
//  ZqwPageListView
//
//  Created by 朱泉伟 on 15/8/16.
//  Copyright (c) 2015年 ZhuQuanWei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZqwPageListView;
typedef UIView *(^LoadViewAtIndexBlock)(NSInteger pageIndex,UIView *dequeueView);
typedef NSInteger(^TotalPagesCountBlock)(void);
typedef void(^PageViewClickBlock)(ZqwPageListView *pageListView, NSInteger pageIndex);

@interface ZqwPageListView : UIView

@property (nonatomic, readonly) NSInteger numberOfPages;
@property (nonatomic, strong, readonly) NSArray *visibleListViews;
@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, readonly, getter = isDragging) BOOL dragging;
@property (nonatomic, readonly, getter = isDecelerating) BOOL decelerating;
@property (nonatomic, readonly, getter = isScrolling) BOOL scrolling;

- (void)reloadData;
//返回 对应index所需要的View
@property (nonatomic , copy) LoadViewAtIndexBlock loadViewAtIndexBlock;
//返回一共有多少个Page
@property (nonatomic , copy) TotalPagesCountBlock totalPagesCountBlock;
//点击事件
@property (nonatomic , copy) PageViewClickBlock pageViewClickBlock;

@end
