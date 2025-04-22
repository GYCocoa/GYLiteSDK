// GYRouter.m
// 轻量级路由框架实现
#import "GYRouter.h"

@interface GYRouter ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, GYRouterHandler> *routeMap;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@end

@implementation GYRouter

+ (instancetype)shared
{
    static GYRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[GYRouter alloc] init];
    });
    return router;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _routeMap = [NSMutableDictionary dictionary];
        _syncQueue = dispatch_queue_create("com.gy.router.sync", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - 路由注册
- (void)registerRoute:(NSString *)route handler:(GYRouterHandler)handler {
    if (![route isKindOfClass:[NSString class]] || route.length == 0 || !handler) {
        NSLog(@"[GYRouter] 注册路由失败: 路由名或回调无效");
        return;
    }
    dispatch_barrier_async(self.syncQueue, ^{
        self.routeMap[route] = [handler copy];
    });
}

#pragma mark - 路由打开
- (id)openRoute:(NSString *)route param:(id)param {
    if (![route isKindOfClass:[NSString class]] || route.length == 0) {
        NSLog(@"[GYRouter] 打开路由失败: 路由名无效");
        return nil;
    }
    __block GYRouterHandler handler = nil;
    dispatch_sync(self.syncQueue, ^{
        handler = self.routeMap[route];
    });
    if (!handler) {
        NSLog(@"[GYRouter] 未找到路由: %@", route);
        return nil;
    }
    id result = nil;
    @try {
        result = handler(param);
    } @catch (NSException *exception) {
        NSLog(@"[GYRouter] 路由执行异常: %@ %@", route, exception);
    }
    return result;
}

#pragma mark - 调试与辅助
- (void)printAllRoutes {
    NSLog(@"[GYRouter] 已注册路由: %@", self.routeMap.allKeys);
}

@end
