
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYAESUtil : NSObject

/// AES128 CBC 加密字符串（Base64输出） key：16位字符串
+ (NSString *)encryptString:(NSString *)string key:(NSString *)key;
/// AES128 CBC 解密字符串（Base64输入）key：16位字符串
+ (NSString *)decryptString:(NSString *)base64String key:(NSString *)key;



@end

NS_ASSUME_NONNULL_END
