//
//  DownloadLinksSection.swift
//  Studios
//
//  Created by Elliot on 10/09/2023.
//

import SwiftUI

struct DownloadLinksSection: View {
  let title: String
  let downloadLinks: [DownloadLink]
  @Environment(\.openURL) private var openURL
  
    var body: some View {
      Text(title)
        .font(.headline)
        .padding(.top)
      ForEach(downloadLinks) { downloadLink in
        HStack(alignment: .center, spacing: nil) {
          Text(downloadLink.fileName)
            .frame(maxWidth: .infinity, alignment: .leading)
          Button(action: {
            openURL(URL(string: downloadLink.url)!)
          }) {
            Text("Download")
          }
          .padding(.leading)
        }
      }
    }
}

struct DownloadLinksSection_Previews: PreviewProvider {
    static var previews: some View {
        DownloadLinksSection(
          title: "Suggested Download",
          downloadLinks: [
            DownloadLink(
              id: 1,
              fileName: "android-studio-2023.1.1.13-mac_arm.zip",
              url: "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.13/android-studio-2023.1.1.13-mac_arm.zip",
              type: DownloadType.Zip,
              platform: Platform.MacSilicon
            )
          ])
    }
}
