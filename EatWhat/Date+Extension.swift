//
//  Date+Extension.swift
//  EatWhat
//
//  Created by smarfid on 2018/10/29.
//  Copyright © 2018 smarfid. All rights reserved.
//

import UIKit

extension Date {
    func getDateString() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: self)
    }
}
