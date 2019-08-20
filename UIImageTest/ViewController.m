//
//  ViewController.m
//  UIImageTest
//
//  Created by net263 on 2019/8/20.
//  Copyright © 2019 net263. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UIImageView *imageView1;
@property(nonatomic, strong)UIImageView *imageView2;
@property(nonatomic, strong)UIImage *image;
@property(nonatomic, strong)UIImage *img1;
@property(nonatomic, strong)UIImage *img2;
@property(nonatomic, strong)NSData *data1;
@property(nonatomic, strong)NSData *data2;
@property(nonatomic, strong)NSData *data3;

@property(nonatomic, strong)UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, 100, 100)];
    [self.view addSubview:self.imageView];
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(100, 80, 60, 30)];
    [self.button setTitle:@"test" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"qqtest" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.image = [UIImage imageWithData:data];
    [self.imageView setImage:self.image];
    NSInteger height = CGImageGetHeight(self.image.CGImage);
    NSInteger rowBytes = CGImageGetBytesPerRow(self.image.CGImage);
    NSInteger total = height * rowBytes;
    NSLog(@"data length:%zd image size:%zd", data.length, height * rowBytes);
    
    self.data1 =[NSData dataWithContentsOfFile:path];//加载图片二进制数据
    self.img1 = [UIImage imageWithData:self.data1];//创建UIImage，此时并没有解压缩
    self.imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 180+20, 100, 100)];
    [self.view addSubview:self.imageView1];
    self.imageView1.image = self.img1;//去渲染的时候，会去解压缩数据
    
    
    self.imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 300+20, 200, 200)];
    [self.view addSubview:self.imageView2];
    self.data2 = [NSData dataWithContentsOfFile:path];
    UIImage *tmpImg = [UIImage imageWithData:self.data2];
    CGImageRef imageRef = [self decodeImg:tmpImg];
    self.img2 = [UIImage imageWithCGImage:imageRef];
    self.imageView2.image = self.img2;
    height = CGImageGetHeight(self.img2.CGImage);
    NSInteger width = CGImageGetWidth(self.img2.CGImage);
    rowBytes = CGImageGetBytesPerRow(self.img2.CGImage);
    total = height * rowBytes;
    NSLog(@"data width:%zd height:%zd image size:%zd", width, height, height * rowBytes);
}

-(void)test
{
    self.imageView1.image = nil;
    NSLog(@"test");
}

//强制解压缩
-(CGImageRef)decodeImg:(UIImage*)img
{
    CGImageRef imageRef = img.CGImage;
    NSInteger width = CGImageGetWidth(imageRef);
    NSInteger height = CGImageGetHeight(imageRef);
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    // BGRA8888 (premultiplied) or BGRX8888
    // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
    if (!context) return NULL;
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    
    return newImage;
}
@end
