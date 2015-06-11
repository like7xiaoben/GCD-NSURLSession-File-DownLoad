//
//  ObjectUtils.m
//  WetDad
//
//  Created by like on 15/5/11.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "ObjectUtils.h"
#import "LDownRequestObject.h"
#import "CoreDataManager.h"

@implementation ObjectUtils

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    }else {
        result = window.rootViewController;
    }
    return result;
}

#pragma mark 文件操作---------start---------
/**
 *  获取沙盒路径
 *
 *  @param filename 新加入的目录路径
 *
 *  @return NSString全路径
 */
+ (NSString *)sandBoxPath:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    return [documentsDirectory stringByAppendingPathComponent:filename];
}

/**
 *  获得下载文件的文件夹路径
 *
 *  @param fileName 文件名称
 *
 *  @return NSString
 */
+ (NSString *)downFolderOfSandBoxPath:(NSString *)fileName
{
    return [[ObjectUtils sandBoxPath:@"fileDown"] stringByAppendingPathComponent:fileName];
}

/**
 *  获得本地下载的文件列表数组
 *
 *  @return NSMutableArray
 */
+ (NSMutableArray *)getSandBoxOfDownFileArray
{
    NSMutableArray *fileArray = [[NSMutableArray alloc]init];
    NSString *downFolderPath = [ObjectUtils downFolderOfSandBoxPath:@""];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //先查看文件夹存不存在
    BOOL folderExist = [fileManager fileExistsAtPath:downFolderPath];
    if (!folderExist) {//不存在创建
        BOOL folderCreate = [fileManager createDirectoryAtPath:downFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (folderCreate) {
            NSLog(@"创建成功");
        }else {
            NSLog(@"创建失败");
        }
    }
    //文件Model
    NSArray *downLoadedArray = [[LDownRequestObject shareDownRequestObject].coreDataManager selectCoreDataWithDownLoaded];
    for (DownLoaded *downLoaded in downLoadedArray) {
        DownLoadFile *downLoadFile = [[LDownRequestObject shareDownRequestObject].coreDataManager selectCoreDataWithDownLoadFileWithLoadUrl:downLoaded.fileUrl];
        if (downLoadFile && [fileManager fileExistsAtPath:[ObjectUtils downFolderOfSandBoxPath:downLoadFile.fileLocPath]]) {
            [fileArray addObject:downLoadFile];
        }
    }
    return fileArray;
}

/**
 *  清除沙盒中下载的文件
 *
 *  @param fileArray 需要清除的文件数组
 *
 *  @return BOOL YES:清除成功  NO:清除失败
 */
+ (NSMutableArray *)clearSandBoxOfDownFileWithFileArray:(NSMutableArray *)fileArray
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //倒序遍历
    for (int i = [fileArray count]-1; i >= 0; i --) {
        DownLoadFile *downLoadFile = [fileArray objectAtIndex:i];
        BOOL fileExist = [fileManager fileExistsAtPath:[ObjectUtils downFolderOfSandBoxPath:downLoadFile.fileLocPath]];
        //如果文件名称和时间相同则删除
        if (fileExist) {
            [fileManager removeItemAtPath:[ObjectUtils downFolderOfSandBoxPath:downLoadFile.fileLocPath] error:&error];
            [fileArray removeObjectAtIndex:i];//移除
            //删除已下载数据库
            [[LDownRequestObject shareDownRequestObject].coreDataManager deleteCoreDataWithFileUrl:downLoadFile.fileUrl];
            //同时删除downLoadFile数据库表中的数据
            [[LDownRequestObject shareDownRequestObject].coreDataManager deleteCoreDataOfDownLoadFileWithFileUrl:downLoadFile.fileUrl];
        }
    }
    return fileArray;
}

/**
 *  创建文件夹
 */
+ (void)createDownFile
{
    NSString *downFolderPath = [ObjectUtils downFolderOfSandBoxPath:@""];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //先查看文件夹存不存在
    BOOL folderExist = [fileManager fileExistsAtPath:downFolderPath];
    if (!folderExist) {//不存在创建
        BOOL folderCreate = [fileManager createDirectoryAtPath:downFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (folderCreate) {
            NSLog(@"创建成功");
        }else {
            NSLog(@"创建失败");
        }
    }
}

/**
 *  写入文件
 *
 *  @param sourcePath     来源路径
 *  @param targetFileName 目的文件名称
 */
+ (NSString *)writeFileWithSourcePath:(NSString *)sourcePath withTargetFileName:(NSString *)targetFileName
{
    [ObjectUtils createDownFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *myData = [fileManager contentsAtPath:sourcePath]; // 从一个文件中读取数据
    BOOL create = [fileManager createFileAtPath:[ObjectUtils downFolderOfSandBoxPath:targetFileName] contents:myData attributes:nil];
    if (create) {
        NSLog(@"%@-文件写入成功",targetFileName);
        return targetFileName;
    }else {
        NSLog(@"%@-文件写入失败",targetFileName);
        return nil;
    }
}

/**
 *  删除临时目录中的文件
 *
 *  @param sourcePath 来源路径
 */
+ (void)deleteFileWithSourcePath:(NSString *)sourcePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL remove = [fileManager removeItemAtPath:sourcePath error:&error];
    if (remove) {
        NSLog(@"移除成功");
    }else {
        NSLog(@"移除失败");
    }
}

/**
 *  截取出路径中的文件名称
 *
 *  @param filePath 文件路径
 *
 *  @return NSString
 */
+ (NSString *)cutOutFileNameWithFilePath:(NSString *)filePath
{
    //截取出1.pdf  http://192.168.191.1/complaince/files/1.pdf
    NSInteger lineLocation = [filePath rangeOfString:@"/"].location;
    while (lineLocation != NSNotFound) {
        filePath = [filePath substringFromIndex:lineLocation+1];
        lineLocation = [filePath rangeOfString:@"/"].location;
    }
    return filePath;
}

+ (NSString *)cutOutFileTypeWithFilePath:(NSString *)filePath
{
    //pdf  http://192.168.191.1/complaince/files/1.pdf
    NSInteger docLocation = [filePath rangeOfString:@"."].location;
    while (docLocation != NSNotFound) {
        filePath = [filePath substringFromIndex:docLocation+1];
        docLocation = [filePath rangeOfString:@"."].location;
    }
    return filePath;
}

/**
 *  判断此文件是否存在
 *
 *  @param fileName 文件的路径
 *
 *  @return BOOL yes:存在  no:不存在
 */
+ (BOOL)judgeIsExistOfFilePath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExist = [fileManager fileExistsAtPath:filePath];
    return fileExist;
}

@end
