//
//  ViewController.m
//  ZqwPageListView
//
//  Created by 朱泉伟 on 15/8/16.
//  Copyright (c) 2015年 ZhuQuanWei. All rights reserved.
//

#import "ViewController.h"
#import "ZqwPageListVIew.h"

@interface ViewController ()

@property(nonatomic, strong) ZqwPageListVIew * pageListView;

@end

@implementation ViewController

#pragma mark -
#pragma mark lazy load

- (ZqwPageListVIew *)pageListView{
    if (nil == _pageListView) {
        _pageListView = [ZqwPageListVIew new];
        _pageListView.totalPagesCountBlock = ^NSInteger(void){
            return 6;
        };
        __weak typeof(self) weakSelf = self;
        _pageListView.loadViewAtIndexBlock = ^UIView *(NSInteger pageIndex,UIView *dequeueView){
            UILabel *label = nil;
            NSLog(@"%zd  %zd",pageIndex,weakSelf.pageListView.currentPageIndex);
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
            
            CGFloat red = arc4random() / (CGFloat)INT_MAX;
            CGFloat green = arc4random() / (CGFloat)INT_MAX;
            CGFloat blue = arc4random() / (CGFloat)INT_MAX;
            dequeueView.backgroundColor = [UIColor colorWithRed:red
                                                          green:green
                                                           blue:blue
                                                          alpha:1.0];
            label.text = [NSString stringWithFormat:@"%ld",pageIndex];
            
            return dequeueView;
        };
        _pageListView.pageViewClickBlock = ^(ZqwPageListVIew *pageListView, NSInteger pageIndex){
            NSLog(@"%zd",pageIndex);
        };

    }
    return _pageListView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.pageListView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidLayoutSubviews{
    self.pageListView.frame = self.view.bounds;
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
