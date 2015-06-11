//
//  LDownRequestObject.m
//  NovartisCompliance
//
//  Created by like on 15/5/15.
//  Copyright (c) 2015年 Pactera. All rights reserved.
//

#import "LDownRequestObject.h"
#import "AFURLSessionManager.h"
#import "ObjectUtils.h"
#import "AppDelegate.h"
/**
 *  提示信息
 */
#import "LShowMsgView.h"

/**
 *  静态的单例实例
 */
static LDownRequestObject *_downRequestObject = nil;
/**
 *  设置最大下载任务量
 */
#define LMAXDOWNFILENUMBER 3

@interface LDownRequestObject ()

/**
 *  是否是后台执行 1:前台正常运行  2:进入后台
 */
@property (nonatomic, assign) NSInteger appState;

/**
 *  创建background的session的时候添加的不同标识
 */
@property (nonatomic, assign) NSInteger backgroundSession;

/**
 *  保存NSURLSessionDownloadTask 对象，用于暂停使用
 */
@property (nonatomic, strong) NSMutableDictionary *downLoadTaskDict;
@end


@implementation LDownRequestObject

- (id)init
{
    self = [super init];
    if (self) {
        self.appState = 1;
        //创建通知进入前台和进入后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendBackgroundDownLoad) name:@"complainceSendBackgroundDownLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveDownLoad) name:@"complainceBecomeActiveDownLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveDownResumeDataWithCrash) name:@"complainceSaveResumeDataWithCrash" object:nil];
        
        self.backgroundSession = 1;
        //CoreData
        self.coreDataManager = [[CoreDataManager alloc]init];
        self.downLoadTaskDict = [[NSMutableDictionary alloc]init];
        serialQueue = dispatch_queue_create("complianceDownQueue", DISPATCH_QUEUE_SERIAL);
        
        //声音
        _appPlaySound = [[AppPlaySound alloc]initSystemSoundWithName:@"SentMessage" SoundType:@"caf"];
    }
    return self;
}
/**
 *  建立单例模式
 *
 *  @return LDownRequestObject
 */
+ (LDownRequestObject *)shareDownRequestObject
{
    if (!_downRequestObject) {
        _downRequestObject = [[LDownRequestObject alloc]init];
    }
    return _downRequestObject;
}

/**
 *  添加新的url下载地址
 *
 *  @param urlStr   下载地址
 *  @param fileName 文档的名字
 *  @param fileId 文档的id
 */
- (void)addNewDownUrlToDownArrayWithUrl:(NSString *)urlStr
                           withFileName:(NSString *)fileName
                             withFileId:(NSInteger)fileId
{
    dispatch_async(serialQueue, ^{
        
        @synchronized(self) {
            //判断有没有文件
            if (![self.coreDataManager selectCoreDataOfDownLoadFileWithFileUrl:urlStr]) {
                //插入下载文件
                DownLoadFile *loadFile = [NSEntityDescription insertNewObjectForEntityForName:@"DownLoadFile" inManagedObjectContext:self.coreDataManager.managedObjectContext];
                loadFile.fileName = fileName;
                loadFile.fileId = [NSNumber numberWithInteger:fileId];
                loadFile.fileType = [ObjectUtils cutOutFileTypeWithFilePath:urlStr];
                loadFile.fileUrl = urlStr;
                [self.coreDataManager insertCoreDataWithDownFile:loadFile];
            }
            //如果之前存在于“正在下载”中 不予理会
            DownLoading *downLoading = [self.coreDataManager selectCoreDataWithDownLoadingWithLoadUrl:urlStr];
            if (!downLoading) {
                //如果存在于“准备下载”中 不能插入
                ReadyDownLoad *oldReadyDownLoad = [self.coreDataManager selectCoreDataOfReadyDownLoadWithFileUrl:urlStr];
                if (!oldReadyDownLoad) {
                    //插入准备下载数据
                    ReadyDownLoad *readyDownLoad = [NSEntityDescription insertNewObjectForEntityForName:@"ReadyDownLoad" inManagedObjectContext:self.coreDataManager.managedObjectContext];
                    readyDownLoad.fileUrl = urlStr;
                    
                    [self.coreDataManager insertCoreDataWithReadyDownLoad:readyDownLoad];
                }
                [self moveReadyToStartDownAction];
            }
        }
    });
}

/**
 *  暂停某个url的下载任务
 *
 *  @param urlStr url
 */
- (void)pauseDownFileWithUrl:(NSString *)urlStr
{
//    dispatch_async(serialQueue, ^{
    
        //查看正在下载的dict
        DownLoading *downLoadingModel = [self.coreDataManager selectCoreDataWithDownLoadingWithLoadUrl:urlStr];
        if (downLoadingModel) {
            __block NSURLSessionDownloadTask *downloadTask = [self.downLoadTaskDict objectForKey:downLoadingModel.fileUrl];
            
            [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                
                //            dispatch_async(dispatch_get_main_queue(), ^{
                // 如果是可恢复的下载任务，应该先将数据保存到partialData中，注意在这里不要调用cancel方法
                [self.coreDataManager updateCoreDataWithDownLoadFileWithLoadUrl:urlStr withResumeData:resumeData];
                
                PauseDownLoad *pauseDownLoad = [NSEntityDescription insertNewObjectForEntityForName:@"PauseDownLoad" inManagedObjectContext:self.coreDataManager.managedObjectContext];
                pauseDownLoad.fileUrl = urlStr;
                //移除正在下载数据库
                [self.coreDataManager deleteCoreDataWithDownLoading:downLoadingModel];
                //添加到暂停数据库
                [self.coreDataManager insertCoreDataWithPauseDownLoad:pauseDownLoad];
                
                //创建dict根据url保存数据的进度，然后在调用下载的时候获取
                downloadTask = nil;
                //暂停了某个下载后需要添加一个新的下载
                [self moveReadyToStartDownAction];
                //            });
            }];
        }
//    });
}

/**
 *  添加到正在加载的数组中，执行下载
 *
 *  @return <#return value description#>
 */
- (void)moveReadyToStartDownAction
{
    dispatch_async(serialQueue, ^{
        
        @synchronized(self) {
            NSArray *loadingArray = [self.coreDataManager selectCoreDataWithDownLoading];
            NSArray *readyLoadArray = [self.coreDataManager selectCoreDataOfCountWithReadyDownLoad];
            if ((!loadingArray || [loadingArray count] < LMAXDOWNFILENUMBER) && [readyLoadArray count] > 0) {
                //获取准备数据 插入到正下载
                ReadyDownLoad *readyDownLoad = [self.coreDataManager selectCoreDataWithReadyDownLoad];
                if (readyDownLoad) {
                    DownLoading *downLoading = [NSEntityDescription insertNewObjectForEntityForName:@"DownLoading" inManagedObjectContext:self.coreDataManager.managedObjectContext];
                    downLoading.fileUrl = readyDownLoad.fileUrl;
                    
                    BOOL insertLoadingBool = [self.coreDataManager insertCoreDataWithDownLoading:downLoading];
                    if (insertLoadingBool) {//插入成功，删除准备数据
                        [self.coreDataManager deleteCoreDataWithReadyDownLoad:readyDownLoad];
                    }
                    //执行下载
                    [self downFileRequestWithUrl:downLoading];
                }
            }
        }
    });
}

/**
 *  文件下载
 *  @param urlStr:下载的url
 *  @return
 */
- (void)downFileRequestWithUrl:(DownLoading *)downLoadingModel
{
    dispatch_async(serialQueue, ^{
        
        NSURLSession *session = [self getCurrentSession];
        NSURLSessionDownloadTask *downloadTask = nil;
        //判断暂停数据中是否存在
        PauseDownLoad *pauseDownLoadModel = [self.coreDataManager selectCoreDataWithPauseDownLoadWithLoadUrl:downLoadingModel.fileUrl];
        DownLoadFile *downLoadFile = [self.coreDataManager selectCoreDataWithDownLoadFileWithLoadUrl:downLoadingModel.fileUrl];
        if (pauseDownLoadModel && downLoadFile.fileDownLoadData) {//存在，则继续下载
            downloadTask = [session downloadTaskWithResumeData:downLoadFile.fileDownLoadData];
            //从暂停数据中移除
            [self.coreDataManager deleteCoreDataWithPauseDownLoad:pauseDownLoadModel];
        }else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downLoadingModel.fileUrl]];
            //开始下载
            downloadTask = [session downloadTaskWithRequest:request];
        }
        if (downloadTask) {
            [downloadTask resume];
        }
        
        //判断正在下载的数据库中是否存在，不存在，添加到正在下载的数据库中
        if (![self.coreDataManager selectCoreDataWithDownLoadingWithLoadUrl:downLoadingModel.fileUrl]) {
            [self.coreDataManager insertCoreDataWithDownLoading:downLoadingModel];
        }
        //更新NSURLSessionDownloadTask
        //    [self.coreDataManager updateCoreDataWithDownLoadingWithLoadUrl:downLoadingModel.fileUrl withDownloadTask:downloadTask];
        if (downLoadingModel) {
            [self.downLoadTaskDict setObject:downloadTask forKey:downLoadingModel.fileUrl];
        }
        //传递url
        session.sessionDescription = downLoadingModel.fileUrl;
        
    });
}

/**
 *  下载成功调用:下载成功后的文件移动到我们想要的目标路径
 *
 *  @param session      <#session description#>
 *  @param downloadTask <#downloadTask description#>
 *  @param location     <#location description#>
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL*)location
{
    __block NSString *fileLocPath = nil;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //下载完成之后回调
        NSString *fileName = [ObjectUtils cutOutFileNameWithFilePath:session.sessionDescription];
        //移动文件到docments中
        fileLocPath = [ObjectUtils writeFileWithSourcePath:[[location absoluteString] substringFromIndex:7] withTargetFileName:fileName];
//    });
    dispatch_async(serialQueue, ^{
        
        NSLog(@"NSURL = %@ ---- %@",location,session.sessionDescription);
        //    dispatch_async(dispatch_get_main_queue(), ^{
        if (fileLocPath && fileLocPath.length > 0) {//移动路径成功,添加数据到已下载数据库中
            //获取正在下载数据 放到已经下载数据库中
            DownLoading *downLoadingModel = [self.coreDataManager selectCoreDataWithDownLoadingWithLoadUrl:session.sessionDescription];
            if (downLoadingModel) {//正在下载中有，
                //更新本地路径
                [self.coreDataManager updateCoreDataWithDownLoadFileWithLoadUrl:downLoadingModel.fileUrl withLocPath:fileLocPath];
                
                DownLoaded *downLoaded = [NSEntityDescription insertNewObjectForEntityForName:@"DownLoaded" inManagedObjectContext:self.coreDataManager.managedObjectContext];
                downLoaded.fileUrl = downLoadingModel.fileUrl;
                
                //判断在下载中是否已经存在了,不存在则保存
                if (![self.coreDataManager selectCoreDataOfDownLoadedWithFileUrl:session.sessionDescription]) {
                    [self.coreDataManager insertCoreDataWithDownLoaded:downLoaded];
                }
                //移除正在下载数据库中的
                [self.coreDataManager deleteCoreDataWithDownLoading:downLoadingModel];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //得到此fileurl的文件对象，获取文件名称
            DownLoadFile *downLoadFile = [self.coreDataManager selectCoreDataWithDownLoadFileWithLoadUrl:session.sessionDescription];
            if (downLoadFile) {
                [LShowMsgView showMsg:[NSString stringWithFormat:@"%@ 下载完成",downLoadFile.fileName] withView:[ObjectUtils getCurrentVC]];
                //加入下载完成声音提示
                [_appPlaySound play];
            }
            if (self.downFinishBlock) {
                self.downFinishBlock(session.sessionDescription, 1);//完成进度100%
            }
        });
        //更新当前url的进度:1 成功
        [self.coreDataManager updateCoreDataWithDownLoadingWithLoadUrl:session.sessionDescription withLoadProgress:1];
        //是否有新的添加
        [self moveReadyToStartDownAction];
        //    });
        
        /**
         *  后台下载
         */
        if (self.appState == 2) {
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            if (appDelegate.backgroundURLSessionCompletionHandler) {
                // 执行回调代码块
                void (^handler)() = appDelegate.backgroundURLSessionCompletionHandler;
                appDelegate.backgroundURLSessionCompletionHandler = nil;
                handler();
            }
        }
    });
    session = nil;//nil
    downloadTask = nil;
    
}

/* 完成下载任务，无论下载成功还是失败都调用该方法 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"NSURLSessionDownloadDelegate: Complete task");
    
    dispatch_async(serialQueue, ^{
        
        //    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (error) {
            NSLog(@"下载---失败：%@", error);
            //获取正在下载数据
            DownLoading *downLoadingModel = [self.coreDataManager selectCoreDataWithDownLoadingWithLoadUrl:session.sessionDescription];
            if (downLoadingModel) {
                NSLog(@"下载失败，不再下载");
                //下载当前
//                [self downFileRequestWithUrl:downLoadingModel];
                //根据url 移除正在下载中的object
                [self.coreDataManager deleteCoreDataWithDownLoading:downLoadingModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.downFinishBlock) {
                        self.downFinishBlock(session.sessionDescription, -1);
                    }
                });
            }else {
                //如果暂停下载数据库中存在，说明是手动点击暂停，不回调
                PauseDownLoad *pauseDownLoad = [self.coreDataManager selectCoreDataWithPauseDownLoadWithLoadUrl:session.sessionDescription];
                if (!pauseDownLoad) {
                    //下载失败
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (self.downFinishBlock) {
                            NSLog(@"下载失败，不再下载");
                            self.downFinishBlock(session.sessionDescription, -1);
                        }
                    });
                }
            }
        }
        //如果暂停下载数据库中存在，说明是手动点击暂停，不清空进度
        PauseDownLoad *pauseDownLoad = [self.coreDataManager selectCoreDataWithPauseDownLoadWithLoadUrl:session.sessionDescription];
        if (!pauseDownLoad) {
            //更新当前url的进度:0 下载失败
            [self.coreDataManager updateCoreDataWithDownLoadingWithLoadUrl:session.sessionDescription withLoadProgress:0];
        }
        //    });
        
    });
    session = nil;//nil
    task = nil;
}

/* 执行下载任务时有数据写入 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten // 每次写入的data字节数
 totalBytesWritten:(int64_t)totalBytesWritten // 当前一共写入的data字节数
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite // 期望收到的所有data字节数
{
    dispatch_async(serialQueue, ^{
        
        if (session.sessionDescription) {
            // 计算当前下载进度并更新视图
            double downloadProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
            //下载完成之后回调
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.downFinishBlock && downloadProgress < 1) {
                    self.downFinishBlock(session.sessionDescription, downloadProgress);
                }
            });
            //更新当前url的进度
            [self.coreDataManager updateCoreDataWithDownLoadingWithLoadUrl:session.sessionDescription withLoadProgress:downloadProgress];
        }
    });
}

/* 从fileOffset位移处恢复下载任务 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"NSURLSessionDownloadDelegate: Resume download at %lld", fileOffset);
    // 计算当前下载进度并更新视图
    //更新当前url的进度
    //    [self.downLoadProgressTaskDict setObject:[NSString stringWithFormat:@"%f",downloadProgress] forKey:session.sessionDescription];
}

/**
 *  根据url得到下载进度
 *
 *  @param urlStr url
 *
 *  @return NSMutableArray(progress:下载进度, state: 1:正在下载 2:暂停下载 3:无下载任务 4:已存在 )
 */
- (NSMutableArray *)getProgressOfDownFileWithUrl:(NSString *)urlStr
{
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    DownLoadFile *downLoadFile = [self.coreDataManager selectCoreDataWithDownLoadFileWithLoadUrl:urlStr];
    DownLoading *downLoadingModel = [self.coreDataManager selectCoreDataWithDownLoadingWithLoadUrl:urlStr];
    ReadyDownLoad *readyDownLoadModel = [self.coreDataManager selectCoreDataOfReadyDownLoadWithFileUrl:urlStr];
    PauseDownLoad *pauseDownLoadModel = [self.coreDataManager selectCoreDataWithPauseDownLoadWithLoadUrl:urlStr];
    //添加progress
    NSString *downProgressStr = @"0";
    if (downLoadFile) {
        downProgressStr = [NSString stringWithFormat:@"%f",[downLoadFile.fileProgress doubleValue]];
    }
    [returnArray addObject:downProgressStr];
    
    //state
    if (downLoadingModel || readyDownLoadModel) {//正在下载
        [returnArray addObject:@1];
    }else if (pauseDownLoadModel) {//暂停下载
        [returnArray addObject:@2];
    }else {//3|4
        //本地查找
        NSString *fileName = [ObjectUtils cutOutFileNameWithFilePath:urlStr];
        BOOL isExist = [ObjectUtils judgeIsExistOfFilePath:[ObjectUtils downFolderOfSandBoxPath:fileName]];
        if (isExist) {
            //存在
            [returnArray addObject:@4];
        }else {//不存在
            [returnArray addObject:@3];
        }
    }
    return returnArray;
}

#pragma mark 得到当前的对象----------start----------
/**
 *  得到当前发起下载请求的sesstion
 *
 *  @return NSURLSession
 */
- (NSURLSession *)getCurrentSession
{
    @autoreleasepool {
        if (self.appState == 1) {//正常 | 回到前台
            NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            return [NSURLSession sessionWithConfiguration:defaultConfig delegate:self delegateQueue:nil];
        }else if (self.appState == 2) {//进入后台
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"complainceBackgroundDownLoad%d",self.backgroundSession++]];//设置不一样的标识，否则会使用上一个
            return [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        }
    }
    return nil;
}
#pragma mark ----------end----------得到当前的对象

#pragma mark 进入后台下载----------start----------
/**
 *  接受进入后台的通知
 */
- (void)sendBackgroundDownLoad
{
    [self changeNSURLSessionConfigurationWithRunState:NO];
}
#pragma mark ----------end----------进入后台下载


#pragma mark 进入前台下载----------start----------
/**
 *  接受进入前台的通知
 */
- (void)becomeActiveDownLoad
{
    [self changeNSURLSessionConfigurationWithRunState:YES];
}

/**
 *  进入后台和进入前台的修改
 *
 *  @param runState YES:前台下载 NO:后台下载
 */
- (void)changeNSURLSessionConfigurationWithRunState:(BOOL)runState
{
    dispatch_async(serialQueue, ^{
        
        self.appState = runState?1:2;
        //得到正在下载数据库数据
        NSArray *downLoadingArray = [self.coreDataManager selectCoreDataWithDownLoading];
        for (int i = 0; i < [downLoadingArray count]; i ++) {
            DownLoading *downLoading = [downLoadingArray objectAtIndex:i];
            if (downLoading) {
                __block NSURLSessionDownloadTask *downloadTask = [self.downLoadTaskDict objectForKey:downLoading.fileUrl];
                [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                    // 如果是可恢复的下载任务，应该先将数据保存到partialData中，注意在这里不要调用cancel方法
                    [self.coreDataManager updateCoreDataWithDownLoadFileWithLoadUrl:downLoading.fileUrl withResumeData:resumeData];
                    
                    PauseDownLoad *pauseDownLoad = [NSEntityDescription insertNewObjectForEntityForName:@"PauseDownLoad" inManagedObjectContext:self.coreDataManager.managedObjectContext];
                    pauseDownLoad.fileUrl = downLoading.fileUrl;
                    
                    //移除正在下载数据库
//                    [self.coreDataManager deleteCoreDataWithDownLoading:downLoading];
                    //添加到暂停数据库
                    [self.coreDataManager insertCoreDataWithPauseDownLoad:pauseDownLoad];
                    
                    //创建dict根据url保存数据的进度，然后在调用下载的时候获取
                    downloadTask = nil;
                    
                    //                dispatch_async(dispatch_get_main_queue(), ^{
                    //调用下载
//                    [self downFileRequestWithUrl:downLoading];
                    //                });
                }];
            }
        }
    });
}
#pragma mark ----------end----------进入前台下载

#pragma mark -app退出保存进度
- (void)saveDownResumeDataWithCrash
{
    dispatch_async(serialQueue, ^{
        
        //得到正在下载数据库数据
        NSArray *downLoadingArray = [self.coreDataManager selectCoreDataWithDownLoading];
        for (int i = 0; i < [downLoadingArray count]; i ++) {
            DownLoading *downLoading = [downLoadingArray objectAtIndex:i];
            if (downLoading) {
                __block NSURLSessionDownloadTask *downloadTask = [self.downLoadTaskDict objectForKey:downLoading.fileUrl];
                [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                    // 如果是可恢复的下载任务，应该先将数据保存到partialData中，注意在这里不要调用cancel方法
                    [self.coreDataManager updateCoreDataWithDownLoadFileWithLoadUrl:downLoading.fileUrl withResumeData:resumeData];
                    
                    PauseDownLoad *pauseDownLoad = [NSEntityDescription insertNewObjectForEntityForName:@"PauseDownLoad" inManagedObjectContext:self.coreDataManager.managedObjectContext];
                    pauseDownLoad.fileUrl = downLoading.fileUrl;
                    
                    //移除正在下载数据库
                    [self.coreDataManager deleteCoreDataWithDownLoading:downLoading];
                    //添加到暂停数据库
                    [self.coreDataManager insertCoreDataWithPauseDownLoad:pauseDownLoad];
                    
                    //创建dict根据url保存数据的进度，然后在调用下载的时候获取
                    downloadTask = nil;
                }];
            }
        }
    });
}

/**
 *  开启上一次的正在下载的任务
 */
- (void)startLastDownTask
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), serialQueue, ^{
//        dispatch_async(serialQueue, ^{
            NSArray *lastDownArray = [self.coreDataManager selectCoreDataWithDownLoading];
            if (lastDownArray && [lastDownArray count] > 0) {
                for (DownLoading *downLoading in lastDownArray) {
                    if (downLoading && downLoading.fileUrl) {
                        //下载
                        [self downFileRequestWithUrl:downLoading];
                    }
                }
            }
//        });
    });
}
@end
