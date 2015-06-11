//
//  LDownRequestObject.h
//  NovartisCompliance
//
//  Created by like on 15/5/15.
//  Copyright (c) 2015年 Pactera. All rights reserved.
//
/**
 *  文件下载类
 */
#import <Foundation/Foundation.h>
#import "CoreDataManager.h"
/**
 *  播放声音
 */
#import "AppPlaySound.h"

@interface LDownRequestObject : NSObject<NSURLSessionDelegate>
{
    dispatch_queue_t serialQueue;
    AppPlaySound *_appPlaySound;
}
/**
 *  block回调:用于下载完之后的回调
 *  @param downUrl:当前正在下载的url
 *  @param downProgress:当前文件下载的进度   如果是-1 则是下载失败，重新点击吧
 */
@property (nonatomic, copy) void(^downFinishBlock)(NSString *downUrl, double downProgress);
//@property (strong, nonatomic) NSURLSessionDownloadTask *resumableTask;   // 可恢复的下载任务

/**
 *  建立单例模式
 *
 *  @return LDownRequestObject
 */
+ (LDownRequestObject *)shareDownRequestObject;

/**
 *  添加新的url下载地址
 *
 *  @param urlStr   下载地址
 *  @param fileName 文档的名字
 *  @param fileId 文档的id
 */
- (void)addNewDownUrlToDownArrayWithUrl:(NSString *)urlStr
                           withFileName:(NSString *)fileName
                             withFileId:(NSInteger)fileId;

/**
 *  暂停某个url的下载任务
 *
 *  @param urlStr url
 */
- (void)pauseDownFileWithUrl:(NSString *)urlStr;

/**
 *  根据url得到下载进度+状态
 *
 *  @param urlStr url
 *
 *  @return NSMutableArray(progress:下载进度, state: 1:正在下载 2:暂停下载 3:无下载任务 4:已存在 )
 */
- (NSMutableArray *)getProgressOfDownFileWithUrl:(NSString *)urlStr;


/**
 *  开启上一次的正在下载的任务
 */
- (void)startLastDownTask;

/**
 *  数据库
 */
@property (nonatomic, strong) CoreDataManager *coreDataManager;

@end
