//
//  ArchiveRelease.swift
//  Studios
//
//  Created by Elliot on 22/07/2023.
//

import Foundation

struct ArchiveRelease: Identifiable, Hashable {
  var id: Int
  
  let title: String
  let date: String
  let name: String
  let version: String
  let channel: ReleaseChannel?
  let downloadLinks: [DownloadLink]
}

struct DownloadLink: Identifiable, Hashable {
  var id: Int
  
  let fileName: String
  let url: String
  let type: DownloadType
  let platform: Platform
}

enum DownloadType {
  case Installer, Zip
}

enum Platform {
  case MacSilicon, MacIntel, Linux, Windows, Unknown
}

enum ReleaseChannel: String, CaseIterable {
  case Stable, RC, Beta, Canary
  var iconName: String {
    switch self {
      case .Stable:
        return "AS Icon Stable"
      case .RC, .Beta, .Canary:
        return "AS Icon Preview"
    }
  }
  
  var name: String {
    switch self {
      case .Stable:
        return "Stable"
      case .RC:
        return "RC"
      case .Beta:
        return "Beta"
      case .Canary:
        return "Canary"
    }
  }
}
