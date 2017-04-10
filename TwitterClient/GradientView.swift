//
//  GradientView.swift
//  TwitterClient
//
//  Created by 新谷　よしみ on 2017/04/07.
//  Copyright © 2017年 新谷　よしみ. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

struct GradientViewModel {
    var colors: [CGColor] = [
        UIColor.clear.cgColor,
        UIColor(white: 0, alpha: 0.1).cgColor,
        UIColor(white: 0, alpha: 0.2).cgColor
    ]
    var locations: [NSNumber] = [0, 0.5, 1]
    var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
    var endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
}

class GradientView: UIView {
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    var viewModel: GradientViewModel! {
        didSet {
            self.gradientLayer.colors = viewModel.colors
            self.gradientLayer.locations = viewModel.locations
            self.gradientLayer.startPoint = viewModel.startPoint
            self.gradientLayer.endPoint = viewModel.endPoint
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        layer.addSublayer(gradientLayer)
        viewModel = GradientViewModel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
