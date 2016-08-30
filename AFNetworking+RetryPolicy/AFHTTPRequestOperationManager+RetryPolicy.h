//
// AFNetworking+RetryPolicy.h
//
// * Supporting version AFNetworking 1.*
//
// - This library is open-sourced and maintained by Jakub Truhlar.
// - Based on Shai Ohev Zion's solution.
// - AFNetworking is owned and maintained by the Alamofire Software Foundation.
//
// - Copyright (c) 2016 Jakub Truhlar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

typedef int (^RetryDelayCalcBlock)(int, int, int); // int totalRetriesAllowed, int retriesRemaining, int delayBetweenIntervalsModifier

/**
 *  Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 *
 *  Supporting version AFNetworking 1.
 *
 *  retryCount       How many times to try. 1 means original call + one retry = 2 attempts.
 *  retryInterval    Time interval between tries in seconds. (Timeout is not running, request is delayed and is not running yet).
 *  progressive      Next interval will take more time than the previous one.
 *  fatalStatusCodes Stop trying with these status codes.
 */
@interface AFHTTPRequestOperationManager (RetryPolicy)

@property (strong) id operationsDict;
@property (copy) id retryDelayCalcBlock;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (AFHTTPRequestOperation *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (AFHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

/**
 *   Adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.
 */
- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes;

@end