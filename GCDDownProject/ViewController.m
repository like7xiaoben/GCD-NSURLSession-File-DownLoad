//
//  ViewController.m
//  GCDDownProject
//
//  Created by YeYe on 15/6/11.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "ViewController.h"

//下载类
#import "LDownRequestObject.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *ImageViewBtn1;
@property (weak, nonatomic) IBOutlet UIButton *ImageViewBtn2;
@property (weak, nonatomic) IBOutlet UIButton *ImageViewBtn3;
@property (weak, nonatomic) IBOutlet UIButton *ImageViewBtn4;
@property (weak, nonatomic) IBOutlet UIButton *ImageViewBtn5;
@property (weak, nonatomic) IBOutlet UIButton *ImageViewBtn6;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //下载进度的回调
    [[LDownRequestObject shareDownRequestObject] setDownFinishBlock:^(NSString *fileUrl, double fileProgress) {
        NSLog(@"fileUrl = %@ ---- %lf",fileUrl,fileProgress);
        if ([fileUrl isEqualToString:@"http://h.hiphotos.baidu.com/image/pic/item/fd039245d688d43f28b8bafc7f1ed21b0ef43bae.jpg"]) {
            [self.ImageViewBtn1 setTitle:[NSString stringWithFormat:@"下载进度%f",fileProgress] forState:UIControlStateNormal];
            if (fileProgress == 1) {
                [self.ImageViewBtn1 setTitle:@"下载完成" forState:UIControlStateNormal];
            }else if (fileProgress == -1) {
                [self.ImageViewBtn1 setTitle:@"下载失败" forState:UIControlStateNormal];
            }
        }else if ([fileUrl isEqualToString:@"http://g.hiphotos.baidu.com/image/pic/item/4bed2e738bd4b31c992253b285d6277f9e2ff899.jpg"]) {
            [self.ImageViewBtn2 setTitle:[NSString stringWithFormat:@"下载进度%f",fileProgress] forState:UIControlStateNormal];
            if (fileProgress == 1) {
                [self.ImageViewBtn2 setTitle:@"下载完成" forState:UIControlStateNormal];
            }else if (fileProgress == -1) {
                [self.ImageViewBtn2 setTitle:@"下载失败" forState:UIControlStateNormal];
            }
        }else if ([fileUrl isEqualToString:@"http://c.hiphotos.baidu.com/image/pic/item/11385343fbf2b21181b5e04ec88065380cd78e12.jpg"]) {
            [self.ImageViewBtn3 setTitle:[NSString stringWithFormat:@"下载进度%f",fileProgress] forState:UIControlStateNormal];
            if (fileProgress == 1) {
                [self.ImageViewBtn3 setTitle:@"下载完成" forState:UIControlStateNormal];
            }else if (fileProgress == -1) {
                [self.ImageViewBtn3 setTitle:@"下载失败" forState:UIControlStateNormal];
            }
        }else if ([fileUrl isEqualToString:@"http://g.hiphotos.baidu.com/image/pic/item/4d086e061d950a7b4cdaaac308d162d9f3d3c9ce.jpg"]) {
            [self.ImageViewBtn4 setTitle:[NSString stringWithFormat:@"下载进度%f",fileProgress] forState:UIControlStateNormal];
            if (fileProgress == 1) {
                [self.ImageViewBtn4 setTitle:@"下载完成" forState:UIControlStateNormal];
            }else if (fileProgress == -1) {
                [self.ImageViewBtn4 setTitle:@"下载失败" forState:UIControlStateNormal];
            }
        }else if ([fileUrl isEqualToString:@"http://h.hiphotos.baidu.com/image/pic/item/cdbf6c81800a19d84b3b020c31fa828ba61e46fb.jpg"]) {
            [self.ImageViewBtn5 setTitle:[NSString stringWithFormat:@"下载进度%f",fileProgress] forState:UIControlStateNormal];
            if (fileProgress == 1) {
                [self.ImageViewBtn5 setTitle:@"下载完成" forState:UIControlStateNormal];
            }else if (fileProgress == -1) {
                [self.ImageViewBtn5 setTitle:@"下载失败" forState:UIControlStateNormal];
            }
        }else if ([fileUrl isEqualToString:@"http://e.hiphotos.baidu.com/image/pic/item/c2fdfc039245d6884818b7aca6c27d1ed21b249b.jpg"]) {
            [self.ImageViewBtn6 setTitle:[NSString stringWithFormat:@"下载进度%f",fileProgress] forState:UIControlStateNormal];
            if (fileProgress == 1) {
                [self.ImageViewBtn6 setTitle:@"下载完成" forState:UIControlStateNormal];
            }else if (fileProgress == -1) {
                [self.ImageViewBtn6 setTitle:@"下载失败" forState:UIControlStateNormal];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击按钮下载图片
- (IBAction)startDownAction:(id)sender
{
    switch ([sender tag]) {
        case 100:
        {
            [[LDownRequestObject shareDownRequestObject] addNewDownUrlToDownArrayWithUrl:@"http://h.hiphotos.baidu.com/image/pic/item/fd039245d688d43f28b8bafc7f1ed21b0ef43bae.jpg" withFileName:@"图片1" withFileId:1];
        }
            break;
        case 101:
        {
            [[LDownRequestObject shareDownRequestObject] addNewDownUrlToDownArrayWithUrl:@"http://g.hiphotos.baidu.com/image/pic/item/4bed2e738bd4b31c992253b285d6277f9e2ff899.jpg" withFileName:@"图片2" withFileId:2];
        }
            break;
        case 102:
        {
            [[LDownRequestObject shareDownRequestObject] addNewDownUrlToDownArrayWithUrl:@"http://c.hiphotos.baidu.com/image/pic/item/11385343fbf2b21181b5e04ec88065380cd78e12.jpg" withFileName:@"图片3" withFileId:3];
        }
            break;
        case 103:
        {
            [[LDownRequestObject shareDownRequestObject] addNewDownUrlToDownArrayWithUrl:@"http://g.hiphotos.baidu.com/image/pic/item/4d086e061d950a7b4cdaaac308d162d9f3d3c9ce.jpg" withFileName:@"图片4" withFileId:4];
        }
            break;
        case 104:
        {
            [[LDownRequestObject shareDownRequestObject] addNewDownUrlToDownArrayWithUrl:@"http://h.hiphotos.baidu.com/image/pic/item/cdbf6c81800a19d84b3b020c31fa828ba61e46fb.jpg" withFileName:@"图片5" withFileId:5];
        }
            break;
        case 105:
        {
            [[LDownRequestObject shareDownRequestObject] addNewDownUrlToDownArrayWithUrl:@"http://e.hiphotos.baidu.com/image/pic/item/c2fdfc039245d6884818b7aca6c27d1ed21b249b.jpg" withFileName:@"图片6" withFileId:6];
        }
            break;
            
        default:
            break;
    }
}

@end
