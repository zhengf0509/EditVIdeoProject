//
//  ZFVideoCompositing.m
//  EditVIdeoProject
//
//  Created by 郑峰 on 2022/11/16.
//

#import "ZFVideoCompositing.h"

@interface ZFVideoCompositing ()

@property (nonatomic) dispatch_queue_t renderingQueue;
@property (nonatomic) dispatch_queue_t renderContextQueue;
@property (nonatomic, strong) AVVideoCompositionRenderContext *renderContext;
@property (nonatomic, assign) BOOL shouldCancelAllRequests;

@end



@implementation ZFVideoCompositing

- (instancetype)init {
    self = [super init];
    if (self) {
        _renderContextQueue = dispatch_queue_create("zf.videocore.rendercontextqueue", 0);
        _renderingQueue = dispatch_queue_create("zf.videocore.renderingqueue", 0);
    }
    return self;
}

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
- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext {
    dispatch_sync(self.renderContextQueue, ^{
        self.renderContext = newRenderContext;
//        self.renderContextDidChange = YES;
    });
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
                    NSLog(@"resultPixels is null");
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
