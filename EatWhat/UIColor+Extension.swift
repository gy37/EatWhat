//
//  UIColor+Extension.swift
//  EatWhat
//
//  Created by smarfid on 2018/11/8.
//  Copyright © 2018 smarfid. All rights reserved.
//

import UIKit

extension UIColor {
    func getHexString() -> String {
        if self.cgColor.components?.count ?? 0 < 4 {
            return "#000000"
        }
        let hexColor = String(format: "#%X%X%X", Int((self.cgColor.components?[0] ?? 0) * 255), Int((self.cgColor.components?[1] ?? 0) * 255), Int((self.cgColor.components?[2] ?? 0) * 255))
        return hexColor
    }
}
