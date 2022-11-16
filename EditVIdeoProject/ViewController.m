//
//  ViewController.m
//  EditVIdeoProject
//
//  Created by 郑峰 on 2022/11/14.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVPlayerViewController.h>
#import "ZFSpliceViewController.h"
#import "ZFGaussBlurViewController.h"
#import "ZFTransitionViewController.h"
#import "ZFCustomizeViewController.h"

@interface ViewController ()

@property (nonatomic, strong) AVPlayerViewController *playerViewController;

@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *normalSpliceBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 128, 48)];
    normalSpliceBtn.backgroundColor = [UIColor colorWithRed:0.3 green:0.4 blue:1 alpha:1.0];
    normalSpliceBtn.layer.cornerRadius = 8.0;
    [normalSpliceBtn setTitle:@"普通拼接" forState:UIControlStateNormal];
    [normalSpliceBtn addTarget:self action:@selector(onNormalSpliceBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:normalSpliceBtn];
    
    UIButton *gaussBlurBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 250, 128, 48)];
    gaussBlurBtn.backgroundColor = [UIColor colorWithRed:0.3 green:0.4 blue:1 alpha:1.0];
    gaussBlurBtn.layer.cornerRadius = 8.0;
    [gaussBlurBtn setTitle:@"高斯模糊" forState:UIControlStateNormal];
    [gaussBlurBtn addTarget:self action:@selector(onGaussBlurBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gaussBlurBtn];
    
    UIButton *transitionBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 128, 48)];
    transitionBtn.backgroundColor = [UIColor colorWithRed:0.3 green:0.4 blue:1 alpha:1.0];
    transitionBtn.layer.cornerRadius = 8.0;
    [transitionBtn setTitle:@"转场效果" forState:UIControlStateNormal];
    [transitionBtn addTarget:self action:@selector(onTransitionBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:transitionBtn];
    
    UIButton *customizeBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 350, 128, 48)];
    customizeBtn.backgroundColor = [UIColor colorWithRed:0.3 green:0.4 blue:1 alpha:1.0];
    customizeBtn.layer.cornerRadius = 8.0;
    [customizeBtn setTitle:@"自定义合成" forState:UIControlStateNormal];
    [customizeBtn addTarget:self action:@selector(onCustomizeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customizeBtn];
}

#pragma mark - action

- (void)onNormalSpliceBtnPressed {
    ZFSpliceViewController *spliceViewController = [[ZFSpliceViewController alloc] init];
    [self.navigationController pushViewController:spliceViewController animated:YES];
}

- (void)onGaussBlurBtnPressed {
    ZFGaussBlurViewController *gaussBlurViewController = [[ZFGaussBlurViewController alloc] init];
    [self.navigationController pushViewController:gaussBlurViewController animated:YES];
}

- (void)onTransitionBtnPressed {
    ZFTransitionViewController *transitionViewController = [[ZFTransitionViewController alloc] init];
    [self.navigationController pushViewController:transitionViewController animated:YES];
}

- (void)onCustomizeBtnPressed {
    ZFCustomizeViewController *customizeViewController = [[ZFCustomizeViewController alloc] init];
    [self.navigationController pushViewController:customizeViewController animated:YES];
}

@end
