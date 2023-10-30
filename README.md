# JFDynamicLottie

[![CI Status](https://img.shields.io/travis/JerryFans/JFDynamicLottie.svg?style=flat)](https://travis-ci.org/JerryFans/JFDynamicLottie)
[![Version](https://img.shields.io/cocoapods/v/JFDynamicLottie.svg?style=flat)](https://cocoapods.org/pods/JFDynamicLottie)
[![License](https://img.shields.io/cocoapods/l/JFDynamicLottie.svg?style=flat)](https://cocoapods.org/pods/JFDynamicLottie)
[![Platform](https://img.shields.io/cocoapods/p/JFDynamicLottie.svg?style=flat)](https://cocoapods.org/pods/JFDynamicLottie)

JFDynamicLottie is a Lottie Extension which can dynamic replace Lottie resource like image、text and with high performance running Lottie animation.

## Usage

First setup your local mainBundle 

```
//setup your main bundle directory to save lottie file also you can setup it in appdelete did finish
        JFLottieAnimationView.setupMainBundleDirectoryPath(path: "Resource/")

```

And then try it.

```
var textReplacement: [String:String] = [:]
            textReplacement["我是用户名1"] = "JerryFans"
            textReplacement["我是用户名2"] = "我是被替换的"
            textReplacement["我是用户名5"] = "替换后的名字"
            
            var imgReplacement: [String:UIImage] = [:]
            
            let imgView = UIImageView(image: UIImage(named: "snap"))
            imgView.frame = CGRect(x: 0, y: 0, width: 92, height: 92)
            imgView.layer.cornerRadius = 46
            imgView.layer.masksToBounds = true
            
            if let img = imgView.jf.syncSnapshotImage() {
                imgReplacement["head_0"] = img
            }
            self.lottieView?.imageReplacement = imgReplacement
            self.lottieView?.textReplacement = textReplacement

```
More usage please see the example code.


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

JFDynamicLottie is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JFDynamicLottie'
```

## Author

JerryFans, fanjiarong_haohao@163.com

## License

JFDynamicLottie is available under the MIT license. See the LICENSE file for more info.
