//
//  String+Extension.swift
//  EatWhat
//
//  Created by smarfid on 2018/10/30.
//  Copyright © 2018 smarfid. All rights reserved.
//

import UIKit

extension String {
    func nsrange(fromRange range : Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    func nsrange(of string: String) -> NSRange {
        guard let range = self.range(of: string) else {
            return NSRange(location: 0, length: 0)
        }
        return nsrange(fromRange: range)
    }
    
}
