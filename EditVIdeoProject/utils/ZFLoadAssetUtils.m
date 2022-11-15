//
//  ZFLoadAssetUtils.m
//  EditVIdeoProject
//
//  Created by 郑峰 on 2022/11/15.
//

#import "ZFLoadAssetUtils.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZFLoadAssetUtils

+ (NSArray<AVAsset *> *)loadAssets {
    // 初始化asset
    NSMutableArray *assetArray = [NSMutableArray array];
    for (int i = 1; i <= 3; i++) {
        NSString *name = [@"test" stringByAppendingFormat:@"%d", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp4"];
        NSURL *url = [NSURL fileURLWithPath:path];
        AVAsset *asset = [AVAsset assetWithURL:url];
        [assetArray addObject:asset];
    }
    return assetArray.copy;
}

@end
