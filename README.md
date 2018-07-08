# WKDownLoad

[![CI Status](https://img.shields.io/travis/wk726/WKDownLoad.svg?style=flat)](https://travis-ci.org/wk726/WKDownLoad)
[![Version](https://img.shields.io/cocoapods/v/WKDownLoad.svg?style=flat)](https://cocoapods.org/pods/WKDownLoad)
[![License](https://img.shields.io/cocoapods/l/WKDownLoad.svg?style=flat)](https://cocoapods.org/pods/WKDownLoad)
[![Platform](https://img.shields.io/cocoapods/p/WKDownLoad.svg?style=flat)](https://cocoapods.org/pods/WKDownLoad)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WKDownLoad is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WKDownLoad'
```


# WKFMDownLoad
音频下载逻辑的封装
用法：
在vc中直接调用方法：
-(void)downLoader:(NSURL *)url downLoadInfo:(downInfoType)downLoadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock failed:(failedBlockType)failedBlock;
第一个参数：url音频地址
第二个参数：下载信息的总大小
第三个参数：下载的进度
第四个参数：下载完成中后的路径
第四个参数：下载失败的处理


