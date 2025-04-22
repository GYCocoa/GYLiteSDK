// GYRouter.h
// 轻量级路由框架
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 路由回调，param为openRoute传入的参数（可为任意类型）
typedef id _Nullable (^GYRouterHandler)(id param);

@interface GYRouter : NSObject

+ (instancetype)shared;

/// 注册路由（block参数为泛型，类型自定义）
- (void)registerRoute:(NSString *)route handler:(GYRouterHandler)handler;

/// 打开路由（param可为任意类型）
- (id)openRoute:(NSString *)route param:(id)param;

@end

NS_ASSUME_NONNULL_END
