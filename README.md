<p align="left" >
  <img src="https://raw.githubusercontent.com/kubatruhlar/AFNetworking-RetryPolicy/master/Images/logo.png" alt="AFNetworking+RetryPolicy" title="AFNetworking+RetryPolicy" width="400">
</p>

[![Travis](https://travis-ci.org/kubatruhlar/AFNetworking-RetryPolicy.svg)](https://travis-ci.org/kubatruhlar/AFNetworking-RetryPolicy)
[![Version](https://img.shields.io/cocoapods/v/AFNetworking+RetryPolicy.svg)](http://cocoapods.org/pods/AFNetworking+RetryPolicy)
[![Platform](https://img.shields.io/cocoapods/p/AFNetworking+RetryPolicy.svg)](http://cocoapods.org/pods/AFNetworking+RetryPolicy)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/AFNetworking+RetryPolicy.svg)](http://cocoadocs.org/docsets/AFNetworking+RetryPolicy/)
[![Join the chat at https://gitter.im/AFNetworking-RetryPolicy/](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/AFNetworking-RetryPolicy/General?utm_source=share-link&utm_medium=link&utm_campaign=share-link)
[![License](https://img.shields.io/cocoapods/l/AFNetworking+RetryPolicy.svg)](http://cocoapods.org/pods/AFNetworking+RetryPolicy)

If a request timed out, you usually have to call that request again by yourself. **AFNetworking+RetryPolicy** is an **objective-c** category that adds the ability to set the retry logic for requests made with [AFNetworking](https://github.com/AFNetworking/AFNetworking).

- [Features](#features)
- [Getting started](#getting-started)
- [Usage](#usage)
- [Requirements](#requirements)
- [Old versions](#old-versions)
- [Author and credit](#author-and-credit)
- [License](#license)

## Features
- [x] **retryCount** - How many times to try.
- [x] **retryInterval** - Time interval between attempts in seconds.
- [x] **progressive** - Next attempt will always take more time than the previous one. *(Uses Exponentiation)*
- [x] **fatalStatusCodes** - These will trigger failure block immediately when received and ends current retry.

## Getting started
- Installing through **[CocoaPods](https://cocoapods.org/)** with `pod 'AFNetworking+RetryPolicy'`
- Use `#import "AFHTTPSessionManager+RetryPolicy.h"` directive.

> Want to try it first? Use `pod try AFNetworking+RetryPolicy` command.

## Usage
### Example
- Simple `GET` request with **AFNetworking+RetryPolicy** could look like this:

```objective-c
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    [manager GET:@"foo" parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        
    } retryCount:5 retryInterval:2.0 progressive:false fatalStatusCodes:@[@401, @403]];
```
### Log 
- Enable to see what is happening by setting the `AFHTTPSessionManager`’s `retryPolicyLogMessagesEnabled` property to `true`. *Disabled by default.*

## Requirements
- **[AFNetworking](https://github.com/AFNetworking/AFNetworking) 3.0 or later** *(However [old versions](#old-versions) are available at the other branches)*
- Target iOS 7 or later
- Target OS X 10.9 or later
- Xcode 7 or later

## Old versions
#### For [AFNetworking](https://github.com/AFNetworking/AFNetworking) 1 support\*
- use branch [`afn1-support`](https://github.com/kubatru/AFNetworking-RetryPolicy/tree/afn1-support).
- Installing through **[CocoaPods](https://cocoapods.org/)** with `pod 'AFNetworking+RetryPolicy', git: 'https://github.com/kubatruhlar/AFNetworking-RetryPolicy.git' , branch: 'afn1-support'`

> \*Will not be updated anymore.

#### For [AFNetworking](https://github.com/AFNetworking/AFNetworking) 2 support\*
- use branch [`afn2-support`](https://github.com/kubatru/AFNetworking-RetryPolicy/tree/afn2-support).
- Installing through **[CocoaPods](https://cocoapods.org/)** with `pod 'AFNetworking+RetryPolicy', git: 'https://github.com/kubatruhlar/AFNetworking-RetryPolicy.git' , branch: 'afn2-support'`

> \*Will not be updated anymore.

## Author and credit
- This library is open-sourced and maintained by [Jakub Truhlář](http://kubatruhlar.cz).
- AFNetworking is owned and maintained by the [Alamofire Software Foundation](http://alamofire.org).
    
## License
- Like :+1: [AFNetworking](https://github.com/AFNetworking/AFNetworking), this category is published under the MIT License. See LICENSE.md for details.
