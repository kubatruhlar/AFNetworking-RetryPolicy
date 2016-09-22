//
// AFNetworking+RetryPolicy.h
//
// * Supporting version AFNetworking 3 and above.*
//
// - This library is open-sourced and maintained by Jakub Truhlar.
// - Based on Shai Ohev Zion's solution.
// - AFNetworking is owned and maintained by the Alamofire Software Foundation.
//
// - Copyright (c) 2016 Jakub Truhlar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

typedef int (^RetryDelayCalcBlock)(int, int, int); // int totalRetriesAllowed, int retriesRemaining, int delayBetweenIntervalsModifier

/**
 *  Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 *
 *  Supporting version AFNetworking 3 and above.
 *
 *  retryCount       How many times to try. 1 means original call + one retry = 2 attempts.
 *  retryInterval    Time interval between tries in seconds. (Timeout is not running, request is delayed and is not running yet).
 *  progressive      Next interval will take more time than the previous one.
 *  fatalStatusCodes Stop trying with these status codes.
 */
@interface AFHTTPSessionManager (RetryPolicy)

/**
 *   Turns retry policy log messages on. Only in `DEBUG` target. Default is `false`.
 */
@property (nonatomic, assign) bool retryPolicyLogMessagesEnabled;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters progress:(void (^)(NSProgress *))downloadProgress success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (NSURLSessionDataTask *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters progress:(void (^)(NSProgress *))downloadProgress success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block progress:(void (^)(NSProgress *))downloadProgress success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (NSURLSessionDataTask *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

@end
