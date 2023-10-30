//
//  JFLottieImageProvider.swift
//  JFDynamicLottie
//
//  Created by JerryFans on 2023/10/25.
//

import Foundation
import Lottie
import UIKit

let JFCGColorSpaceGetDeviceRGB: CGColorSpace = CGColorSpaceCreateDeviceRGB()

private let _lottieImageCache: NSCache<NSString, UIImage> = {
    var imageCache = NSCache<NSString, UIImage>()
    var memoryGBUnit = ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024
    if memoryGBUnit > 6 {
        memoryGBUnit = 6
    }
    // 50 per GB Memory
    imageCache.countLimit = Int(50 * memoryGBUnit)
    // Unit 50 mb per GB Memory
    imageCache.totalCostLimit = Int(1024 * 1024 * (50 * memoryGBUnit))
    return imageCache
}()


func JFCGImageRefContainsAlpha(_ imageRef: CGImage?) -> Bool {
    guard let imageRef = imageRef else {
        return false
    }
    let alphaInfo = imageRef.alphaInfo
    let hasAlpha = !(alphaInfo == .none ||
                     alphaInfo == .noneSkipFirst ||
                     alphaInfo == .noneSkipLast)
    return hasAlpha
}


public class JFLottieImageProvider: AnimationImageProvider {
    
    public var cacheEligible: Bool = false
    
    public var cgImageReplacement: [String : CGImage] = [String : CGImage]()
    private var filePathUrl: URL?
    
    deinit {
        print("JFLottieImageProvider deinit")
    }
    
    public init(filepath: String, imageReplacement:[String : UIImage]? = nil) {
        self.filePathUrl = URL.init(string: filepath)
        self.refreshImageReplacement(imageReplacement: imageReplacement)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning(_:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc func didReceiveMemoryWarning(_ noti: Notification) {
        _lottieImageCache.removeAllObjects()
    }
    
    public func refreshImageReplacement(imageReplacement:[String : UIImage]? = nil){
        self.cgImageReplacement = [String : CGImage]()
        if let map = imageReplacement{
            for (key,value) in map {
                self.cgImageReplacement[key] = value.cgImage
            }
        }
    }
    
    //实现协议方法返回缓存图像
    public func imageForAsset(asset: Lottie.ImageAsset) -> CGImage? {
        if let image = self.cgImageReplacement[asset.id] {
            return image
        }
        if let image = self.cgImageReplacement[asset.name] {
            clearSameImageCache(with: asset)
            return image
        }
        return _imageForAsset(asset: asset)
    }
    
    private func clearSameImageCache(with asset: Lottie.ImageAsset) {
        if let key = self.filePathUrl?.appendingPathComponent(asset.name).path as? NSString {
            if (_lottieImageCache.object(forKey: key) != nil) {
                _lottieImageCache.removeObject(forKey: key)
            }
            return
        }
        if let key = self.filePathUrl?.appendingPathComponent(asset.directory).appendingPathComponent(asset.name).path as? NSString {
            if (_lottieImageCache.object(forKey: key) != nil) {
                _lottieImageCache.removeObject(forKey: key)
            }
        }
    }
    
    private func _imageForAsset(asset: ImageAsset) -> CGImage? {
        guard let filePathUrl = self.filePathUrl else {
            return nil
        }
        if asset.name.hasPrefix("data:"),
           let url = URL(string: asset.name),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image.cgImage
        }
        
        let directPath = filePathUrl.appendingPathComponent(asset.name).path
        if FileManager.default.fileExists(atPath: directPath) {
            if let img = _lottieImageCache.object(forKey: directPath as NSString) {
                return img.cgImage
            } else {
                var img: CGImage?
                autoreleasepool {
                    img = Self.decodeImage(withPath: directPath)?.cgImage
                }
                if let img {
                    _lottieImageCache.setObject(UIImage(cgImage: img), forKey: directPath as NSString)
                }
                return img
            }
        }
        
        let pathWithDirectory = filePathUrl.appendingPathComponent(asset.directory).appendingPathComponent(asset.name).path
        if FileManager.default.fileExists(atPath: pathWithDirectory) {
            if let img = _lottieImageCache.object(forKey: directPath as NSString) {
                return img.cgImage
            } else {
                var img: CGImage?
                autoreleasepool {
                    img = Self.decodeImage(withPath: pathWithDirectory)?.cgImage
                }
                if let img {
                    _lottieImageCache.setObject(UIImage(cgImage: img), forKey: pathWithDirectory as NSString)
                }
                return img
            }
        }
        
        return nil
    }
    
    private class func decodeImage(withPath imagePath: String) -> UIImage? {
        if !FileManager.default.fileExists(atPath: imagePath) {
            return nil
        }
        
        guard let imageData = NSData(contentsOfFile: imagePath) else {
            return nil
        }
        
        let imageSource = CGImageSourceCreateIncremental(nil)
        
        CGImageSourceUpdateData(imageSource, imageData, true)
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            return nil
        }
        
        var width: Int = 0
        var height: Int = 0
        if let val = properties[kCGImagePropertyPixelHeight] as? NSNumber {
            height = val.intValue
        }
        if let val = properties[kCGImagePropertyPixelWidth] as? NSNumber {
            width = val.intValue
        }
        
        guard let decompressedImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
        }
        
        if width + height == 0 {
            return nil
        }
        
        let compressedImage = UIImage(cgImage: decompressedImageRef)
        let decompressedImage = Self.decompressedImage(with: compressedImage)
        
        return decompressedImage
    }
    
    private class func decompressedImage(with image: UIImage?) -> UIImage? {
        guard let image = image, let imageRef = image.cgImage else {
            return image
        }
        
        let colorspaceRef = JFCGColorSpaceGetDeviceRGB
        let hasAlpha = JFCGImageRefContainsAlpha(imageRef)
        
        var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= hasAlpha ? CGImageAlphaInfo.premultipliedFirst.rawValue : CGImageAlphaInfo.noneSkipFirst.rawValue
        
        let width = imageRef.width
        let height = imageRef.height
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorspaceRef, bitmapInfo: bitmapInfo) else {
            return image
        }
        
        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let imageRefWithoutAlpha = context.makeImage() else {
            return image
        }
        
        let imageWithoutAlpha = UIImage(cgImage: imageRefWithoutAlpha, scale: image.scale, orientation: image.imageOrientation)
        
        return imageWithoutAlpha
    }
}
