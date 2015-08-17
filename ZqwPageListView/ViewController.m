//
//  ViewController.m
//  ZqwPageListView
//
//  Created by 朱泉伟 on 15/8/16.
//  Copyright (c) 2015年 ZhuQuanWei. All rights reserved.
//

#import "ViewController.h"
#import "ZqwPageListView.h"

@interface ViewController ()

@property(nonatomic, strong) ZqwPageListView * pageListView;

@end

@implementation ViewController

#pragma mark -
#pragma mark lazy load

- (ZqwPageListView *)pageListView{
    if (nil == _pageListView) {
        _pageListView = [ZqwPageListView new];
        __weak typeof(self) weakSelf = self;
        _pageListView.totalPagesCountBlock = ^NSInteger(void){
            return 60000;
        };
        _pageListView.loadViewAtIndexBlock = ^UIView *(NSInteger pageIndex,UIView *dequeueView){
            UILabel *label = nil;
            if (nil == dequeueView) {
                dequeueView = [[UIView alloc] initWithFrame:self.pageListView.bounds];
                dequeueView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
                label = [[UILabel alloc] initWithFrame:dequeueView.bounds];
                label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                label.backgroundColor = [UIColor clearColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [label.font fontWithSize:90];
                label.tag = 1;
                [dequeueView addSubview:label];
                
            }
            else{
                label = (UILabel *)[dequeueView viewWithTag:1];
                
            }
            dequeueView.backgroundColor = [weakSelf getRandomColor];
            label.text = [NSString stringWithFormat:@"%ld",pageIndex];
            
            return dequeueView;
        };
        _pageListView.pageViewClickBlock = ^(ZqwPageListView *pageListView, NSInteger pageIndex){
            NSLog(@"%zd",pageIndex);
        };

    }
    return _pageListView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.pageListView];
}

- (void)viewDidLayoutSubviews{
    self.pageListView.frame = self.view.bounds;
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark color helper

- (UIColor *)getRandomColor{
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    return  [UIColor colorWithRed:red
                            green:green
                             blue:blue
                            alpha:1.0];
}

@end
