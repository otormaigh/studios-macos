//
//  String+Ext.swift
//  Studios
//
//  Created by Elliot on 22/07/2023.
//

import Foundation

extension String {
  func condenseWhitespace() -> String {
    let components = self.components(separatedBy: .whitespacesAndNewlines)
    return components.filter { !$0.isEmpty }.joined(separator: " ")
  }
}
