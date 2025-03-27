#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^ZSProgressCallback)(CGFloat progress);
typedef void (^ZSCompletionCallback)(BOOL success, NSError * _Nullable error);

@interface ZSSqlFileManager : NSObject

+ (instancetype)shared;

/**
 * 将指定文件夹中的所有文件（包括子目录）保存到沙盒
 * @param folderPath 源文件夹路径
 * @param dbName 数据库名称
 */
- (void)zs_saveFolderToSandbox:(NSString *)folderPath dbName:(NSString *)dbName progressCallback:(ZSProgressCallback)progressCallback completion:(ZSCompletionCallback)completion;

/**
 * 从数据库中恢复指定文件夹到沙盒
 * @param folderName 要恢复的文件夹名称
 * @param dbName 数据库名称
 */
- (void)zs_restoreFolderFromSandbox:(NSString *)folderName dbName:(NSString *)dbName isSandbox:(BOOL)isSandbox progressCallback:(ZSProgressCallback)progressCallback completion:(ZSCompletionCallback)completion;

@end


NS_ASSUME_NONNULL_END


