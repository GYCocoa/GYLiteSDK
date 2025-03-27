# ZSAdSDK

### 1.0.x: 老版本SDK
### 1.1.x: 新版本SDK


SDK初始化：

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[ZSAdSDKConfiguration configuration] zs_didFinishLaunchingWithOptions:launchOptions];
}
```

```
    ZSAdSDKConfiguration * config = [ZSAdSDKConfiguration configuration];
    config.productName = @"xxx";
    config.appID = @"xxx";
    config.pkgID = @"xxx";
    config.accessKey = @"xxx";
    config.zs_groupType = xxx;

    [ZSAdSDKManager startWithAsyncAdCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            NSLog(@"初始化SDK成功");
        }
        
    }];
```

SDK获取caid：

```
     [[ZSAdSDKManager shared] zs_requestCaidWithCompleted:^(BOOL success, NSString * _Nonnull caid) {
          if (success) {
          
           }
      }];
```

SDK激励视频：

```
    [[ZSAdSDKManager shared] zs_showVideoWithInfo:str withGameState:^(BOOL state) {
        
        NSLog(@"游戏状态:%@", state ? @"恢复游戏" : @"游戏暂停");
        
        if (state) { // 游戏恢复


        }else{ // 游戏暂停


        }
        
    } withCompleted:^(BOOL success, NSDictionary * _Nullable info) {
        NSLog(@"奖励结果:%@ info:%@", success ? @"获得奖励" : @"未获得奖励", info);

        
    }];
```



SDK插屏：

```
    [[ZSAdSDKManager shared] zs_showInsertWithGameState:^(BOOL state) {
        
        NSLog(@"游戏状态:%@", state ? @"恢复游戏" : @"游戏暂停");

        
    } WithCompleted:^(BOOL success) {
        
        NSLog(@"插屏结果:%@", success ? @"成功" : @"失败");

        
    }];
```

## 一组交互

```
给cocos传初始化参数
+(void)getCommentInfo:(NSString *)str
{
    NSLog(@"%@", str);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *dict = @{}; // 公共参数
        NSString *jsonHead = dict.mj_JSONString;
        NSString *actionName = @"cc.NativeUtils.cocosInitCallback";
        NSString *str = [NSString stringWithFormat:@"%@('%@');",actionName, jsonHead];
        se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}

```
 
```
cocos调用OC交互方法
+ (void)openNativeView:(NSString *)str {}
cocos调用分享
+ (void)shareWeChat:(NSString *)str {}
cocos调用震动
+ (void)businessMethod:(NSString *)str {}
cocos调用退出登录
+ (void)logoutApp:(NSString *)str {}
+ (void)reLoginDialog:(NSString *)str {}
cocos调用copy方法
+ (void)copyText:(NSString *)str {}
cocos调用观看视频广告
+ (void)showVideoAD:(NSString *)str {
    // 看完广告回调
    NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"result"] = @"success";
        dict[@"ecpm"] = @(当前ecpm);
    dispatch_async(dispatch_get_main_queue(), ^{
       NSString *actionName = @"cc.NativeUtils.showVideoAdCallback";
       NSString *str = [NSString stringWithFormat:@"%@('%@');",actionName, dict.mj_JSONString];
       se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}
cocos调用观看插屏广告
+ (void)screenAds:(NSString *)str {}
cocos调用打开客服
+ (void)openKefu:(NSString *)str {}
cocos调用上报
+ (void)sensorHit:(NSString *)str {}
```
    

## 五组交互

```
给cocos传初始化参数
+ (NSString *)callNative:(NSString *)str
{
    if ([str containsString:@"listDeviceInfo"]) {
        NSMutableDictionary *dict = @{}; // 公共参数
        NSString *jsonHead = dict.mj_JSONString;
        return jsonHead;
    }
    
    return nil;
}

```
 
```
cocos调用OC同步方法，不需要回调
+ (void)callNativeAsync:(NSString *)str {}
cocos调用OC异步方法，需要回调
+ (void)callNativeWithCallbackAsync:(NSString *)str {}
```

```
看视频回调
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if (success) {
            NSMutableDictionary *paramters = [[NSMutableDictionary alloc] init];
            paramters[@"result"] = @"success";
            paramters[@"value"] = @(当前ecpm);
            paramters[@"redBag"] = @(redBag);
            dict[@"params"] = paramters;
        }else {
            dict[@"params"] = @{@"result":@"fail"};
        }
        
        dict[@"func"] = @"callNativeVideo";
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *nativeCb = @"cc.NativeUtils.nativeCallbackJs";
            NSString *evalName = [NSString stringWithFormat:@"%@('%@');",nativeCb, dict.mj_JSONString];
            se::ScriptEngine::getInstance()->evalString([evalName UTF8String]);
        });
```


## 七组交互

```
给cocos传初始化参数
+(void)getCommentInfo:(NSString *)str
{
    NSLog(@"%@", str);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *dict = @{}; // 公共参数
        NSString *jsonHead = dict.mj_JSONString;
        NSString *actionName = @"cc.NativeUtils.cocosInitCallback";
        NSString *str = [NSString stringWithFormat:@"%@('%@');",actionName, jsonHead];
        se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}

```
 
```
cocos调用OC交互方法， 对str做加密
+ (void)RsaService:(NSString *)str {
    NSDictionary *dict = str.mj_JSONObject;
    // 使用公共keyMFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMQAooIXEH1Ot3XjE6CHRrsr0xUg068Bpu1kg3YhaHmrPXa4y+TR8c9he72KZeccDwxhb2nsm+HF5rnXv0omPkkCAwEAAQ== 对dict[@"data"]进行RSA加密
    NSString *data = @"加密后的字符串";
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *className = @"cc.NativeUtils.RsaCallback";
        NSString *str = [NSString stringWithFormat:@"%@('%@');",className, data];
        se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}

+ (void)openNativeView:(NSString *)str {}
cocos调用分享
+ (void)shareWeChat:(NSString *)str {}
cocos调用震动
+ (void)deviceVibrate:(NSString *)str {}
cocos调用退出登录
+ (void)logout:(NSString *)str {}
+ (void)logoutApp:(NSString *)str {}
+ (void)unRegist:(NSString *)str {}
cocos打点上报
+ (void)sensorHit:(NSString *)str {}

cocos调用copy方法
+ (void)copyText:(NSString *)str {}
cocos调用观看视频广告
+ (void)showVideoAD:(NSString *)str {
    // 看完广告回调
    NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"result"] = @"success";
        dict[@"ecpm"] = @(当前ecpm);
    dispatch_async(dispatch_get_main_queue(), ^{
       NSString *actionName = @"cc.NativeUtils.showVideoAdCallback";
       NSString *str = [NSString stringWithFormat:@"%@('%@');",actionName, dict.mj_JSONString];
       se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}
cocos调用观看插屏广告
+ (void)screenAds:(NSString *)str {}
cocos调用打开用户协议
+ (void)openAgreement:(NSString *)str {}
cocos调用打开隐私政策
+ (void)openPrivacy:(NSString *)str {}

```


## 七组交互

```
给cocos传初始化参数
+(void)getCommentInfo:(NSString *)str
{
    NSLog(@"%@", str);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *dict = @{}; // 公共参数
        NSString *jsonHead = dict.mj_JSONString;
        NSString *actionName = @"cc.NativeUtils.cocosInitCallback";
        NSString *str = [NSString stringWithFormat:@"%@('%@');",actionName, jsonHead];
        se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}

```
 
```
cocos调用OC交互方法， 对str做加密
+ (void)RsaService:(NSString *)str {
    NSDictionary *dict = str.mj_JSONObject;
    // 使用公共keyMFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMQAooIXEH1Ot3XjE6CHRrsr0xUg068Bpu1kg3YhaHmrPXa4y+TR8c9he72KZeccDwxhb2nsm+HF5rnXv0omPkkCAwEAAQ== 对dict[@"data"]进行RSA加密
    NSString *data = @"加密后的字符串";
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *className = @"cc.NativeUtils.RsaCallback";
        NSString *str = [NSString stringWithFormat:@"%@('%@');",className, data];
        se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}

cocos调用震动
+ (void)deviceVibrate:(NSString *)str {}
cocos调用退出登录
+ (void)logout:(NSString *)str {}
+ (void)logoutApp:(NSString *)str {}
+ (void)unRegist:(NSString *)str {}
cocos打点上报
+ (void)sensorHit:(NSString *)str {}

cocos调用copy方法
+ (void)copyText:(NSString *)str {}
cocos调用观看视频广告
+ (void)showVideoAD:(NSString *)str {
    // 看完广告回调
    NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"result"] = @"success";
        dict[@"ecpm"] = @(当前ecpm);
    dispatch_async(dispatch_get_main_queue(), ^{
       NSString *actionName = @"cc.NativeUtils.showVideoAdCallback";
       NSString *str = [NSString stringWithFormat:@"%@('%@');",actionName, dict.mj_JSONString];
       se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}
cocos调用观看插屏广告
+ (void)screenAds:(NSString *)str {}
cocos调用打开用户协议
+ (void)openAgreement:(NSString *)str {}
cocos调用打开隐私政策
+ (void)openPrivacy:(NSString *)str {}

```



## 十组交互

```
给cocos传初始化参数
+(void)getCommentInfo:(NSString *)str
{
    NSLog(@"%@", str);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *dict = @{}; // 公共参数
        NSString *jsonHead = dict.mj_JSONString;
        NSString *actionName = @"cc.NativeUtils.cocosInitCallback";
        NSString *str = [NSString stringWithFormat:@"%@('%@');",actionName, jsonHead];
        se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}

```
 
```
cocos调用OC交互方法， 对str做加密
+ (void)RsaService:(NSString *)str {
    NSDictionary *dict = str.mj_JSONObject;
    // 使用公共keyMFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMQAooIXEH1Ot3XjE6CHRrsr0xUg068Bpu1kg3YhaHmrPXa4y+TR8c9he72KZeccDwxhb2nsm+HF5rnXv0omPkkCAwEAAQ== 对dict[@"data"]进行RSA加密
    NSString *data = @"加密后的字符串";
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *className = @"cc.NativeUtils.RsaCallback";
        NSString *str = [NSString stringWithFormat:@"%@('%@');",className, data];
        se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}


cocos调用震动
+ (void)deviceVibrate:(NSString *)str {}
cocos调用退出登录
+ (void)logout:(NSString *)str {}
+ (void)unRegist:(NSString *)str {}
cocos打点上报
+ (void)sensorHit:(NSString *)str {}

cocos调用copy方法
+ (void)copyText:(NSString *)str {}
cocos调用观看视频广告
+ (void)showVideoAD:(NSString *)str {
    // 看完广告回调
    NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"result"] = @"success";
        dict[@"ecpm"] = @(当前ecpm);
    dispatch_async(dispatch_get_main_queue(), ^{
       NSString *actionName = @"cc.NativeUtils.showVideoAdCallback";
       NSString *str = [NSString stringWithFormat:@"%@('%@');",actionName, dict.mj_JSONString];
       se::ScriptEngine::getInstance()->evalString([str UTF8String]);
    });
}
cocos调用观看插屏广告
+ (void)screenAds:(NSString *)str {}
cocos调用打开用户协议
+ (void)openAgreement:(NSString *)str {}
cocos调用打开隐私政策
+ (void)openPrivacy:(NSString *)str {}
cocos打开客服
+ (void)openKefu:(NSString *)str {}


```





## Add your files

- [ ] [Create](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) or [upload](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) files
- [ ] [Add files using the command line](https://docs.gitlab.com/ee/gitlab-basics/add-file.html#add-a-file-using-the-command-line) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://gitlab.shinet.top/core-ios/zsadsdk.git
git branch -M main
git push -uf origin main
```


