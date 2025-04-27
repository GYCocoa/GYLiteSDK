#import "GYAESUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation GYAESUtil

+ (NSData *)hj_encryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    size_t outLength;
    NSMutableData *cipherData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    CCCryptorStatus result = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     key.bytes, kCCKeySizeAES128, iv.bytes,
                                     data.bytes, data.length,
                                     cipherData.mutableBytes, cipherData.length, &outLength);
    if (result == kCCSuccess) {
        cipherData.length = outLength;
        return cipherData;
    }
    return nil;
}

+ (NSData *)hj_decryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    size_t outLength;
    NSMutableData *clearData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    CCCryptorStatus result = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     key.bytes, kCCKeySizeAES128, iv.bytes,
                                     data.bytes, data.length,
                                     clearData.mutableBytes, clearData.length, &outLength);
    if (result == kCCSuccess) {
        clearData.length = outLength;
        return clearData;
    }
    return nil;
}

+ (NSString *)encryptString:(NSString *)string key:(NSString *)key {
    @try {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        // 生成16字节随机iv
        uint8_t ivBytes[kCCBlockSizeAES128];
        int result = SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, ivBytes);
        if (result != errSecSuccess) return @"";
        NSData *ivData = [NSData dataWithBytes:ivBytes length:kCCBlockSizeAES128];
        NSData *encrypted = [self hj_encryptData:data key:keyData iv:ivData];
        if (!encrypted) return @"";
        // 拼接iv+密文
        NSMutableData *finalData = [NSMutableData dataWithData:ivData];
        [finalData appendData:encrypted];
        return [finalData base64EncodedStringWithOptions:0];
    } @catch (__unused NSException *e) {
        return @"";
    }
}

+ (NSString *)decryptString:(NSString *)base64String key:(NSString *)key {
    @try {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
        if (data.length <= kCCBlockSizeAES128) return @"";
        NSData *ivData = [data subdataWithRange:NSMakeRange(0, kCCBlockSizeAES128)];
        NSData *cipherData = [data subdataWithRange:NSMakeRange(kCCBlockSizeAES128, data.length - kCCBlockSizeAES128)];
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        NSData *decrypted = [self hj_decryptData:cipherData key:keyData iv:ivData];
        if (!decrypted) return @"";
        NSString *plain = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
        return plain ?: @"";
    } @catch (__unused NSException *e) {
        return @"";
    }
}




@end
