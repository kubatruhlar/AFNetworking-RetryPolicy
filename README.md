[![Version](https://img.shields.io/cocoapods/v/AFNetworking-RetryPolicy.svg)](http://cocoapods.org/pods/SFDraggableDialogView)
[![License](https://img.shields.io/cocoapods/l/AFNetworking-RetryPolicy.svg)](http://cocoapods.org/pods/SFDraggableDialogView)
[![Platform](https://img.shields.io/cocoapods/p/AFNetworking-RetryPolicy.svg)](http://cocoapods.org/pods/SFDraggableDialogView)

<p align="center" >
  <img src="https://raw.githubusercontent.com/kubatru/AFNetworking-RetryPolicy/master/Images/logo.png" alt="AFNetworking+RetryPolicy" title="AFNetworking+RetryPolicy">
</p>

- If the request timed out, you usually have to call the request again by yourself. **AFNetworking+RetryPolicy** handles that for you.
 
- **AFNetworking+RetryPolicy category** adds the ability to set the retry interval, retry count and progressive (uses power rule e.g. interval = 3 -> 3, 9, 27 etc.). `failure` is called no earlier than `retryCount` = 0, only `fatalStatusCodes` finishes the request earlier.

## Allows
- [x] How many times to try.
- [x] Time interval between attempts in seconds.
- [x] Progressive - next attempt will always take more time than the previous one if set.
- [x] Set fatal status codes. These will trigger failure block immediately when received, ends all retry counts.

## Requirements
- **Category uses [AFNetworking](https://github.com/AFNetworking/AFNetworking) 3.0 and above.**

- *For [AFNetworking](https://github.com/AFNetworking/AFNetworking) 1 support, use branch [`afn1-support`](https://github.com/kubatru/AFNetworking-RetryPolicy/tree/afn1-support). Will not be updated anymore.*

- *For [AFNetworking](https://github.com/AFNetworking/AFNetworking) 2 support, use branch [`afn2-support`](https://github.com/kubatru/AFNetworking-RetryPolicy/tree/afn2-support). Will not be updated anymore.*

## Installation
1. There are two ways to add the **AFNetworking+RetryPolicy** library to your project. Add it as a regular library or install it through **CocoaPods** with `pod 'AFNetworking+RetryPolicy'`

2. Use `#import "AFNetworking+RetryPolicy.h"`

## Usage (Example)
- Simple `GET` request will look like this.

```objective-c
	AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    [manager GET:@"foo" parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        
    } retryCount:5 retryInterval:2.0 progressive:false fatalStatusCodes:@[@401, @403]];
```

- You can also turn on the logging in the category to see what happens (`kDebugLoggingEnabled = true`).

## Author and credit
- This library is open-sourced and maintained by [Jakub Truhlar](http://kubatruhlar.cz).
- Based on [@shaioz](https://github.com/shaioz) solution.
- AFNetworking is owned and maintained by the [Alamofire Software Foundation](http://alamofire.org).
    
## License
- Like :+1: [AFNetworking](https://github.com/AFNetworking/AFNetworking), this category is under the MIT License (MIT).
Copyright © 2016 Jakub Truhlar
