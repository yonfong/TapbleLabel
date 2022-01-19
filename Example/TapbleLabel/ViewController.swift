//
//  ViewController.swift
//  TapbleLabel
//
//  Created by yonfong on 01/19/2022.
//  Copyright (c) 2022 yonfong. All rights reserved.
//

import UIKit
import TapbleLabel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let serviceTip = "• 文件发送需要时间，如果没有收到，请您稍后重试或者更换邮箱（建议使用非QQ邮箱）。\n\n• 请点击这里联系客服"
        let attributedString = NSMutableAttributedString(string: serviceTip, attributes: [.foregroundColor : UIColor.black, .font: UIFont.systemFont(ofSize: 14)])
        if let range = attributedString.string.range(of: "点击这里")  {
            attributedString.addAttributes([.foregroundColor: UIColor.red], range: NSRange(range, in: attributedString.string))

            let serviceTapAction: TextTapAction = {
                print("11111")
            }
            
            attributedString.addAttribute(.tapAction, value: serviceTapAction, range: NSRange(range, in: attributedString.string))
        }

        let serviceLabel = UILabel()
        serviceLabel.numberOfLines = 0
        serviceLabel.attributedText = attributedString
        view.addSubview(serviceLabel)
        serviceLabel.isEnableTextTapAction = true
        serviceLabel.frame = CGRect(x: 10, y: 100, width: 300, height: 500)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

