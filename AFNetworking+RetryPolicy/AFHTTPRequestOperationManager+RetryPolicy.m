//
// AFNetworking+RetryPolicy.m
//
// * Supporting version AFNetworking 1.*
//
// - This library is open-sourced and maintained by Jakub Truhlar.
// - Based on Shai Ohev Zion's solution.
// - AFNetworking is owned and maintained by the Alamofire Software Foundation.
//
// - Copyright (c) 2016 Jakub Truhlar. All rights reserved.
//

#import "AFHTTPRequestOperationManager+RetryPolicy.h"
#import "ObjcAssociatedObjectHelpers.h"

static bool const kDebugLoggingEnabled = false;

@implementation AFHTTPRequestOperationManager (RetryPolicy)

SYNTHESIZE_ASC_OBJ(__operationsDict, setOperationsDict);
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

- (void)createOperationsDict {
    [self setOperationsDict:[[NSDictionary alloc] init]];
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

- (id)operationsDict {
    if (!self.__operationsDict) {
        [self createOperationsDict];
    }
    return self.__operationsDict;
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

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure autoRetryOf:(NSInteger)retriesRemaining retryInterval:(NSTimeInterval)intervalInSeconds progressive:(bool)progressive fatalStatusCodes:(NSArray *)fatalStatusCodes {
    
    void (^retryBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self isErrorFatal:error]) {
            RetryPolicyLog(@"Request failed with fatal error: %@ - Will not try again!", error.localizedDescription);
            failure(operation, error);
            return;
        }
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
        for (NSNumber *fatalStatusCode in fatalStatusCodes) {
            if (response.statusCode == fatalStatusCode.integerValue) {
                RetryPolicyLog(@"Request failed with fatal error: %@ - Will not try again!", error.localizedDescription);
                failure(operation, error);
                return;
            }
        }
        
        NSMutableDictionary *retryOperationDict = self.operationsDict[request];
        int originalRetryCount = [retryOperationDict[@"originalRetryCount"] intValue];
        int retriesRemainingCount = [retryOperationDict[@"retriesRemainingCount"] intValue];
        RetryPolicyLog(@"Request failed: %@, %ld attempt/s left", error.localizedDescription, retriesRemainingCount);
        if (retriesRemainingCount > 0) {
            AFHTTPRequestOperation *retryOperation = [self HTTPRequestOperationWithRequest:request success:success failure:failure autoRetryOf:retriesRemainingCount - 1 retryInterval:intervalInSeconds progressive:progressive fatalStatusCodes:fatalStatusCodes];
            void (^addRetryOperation)() = ^{
                [self.operationQueue addOperation:retryOperation];
            };
            RetryDelayCalcBlock delayCalc = self.retryDelayCalcBlock;
            int intervalToWait = delayCalc(originalRetryCount, retriesRemainingCount, intervalInSeconds);
            if (intervalToWait > 0) {
                
                dispatch_time_t delay;
                if (progressive) {
                    delay = dispatch_time(0, (int64_t)(pow(intervalToWait, (originalRetryCount - retriesRemainingCount) + 1) * NSEC_PER_SEC));
                    RetryPolicyLog(@"Delaying the next attempt by %.0f seconds …", pow(intervalToWait, (originalRetryCount - retriesRemainingCount) + 1));
                    
                } else {
                    delay = dispatch_time(0, (int64_t)(intervalToWait * NSEC_PER_SEC));
                    RetryPolicyLog(@"Delaying the next attempt by %.0f seconds …", intervalToWait);
                }
                
                dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                    addRetryOperation();
                });
            } else {
                addRetryOperation();
            }
        } else {
            RetryPolicyLog(@"No more attempts left! Will execute the failure block.");
            failure(operation, error);
        }
    };
    NSMutableDictionary *operationDict = self.operationsDict[request];
    if (!operationDict) {
        operationDict = [NSMutableDictionary new];
        operationDict[@"originalRetryCount"] = [NSNumber numberWithInteger:retriesRemaining];
    }
    operationDict[@"retriesRemainingCount"] = [NSNumber numberWithInteger:retriesRemaining];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self.operationsDict];
    newDict[request] = operationDict;
    self.operationsDict = newDict;
    AFHTTPRequestOperation *nextOperation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObj) {
                                                                          //NSMutableDictionary *successOperationDict = self.operationsDict[request];
                                                                          //int originalRetryCount = [successOperationDict[@"originalRetryCount"] intValue];
                                                                          //int retriesRemainingCount = [successOperationDict[@"retriesRemainingCount"] intValue];
                                                                          //NSLog(@"AutoRetry: success with %d retries, running success block...", originalRetryCount - retriesRemainingCount);
                                                                          success(operation, responseObj);
                                                                          //NSLog(@"AutoRetry: done.");

                                                                      } failure:retryBlock];
    return nextOperation;
}

#pragma mark - Base
- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure autoRetryOf:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"HEAD" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *requestOperation, __unused id responseObject) {
        if (success) {
            success(requestOperation);
        }
    } failure:failure autoRetryOf:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure autoRetryOf:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure autoRetryOf:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure autoRetryOf:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PATCH" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure autoRetryOf:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval progressive:(bool)progressive fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes {
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure autoRetryOf:retryCount retryInterval:retryInterval progressive:progressive fatalStatusCodes:fatalStatusCodes];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

@end