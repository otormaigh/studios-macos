//
//  HomeViewModel.swift
//  Studios
//
//  Created by Elliot on 22/07/2023.
//

import Foundation
import os
import SwiftSoup
import Combine

class HomeViewModel: ObservableObject {
  @Published var state = HomeState.loading
  
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: HomeViewModel.self)
  )
  var cancellables: Set<AnyCancellable> = Set()
  
  func fetch() {
    self.state = HomeState.loading
    let installedVersions = fetchInstalledVersions()
    
    let url = URL(string: "https://developer.android.com/studio/archive")!
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
      guard let data = data else { return }
  
      do {
        let html = String(data: data, encoding: .utf8)!
        let doc: Document = try SwiftSoup.parse(html)
        let iframeUrl = try doc.getElementsByTag("devsite-iframe").get(0).getElementsByTag("iframe").attr("src")
        
        let task = URLSession.shared.dataTask(with: URL(string: iframeUrl)!) {(data, response, error) in
          guard let data = data else { return }
          do {
            let html = String(data: data, encoding: .utf8)!
            let doc: Document = try SwiftSoup.parse(html)
            let elements = try doc.getElementsByClass("all-downloads").get(0).getElementsByClass("expandable").prefix(100)
            let archiveReleases: [ArchiveRelease] = elements.enumerated().map { (index, element) in
              // Android Studio Hedgehog | 2023.1.1 Canary 15 July 31, 2023
              let title = try! element.select("p").text().replacingOccurrences(of: "Android Studio ", with: "")
              let titleSplit = title.split(separator: " ")
              let releaseDate = titleSplit.suffix(3).joined(separator: " ")
              let releaseName = titleSplit.prefix(1).joined(separator: " ")
              let versionName: String
              if titleSplit[3].contains("Canary") || titleSplit[3].contains("Beta") || titleSplit[3].contains("RC") || titleSplit[3].contains("Patch") {
                versionName = [titleSplit[2], titleSplit[3], titleSplit[4]].joined(separator: " ")
              } else {
                versionName = String(titleSplit[2])
              }
              let filePath = installedVersions[versionName]
              let isInstalled = filePath != nil
              let releaseChannel: ReleaseChannel?
              if title.contains(" Canary ") {
                releaseChannel = ReleaseChannel.Canary
              } else if title.contains(" Beta ") {
                releaseChannel = ReleaseChannel.Beta
              } else if title.contains(" RC ") {
                releaseChannel = ReleaseChannel.RC
              } else if title.contains(" Patch ") {
                releaseChannel = ReleaseChannel.Stable
              } else {
                releaseChannel = ReleaseChannel.Stable
              }
              
              let downloadLinks = try! element.select("a")
                .enumerated()
                .map({ (index, element) in
                  let href = try! element.attr("href")
                  let fileName = String(href.split(separator: "/").last!).condenseWhitespace()
                  let downloadType: DownloadType
                  if fileName.contains(".dmg") {
                    downloadType = DownloadType.Installer
                  } else  {
                    downloadType = DownloadType.Zip
                  }
                  let platform: Platform
                  if fileName.contains("mac_arm.") {
                    platform = Platform.MacSilicon
                  } else if fileName.contains("mac.") {
                    platform = Platform.MacIntel
                  } else if fileName.contains("linux.") {
                    platform = Platform.Linux
                  } else if fileName.contains("windows.") {
                    platform = Platform.Windows
                  } else {
                    platform = Platform.Unknown
                  }
                  return DownloadLink(
                    id: Int(index),
                    fileName: fileName,
                    url: href,
                    type: downloadType,
                    platform: platform
                  )
                })
              
              return ArchiveRelease(
                id: Int(index),
                title: title,
                date: releaseDate,
                name: releaseName,
                version: versionName,
                channel: releaseChannel,
                downloadLinks: downloadLinks,
                isInstalled: isInstalled,
                filePath: filePath)
            }
            
            self.state = HomeState.listItems(archiveReleases.sorted { $0.name > $1.name })
          } catch {
            self.state = HomeState.error
          }
        }
        task.resume()
      } catch {
        self.state = HomeState.error
      }
    }
    
    task.resume()
  }
  
  func fetchInstalledVersions() -> [String: URL] {
    HomeViewModel.logger.info("fetchInstalledVersions")
    
    var installedVersions: [String: URL] = [String:URL]()
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .applicationDirectory, in: .localDomainMask).first!
    do {
      let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil).filter({ url in
        url.absoluteString.contains("Android%20Studio")
      })
      HomeViewModel.logger.info("fileURLs -> \(fileURLs)")
      fileURLs.map { fileUrl in
        let version = fileUrl.lastPathComponent.replacingOccurrences(of: "Android Studio ", with: "").replacingOccurrences(of: ".app", with: "")
        HomeViewModel.logger.info("version -> \(version)")
        installedVersions[version] = fileUrl
      }
    } catch {
      HomeViewModel.logger.info("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
    }
    return installedVersions
  }
}
