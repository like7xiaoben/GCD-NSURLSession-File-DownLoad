//
//  AppDelegate.m
//  GCDDownProject
//
//  Created by YeYe on 15/6/11.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /**
     *  进入后台后发出通知,切换到后台下载
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:@"complainceSendBackgroundDownLoad" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    /**
     *  进入前台后发出通知,切换到前台下载
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:@"complainceBecomeActiveDownLoad" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /**
     *  退出的时候保存，下载进度
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:@"complainceSaveResumeDataWithCrash" object:nil];
}

//当设备为应用程序分配了太多的内存，操作系统会终止应用程序的运行，在终止前会执行这个方法
//通常可以在这里进行内存清理工作，防止程序被终止
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /**
     *  退出的时候保存，下载进度
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:@"complainceSaveResumeDataWithCrash" object:nil];
    NSLog(@"系统内存不足，需要进行清理工作");
}

/* 后台下载任务完成后，程序被唤醒，该方法将被调用 */
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    NSLog(@"Application Delegate: Background download task finished");
    if ([identifier isEqualToString:@"complainceBackgroundDownLoad"]) {
        NSLog(@"--------complainceBackgroundDownLoad--------");
        // 设置回调的完成代码块
        self.backgroundURLSessionCompletionHandler = completionHandler;
    }
}
@end
