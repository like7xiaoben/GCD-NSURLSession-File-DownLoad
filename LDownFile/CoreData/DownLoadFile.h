//
//  DownLoadFile.h
//  NovartisCompliance
//
//  Created by like on 15/5/24.
//  Copyright (c) 2015年 Pactera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DownLoadFile : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * fileUrl;
@property (nonatomic, retain) NSString * fileType;
@property (nonatomic, retain) NSString * fileLocPath;
@property (nonatomic, retain) NSData * fileDownLoadData;
@property (nonatomic, retain) NSDate * fileDate;
@property (nonatomic, retain) NSNumber * fileProgress;
@property (nonatomic, retain) NSNumber * fileId;

@end
