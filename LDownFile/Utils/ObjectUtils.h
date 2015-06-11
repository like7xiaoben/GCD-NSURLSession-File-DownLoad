//
//  ObjectUtils.h
//  WetDad
//
//  Created by like on 15/5/11.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectUtils : NSObject

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC;

#pragma mark ---------start---------文件操作
/**
 *  获取沙盒路径
 *
 *  @param filename 新加入的目录路径
 *
 *  @return NSString全路径
 */
+ (NSString *)sandBoxPath:(NSString *)filename;

/**
 *  获得下载文件的文件夹路径
 *
 *  @param fileName 文件名称
 *
 *  @return NSString
 */
+ (NSString *)downFolderOfSandBoxPath:(NSString *)fileName;

/**
 *  获得本地下载的文件列表数组
 *
 *  @return NSMutableArray
 */
+ (NSMutableArray *)getSandBoxOfDownFileArray;

/**
 *  清除沙盒中下载的文件(下载和临时)
 *
 *  @param fileArray 需要清除的文件数组
 *
 *  @return BOOL YES:清除成功  NO:清除失败
 */
+ (NSMutableArray *)clearSandBoxOfDownFileWithFileArray:(NSMutableArray *)fileArray;

/**
 *  创建文件夹
 */
+ (void)createDownFile;

/**
 *  写入文件
 *
 *  @param sourcePath     来源路径
 *  @param targetFileName 目的文件名称
 */
+ (NSString *)writeFileWithSourcePath:(NSString *)sourcePath withTargetFileName:(NSString *)targetFileName;

/**
 *  删除临时目录中的文件
 *
 *  @param sourcePath 来源路径
 */
+ (void)deleteFileWithSourcePath:(NSString *)sourcePath;

/**
 *  截取出路径中的文件名称
 *
 *  @param filePath 文件路径
 *
 *  @return NSString
 */
+ (NSString *)cutOutFileNameWithFilePath:(NSString *)filePath;

+ (NSString *)cutOutFileTypeWithFilePath:(NSString *)filePath;

/**
 *  判断此文件是否存在
 *
 *  @param fileName 文件的路径
 *
 *  @return BOOL yes:存在  no:不存在
 */
+ (BOOL)judgeIsExistOfFilePath:(NSString *)filePath;
@end
