//
//  LShowMsgView.h
//  LRequestPackage
//
//  Created by like on 15/4/6.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LShowMsgView : NSObject

/*
 *黑底白字的短暂提示语
 *@param msg:提示的内容，如：登陆成功，正在跳转
 *@param controller:展示位置的controller
 */
+ (void)showMsg:(NSString *)msg
       withView:(UIViewController *)controller;
@end
