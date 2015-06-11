//
//  AppDelegate.h
//  GCDDownProject
//
//  Created by YeYe on 15/6/11.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


/**
 *  completionHandler:(void (^)())completionHandler
 */
@property (strong, nonatomic) void (^backgroundURLSessionCompletionHandler)() ;
@end

