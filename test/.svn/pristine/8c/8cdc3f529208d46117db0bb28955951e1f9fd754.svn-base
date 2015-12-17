//
//  ImageTool.h
//  SystemFunction
//
//  Copyright (c) 2013年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageTool : NSObject

// 返回单例的静态方法
+ (ImageTool *)shareTool;

// 返回特定尺寸的UImage  ,  image参数为原图片，size为要设定的图片大小
- (UIImage*)resizeImageToSize:(CGSize)size
                 sizeOfImage:(UIImage*)image;

// 在指定的视图内进行截屏操作,返回截屏后的图片
- (UIImage *)imageWithScreenContentsInView:(UIView *)view;

@end
