//
//  AppDelegate.m
//  Example
//
//  Created by Jakub Truhlar on 28.09.16.
//  Copyright © 2016 Jakub Truhlář. All rights reserved.
//

#import "AppDelegate.h"
#import "AFHTTPSessionManager+RetryPolicy.h"

static NSString * const kTestURL = @"http://httpbin.org/get";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
    UIViewController *viewController = [UIViewController new];
    viewController.view.backgroundColor = [UIColor purpleColor];
    [UIApplication sharedApplication].delegate.window.rootViewController = viewController;
    
    // App Transport Security will block this request since App transport security settings is not set. You will see how retry logic working in log.
    [self exampleGETRequest];
    return YES;
}

- (void)exampleGETRequest {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    manager.retryPolicyLogMessagesEnabled = true;
    [manager GET:kTestURL parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Success");
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failure");
        
    } retryCount:5 retryInterval:2.0 progressive:false fatalStatusCodes:nil];
}

@end
