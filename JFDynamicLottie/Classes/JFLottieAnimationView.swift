//
//  JFLottieAnimationView.swift
//  JFDynamicLottie
//
//  Created by JerryFans on 2023/10/25.
//

import Lottie
import UIKit

@objc public enum JFAnimationLoopMode: Int {
    /// Animation is played once then stops.
    case playOnce = 0
    /// Animation will loop from beginning to end until stopped.
    case loop = 1
    /// Animation will play forward, then backwards and loop until stopped.
    case autoReverse = 2
    
    /// Animation will loop from beginning to end up to defined amount of times.
    case `repeat` = 3

    /// Animation will play forward, then backwards a defined amount of times.
    case repeatBackwards = 4
  
    case unknow = 999
}


open class JFLottieAnimationView: UIView {
    
    private static var mainBundleDirectoryPath: String?
    
    private var animationView: LottieAnimationView!
    
    @objc dynamic public var animContentMode: UIView.ContentMode {
        set {
            self.animationView.contentMode = newValue
        }
        get {
            return self.animationView.contentMode
        }
    }
    
    open override var contentMode: UIView.ContentMode {
        didSet {
            self.animationView.contentMode = contentMode
        }
    }
    
    @objc public static func setupMainBundleDirectoryPath(path: String) {
        Self.mainBundleDirectoryPath = path
    }
    
    @objc dynamic public var imageReplacement: [String : UIImage]? {
        didSet {
            let provider = self.animationView.imageProvider as? JFLottieImageProvider
            provider?.refreshImageReplacement(imageReplacement: imageReplacement)
            self.animationView.reloadImages()
        }
    }
    
    @objc dynamic public var textReplacement: [String : String]? {
        didSet {
            if let textReplacement {
                self.animationView.textProvider = JFLottieTextProvider(textReplacement: textReplacement)
            }
        }
    }
    
    @objc dynamic public var isAnimationPlaying: Bool {
        return self.animationView.isAnimationPlaying
    }
    
    @objc dynamic public var loopMode: JFAnimationLoopMode {
        set {
            switch newValue {
            case .playOnce:
                self.animationView.loopMode = .playOnce
            case .loop:
                self.animationView.loopMode = .loop
            case .autoReverse:
                self.animationView.loopMode = .autoReverse
            default:
                fatalError("NOT a valid value")
            }
        }
        get {
            switch animationView.loopMode {
            case .playOnce:
                return .playOnce
            case .loop:
                return .loop
            case .autoReverse:
                return .autoReverse
            default:
                return .unknow
            }
        }
    }
    
    @available(*, deprecated, message: "This method is deprecated. Use self.loopMode = .loop instead.")
    @objc dynamic public var loopAnimation: Bool = false {
        didSet {
            if loopAnimation {
                self.loopMode = .loop
            }
        }
    }
    
    @available(*, deprecated, message: "This method is deprecated. Use self.loopMode = .autoReverse instead.")
    @objc dynamic public var autoReverseAnimation: Bool = false {
        didSet {
            if autoReverseAnimation {
                self.loopMode = .autoReverse
            }
        }
    }
    
    @objc dynamic public var currentProgress: AnimationProgressTime {
        set {
            self.animationView.currentProgress = newValue
        }
        get {
            return self.animationView.currentProgress
        }
    }
    
    @objc dynamic public var animationSpeed: CGFloat {
        set {
            self.animationView.animationSpeed = newValue
        }
        get {
            return self.animationView.animationSpeed
        }
    }
    
    @objc dynamic public var animationDuration: TimeInterval {
        get {
            return self.animationView.animation?.duration ?? 0
        }
    }
    
    @objc class func loadLottieFrom(url: URL, completion: @escaping (_ animationView: JFLottieAnimationView?) -> Void) {
        LottieAnimation.loadedFrom(url: url) { animation in
            DispatchQueue.main.async {
                if let animation {
                    let view = JFLottieAnimationView(animation: animation)
                    completion(view)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    @objc convenience public init(withMainBundle directoryName: String) {
        self.init(withMainBundle: directoryName, imageReplacement: nil)
    }
    
    @objc convenience public init(withMainBundle directoryName: String, imageReplacement: [String : UIImage]? = nil, textReplacement: [String : String]? = nil) {
        let dir = Self.mainBundleDirectoryPath ?? ""
        let filepath = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "\(dir)\(directoryName)") ?? ""
        self.init(filepath: filepath, imageReplacement: imageReplacement, textReplacement: textReplacement)
    }
    
    @objc convenience public init(directoryPath: String) {
        self.init(directoryPath: directoryPath, imageReplacement: nil)
    }
    
    @objc convenience public init(directoryPath: String, imageReplacement: [String : UIImage]? = nil, textReplacement: [String : String]? = nil) {
        var filepath = URL(fileURLWithPath: directoryPath).appendingPathComponent("data.json").path
        //兼容一下json名字叫目录名的写法
        if !FileManager.default.fileExists(atPath: filepath), let dirName = Self.getLastDirectoryName(from: directoryPath) {
            filepath = URL(fileURLWithPath: directoryPath).appendingPathComponent("\(dirName).json").path
        }
        self.init(filepath: filepath, imageReplacement: imageReplacement, textReplacement: textReplacement)
    }
    
    // filepath: 导入的资源文件路径，具体到(默认为data).json
    @objc convenience public init(filepath: String, imageReplacement: [String : UIImage]? = nil, textReplacement: [String : String]? = nil) {
        let imageProvider = JFLottieImageProvider(filepath: URL(fileURLWithPath: filepath).deletingLastPathComponent().path, imageReplacement: imageReplacement)
        self.init(filepath: filepath, imageProvider: imageProvider, imageReplacement: imageReplacement, textReplacement: textReplacement)
    }
    
    private class func getLastDirectoryName(from directoryPath: String) -> String? {
        let url = URL(fileURLWithPath: directoryPath)
        return url.lastPathComponent
    }
    
    required public init(filepath: String, imageProvider:JFLottieImageProvider, imageReplacement: [String : UIImage]? = nil, textReplacement: [String : String]? = nil) {
        super.init(frame: CGRect.zero)
        self.animationView = LottieAnimationView(filePath: filepath, imageProvider: imageProvider)
        if let textReplacement {
            self.animationView.textProvider = JFLottieTextProvider(textReplacement: textReplacement)
        }
        self.animationView.contentMode = .scaleToFill
        self.animationView.backgroundBehavior = .pauseAndRestore
        self.layoutAnimationView()
    }
    
    required public init(animation: LottieAnimation) {
        super.init(frame: CGRect.zero)
        self.animationView = LottieAnimationView(animation: animation)
        self.animationView.contentMode = .scaleToFill
        self.animationView.backgroundBehavior = .pauseAndRestore
        self.layoutAnimationView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) should NOT be called")
    }
    
    private func layoutAnimationView(isReload: Bool = false) {
        let v = self.animationView!
        if !isReload {
            self.bounds = v.bounds
        }
        v.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(v)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            v.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            v.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            v.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])

    }

    @objc dynamic public func play() {
        self.play(completion: nil)
    }
    
    @objc dynamic public func play(completion: LottieCompletionBlock? = nil) {
        self.animationView.play(completion: completion)
    }
    
    @objc dynamic public func play(toProgress: AnimationProgressTime,
                     completion: LottieCompletionBlock? = nil) {
        self.animationView.play(toProgress: toProgress, completion: completion)
    }
    
    public func play(fromProgress: AnimationProgressTime? = nil,
                     toProgress: AnimationProgressTime,
                     loopMode: JFAnimationLoopMode? = nil,
                     repeatCount: Float = 0,
                     completion: LottieCompletionBlock? = nil) {
        
        var mode = LottieLoopMode.playOnce
        switch loopMode {
        case .playOnce:
            mode = .playOnce
        case .loop:
            mode = .loop
        case .autoReverse:
            mode = .autoReverse
        case .repeat:
            mode = .repeat(repeatCount)
        case .repeatBackwards:
            mode = .repeatBackwards(repeatCount)
        default:
            fatalError("NOT a valid value")
        }
        
        self.animationView.play(fromProgress: fromProgress, toProgress: toProgress, loopMode: mode, completion: completion)
    }
    
    @objc dynamic public func stop() {
        self.animationView.stop()
    }
    
    @objc dynamic public func pause() {
        self.animationView.pause()
    }
}

public extension JFLottieAnimationView {
    
    //only support single lottie json file
    @available(iOS 13.0, *)
    class func network(fromJson url: URL, imageReplacement: [String : UIImage]? = nil, textReplacement: [String : String]? = nil) async -> JFLottieAnimationView? {
        let view = await withCheckedContinuation { continuation in
            JFLottieAnimationView.loadLottieFrom(url: url) { animationView in
                continuation.resume(returning: animationView)
            }
          }
        view?.textReplacement  = textReplacement
        view?.imageReplacement = imageReplacement
        return view
    }
    
    @objc class func network(fromJson url: URL, completion: @escaping (_ animationView: JFLottieAnimationView?) -> Void) {
        JFLottieAnimationView.loadLottieFrom(url: url, completion: completion)
    }
    
    //support zip resource
    @available(iOS 13.0, *)
    class func network(fromZip url: URL, imageReplacement: [String : UIImage]? = nil, textReplacement: [String : String]? = nil) async -> JFLottieAnimationView? {
        let view = await withCheckedContinuation { continuation in
            Self.network(fromZip: url) { animationView in
                continuation.resume(returning: animationView)
            }
          }
        view?.textReplacement  = textReplacement
        view?.imageReplacement = imageReplacement
        return view
    }
    
    @objc class func network(fromZip url: URL, completion: @escaping (_ animationView: JFLottieAnimationView?) -> Void) {
        JFLottieAnimationHelper.loadLottieFromNetowrkZip(url: url) { directoryPath in
            if let directoryPath {
                completion(JFLottieAnimationView(directoryPath: directoryPath))
            } else {
                completion(nil)
            }
        }
    }

    @objc class func file(filePath: String, imageReplacement: [String : UIImage]? = nil, textReplacement: [String : String]? = nil) -> JFLottieAnimationView {
        return JFLottieAnimationView(filepath: filePath, imageReplacement: imageReplacement, textReplacement: textReplacement)
    }
    
    @objc class func mainBundle(directoryPath: String, imageReplacement: [String : UIImage]? = nil, textReplacement: [String : String]? = nil) -> JFLottieAnimationView {
        if Self.mainBundleDirectoryPath == nil {
            assert(Self.mainBundleDirectoryPath != nil, "must setup a main bundle directory path , use setupMainBundleDirectoryPath class method to setup like (Resource/Lottie/)")
        }
        return JFLottieAnimationView(withMainBundle: directoryPath, imageReplacement: imageReplacement, textReplacement: textReplacement)
    }
    
}
