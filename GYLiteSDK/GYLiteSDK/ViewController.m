//
//  ViewController.m
//  GYLiteSDK
//
//  Created by gyz on 2025/3/27.
//

#import "ViewController.h"
#import <GYLiteFramework/GYLiteFramework.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"remote-asset" ofType:nil];
    [[ZSSqlFileManager shared] zs_saveFolderToSandbox:sourcePath dbName:@"zs_file" progressCallback:^(CGFloat progress) {
        
        NSLog(@"%f", progress);
        
    } completion:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"%@", success ? @"成功" : @"失败");

        
    }];
    
    
    [[GYRouter shared] registerRoute:@"111" handler:^id _Nullable(NSDictionary * _Nonnull params) {
        
        NSLog(@"获得注册数据：%@", params);
        
        return @{@"注册成功回调":@"success"};
        
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    id res = [[GYRouter shared] openRoute:@"111" param:@{@"111":@"222"}];
    NSLog(@"res: %@", res);
}





@end
