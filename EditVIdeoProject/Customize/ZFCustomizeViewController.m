//
//  ZFCustomizeViewController.m
//  EditVIdeoProject
//
//  Created by 郑峰 on 2022/11/16.
//

#import "ZFCustomizeViewController.h"
#import <AVKit/AVPlayerViewController.h>
#import "ZFVideoCompositing.h"

@interface ZFCustomizeViewController ()

@property (nonatomic, weak) AVPlayerViewController *playerViewController;

@end

@implementation ZFCustomizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    NSMutableArray *audioMixInputParameters = [NSMutableArray array];
    AVMutableCompositionTrack* videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test3" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetTrack* videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack* audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSError *error;
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:&error];
    
    AVMutableAudioMixInputParameters *audioTrackParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    [audioTrackParameters setVolumeRampFromStartVolume:0 toEndVolume:1 timeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
    [audioMixInputParameters addObject:audioTrackParameters];
    audioMix.inputParameters = audioMixInputParameters;
    
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:asset];
    videoComposition.renderSize = CGSizeMake(720, 1280);
    videoComposition.customVideoCompositorClass = ZFVideoCompositing.class;
    videoComposition.frameDuration = videoTrack.minFrameDuration;
    videoComposition.renderScale = 1.0;
    
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:composition];
    playerItem.audioMix = audioMix;
    playerItem.videoComposition = videoComposition;
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
