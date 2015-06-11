//
//  CoreDataManager.m
//  NovartisCompliance
//
//  Created by like on 15/5/23.
//  Copyright (c) 2015年 Pactera. All rights reserved.
//

#import "CoreDataManager.h"
#import "ObjectUtils.h"


@implementation CoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init
{
    self = [super init];
    if (self) {
        coredata_queue = dispatch_queue_create("com.whatever.you.want.for.data-access", NULL);
    }
    return self;
}
#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ComplianceDownFile" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath:[ObjectUtils sandBoxPath:@"ComplianceDownFile.sqlite"]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark -Core Data insert delete update select
/**
 *  插入文件数据
 *
 *  @param downFileModel <#downFileModel description#>
 */
- (void)insertCoreDataWithDownFile:(DownLoadFile *)downFileModel
{
    @synchronized(self) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}

/**
 *  插入准备下载数据
 *
 *  @param readyModel <#readyModel description#>
 */
- (void)insertCoreDataWithReadyDownLoad:(ReadyDownLoad *)readyModel
{
    @synchronized(self) {
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}
/**
 *  插入正在下载数据
 *
 *  @param loadingModel <#loadingModel description#>
 */
- (BOOL)insertCoreDataWithDownLoading:(DownLoading *)loadingModel
{
    @synchronized(self) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
            return NO;
        }
        return YES;
    }
}
/**
 *  插入暂停下载数据
 *
 *  @param pauseDownModel <#pauseDownModel description#>
 */
- (void)insertCoreDataWithPauseDownLoad:(PauseDownLoad *)pauseDownModel
{
    @synchronized(self) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}
/**
 *  插入已经下载数据
 *
 *  @param loadedModel <#loadedModel description#>
 */
- (void)insertCoreDataWithDownLoaded:(DownLoaded *)loadedModel
{
    @synchronized(self) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}

/**
 *  删除准备下载数据
 *
 *  @param readyModel <#readyModel description#>
 */
- (void)deleteCoreDataWithReadyDownLoad:(ReadyDownLoad *)readyModel
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:readyModel];
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}
/**
 *  删除正在下载数据
 *
 *  @param loadingModel <#loadingModel description#>
 */
- (void)deleteCoreDataWithDownLoading:(DownLoading *)loadingModel
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:loadingModel];
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}
/**
 *  删除暂停下载数据
 *
 *  @param pauseDownModel <#pauseDownModel description#>
 */
- (void)deleteCoreDataWithPauseDownLoad:(PauseDownLoad *)pauseDownModel
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:pauseDownModel];
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}
/**
 *  根据url 删除已经下载数据
 *
 *  @param fileUrl <#fileUrl description#>
 */
- (void)deleteCoreDataWithFileUrl:(NSString *)fileUrl
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoaded" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",fileUrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        DownLoaded *downLoaded = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
        if (downLoaded) {
            [context deleteObject:downLoaded];
        }
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}
/**
 *  删除已经下载数据
 *
 *  @param loadedModelArray <#loadedModelArray description#>
 */
- (void)deleteCoreDataWithDownLoaded:(NSArray *)loadedModelArray
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        for (DownLoaded *downLoaded in loadedModelArray) {
            [context deleteObject:downLoaded];
        }
        NSError *error;
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}

/**
 *  删除文件数据表中的数据
 *
 *  @param fileUrl <#fileUrl description#>
 */
- (void)deleteCoreDataOfDownLoadFileWithFileUrl:(NSString *)fileUrl
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoadFile" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",fileUrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        DownLoadFile *downLoadFile = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
        if (downLoadFile) {
            [context deleteObject:downLoadFile];
        }
        if(![context save:&error]) {
            NSLog(@"ReadyDownLoad-不能保存：%@",[error localizedDescription]);
        }
    }
}

/**
 *  查询文件数据表中是否有此文件
 *
 *  @param fileUrl url
 *
 *  @return <#return value description#>
 */
- (BOOL)selectCoreDataOfDownLoadFileWithFileUrl:(NSString *)fileUrl
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoadFile" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",fileUrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        NSArray *fileArray = [context executeFetchRequest:fetchRequest error:&error];
        if (fileArray && [fileArray count] > 0) {
            return YES;
        }
        return NO;
    }
}

/**
 *  查询已经下载的文件列表
 */
- (NSArray *)selectCoreDataWithDownLoaded
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoaded" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        NSMutableArray *resultArray = [NSMutableArray array];
        
        for (DownLoaded *downLoaded in fetchedObjects) {
            [resultArray addObject:downLoaded];
        }
        return resultArray;
    }
}

/**
 *  查找某url是否在已下载的数据库中
 *
 *  @param fileUrl url
 *
 *  @return <#return value description#>
 */
- (BOOL)selectCoreDataOfDownLoadedWithFileUrl:(NSString *)fileUrl
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoaded" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",fileUrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        NSArray *downLoadedArray = [context executeFetchRequest:fetchRequest error:&error];
        if (downLoadedArray && [downLoadedArray count] > 0) {
            return YES;
        }
        return NO;
    }
}

/**
 *  查询准备下载的某条数据
 *
 *  @return <#return value description#>
 */
- (ReadyDownLoad *)selectCoreDataWithReadyDownLoad
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReadyDownLoad" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects && [fetchedObjects count] > 0) {
            return [fetchedObjects objectAtIndex:0];
        }
        return nil;
    }
}

/**
 *  查询准备下载的数据表中是否有fileurl这条数据
 *
 *  @param fileUrl <#fileUrl description#>
 *
 *  @return <#return value description#>
 */
- (ReadyDownLoad *)selectCoreDataOfReadyDownLoadWithFileUrl:(NSString *)fileUrl
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReadyDownLoad" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",fileUrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        ReadyDownLoad *readyDownLoad = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
        if (readyDownLoad) {
            return readyDownLoad;
        }else {
            return nil;
        }
    }
}

/**
 *  查询准备下载数据库中的条数
 *
 *  @return <#return value description#>
 */
- (NSArray *)selectCoreDataOfCountWithReadyDownLoad
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReadyDownLoad" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects && [fetchedObjects count] > 0) {
            return fetchedObjects;
        }
        return nil;
    }
}

/**
 *  查询正在下载数据库中的条数
 *
 *  @return <#return value description#>
 */
- (NSArray *)selectCoreDataWithDownLoading
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoading" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects && [fetchedObjects count] > 0) {
            return fetchedObjects;
        }
        return nil;
    }
}

/**
 *  查询暂停数据中是否存在某个url
 *
 *  @param loadUrl 下载的url
 *
 *  @return <#return value description#>
 */
- (PauseDownLoad *)selectCoreDataWithPauseDownLoadWithLoadUrl:(NSString *)loadUrl
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PauseDownLoad" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",loadUrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        PauseDownLoad *pauseDownLoad = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
        if (pauseDownLoad) {
            return pauseDownLoad;
        }else {
            return nil;
        }
    }
}

/**
 *  查询正在下载数据库中是否有某个url数据
 *
 *  @param loadUrl 下载的url地址
 *
 *  @return <#return value description#>
 */
- (DownLoading *)selectCoreDataWithDownLoadingWithLoadUrl:(NSString *)loadUrl
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoading" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",loadUrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        DownLoading *downLoadingModel = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
        if (downLoadingModel) {
            return downLoadingModel;
        }else {
            return nil;
        }
    }
}

/**
 *  查询文件数据库中是否有某个url数据
 *
 *  @param loadUrl url
 *
 *  @return <#return value description#>
 */
- (DownLoadFile *)selectCoreDataWithDownLoadFileWithLoadUrl:(NSString *)loadUrl
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoadFile" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",loadUrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        DownLoadFile *downLoadFile = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
        if (downLoadFile) {
            return downLoadFile;
        }else {
            return nil;
        }
    }
}

/**
 *  更新正在下载数据库中的下载进度
 *
 *  @param loadUrl  下载的url地址
 *  @param progress 进度 double
 */
- (void)updateCoreDataWithDownLoadingWithLoadUrl:(NSString *)loadUrl withLoadProgress:(double)progress
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"DownLoadFile"];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoadFile" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",loadUrl];
        [fetch setEntity:entity];
        [fetch setPredicate:predicate];
        NSError *error;
        DownLoadFile *downLoadFile = [[context executeFetchRequest:fetch error:&error] lastObject];
        if (downLoadFile) {
            downLoadFile.fileProgress = [NSNumber numberWithDouble:progress];
        }
        if (![context save:&error]) {
            NSLog(@"error:%@",error);
        }
    }
}


/**
 *  更新文件数据库中的下载进度
 *
 *  @param loadUrl    url
 *  @param resumeData 已经下载的进度数据
 */
- (void)updateCoreDataWithDownLoadFileWithLoadUrl:(NSString *)loadUrl withResumeData:(NSData *)resumeData
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"DownLoadFile"];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoadFile" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",loadUrl];
        [fetch setEntity:entity];
        [fetch setPredicate:predicate];
        NSError *error;
        NSArray *fileModelArray = [context executeFetchRequest:fetch error:&error];
        DownLoadFile *downLoadFileModel = [fileModelArray lastObject];
        NSLog(@"fileModelArray count = %d",[fileModelArray count]);
        if (downLoadFileModel) {
            downLoadFileModel.fileDownLoadData = resumeData;
        }
        if (![context save:&error]) {
            NSLog(@"error:%@",error);
        }
    }
}

/**
 *  更新文件数据库中的本地文件路径
 *
 *  @param loadUrl <#loadUrl description#>
 *  @param locPath <#locPath description#>
 */
- (void)updateCoreDataWithDownLoadFileWithLoadUrl:(NSString *)loadUrl withLocPath:(NSString *)locPath
{
    @synchronized(self){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"DownLoadFile"];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DownLoadFile" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUrl = %@",loadUrl];
        [fetch setEntity:entity];
        [fetch setPredicate:predicate];
        NSError *error;
        DownLoadFile *downLoadFileModel = [[context executeFetchRequest:fetch error:&error] lastObject];
        if (downLoadFileModel) {
            downLoadFileModel.fileLocPath = locPath;
            downLoadFileModel.fileDate = [NSDate date];
        }
        if (![context save:&error]) {
            NSLog(@"error:%@",error);
        }
    }
}
@end
