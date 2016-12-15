//
//  DDSendPhotoMessageAPI.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-6.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDSendPhotoMessageAPI.h"
#import "AFHTTPRequestOperationManager.h"
#import <AliyunOSSiOS/OSSService.h>
#import "MTTMessageEntity.h"
#import "MTTPhotosCache.h"
#import "NSDictionary+Safe.h"
#import "MTTUtil.h"
#import "AFNetworking.h"

static int max_try_upload_times = 5;
static NSString * const kBucketNameInAliYunOSS = @"maomaojiang";
static NSString * const kHomeBucketNameInAliYunOSS = @"tenth";

@interface DDSendPhotoMessageAPI ()

@property(nonatomic,strong)AFHTTPRequestOperationManager *manager;
@property(nonatomic,strong)NSOperationQueue *queue;
@property(assign)bool isSending;

@end

@implementation DDSendPhotoMessageAPI

#pragma mark - Common Init

+ (DDSendPhotoMessageAPI *)sharedPhotoCache
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [AFHTTPRequestOperationManager manager];
        self.manager.responseSerializer.acceptableContentTypes
        = [NSSet setWithObject:@"text/html"];
        self.queue = [NSOperationQueue new];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

/**
 *  初始化一个OSSClient实例
 *
 *  @return OSSClient
 */
- (OSSClient *)ossInit {
    // 阿里云OSS服务在各个区域的地址
    NSString *endPoint = @"http://oss-cn-shenzhen.aliyuncs.com";
    // 构造一个获取STSToken的凭证提供器
    id<OSSCredentialProvider> credential = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
        // 实现一个函数，同步返回从server获取到的STSToken
        return [self getFederationToken];
    }];
    // 用endpoint、凭证提供器初始化一个OSSClient
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
    return client;
}

#pragma mark - Upload Request

- (void)uploadImage:(NSString*)imagekey success:(void(^)(NSString* imageURL))success failure:(void(^)(id error))failure
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^(){
        NSString *urlString =  [[MTTUtil getMsfsUrl]
                                stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        @autoreleasepool
        {
            __block NSData *imageData = [[MTTPhotosCache sharedPhotoCache] photoFromDiskCacheForKey:imagekey];
            if (imageData == nil) {
                failure(@"data is emplty");
                return;
            }
            __block UIImage *image = [UIImage imageWithData:imageData];
            NSString *imageName = [NSString stringWithFormat:@"image.png_%fx%f.png",image.size.width,image.size.height];
            NSDictionary *params =[NSDictionary dictionaryWithObjectsAndKeys:@"im_image",@"type", nil];
            [self.manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:imageData name:@"image" fileName:imageName mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {

                imageData =nil;
                image=nil;
                NSInteger statusCode = [operation.response statusCode];
                if (statusCode == 200) {
                    NSString *imageURL=nil;
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        if ([[responseObject safeObjectForKey:@"error_code"] intValue]==0) {
                                imageURL = [responseObject safeObjectForKey:@"url"];
                        }else{
                            failure([responseObject safeObjectForKey:@"error_msg"]);
                        }
                        
                    }
                    
                    NSMutableString *url = [NSMutableString stringWithFormat:@"%@",DD_MESSAGE_IMAGE_PREFIX];
                    if (!imageURL)
                    {
                        max_try_upload_times --;
                        if (max_try_upload_times > 0)
                        {
                            
                            [self uploadImage:imagekey success:^(NSString *imageURL) {
                                success(imageURL);
                            } failure:^(id error) {
                                failure(error);
                            }];
                        }
                        else
                        {
                            failure(nil);
                        }
                        
                    }
                    if (imageURL) {
                        [url appendString:imageURL];
                        [url appendString:@":}]&$~@#@"];
                        success(url);
                    }
                }
                else
                {
                    self.isSending=NO;
                    failure(nil);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                self.isSending=NO;
                NSDictionary* userInfo = error.userInfo;
                NSHTTPURLResponse* response = userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                NSInteger stateCode = response.statusCode;
                
                if (!(stateCode >= 300 && stateCode <=307))
                {
                    failure(@"断网");
                }
            }];
        }
    }];
    [self.queue addOperation:operation];
}

#pragma mark - 上传图片至阿里云OSS
/**
 *  其它页上传阿里云
 *
 */
- (void)uploadBlogToAliYunOSSWithContent:(NSString *)imageKey success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure
{
    NSData *imageData = [[MTTPhotosCache sharedPhotoCache] photoFromDiskCacheForKey:imageKey];
    // 待上传的图片为空,取消上传操作
    if (imageData == nil) return;
    
    
    NSString *objectKey = [self createImagePathInAliYunOSSWithImageName:imageKey];
    /** OSS客户端 */
    OSSClient *client = [self ossInit];
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.bucketName = kBucketNameInAliYunOSS;
    put.objectKey = objectKey;
    put.uploadingData = imageData; // 直接上传NSData
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            task = [client presignPublicURLWithBucketName:kBucketNameInAliYunOSS
                                            withObjectKey:objectKey];
//            task = [client presignConstrainURLWithBucketName:kBucketNameInAliYunOSS withObjectKey:objectKey withExpirationInterval:30 * 60];
            NSString *imagePath = [task.result stringByRemovingPercentEncoding];
            success(imagePath);
        } else {
            failure(task.error);
            DDLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

/**
 *  首页图片上传阿里云
 *
 */
- (void)homeUploadBlogToAliYunOSSWithContent:(NSString *)imageKey success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure
{
    NSData *imageData = [[MTTPhotosCache sharedPhotoCache] photoFromDiskCacheForKey:imageKey];
    if (imageData == nil) return;
    
    
    NSString *objectKey = [self createHomeImagePathInAliYunOSSWithImageName:imageKey];
    /** OSS客户端 */
    OSSClient *client = [self ossInit];
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.bucketName = kHomeBucketNameInAliYunOSS;
    put.objectKey  = objectKey;
    put.uploadingData = imageData; // 直接上传NSData
    OSSTask *putTask  = [client putObject:put];
    
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
//            task = [client presignPublicURLWithBucketName:kHomeBucketNameInAliYunOSS
//                                            withObjectKey:objectKey];
//            task = [client presignConstrainURLWithBucketName:kHomeBucketNameInAliYunOSS withObjectKey:objectKey withExpirationInterval:30 * 60];
//            NSString *imagePath = [task.result stringByRemovingPercentEncoding];
//            success(task.result);
//            success(imagePath);
            success(nil);
            NSLog(@"home image upload object success!");
        } else {
            failure(task.error);
            DDLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

/**
 *  博客图片上传阿里云
 *
 */
- (void)blogImagesUploadToAliYunOSSWithContent:(NSString *)imageKey success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure
{
    NSData *imageData = [[MTTPhotosCache sharedPhotoCache] photoFromDiskCacheForKey:imageKey];
    if (imageData == nil) return;
    
    
    NSString *objectKey = [self createBlogImagePathInAliYunOSSWithImageName:imageKey];
    /** OSS客户端 */
    OSSClient *client = [self ossInit];
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.bucketName    = kBucketNameInAliYunOSS;
    put.objectKey     = objectKey;
    put.uploadingData = imageData; // 直接上传NSData
    OSSTask *putTask  = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            task = [client presignPublicURLWithBucketName:kBucketNameInAliYunOSS
                                            withObjectKey:objectKey];
            NSString *imagePath = [task.result stringByRemovingPercentEncoding];
            success(imagePath);
            
        } else {
            failure(task.error);
            DDLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

#pragma mark - Utils

/**
 *  根据图片名生成保存在阿里云OSS中的路径+文件名
 *
 *  @param imageKey 图片名称
 *
 *  @return 在阿里云OSS中的路径+文件名
 */
- (NSString *)createImagePathInAliYunOSSWithImageName:(NSString *)imageKey
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddhhmmssSSS"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    NSString *year = [timeNow substringToIndex:4];
    NSString *month = [timeNow substringWithRange:NSMakeRange(4, 2)];
    
    NSString *objectKey = [NSString stringWithFormat:@"IM/%@/%@/%@.png", year, month, imageKey];
    
    return objectKey;
}

/**
 *  首页上传阿里云文件路径
 *
 */
- (NSString *)createHomeImagePathInAliYunOSSWithImageName:(NSString *)imageKey
{
    NSString *objectKey = [NSString stringWithFormat:@"im/live/%@.png", imageKey];
    return objectKey;
}

/**
 *  首页上传阿里云文件路径
 *
 */
- (NSString *)createBlogImagePathInAliYunOSSWithImageName:(NSString *)imageKey
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddhhmmssSSS"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    NSString *year = [timeNow substringToIndex:4];
    NSString *month = [timeNow substringWithRange:NSMakeRange(4, 2)];
    
    NSString *objectKey = [NSString stringWithFormat:@"im/blog/%@/%@/%@.png", year, month, imageKey];
    return objectKey;
}

#pragma mark - 获取STSToken
/**
 *  获取STSToken
 *
 *  @return STSToken
 */
- (OSSFederationToken *)getFederationToken
{
    NSURL *url = [NSURL URLWithString:STS_SERVER];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body = [NSString stringWithFormat:@"arg=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"]];
    body = [body stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    
    
    OSSTaskCompletionSource *tcs = [OSSTaskCompletionSource taskCompletionSource];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask  *sessionTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        [tcs setError:error];
                                                        return;
                                                    }
                                                    [tcs setResult:data];
                                                }];
    [sessionTask resume];
    // 实现这个回调需要同步返回Token，所以要waitUntilFinished
    [tcs.task waitUntilFinished];
    if (tcs.task.error) {
        // 如果网络请求出错，返回nil表示无法获取到Token。该次请求OSS会失败。
        return nil;
    } else {
        // 从网络请求返回的内容中解析JSON串拿到Token的各个字段，组成STSToken返回
        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:tcs.task.result
                                                                options:kNilOptions
                                                                  error:nil];
        
        OSSFederationToken *token = [OSSFederationToken new];
        token.tAccessKey = [object objectForKey:@"AccessKeyId"];
        token.tSecretKey = [object objectForKey:@"AccessKeySecret"];
        token.tToken     = [object objectForKey:@"SecurityToken"];
        token.expirationTimeInGMTFormat = [object objectForKey:@"Expiration"];
        
        return token;
    }
}

+(NSString *)imageUrl:(NSString *)content
{
    NSRange range = [content rangeOfString:@"path="];
    NSString* url = nil;
    if ([content length] > range.location + range.length)
    {
        url = [content substringFromIndex:range.location+range.length];
    }
    url = [(NSString *)url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

#pragma mark - 上传头像至阿里云OSS

- (void)uploadAvatarToAliYunOSSWithContent:(NSString *)imageKey andUserID:(NSString*)userID success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure
{
    NSData *imageData = [[MTTPhotosCache sharedPhotoCache] photoFromDiskCacheForKey:imageKey];
    if (imageData == nil) return;
    
    
    NSString *objectKey = [self createImagePathInAliYunOSSWithAtavarImageName:imageKey andUserID:userID];
    /** OSS客户端 */
    OSSClient *client = [self ossInit];
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.bucketName = kBucketNameInAliYunOSS;
    put.objectKey  = objectKey;
    put.uploadingData = imageData; // 直接上传NSData
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            task = [client presignPublicURLWithBucketName:kBucketNameInAliYunOSS
                                            withObjectKey:objectKey];
//            task = [client presignConstrainURLWithBucketName:kBucketNameInAliYunOSS withObjectKey:objectKey withExpirationInterval:30 * 60];
            NSString *imagePath = [task.result stringByRemovingPercentEncoding];
            success(imagePath);
            
        } else {
            failure(task.error);
            DDLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

/**
 *  根据图片名生成保存在阿里云OSS中的路径+文件名
 *
 *  @param imageKey 图片名称
 *
 *  @return 在阿里云OSS中的路径+文件名
 */
- (NSString *)createImagePathInAliYunOSSWithAtavarImageName:(NSString *)imageKey andUserID:(NSString*)userID
{
//    NSString* date;
//    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
//    [formatter setDateFormat:@"YYYYMMddhhmmssSSS"];
//    date = [formatter stringFromDate:[NSDate date]];
//    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
//    NSString *year = [timeNow substringToIndex:4];
//    NSString *month = [timeNow substringWithRange:NSMakeRange(4, 2)];
    
    NSString *objectKey = [NSString stringWithFormat:@"im/avatar/%@.png", userID];
    
    return objectKey;
}

- (void)uploadMsgImageToAliYunOSSWithContent:(NSString *)imageKey andUserID:(NSString*)userID success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure
{
    NSData *imageData = [[MTTPhotosCache sharedPhotoCache] photoFromDiskCacheForKey:imageKey];
    // 待上传的图片为空,取消上传操作
    if (imageData == nil) return;
    
    
    NSString *objectKey = [self createMsgImagePathInAliYunOSSWithAtavarImageName:imageKey andUserID:userID];
    /** OSS客户端 */
    OSSClient *client = [self ossInit];
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.bucketName = kBucketNameInAliYunOSS;
    put.objectKey = objectKey;
    put.uploadingData = imageData; // 直接上传NSData
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            task = [client presignPublicURLWithBucketName:kBucketNameInAliYunOSS
                                            withObjectKey:objectKey];
//            task = [client presignConstrainURLWithBucketName:kBucketNameInAliYunOSS withObjectKey:objectKey withExpirationInterval:30 * 60];
//            NSString *imagePath = [task.result stringByRemovingPercentEncoding];
            NSString *imagePath = task.result ;
//            NSString *imagePath = task.result;
            
            NSMutableString *url = [NSMutableString stringWithFormat:@"%@",DD_MESSAGE_IMAGE_PREFIX];
            if (imagePath) {
                [url appendString:task.result ];
                [url appendString:@":}]&$~@#@"];
            }
            success(url);
        } else {
            failure(task.error);
            DDLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

- (NSString *)createMsgImagePathInAliYunOSSWithAtavarImageName:(NSString *)imageKey andUserID:(NSString*)userID
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddhhmmssSSS"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    NSString *year = [timeNow substringToIndex:4];
    NSString *month = [timeNow substringWithRange:NSMakeRange(4, 2)];
    
    NSString *objectKey = [NSString stringWithFormat:@"im/chat/%@/%@/%@_%@.png",year,month,userID,imageKey];
    
 
    return objectKey;
}

@end
