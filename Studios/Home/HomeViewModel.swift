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
  @Published var listItems = [ArchiveRelease]()
  
  func fetch() {
    let url = URL(string: "https://developer.android.com/studio/archive")!
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
      guard let data = data else { return }
  
      do {
        //
        let html = String(data: data, encoding: .utf8)!
        let doc: Document = try SwiftSoup.parse(html)
        let iframeUrl = try doc.getElementsByTag("devsite-iframe").get(0).getElementsByTag("iframe").attr("src")
        
        let task = URLSession.shared.dataTask(with: URL(string: iframeUrl)!) {(data, response, error) in
          guard let data = data else { return }
          do {
            let html = String(data: data, encoding: .utf8)!
            let doc: Document = try SwiftSoup.parse(html)
            let elements = try doc.getElementsByClass("all-downloads").get(0).getElementsByClass("expandable").prefix(10)
            let archiveReleases: [ArchiveRelease] = elements.enumerated().map { (index, element) in
              let title = try! element.select("p").text().replacingOccurrences(of: "Android Studio ", with: "")
              
              let downloadLinks = try! element.select("a").filter({ element in
                let href = try! element.attr("href")
                return href.contains("mac")
              })
                .enumerated()
                .map({ (index, element) in
                  let href = try! element.attr("href")
                  let downloadType: DownloadType
                  if title.contains(".dmg") {
                    downloadType = DownloadType.Installer
                  } else  {
                    downloadType = DownloadType.Zip
                  }
                  return DownloadLink(
                    id: Int(index),
                    fileName: String(href.split(separator: "/").last!).condenseWhitespace(),
                    url: href,
                    type: downloadType)
                })
              let titleSplit = title.split(separator: " ")
              
              return ArchiveRelease(
                id: Int(index),
                title: title,
                date: titleSplit.suffix(3).joined(separator: " "),
                name: titleSplit.prefix(1).joined(separator: " "),
                version: [titleSplit[2], titleSplit[3], titleSplit[4]].joined(separator: " "),
                downloadLinks: downloadLinks)
            }
            self.listItems.append(contentsOf: archiveReleases.sorted { $0.title > $1.title })
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
