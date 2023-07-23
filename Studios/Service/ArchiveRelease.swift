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
  let type: ReleaseType
  let downloadLinks: [DownloadLink]
}

struct DownloadLink: Identifiable, Hashable {
  var id: Int
  
  let fileName: String
  let url: String
  let type: DownloadType
}

enum DownloadType {
  case Installer, Zip
}

enum ReleaseType: String {
  case Stable, Unknown, RC, Beta, Canary
  
  var iconName: String {
    switch self {
      case .Stable, .Unknown:
        return "AS Icon Stable"
      case .RC, .Beta, .Canary:
        return "AS Icon Preview"
    }
  }
}
