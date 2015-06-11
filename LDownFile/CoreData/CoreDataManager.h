//
//  CoreDataManager.h
//  NovartisCompliance
//
//  Created by like on 15/5/23.
//  Copyright (c) 2015年 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DownLoaded.h"
#import "DownLoadFile.h"
#import "DownLoading.h"
#import "ReadyDownLoad.h"
#import "PauseDownLoad.h"

@interface CoreDataManager : NSObject
{
    dispatch_queue_t coredata_queue;
}
/**
 *  CoreData
 */
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  插入文件数据
 *
 *  @param downFileModel <#downFileModel description#>
 */
- (void)insertCoreDataWithDownFile:(DownLoadFile *)downFileModel;

/**
 *  插入准备下载数据
 *
 *  @param readyModel <#readyModel description#>
 */
- (void)insertCoreDataWithReadyDownLoad:(ReadyDownLoad *)readyModel;
/**
 *  插入正在下载数据
 *
 *  @param loadingModel <#loadingModel description#>
 */
- (BOOL)insertCoreDataWithDownLoading:(DownLoading *)loadingModel;
/**
 *  插入暂停下载数据
 *
 *  @param pauseDownModel <#pauseDownModel description#>
 */
- (void)insertCoreDataWithPauseDownLoad:(PauseDownLoad *)pauseDownModel;
/**
 *  插入已经下载数据
 *
 *  @param loadedModel <#loadedModel description#>
 */
- (void)insertCoreDataWithDownLoaded:(DownLoaded *)loadedModel;


/**
 *  删除准备下载数据
 *
 *  @param readyModel <#readyModel description#>
 */
- (void)deleteCoreDataWithReadyDownLoad:(ReadyDownLoad *)readyModel;
/**
 *  删除正在下载数据
 *
 *  @param loadingModel <#loadingModel description#>
 */
- (void)deleteCoreDataWithDownLoading:(DownLoading *)loadingModel;
/**
 *  删除暂停下载数据
 *
 *  @param pauseDownModel <#pauseDownModel description#>
 */
- (void)deleteCoreDataWithPauseDownLoad:(PauseDownLoad *)pauseDownModel;
/**
 *  根据url 删除已经下载数据
 *
 *  @param fileUrl <#fileUrl description#>
 */
- (void)deleteCoreDataWithFileUrl:(NSString *)fileUrl;

/**
 *  删除已经下载数据
 *
 *  @param loadedModelArray <#loadedModelArray description#>
 */
- (void)deleteCoreDataWithDownLoaded:(NSArray *)loadedModelArray;

/**
 *  删除文件数据表中的数据
 *
 *  @param fileUrl <#fileUrl description#>
 */
- (void)deleteCoreDataOfDownLoadFileWithFileUrl:(NSString *)fileUrl;

/**
 *  查询文件数据表中是否有此文件
 *
 *  @param fileUrl url
 *
 *  @return <#return value description#>
 */
- (BOOL)selectCoreDataOfDownLoadFileWithFileUrl:(NSString *)fileUrl;

/**
 *  查询已经下载的文件列表
 */
- (NSArray *)selectCoreDataWithDownLoaded;

/**
 *  查找某url是否在已下载的数据库中
 *
 *  @param fileUrl url
 *
 *  @return <#return value description#>
 */
- (BOOL)selectCoreDataOfDownLoadedWithFileUrl:(NSString *)fileUrl;

/**
 *  查询准备下载的某条数据
 *
 *  @return <#return value description#>
 */
- (ReadyDownLoad *)selectCoreDataWithReadyDownLoad;

/**
 *  查询准备下载的数据表中是否有fileurl这条数据
 *
 *  @param fileUrl <#fileUrl description#>
 *
 *  @return <#return value description#>
 */
- (ReadyDownLoad *)selectCoreDataOfReadyDownLoadWithFileUrl:(NSString *)fileUrl;

/**
 *  查询准备下载数据库中的条数
 *
 *  @return <#return value description#>
 */
- (NSArray *)selectCoreDataOfCountWithReadyDownLoad;

/**
 *  查询正在下载数据库中的条数
 *
 *  @return <#return value description#>
 */
- (NSArray *)selectCoreDataWithDownLoading;

/**
 *  查询暂停数据中是否存在某个url
 *
 *  @param loadUrl 下载的url
 *
 *  @return <#return value description#>
 */
- (PauseDownLoad *)selectCoreDataWithPauseDownLoadWithLoadUrl:(NSString *)loadUrl;

/**
 *  查询正在下载数据库中是否有某个url数据
 *
 *  @param loadUrl 下载的url地址
 *
 *  @return <#return value description#>
 */
- (DownLoading *)selectCoreDataWithDownLoadingWithLoadUrl:(NSString *)loadUrl;

/**
 *  查询文件数据库中是否有某个url数据
 *
 *  @param loadUrl url
 *
 *  @return <#return value description#>
 */
- (DownLoadFile *)selectCoreDataWithDownLoadFileWithLoadUrl:(NSString *)loadUrl;

/**
 *  查询文件数据库中的个数
 *
 *  @return <#return value description#>
 */
- (NSArray *)selectCoreDataWithDownLoadFile;

/**
 *  更新正在下载数据库中的下载进度
 *
 *  @param loadUrl  下载的url地址
 *  @param progress 进度 double
 */
- (void)updateCoreDataWithDownLoadingWithLoadUrl:(NSString *)loadUrl withLoadProgress:(double)progress;

/**
 *  更新正在下载数据库中的实现下载的实例对象
 *
 *  @param loadUrl      下载的url地址
 *  @param downLoadTask NSURLSessionDownloadTask 对象
 */
//- (void)updateCoreDataWithDownLoadingWithLoadUrl:(NSString *)loadUrl withDownloadTask:(id)downLoadTask;

/**
 *  更新文件数据库中的下载进度数据
 *
 *  @param loadUrl    url
 *  @param resumeData 已经下载的进度数据
 */
- (void)updateCoreDataWithDownLoadFileWithLoadUrl:(NSString *)loadUrl withResumeData:(NSData *)resumeData;

/**
 *  更新文件数据库中的本地文件路径
 *
 *  @param loadUrl <#loadUrl description#>
 *  @param locPath <#locPath description#>
 */
- (void)updateCoreDataWithDownLoadFileWithLoadUrl:(NSString *)loadUrl withLocPath:(NSString *)locPath;
@end
