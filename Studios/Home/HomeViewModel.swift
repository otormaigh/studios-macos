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
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: HomeViewModel.self)
  )
  var cancellables: Set<AnyCancellable> = Set()
  // FIXME: Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.
  @Published var listItems = [ArchiveRelease]()
  
  func fetch() {
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
            let elements = try doc.getElementsByClass("all-downloads").get(0).getElementsByClass("expandable").prefix(25)
            let archiveReleases: [ArchiveRelease] = elements.enumerated().map { (index, element) in
              let title = try! element.select("p").text().replacingOccurrences(of: "Android Studio ", with: "")
              let titleSplit = title.split(separator: " ")
              let releaseDate = titleSplit.suffix(3).joined(separator: " ")
              let releaseName = titleSplit.prefix(1).joined(separator: " ")
              let versionName = [titleSplit[2], titleSplit[3], titleSplit[4]].joined(separator: " ")
              let releaseChannel: ReleaseChannel
              if versionName.contains(" Canary ") {
                releaseChannel = ReleaseChannel.Canary
              } else if versionName.contains(" Beta ") {
                releaseChannel = ReleaseChannel.Beta
              } else if versionName.contains(" RC ") {
                releaseChannel = ReleaseChannel.RC
              } else if versionName.contains(" Patch ") {
                releaseChannel = ReleaseChannel.Stable
              } else {
                releaseChannel = ReleaseChannel.Unknown
              }
              
              let downloadLinks = try! element.select("a").filter({ element in
                let href = try! element.attr("href")
                return href.contains("mac")
              })
                .enumerated()
                .map({ (index, element) in
                  let href = try! element.attr("href")
                  let fileName = String(href.split(separator: "/").last!).condenseWhitespace()
                  let downloadType: DownloadType
                  if title.contains(".dmg") {
                    downloadType = DownloadType.Installer
                  } else  {
                    downloadType = DownloadType.Zip
                  }
                  return DownloadLink(
                    id: Int(index),
                    fileName: fileName,
                    url: href,
                    type: downloadType)
                })
              
              return ArchiveRelease(
                id: Int(index),
                title: title,
                date: releaseDate,
                name: releaseName,
                version: versionName,
                channel: releaseChannel,
                downloadLinks: downloadLinks)
            }
            self.listItems.append(contentsOf: archiveReleases.sorted { $0.name > $1.name })
          } catch {
            
          }
        }
        task.resume()
      } catch {
        
      }
    }
    
    task.resume()
  }
}
