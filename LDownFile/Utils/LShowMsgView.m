//
//  LShowMsgView.m
//  LRequestPackage
//
//  Created by like on 15/4/6.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "LShowMsgView.h"
#import "MBProgressHUD.h"
@implementation LShowMsgView

/*
 *黑底白字的短暂提示语
 *@param msg:提示的内容，如：登陆成功，正在跳转
 */
+ (void)showMsg:(NSString *)msg
       withView:(UIViewController *)controller
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:controller.view];
    [controller.view addSubview:hud];
    [controller.view bringSubviewToFront:hud];
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = msg;
    [hud show:YES];
    [hud hide:YES afterDelay:3];
    hud = nil;
}
@end
