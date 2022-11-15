//
//  ZFPathManager.m
//  EditVIdeoProject
//
//  Created by 郑峰 on 2022/11/15.
//

#import "ZFPathManager.h"

static NSString *const ZFCacheFolderName = @"ZFv1";

@implementation ZFPathManager

+ (NSString *)cachePath {
    static dispatch_once_t onceToken;
    static NSString *s_docPath = nil;
    dispatch_once(&onceToken, ^{
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        s_docPath = [[array firstObject] stringByAppendingPathComponent:ZFCacheFolderName];

        [self createPath:s_docPath];
    });

    return s_docPath;
}

+ (void)createPath:(NSString *)path {
    if (![self isFileExist:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"<%s> failed to create path: %s, error: %s", __FUNCTION__, path.UTF8String, error.description.UTF8String);
    }
}

+ (BOOL)isFileExist:(NSString *)path {
    if (nil != path && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }

    return NO;
}

@end
