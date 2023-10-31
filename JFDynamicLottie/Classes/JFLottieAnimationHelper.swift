//
//  JFLottieAnimationHelper.swift
//  JFDynamicLottie
//
//  Created by JerryFans on 2023/10/31.
//

import Foundation
import Zip
import CommonCrypto

class JFLottieAnimationHelper {
    
    class func loadLottieFromNetowrkZip(url: URL, completion: @escaping (_ directoryPath: String?) -> Void) {
        let md5 = Self.calculateMD5Hash(for: url.path)
        let result = Self.checkLottieFileIfSave(fileName: md5)
        if result.0 == true {
            DispatchQueue.main.async {
                let unzipFilePath = result.1
                completion(unzipFilePath)
            }
            return
        }
        let session = URLSession.shared
        let req = URLRequest(url: url, timeoutInterval: 30)
        let task = session.downloadTask(with: req) { filePathUrl, response, error in
            guard error == nil, let filePathUrl else {
              DispatchQueue.main.async {
                completion(nil)
              }
              return
            }
            let name = url.deletingPathExtension().lastPathComponent
            Self.unzipToCacheDirectory(originalURL: filePathUrl,networkUrlMd5: md5, fileName: name) { unzipUrl in
                DispatchQueue.main.async {
                    if let unzipUrl {
                        completion(unzipUrl.path)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
        task.resume()
    }

    private class  func calculateMD5Hash(for string: String) -> String {
        if let data = string.data(using: .utf8) {
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            data.withUnsafeBytes { bytes in
                CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
            }
            var md5String = ""
            for byte in digest {
                md5String += String(format: "%02x", byte)
            }
            return md5String
        }
        return ""
    }
    
    private class func checkLottieFileIfSave(fileName: String) -> (Bool,String) {
        let filePath = Self.lottieResourceSavePath().appendingPathComponent(fileName).path
        return (FileManager.default.fileExists(atPath: filePath),filePath)
    }
    
    private class func lottieResourceSavePath() -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let sourceURL = cacheDirectory.appendingPathComponent("lottieUnZipDir")
        return sourceURL
    }
    
    private class func unzipToCacheDirectory(originalURL: URL,networkUrlMd5: String ,fileName: String ,completion: @escaping (_ url: URL?) -> Void) {
        DispatchQueue.global().async {
            let sourceURL = Self.lottieResourceSavePath()
            let md5 = networkUrlMd5
            let fileUrl = originalURL.deletingLastPathComponent().appendingPathComponent("\(md5).zip")
            let destinationUrl = sourceURL.appendingPathComponent(fileName)
            let finalLotieUrl = sourceURL.appendingPathComponent(md5)
            do {
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
                try FileManager.default.moveItem(at: originalURL, to: fileUrl)
                try FileManager.default.createDirectory(at: sourceURL, withIntermediateDirectories: true, attributes: nil) // 创建目标目录
                try Zip.unzipFile(fileUrl, destination: sourceURL, overwrite: true, password: nil, progress: nil)
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try FileManager.default.moveItem(at: destinationUrl, to: finalLotieUrl)
                    completion(finalLotieUrl)
                } else {
                    completion(nil)
                }
            } catch {
                print("Unzip failed with error: \(error)")
                completion(nil)
            }
        }
    }
}
