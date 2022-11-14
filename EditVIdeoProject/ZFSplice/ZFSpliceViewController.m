//
//  ZFSpliceViewController.m
//  EditVIdeoProject
//
//  Created by 郑峰 on 2022/11/15.
//

#import "ZFSpliceViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ZFSpliceViewController ()

@property (nonatomic, weak) AVPlayerViewController *playerViewController;

@end

@implementation ZFSpliceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化asset
    NSMutableArray *assetArray = [NSMutableArray array];
    for (int i = 1; i <= 3; i++) {
        NSString *name = [@"test" stringByAppendingFormat:@"%d", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp4"];
        NSURL *url = [NSURL fileURLWithPath:path];
        AVAsset *asset = [AVAsset assetWithURL:url];
        [assetArray addObject:asset];
    }
    
    // 1. 创建AVMutableComposition、AVMutableudioMix、和AVAudioMixInputParameters数组
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    NSMutableArray *audioMixInputParameters = [NSMutableArray array];

    // 2. 插入空的音视频轨道
    AVMutableCompositionTrack* videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    // 记录已添加的视频总时间
    CMTime startTime = kCMTimeZero;
    CMTime duration = kCMTimeZero;
    // 拼接视频
    for (int i = 0; i < assetArray.count; i++) {
        AVAsset* asset = assetArray[i];
        AVAssetTrack* videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        AVAssetTrack* audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        // 3. 轨道中插入对应的音视频
        NSError *error;
        [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:startTime error:&error];
        if (error) {
            NSLog(@"videoCompositionTrack error: %s", error.description.UTF8String);
        }
        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:startTime error:&error];
        if (error) {
            NSLog(@"audioCompositionTrack error: %s", error.description.UTF8String);
        }

        // 4. 配置原视频的AVMutableAudioMixInputParameters
        AVMutableAudioMixInputParameters *audioTrackParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        // 设置原视频声音音量
        [audioTrackParameters setVolume:0.1 atTime:kCMTimeZero];
        [audioMixInputParameters addObject:audioTrackParameters];

        // 拼接时间
        startTime = CMTimeAdd(startTime, asset.duration);
        duration = CMTimeAdd(duration, asset.duration);
    };

    // 5. 添加BGM音频轨道
    NSString *path = [[NSBundle mainBundle] pathForResource:@"slowdown" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAsset *bgmAsset = [AVAsset assetWithURL:url];
    AVMutableCompositionTrack *bgmAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *bgmAssetAudioTrack = [[bgmAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [bgmAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack:bgmAssetAudioTrack atTime:kCMTimeZero error:nil];
    AVMutableAudioMixInputParameters *bgAudioTrackParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:bgmAudioTrack];
    // 6. 设置背景音乐音量
    [bgAudioTrackParameters setVolume:0.8 atTime:kCMTimeZero];
    [audioMixInputParameters addObject:bgAudioTrackParameters];
    // 7. 设置inputParameters
    audioMix.inputParameters = audioMixInputParameters;
    // 使用AVPlayerViewController预览
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    // 使用AVMutableComposition创建AVPlayerItem
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:composition];
    // 8. 将音频混合参数传递给AVPlayerItem
    playerItem.audioMix = audioMix;
    playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    playerViewController.view.frame = self.view.frame;
    self.playerViewController = playerViewController;
    
    [self addChildViewController:playerViewController];
    [self.view addSubview:playerViewController.view];
    [playerViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.playerViewController.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playerViewController.player pause];
}

@end
