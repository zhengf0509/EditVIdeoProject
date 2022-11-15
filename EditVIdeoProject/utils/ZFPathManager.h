//
//  ZFPathManager.h
//  EditVIdeoProject
//
//  Created by 郑峰 on 2022/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFPathManager : NSObject

+ (NSString *)cachePath;
+ (void)createPath:(NSString *)path;
+ (BOOL)isFileExist:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
