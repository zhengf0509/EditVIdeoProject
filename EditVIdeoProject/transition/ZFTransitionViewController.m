//
//  ZFTransitionViewController.m
//  EditVIdeoProject
//
//  Created by 郑峰 on 2022/11/15.
//

#import "ZFTransitionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVPlayerViewController.h>

@interface ZFTransitionViewController ()

@property (nonatomic, weak) AVPlayerViewController *playerViewController;
@property (nonatomic, strong) NSArray* assets;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, strong) NSMutableArray<AVMutableCompositionTrack*>* videoTracks;

@end

@implementation ZFTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self generateVideo];
}

- (void)generateVideo {
    [self loadAssets];
    AVComposition* composotion = [self configurationComposition];
    AVVideoComposition* videoComposition = [self videoCompositionWithAsset:composotion];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composotion];
    playerItem.videoComposition = videoComposition;
    
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    playerViewController.view.frame = self.view.frame;
    self.playerViewController = playerViewController;
    
    [self addChildViewController:playerViewController];
    [self.view addSubview:playerViewController.view];
    [playerViewController didMoveToParentViewController:self];
}

- (void)loadAssets {
    // 初始化asset
    NSMutableArray *assets = [NSMutableArray array];
    for (int i = 1; i <= 3; i++) {
        NSString *name = [@"test" stringByAppendingFormat:@"%d", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp4"];
        NSURL *url = [NSURL fileURLWithPath:path];
        AVAsset *asset = [AVAsset assetWithURL:url];
        [assets addObject:asset];
    }
    _assets = assets;
}

- (AVComposition*)configurationComposition {
    AVMutableComposition* composition = [AVMutableComposition composition];
    
    CMTime cursorTime = kCMTimeZero;
    CMTime transTime = CMTimeMake(1.0, 1.0);
    for (int i = 0; i < _assets.count; i++) {
        AVMutableCompositionTrack* videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

        AVAsset* asset = _assets[i];
        AVAssetTrack* assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTrack.asset.duration) ofTrack:assetTrack atTime:cursorTime error:nil];
        cursorTime = CMTimeAdd(cursorTime, assetTrack.asset.duration);
        cursorTime = CMTimeSubtract(cursorTime, transTime);
        if(!_videoTracks) {
            _videoTracks = [NSMutableArray array];
        }
        [_videoTracks removeAllObjects];
        [_videoTracks addObject:videoTrack];
    }
    
    return composition;
}

- (AVVideoComposition*)videoCompositionWithAsset:(AVAsset*)asset {
    CMTime cursorTime = kCMTimeZero;
    CMTime transTime = CMTimeMake(1.0, 1.0);
    
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:asset];
    
    NSMutableArray* passThrouTime = [NSMutableArray array];
    NSMutableArray* transitionTime = [NSMutableArray array];
    
    NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    //计算转场时间
    for (int i = 0; i < _assets.count; i++) {
        AVAssetTrack* curTack = [[_assets[i] tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        if (i == 0) {
            [passThrouTime addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(curTack.asset.duration, transTime))]];
            cursorTime = CMTimeAdd(cursorTime, CMTimeSubtract(curTack.asset.duration, transTime));
        } else {
            if(i + 1 < _assets.count) {
                [passThrouTime addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(cursorTime, CMTimeSubtract(CMTimeSubtract(curTack.asset.duration, transTime), transTime))]];
            } else {
                [passThrouTime addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(cursorTime, CMTimeSubtract(curTack.asset.duration, transTime))]];
            }
                
            cursorTime = CMTimeAdd(cursorTime, curTack.asset.duration);
            cursorTime = CMTimeSubtract(cursorTime, transTime);
            cursorTime = CMTimeSubtract(cursorTime, transTime);
        }
        
        if (i + 1 < _assets.count) {
            [transitionTime addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(cursorTime, transTime)]];
            cursorTime = CMTimeAdd(cursorTime, transTime);
        }
    }

    //操作指令 - 溶解
    NSMutableArray* instructions = [NSMutableArray array];
    for (int i = 0; i < passThrouTime.count; i++) {

        AVMutableVideoCompositionInstruction* videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        videoCompositionInstruction.timeRange = [[passThrouTime objectAtIndex:i] CMTimeRangeValue];

        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:tracks[i]];

        videoCompositionInstruction.layerInstructions = @[layerInstruction];

        [instructions addObject:videoCompositionInstruction];

        if (i < transitionTime.count) {

            AVMutableVideoCompositionInstruction* transCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            transCompositionInstruction.timeRange = [[transitionTime objectAtIndex:i] CMTimeRangeValue];

            //第一个媒体透明度重 1.0 到 0.0 逐渐消失
            AVMutableVideoCompositionLayerInstruction* fromLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:tracks[i]];
            [fromLayerInstruction setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:[[transitionTime objectAtIndex:i] CMTimeRangeValue]];

            //第二个媒体透明度重 0.0 到 1.0 逐渐显示
            AVMutableVideoCompositionLayerInstruction* toLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:tracks[i + 1]];
            [toLayerInstruction setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:[[transitionTime objectAtIndex:i] CMTimeRangeValue]];

            transCompositionInstruction.layerInstructions = @[fromLayerInstruction,toLayerInstruction];
            [instructions addObject:transCompositionInstruction];

        }

    }
    
    videoComposition.instructions = instructions;
    //设置分辨率
    videoComposition.renderSize = CGSizeMake(720, 1280);
    //设置视频帧率
    videoComposition.frameDuration = _videoTracks[0].minFrameDuration;
    videoComposition.renderScale = 1.0;
    
    return [videoComposition copy];
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
