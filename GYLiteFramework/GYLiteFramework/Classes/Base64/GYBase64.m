//
//  GYBase64.m
//  GYLiteFramework
//
//  Created by gyz on 2025/10/29.
//

#import "GYBase64.h"

@implementation GYBase64


+ (nullable NSString *)base64EncodeString:(NSString *)string {
    if (string.length == 0) { return @""; }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    if (!data) { return nil; }
    return [data base64EncodedStringWithOptions:0];
}

+ (nullable NSString *)base64DecodeString:(NSString *)base64String {
    if (base64String.length == 0) { return @""; }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!data) { return nil; }
    NSString *decoded = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return decoded;
}

+ (nullable NSString *)jsonStringFromObject:(id)obj {
    return [self jsonStringFromObject:obj prettyPrinted:NO error:nil];
}

+ (nullable NSString *)jsonStringFromObject:(id)obj
                             prettyPrinted:(BOOL)pretty
                                     error:(NSError * _Nullable * _Nullable)error {
    if (!obj) { return nil; }
    if (![NSJSONSerialization isValidJSONObject:obj]) {
        // 只允许 NSJSONSerialization 能处理的类型：NSDictionary、NSArray、NSString、NSNumber、NSNull
        if (error) {
            *error = [NSError errorWithDomain:@"OCUtility.JSON"
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"对象无法转换为 JSON，请确认为字典/数组/字符串/数字/NSNull"}];
        }
        return nil;
    }
    NSJSONWritingOptions options = pretty ? NSJSONWritingPrettyPrinted : 0;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:options error:error];
    if (!data) { return nil; }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (nullable id)JSONObjectFromString:(NSString *)jsonString {
    return [self JSONObjectFromString:jsonString error:nil];
}

+ (nullable id)JSONObjectFromString:(NSString *)jsonString
                              error:(NSError * _Nullable * _Nullable)error {
    if (jsonString.length == 0) { return nil; }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) { return nil; }
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingAllowFragments
                                             error:error];
}

+ (nullable id)JSONObjectFromData:(NSData *)jsonData
                            error:(NSError * _Nullable * _Nullable)error {
    if (!jsonData || jsonData.length == 0) { return nil; }
    return [NSJSONSerialization JSONObjectWithData:jsonData
                                           options:NSJSONReadingAllowFragments
                                             error:error];
}






@end
