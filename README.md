<p align="left" >
  <img src="https://raw.githubusercontent.com/kubatruhlar/AFNetworking-RetryPolicy/master/Images/logo.png" alt="AFNetworking+RetryPolicy" title="AFNetworking+RetryPolicy" width="400">
</p>

[![Travis](https://travis-ci.org/kubatruhlar/AFNetworking-RetryPolicy.svg)](https://travis-ci.org/kubatruhlar/AFNetworking-RetryPolicy)
[![Version](https://img.shields.io/cocoapods/v/AFNetworking+RetryPolicy.svg)](http://cocoapods.org/pods/AFNetworking+RetryPolicy)
[![Platform](https://img.shields.io/cocoapods/p/AFNetworking+RetryPolicy.svg)](http://cocoapods.org/pods/AFNetworking+RetryPolicy)
[![License](https://img.shields.io/cocoapods/l/AFNetworking+RetryPolicy.svg)](http://cocoapods.org/pods/AFNetworking+RetryPolicy)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/AFNetworking+RetryPolicy.svg)](http://cocoadocs.org/docsets/AFNetworking+RetryPolicy/)

If a request timed out, you usually have to call that request again by yourself. **AFNetworking+RetryPolicy** is an **objective-c** category that adds the ability to set the retry logic for requests made with [AFNetworking](https://github.com/AFNetworking/AFNetworking).

## Features
- [x] **retryCount** - How many times to try.
- [x] **retryInterval** - Time interval between attempts in seconds.
- [x] **progressive** - Next attempt will always take more time than the previous one. *(Uses Exponentiation)*
- [x] **fatalStatusCodes** - These will trigger failure block immediately when received and ends current retry.

## Getting started
- Installing **AFNetworking+RetryPolicy** library in a project through **[CocoaPods](https://cocoapods.org/)** with `pod 'AFNetworking+RetryPolicy'`

- And use `#import "AFHTTPSessionManager+RetryPolicy.h"` directive.

> Or just try it first with `pod try AFNetworking+RetryPolicy`

## Usage
- Simple `GET` request with **AFNetworking+RetryPolicy** could look like this:

```objective-c
	AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    [manager GET:@"foo" parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        
    } retryCount:5 retryInterval:2.0 progressive:false fatalStatusCodes:@[@401, @403]];
```

- You can also turn-on retry policy logging to see what is happening by setting the `AFHTTPSessionManager`’s `retryPolicyLogMessagesEnabled` property to `true`. Disabled by default.

## Requirements
- **Category uses [AFNetworking](https://github.com/AFNetworking/AFNetworking) 3.**

| Target        | IDE           |
| ------------- |:-------------:|
| iOS 7+        | Xcode 7+      |

- *For [AFNetworking](https://github.com/AFNetworking/AFNetworking) 1 support, use branch [`afn1-support`](https://github.com/kubatru/AFNetworking-RetryPolicy/tree/afn1-support). Will not be updated anymore.*

- *For [AFNetworking](https://github.com/AFNetworking/AFNetworking) 2 support, use branch [`afn2-support`](https://github.com/kubatru/AFNetworking-RetryPolicy/tree/afn2-support). Will not be updated anymore.*

## Author and credit
- This library is open-sourced and maintained by [Jakub Truhlář](http://kubatruhlar.cz).
- AFNetworking is owned and maintained by the [Alamofire Software Foundation](http://alamofire.org).
    
## License
- Like :+1: [AFNetworking](https://github.com/AFNetworking/AFNetworking), this category is published under the MIT License. See LICENSE.md for details.
