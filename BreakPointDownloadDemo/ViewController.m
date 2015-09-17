//
//  ViewController.m
//  BreakPointDownloadDemo
//
//  Created by lzxuan on 15/9/1.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "ViewController.h"
#import "BreakPointDownload.h"
#import "NSString+Hashing.h"

#define kUrl @"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.0.1419920162.dmg"

@interface ViewController ()
{
    BreakPointDownload *_download;//下载对象地址
    NSTimer *_timer;
}


@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)startDownload:(UIButton *)sender;
- (IBAction)stopDownload:(UIButton *)sender;

@property (nonatomic) unsigned long long totalFileSize;
//已经下载的大小
@property (nonatomic) unsigned long long loadedSize;
//前1s之前已经下载的大小
@property (nonatomic) unsigned long long preloadedSize;
//下载速度
@property (nonatomic) double speed;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //先创建下载对象
    _download = [[BreakPointDownload alloc] init];
    
    //从本地获取 比例
    self.progressView.progress = [[NSUserDefaults standardUserDefaults] doubleForKey:[kUrl MD5Hash]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//定时器获取下载速度
- (void)updateSpeed:(NSTimer *)timer {
    //当前 已经下载 - 前1s 已经下载的大小
    self.speed = (self.loadedSize - self.preloadedSize)/1024.0;
    self.preloadedSize = self.loadedSize;
}

- (IBAction)startDownload:(UIButton *)sender {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSpeed:) userInfo:nil repeats:YES];
    }
    
    
    //typeof(self)  获取 self 的类型
    __weak typeof(self) weakSelf = self;
    
    [_download downloadDataFromUrl:kUrl successBlock:^(BreakPointDownload *download) {
        //下载 过程 中 要一直回调的方法
        weakSelf.totalFileSize = download.totalFileSize;
        weakSelf.loadedSize = download.loadedFileSize;
        //换算成M 1M = 1024KB = 1024*1024*字节
        double fileSize = weakSelf.totalFileSize / 1024.0 / 1024.0;
        //下载比例
        double scale = (double)weakSelf.loadedSize/weakSelf.totalFileSize;
        weakSelf.progressView.progress = scale;
        weakSelf.label.text = [NSString stringWithFormat:@"%.2f%% 文件总大小%.2fM download speed:%.2fKB/S",scale*100,fileSize,weakSelf.speed];
        //下载 之后 保存到本地 下载进度
        [[NSUserDefaults standardUserDefaults] setDouble:scale forKey:[kUrl MD5Hash]];
        //立即保存到本地
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (scale >= 1.0) {
            //下载完成
            if ([_timer isValid]) {//是否有效
                [_timer invalidate];//销毁
                _timer = nil;
            }
        }
        
    }];
}

- (IBAction)stopDownload:(UIButton *)sender {
    //手动停止下载
    [_download stopDownload];
    if ([_timer isValid]) {//是否有效
        [_timer invalidate];//销毁
        _timer = nil;
    }
    
}
@end







