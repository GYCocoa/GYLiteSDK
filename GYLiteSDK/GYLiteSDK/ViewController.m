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
    
    [[ZSSqlFileManager shared] zs_saveFolderToSandbox:@"" dbName:@"" progressCallback:^(CGFloat progress) {
        
    } completion:^(BOOL success, NSError * _Nullable error) {
        
    }];
    
}


@end
