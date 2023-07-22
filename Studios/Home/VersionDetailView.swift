//
//  VersionDetailView.swift
//  Studios
//
//  Created by Elliot on 22/07/2023.
//

import SwiftUI

struct ReleaseDetailView: View {
  var archiveRelease: ArchiveRelease
  
    var body: some View {
      HStack() {
        VStack(alignment: .leading, spacing: nil) {
          Text("\(archiveRelease.name) \(archiveRelease.version)")
            .font(.largeTitle)
            .padding(.bottom)
          
          Text("Release Date")
            .font(.headline)
          Text(archiveRelease.date)
            .padding(.bottom)
          
          Text("Downloads")
            .font(.headline)
          ForEach(archiveRelease.downloadLinks) { downloadLink in
            HStack(alignment: .center, spacing: nil) {
              Text(downloadLink.fileName)
                .frame(maxWidth: .infinity, alignment: .leading)
              Button(action: {
              }) {
                Text("Download")
              }
              .padding(.leading)
            }
          }
        }
      }
      .padding()
      .frame(
        minWidth: 0,
        maxWidth: .infinity,
        minHeight: 0,
        maxHeight: .infinity,
        alignment: .topLeading
      )
  }
}

struct ReleaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
      ReleaseDetailView(archiveRelease: ArchiveRelease(
        id: 1,
        title: "Hedgehog 2023.1.1 Canary 13",
        date: "July 18, 2023",
        name: "Hedgehog",
        version: "2023.1.1 Canary 13",
        downloadLinks: [
          DownloadLink(
            id: 1,
            fileName: "android-studio-2023.1.1.13-mac_arm.zip",
            url: "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.13/android-studio-2023.1.1.13-mac_arm.zip",
            type: DownloadType.Zip),
          DownloadLink(
            id: 1,
            fileName: "android-studio-2023.1.1.13-mac.zip",
            url: "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.13/android-studio-2023.1.1.13-mac.zip",
            type: DownloadType.Zip)]
      ))
    }
}
