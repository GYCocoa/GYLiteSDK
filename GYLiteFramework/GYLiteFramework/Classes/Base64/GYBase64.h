//
//  GYBase64.h
//  GYLiteFramework
//
//  Created by gyz on 2025/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYBase64 : NSObject

/// Base64 加密：输入普通字符串，返回 Base64 字符串
+ (nullable NSString *)base64EncodeString:(NSString *)string;

/// Base64 解密：输入 Base64 字符串，返回普通字符串
+ (nullable NSString *)base64DecodeString:(NSString *)base64String;

/// 对象转 JSON 字符串（字典、数组等），默认紧凑输出
+ (nullable NSString *)jsonStringFromObject:(id)obj;

/// 对象转 JSON 字符串，可控制是否 prettyPrinted，并返回错误
+ (nullable NSString *)jsonStringFromObject:(id)obj
                             prettyPrinted:(BOOL)pretty
                                     error:(NSError * _Nullable * _Nullable)error;

/// JSON 字符串转对象（字典、数组或基础值），默认允许 fragments
+ (nullable id)JSONObjectFromString:(NSString *)jsonString;

/// JSON 字符串转对象，并返回错误
+ (nullable id)JSONObjectFromString:(NSString *)jsonString
                              error:(NSError * _Nullable * _Nullable)error;

/// JSON 数据转对象，并返回错误（有时你直接拿到 NSData）
+ (nullable id)JSONObjectFromData:(NSData *)jsonData
                            error:(NSError * _Nullable * _Nullable)error;





@end

NS_ASSUME_NONNULL_END
