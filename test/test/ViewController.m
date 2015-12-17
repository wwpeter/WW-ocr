//
//  ViewController.m
//  test
//
//  Created by shinefee on 15/12/8.
//  Copyright © 2015年 shinefee. All rights reserved.
//

#import "ViewController.h"
#import "GTMBase64.h"
#import <MobileCoreServices/MobileCoreServices.h> // 这里面预置一些宏和其他功能 比如kUTTypeImage
#import "ImageTool.h"
#define key @"自己的key"
#import "AFNetworking.h"
#import "Model.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *JSON;
@property (nonatomic) NSMutableArray *mut_arr;
@property (nonatomic,copy) NSMutableString *mut_str;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

//处理
- (IBAction)chuli:(id)sender {
    NSString *httpUrl = @"http://apis.baidu.com/idl_baidu/baiduocrpay/idlocrpaid";
    NSString *httpArg = @"fromdevice=pc&clientip=10.10.10.0&detecttype=LocateRecognize&languagetype=CHN_ENG&imagetype=1&image=%@";
    
    NSString *str = [[NSString alloc] init];
    //输入图片
    str = [self codeImg:@"currentImage.jpg"];
    NSString *str2 = [[NSString alloc] init];
    str2 = [self encodeString:str];
    NSString *resHttpArg = [NSString stringWithFormat:httpArg,str2];
    [self request: httpUrl withHttpArg: resHttpArg];
   
}

#pragma mark -图片编码
-(NSString *)codeImg:(NSString *)imageName{
    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),imageName];
    UIImage *img= [UIImage imageWithContentsOfFile:aPath3];
    NSData *data=UIImageJPEGRepresentation(img, 1.0);//UIImageJPEGRepresentation返回图片较小，但是清晰度模糊
    //    NSData *data=UIImagePNGRepresentation(img);//UIImagePNGRepresentation图片大，清晰
    
    data= [GTMBase64 encodeData:data];
    NSString *str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"+++++++++++++++++++%@",str);
    return str;
}
#pragma mark - encode编码
-(NSString*)encodeString:(NSString*)unencodedString{
    
        NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

#pragma mark - 数据请求
-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    NSURL *url = [NSURL URLWithString: httpUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"POST"];
    [request addValue: key forHTTPHeaderField: @"apikey"];
    [request addValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    NSData *data = [HttpArg dataUsingEncoding: NSUTF8StringEncoding];
    [request setHTTPBody: data];
    _mut_str = [[NSMutableString alloc] init];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, (long)error.code);
                               } else {
                                  // NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSString *resStr = [self replaceUnicode:responseString];//转为汉语
                                   //NSLog(@"HttpResponseCode:%ld", responseCode);
                                   NSLog(@"HttpResponseBody %@",resStr);
                                   NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   
                                   //获得的Json数据
                                   NSLog(@"json数据------%@",json);
                                  
                                   
                                   NSDictionary *dict = [NSDictionary dictionary];
                                   dict = (NSDictionary *)json;
                                   NSDictionary *dict2 = [NSDictionary dictionary];
                                   dict2 = [dict valueForKey:@"retData"];
                                  
                                   NSArray *dict3 = [NSArray array];
                                   dict3 = [dict2 valueForKey:@"word"];
                                  // NSLog(@"获取内容-----------%@",dict3);
                                  
                                   _mut_arr = [NSMutableArray array];
                                   for (NSString *str in dict3) {
                                     NSString *str1 = [self replaceUnicode:str];
                                       NSLog(@"rr%@",str1);
                                      [_mut_str appendFormat:@"%@\n",str1];
                                       
                                      
                                       NSLog(@"wwwwwww++%@",_mut_str);
                                       
                                       
                                   }
                                   
                                   self.JSON.text = _mut_str;
                                  // NSLog(@"****************************%@",_mut_str);
                             
                                   
                                   
                                   
                                   
                                   
                               }
                           }];
}

#pragma mark - Unicode转汉语
- (NSString *)replaceUnicode:(NSString *)unicodeStr {
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                          mutabilityOption:NSPropertyListImmutable
                                                                    format:NULL
                                                          errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}


#pragma mark - 调用相机

- (IBAction)buttonClick:(id)sender {
  //[self loadImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        
    {
        
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
        
    }
    
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
        
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
    


}
//判断是否支持相机跳转
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                    
                case 0:
                    
                    // 取消
                    
                    return;
                    
                case 1:
                    
                    // 相机
                    
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    
                    break;
                    
                case 2:
                    
                    // 相册
                    
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    
                    break;
                    
            }
            
        }
        
        else {
            
            if (buttonIndex == 0) {
                
                return;
                
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                
            }
            
        }
        
        // 跳转到相机或相册页面
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
        
        
    }
    
    
}

#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = [self imageWithImage:image scaledToSize:CGSizeMake(300, 250)];
    UIImage *image2 = [UIImage imageWithData:imageData];
    
    /* 此处info 有六个值
     08
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     09
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     10
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     11
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     12
     * UIImagePickerControllerMediaURL;       // an NSURL
     13
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     14
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     15
     */
    
    // 保存图片至本地，方法见下文
    _imageView.image = image2;
    
    [self saveImage:image2 withName:@"currentImage.jpg"];
//    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.jpg"];
//    
//    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
//    
//    
//    
//    //isFullScreen = NO;
//    
//    [self.imageView setImage:savedImage];
    
    
    self.imageView.tag = 100;
    
    
    
}
//对图片进行处理
- (NSData *)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(newImage, 0.8);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker

{
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

//NSData * UIImageJPEGRepresentation ( UIImage *image, CGFloat compressionQuality
//                                    )

#pragma mark - 保存图片至沙盒

- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName

{
   
    
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    
    // 获取沙盒目录
    
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    
    // 将图片写入文件
    //UIImageWriteToSavedPhotosAlbum
    
    [imageData writeToFile:fullPath atomically:NO];
    
    
    
  //  UIImageWriteToSavedPhotosAlbum(currentImage,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
}



//- (IBAction)outPutImage:(id)sender {
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,                                                                          NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:@"currentImage.jpg"];
//    UIImage *img = [UIImage imageWithContentsOfFile:filePath2];
//    [self.imageView setImage:img];
//
//}
@end
