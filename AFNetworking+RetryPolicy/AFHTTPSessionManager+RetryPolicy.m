//
// Created by Jakub Truhlar on 08/16/16. (Based on Shai Ohev Zion's category)
//
// Copyright (c) 2016 Jakub Truhlar. All rights reserved.
//

#import "AFHTTPSessionManager+RetryPolicy.h"
#import "ObjcAssociatedObjectHelpers.h"

static bool const kDebugLoggingEnabled = false;

@implementation AFHTTPSessionManager (RetryPolicy)

SYNTHESIZE_ASC_OBJ(__tasksDict, setTasksDict);
SYNTHESIZE_ASC_OBJ(__retryDelayCalcBlock, setRetryDelayCalcBlock);

static inline void RetryPolicyLog(NSString *log, ...) {
#ifdef DEBUG
    if (kDebugLoggingEnabled) {
        va_list args;
        va_start(args, log);
        va_end(args);
        NSLogv([NSString stringWithFormat:@"RetryPolicy: %@", log], args);
    }
#endif
}

- (void)createTasksDict {
    [self setTasksDict:[[NSDictionary alloc] init]];
}

- (void)createDelayRetryCalcBlock {
    RetryDelayCalcBlock block = ^int(int totalRetries, int currentRetry, int delayInSecondsSpecified) {
        return delayInSecondsSpecified;
    };
    [self setRetryDelayCalcBlock:block];
}

- (id)retryDelayCalcBlock {
    if (!self.__retryDelayCalcBlock) {
        [self createDelayRetryCalcBlock];
    }
    return self.__retryDelayCalcBlock;
}

- (id)tasksDict {
    if (!self.__tasksDict) {
        [self createTasksDict];
    }
    return self.__tasksDict;
}

- (BOOL)isErrorFatal:(NSError *)error {
    switch (error.code) {
        case kCFHostErrorHostNotFound:
        case kCFHostErrorUnknown: // Query the kCFGetAddrInfoFailureKey to get the value returned from getaddrinfo; lookup in netdb.h
        // HTTP errors
        case kCFErrorHTTPAuthenticationTypeUnsupported:
        case kCFErrorHTTPBadCredentials:
        case kCFErrorHTTPParseFailure:
        case kCFErrorHTTPRedirectionLoopDetected:
        case kCFErrorHTTPBadURL:
        case kCFErrorHTTPBadProxyCredentials:
        case kCFErrorPACFileError:
        case kCFErrorPACFileAuth:
        case kCFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod:
        // Error codes for CFURLConnection and CFURLProtocol
        case kCFURLErrorUnknown:
        case kCFURLErrorCancelled:
        case kCFURLErrorBadURL:
        case kCFURLErrorUnsupportedURL:
        case kCFURLErrorHTTPTooManyRedirects:
        case kCFURLErrorBadServerResponse:
        case kCFURLErrorUserCancelledAuthentication:
        case kCFURLErrorUserAuthenticationRequired:
        case kCFURLErrorZeroByteResource:
        case kCFURLErrorCannotDecodeRawData:
        case kCFURLErrorCannotDecodeContentData:
        case kCFURLErrorCannotParseResponse:
        case kCFURLErrorInternationalRoamingOff:
        case kCFURLErrorCallIsActive:
        case kCFURLErrorDataNotAllowed:
        case kCFURLErrorRequestBodyStreamExhausted:
        case kCFURLErrorFileDoesNotExist:
        case kCFURLErrorFileIsDirectory:
        case kCFURLErrorNoPermissionsToReadFile:
        case kCFURLErrorDataLengthExceedsMaximum:
        // SSL errors
        case kCFURLErrorServerCertificateHasBadDate:
        case kCFURLErrorServerCertificateUntrusted:
        case kCFURLErrorServerCertificateHasUnknownRoot:
        case kCFURLErrorServerCertificateNotYetValid:
        case kCFURLErrorClientCertificateRejected:
        case kCFURLErrorClientCertificateRequired:
        case kCFURLErrorCannotLoadFromNetwork:
        // Cookie errors
        case kCFHTTPCookieCannotParseCookieFile:
        // Errors originating from CFNetServices
        case kCFNetServiceErrorUnknown:
        case kCFNetServiceErrorCollision:
        case kCFNetServiceErrorNotFound:
        case kCFNetServiceErrorInProgress:
        case kCFNetServiceErrorBadArgument:
        case kCFNetServiceErrorCancel:
        case kCFNetServiceErrorInvalid:
        // Special case
        case 101: // null address
        case 102: // Ignore "Frame Load Interrupted" errors. Seen after app store links.
            return YES;
            
        default:
            break;
    }
    
    return NO;
}

- (NSURLSessionDataTask *)requestUrlWithRetryRemaining:(NSInteger)retryRemaining maxRetry:(NSInteger)maxRetry retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes originalRequestCreator:(NSURLSessionDataTask *(^)(void (^)(NSURLSessionDataTask *, NSError *)))taskCreator originalFailure:(void(^)(NSURLSessionDataTask *task, NSError *))failure {
    void(^retryBlock)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        if ([self isErrorFatal:error]) {
            RetryPolicyLog(@"Request failed with fatal error: %@ - Will not try again!", error.localizedDescription);
            failure(task, error);
            return;
        }
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        for (NSNumber *fatalStatusCode in fatalStatusCodes) {
            if (response.statusCode == fatalStatusCode.integerValue) {
                RetryPolicyLog(@"Request failed with fatal error: %@ - Will not try again!", error.localizedDescription);
                failure(task, error);
                return;
            }
        }
        
        RetryPolicyLog(@"Request failed: %@, %ld attempt/s left", error.localizedDescription, retryRemaining);
        if (retryRemaining > 0) {
            void (^addRetryOperation)() = ^{
                [self requestUrlWithRetryRemaining:retryRemaining - 1 maxRetry:maxRetry retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:taskCreator originalFailure:failure];
            };
            if (retryInterval > 0.0) {
                dispatch_time_t delay;
                if (progressive) {
                    delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pow(retryInterval, (maxRetry - retryRemaining) + 1) * NSEC_PER_SEC));
                    RetryPolicyLog(@"Delaying the next attempt by %.0f seconds …", pow(retryInterval, (maxRetry - retryRemaining) + 1));
                    
                } else {
                    delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC));
                    RetryPolicyLog(@"Delaying the next attempt by %.0f seconds …", retryInterval);
                }
                
                // Not accurate because of "Timer Coalescing and App Nap" - which helps to reduce power consumption.
                dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                    addRetryOperation();
                });
                
            } else {
                addRetryOperation();
            }
            
        } else {
            RetryPolicyLog(@"No more attempts left! Will execute the failure block.");
            failure(task, error);
        }
    };
    NSURLSessionDataTask *task = taskCreator(retryBlock);
    return task;
}

#pragma mark - Base
- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters progress:(void (^)(NSProgress *))downloadProgress success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSURLSessionDataTask *task = [self requestUrlWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self GET:URLString parameters:parameters progress:downloadProgress success:success failure:retryBlock];
    } originalFailure:failure];
    return task;
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSURLSessionDataTask *task = [self requestUrlWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self HEAD:URLString parameters:parameters success:success failure:retryBlock];
    } originalFailure:failure];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters progress:(void (^)(NSProgress *))downloadProgress success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    
    NSURLSessionDataTask *task = [self requestUrlWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self POST:URLString parameters:parameters progress:downloadProgress success:success failure:retryBlock];
    } originalFailure:failure];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block progress:(void (^)(NSProgress *))downloadProgress success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSURLSessionDataTask *task = [self requestUrlWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self POST:URLString parameters:parameters constructingBodyWithBlock:block progress:downloadProgress success:success failure:retryBlock];
    } originalFailure:failure];
    return task;
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSURLSessionDataTask *task = [self requestUrlWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self PUT:URLString parameters:parameters success:success failure:retryBlock];
    } originalFailure:failure];
    return task;
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSURLSessionDataTask *task = [self requestUrlWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self PATCH:URLString parameters:parameters success:success failure:retryBlock];
    } originalFailure:failure];
    return task;
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSURLSessionDataTask *task = [self requestUrlWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self DELETE:URLString parameters:parameters success:success failure:retryBlock];
    } originalFailure:failure];
    return task;
}

@end