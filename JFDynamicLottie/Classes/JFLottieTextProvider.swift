//
//  JFLottieTextProvider.swift
//  JFDynamicLottie
//
//  Created by JerryFans on 2023/10/25.
//

import Lottie
import UIKit

class JFLottieTextProvider: AnimationKeypathTextProvider {
    
    func text(for keypath: Lottie.AnimationKeypath, sourceText: String) -> String? {
        if let replaceText = self.textReplacement[keypath.string] {
            return replaceText
        }
        return sourceText
    }
    
    public var textReplacement: [String : String] = [String : String]()
    
    public init(textReplacement:[String : String]? = nil) {
        if let textReplacement {
            self.textReplacement = textReplacement
        }
    }
}

