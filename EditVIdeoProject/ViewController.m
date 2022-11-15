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

@interface ViewController ()

@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property (nonatomic, assign) BOOL shouldCancelAllRequests;
@property (nonatomic, strong) dispatch_queue_t renderingQueue;

@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _renderingQueue = dispatch_queue_create("renderQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    // 初始化asset
//    NSMutableArray *assetArray = [NSMutableArray array];
//    for (int i = 1; i <= 3; i++) {
//        NSString *name = [@"test" stringByAppendingFormat:@"%d", i];
//        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp4"];
//        NSURL *url = [NSURL fileURLWithPath:path];
//        AVAsset *asset = [AVAsset assetWithURL:url];
//        [assetArray addObject:asset];
//    }
//
//    // 1. 创建AVMutableComposition、AVMutableudioMix、和AVAudioMixInputParameters数组
//    AVMutableComposition *composition = [AVMutableComposition composition];
//    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
//    NSMutableArray *audioMixInputParameters = [NSMutableArray array];
//
//    // 2. 插入空的音视频轨道
//    AVMutableCompositionTrack* videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    AVMutableCompositionTrack* audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//
//    // 记录已添加的视频总时间
//    CMTime startTime = kCMTimeZero;
//    CMTime duration = kCMTimeZero;
//    // 拼接视频
//    for (int i = 0; i < assetArray.count; i++) {
//        AVAsset* asset = assetArray[i];
//        AVAssetTrack* videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
//        AVAssetTrack* audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//
//        // 3. 轨道中插入对应的音视频
//        NSError *error;
//        [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:startTime error:&error];
//        if (error) {
//            NSLog(@"videoCompositionTrack error: %s", error.description.UTF8String);
//        }
//        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:startTime error:&error];
//        if (error) {
//            NSLog(@"audioCompositionTrack error: %s", error.description.UTF8String);
//        }
//
//        // 4. 配置原视频的AVMutableAudioMixInputParameters
//        AVMutableAudioMixInputParameters *audioTrackParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
//        // 设置原视频声音音量
//        [audioTrackParameters setVolume:0.3 atTime:kCMTimeZero];
//        [audioMixInputParameters addObject:audioTrackParameters];
//
//        // 拼接时间
//        startTime = CMTimeAdd(startTime, asset.duration);
//        duration = CMTimeAdd(duration, asset.duration);
//    };
//
//    // 5. 添加BGM音频轨道
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"slowdown" ofType:@"mp3"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    AVAsset *bgmAsset = [AVAsset assetWithURL:url];
//    AVMutableCompositionTrack *bgmAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    AVAssetTrack *bgmAssetAudioTrack = [[bgmAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//    [bgmAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack:bgmAssetAudioTrack atTime:kCMTimeZero error:nil];
//    AVMutableAudioMixInputParameters *bgAudioTrackParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:bgmAudioTrack];
//    // 6. 设置背景音乐音量
//    [bgAudioTrackParameters setVolume:0.8 atTime:kCMTimeZero];
//    [audioMixInputParameters addObject:bgAudioTrackParameters];
//    // 7. 设置inputParameters
//    audioMix.inputParameters = audioMixInputParameters;
    
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
    
//    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//    AVMutableVideoComposition *videocomposition = [AVMutableVideoComposition videoCompositionWithAsset:composition applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
//        // 获取源ciimage
//        CIImage *source = request.sourceImage.imageByClampingToExtent;
//        // 添加滤镜
//        [filter setValue:source forKey:kCIInputImageKey];
//        Float64 seconds = CMTimeGetSeconds(request.compositionTime);
//        CIImage *output = [filter.outputImage imageByCroppingToRect:request.sourceImage.extent];
//        [filter setValue:@(5) forKey:kCIInputRadiusKey];
//        // 提交输出
//        [request finishWithImage:output context:nil];
//    }];
//
//    // 使用AVPlayerViewController预览
//    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//    // 使用AVMutableComposition创建AVPlayerItem
//    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:composition];
//    // 8. 将音频混合参数传递给AVPlayerItem
//    playerItem.audioMix = audioMix;
//    playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
//    playerViewController.view.frame = self.view.frame;
//    playerItem.videoComposition = videocomposition;
//    self.playerViewController = playerViewController;
}

#pragma mark - action

- (void)onNormalSpliceBtnPressed {
    ZFSpliceViewController *spliceViewController = [[ZFSpliceViewController alloc] init];
    [self presentViewController:spliceViewController animated:YES completion:nil];
}

- (void)onGaussBlurBtnPressed {
    ZFGaussBlurViewController *gaussBlurViewController = [[ZFGaussBlurViewController alloc] init];
    [self presentViewController:gaussBlurViewController animated:YES completion:nil];
}

- (void)onTransitionBtnPressed {
    ZFTransitionViewController *transitionViewController = [[ZFTransitionViewController alloc] init];
    [self presentViewController:transitionViewController animated:YES completion:nil];
}

#pragma mark - 创建自定义合成器
// 返回源PixelBuffer的属性
- (NSDictionary *)sourcePixelBufferAttributes {
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}
// 返回VideoComposition创建的PixelBuffer的属性
- (NSDictionary *)requiredPixelBufferAttributesForRenderContext {
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}
// 通知切换渲染上下文
- (void)renderContextChanged:(nonnull AVVideoCompositionRenderContext *)newRenderContext {
}
// 开始合成请求
- (void)startVideoCompositionRequest:(nonnull AVAsynchronousVideoCompositionRequest *)request {
    @autoreleasepool {
        dispatch_async(_renderingQueue, ^{
            if (self.shouldCancelAllRequests) {
                // 用于取消合成
                [request finishCancelledRequest];
            } else {
                NSError *err = nil;
                CVPixelBufferRef resultPixels = nil;
                //获取当前合成指令
                id<AVVideoCompositionInstruction> currentInstruction = request.videoCompositionInstruction;
                // 获取指定trackID的轨道的PixelBuffer
                CVPixelBufferRef currentPixelBuffer = [request sourceFrameByTrackID:currentInstruction.passthroughTrackID];
                // 在这里就可以进行自定义的处理了
                resultPixels = currentPixelBuffer; //[self handleByYourSelf:currentPixelBuffer];
                
                if (resultPixels) {
                    CFRetain(resultPixels);
                    // 处理完毕提交处理后的CVPixelBufferRef
                    [request finishWithComposedVideoFrame:resultPixels];
                    CFRelease(resultPixels);
                } else {
                    [request finishWithError:err];
                }
            }
        });
    }
}
// 取消合成请求
- (void)cancelAllPendingVideoCompositionRequests {
    _shouldCancelAllRequests = YES;
    dispatch_barrier_async(_renderingQueue, ^() {
        self.shouldCancelAllRequests = NO;
    });
}

@end
