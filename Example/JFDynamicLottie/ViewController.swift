//
//  ViewController.swift
//  JFDynamicLottie
//
//  Created by JerryFans on 10/27/2023.
//  Copyright (c) 2023 JerryFans. All rights reserved.
//

import UIKit
import JFPopup
import JFDynamicLottie

class ViewController: UIViewController {
    
    
    @IBOutlet weak var bgView: UIView!
    var lottieView: JFLottieAnimationView?
    
    var isReplaceText = false
    var isReplaceImg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup your main bundle directory to save lottie file also you can setup it in appdelete did finish
        JFLottieAnimationView.setupMainBundleDirectoryPath(path: "Resource/")
        
    }
    
    @IBAction func playBtnClick(_ sender: Any) {
        self.view.popup.actionSheet {
            [
                JFPopupAction(with: "测试FilePath方式播放", subTitle: nil, clickActionCallBack: { [weak self] in
                    self?.filePathPlay()
                }),
                JFPopupAction(with: "测试MainBundle方式播放", subTitle: nil, clickActionCallBack: { [weak self] in
                    self?.mainBundlePlay()
                }),
                JFPopupAction(with: "测试网络Json文件方式播放", subTitle: nil, clickActionCallBack: { [weak self] in
                    self?.replaceNetworkResourcePlay()
                }),
                JFPopupAction(with: "测试网络Lottie Zip文件方式播放", subTitle: nil, clickActionCallBack: { [weak self] in
                    self?.replaceNetworkZipResourcePlay()
                }),
                JFPopupAction(with: "测试替换图片资源（播放后点击替换）", subTitle: nil, clickActionCallBack: { [weak self] in
                    self?.replaceImgResourcePlay()
                }),
                JFPopupAction(with: "测试替换文字资源（播放后点击替换）", subTitle: nil, clickActionCallBack: { [weak self] in
                    self?.replaceTextResourcePlay()
                })
            ]
        }
    }
    
    //暂时只支持网络单json文件播放，后续支持zip方式整个lottie目录播放
    //For the time being, you can play only a single json file on the network. Later, you can play the entire lottie directory in zip mode
    func replaceNetworkResourcePlay() {
        self.isReplaceImg = false
        self.isReplaceText = false
        if #available(iOS 13.0, *) {
            Task {
                guard let view = await JFLottieAnimationView.network(fromJson: URL(string: "http://image.jerryfans.com/lottie_data.json")!) else { return }
                self.lottieView?.stop()
                self.lottieView?.removeFromSuperview()
                self.bgView.addSubview(view)
                let size = self.bgView.frame.size
                view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                view.loopMode = .loop
                view.play()
                self.lottieView = view
            }
        } else {
            JFLottieAnimationView.network(fromJson: URL(string: "http://image.jerryfans.com/lottie_data.json")!) { [weak self] animationView in
                guard let self = self else { return }
                self.lottieView?.stop()
                self.lottieView?.removeFromSuperview()
                guard let view = animationView else { return }
                self.bgView.addSubview(view)
                let size = self.bgView.frame.size
                view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                view.loopMode = .loop
                view.play()
                self.lottieView = view
            }
        }
    }
    
    func replaceNetworkZipResourcePlay() {
        self.isReplaceImg = true
        self.isReplaceText = false
        //支持Swift并发
        if #available(iOS 13.0, *) {
            Task {
                guard let view = await JFLottieAnimationView.network(fromZip: URL(string: "http://image.jerryfans.com/slog_zm_effect_1.zip")!) else { return }
                self.lottieView?.stop()
                self.lottieView?.removeFromSuperview()
                self.bgView.addSubview(view)
                let size = self.bgView.frame.size
                view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                view.loopMode = .loop
                view.play()
                self.lottieView = view
            }
        } else {
            JFLottieAnimationView.network(fromZip: URL(string: "http://image.jerryfans.com/slog_zm_effect_1.zip")!) { [weak self] animationView in
                guard let self = self else { return }
                self.lottieView?.stop()
                self.lottieView?.removeFromSuperview()
                guard let view = animationView else { return }
                self.bgView.addSubview(view)
                let size = self.bgView.frame.size
                view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                view.loopMode = .loop
                view.play()
                self.lottieView = view
            }
        }
    }
    
    func replaceImgResourcePlay() {
        self.isReplaceImg = true
        self.isReplaceText = false
        self.lottieView?.removeFromSuperview()
        self.lottieView?.stop()
        let view = JFLottieAnimationView.mainBundle(directoryPath: "slog_zm_effect_1")
        self.bgView.addSubview(view)
        let size = self.bgView.frame.size
        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        view.loopMode = .loop
        view.play()
        self.lottieView = view
    }
    
    func replaceTextResourcePlay() {
        self.isReplaceImg = false
        self.isReplaceText = true
        self.lottieView?.removeFromSuperview()
        self.lottieView?.stop()
        let view = JFLottieAnimationView.mainBundle(directoryPath: "pk_start")
        self.bgView.addSubview(view)
        var size = self.bgView.frame.size
        size.width = size.height * view.jf_size.width / view.jf_size.height
        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        view.jf_centerX = self.bgView.jf_centerX
        view.loopMode = .loop
        view.play()
        self.lottieView = view
    }
    
    func mainBundlePlay() {
        self.isReplaceImg = false
        self.isReplaceText = false
        self.lottieView?.removeFromSuperview()
        self.lottieView?.stop()
        let view = JFLottieAnimationView.mainBundle(directoryPath: "cube_normal_lottie")
        self.bgView.addSubview(view)
        let size = self.bgView.frame.size
        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        view.loopMode = .loop
        view.play()
        self.lottieView = view
    }
    
    func filePathPlay() {
        self.isReplaceImg = false
        self.isReplaceText = false
        self.lottieView?.removeFromSuperview()
        self.lottieView?.stop()
        guard let path = Bundle.main.path(forResource: "data", ofType: "json") else { return }
        let view = JFLottieAnimationView.file(filePath: path)
        self.bgView.addSubview(view)
        let size = self.bgView.frame.size
        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        view.loopMode = .loop
        view.play()
        self.lottieView = view
    }
    
    @IBAction func replaceBtnClick(_ sender: Any) {
        guard self.isReplaceImg || self.isReplaceText else {
            JFToastView.toast(hit: "请选择支持替换的选项")
            return
        }
        
        if self.isReplaceImg {
            let lable1 = UILabel(frame: CGRect(x: 0, y: 0, width: 66, height: 25))
            lable1.text = "动态"
            lable1.textColor = .white
            lable1.font = UIFont.systemFont(ofSize: 18)
            lable1.textAlignment = .center
            var imgReplaceMap: [String: UIImage] = [:]
            if let img1 = lable1.jf.syncSnapshotImage() {
                //支持直接替换图片名字 或者 图片对应id
                imgReplaceMap["img_0.png"] = img1
            }
            
            let lable2 = UILabel(frame: CGRect(x: 0, y: 0, width: 49, height: 25))
            lable2.text = "Lottie"
            lable2.textColor = .white
            lable2.font = UIFont.systemFont(ofSize: 18)
            lable2.textAlignment = .center
            
            if let img2 = lable2.jf.syncSnapshotImage() {
                //支持直接替换图片名字 或者 图片对应id
                imgReplaceMap["img_1.png"] = img2
            }
            
            self.lottieView?.imageReplacement = imgReplaceMap
        }
        
        if self.isReplaceText {
            //支持imageReplacement 和 textReplacement一起 取决于你的Lottie设计
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
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

