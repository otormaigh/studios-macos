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
          Image(archiveRelease.channel?.iconName ?? ReleaseChannel.Stable.iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 75, height: 75)
          
          Text("\(archiveRelease.name) \(archiveRelease.version)")
            .font(.largeTitle)
            .padding(.bottom)
          
          Text("Release Date")
            .font(.headline)
          Text(archiveRelease.date)
            .padding(.bottom)
          
          if archiveRelease.filePath != nil {
              Text("File Path")
                .font(.headline)
              Button {
                NSWorkspace.shared.activateFileViewerSelecting([archiveRelease.filePath!])
              } label: {
                let filePathString = archiveRelease.filePath!.absoluteString
                  .replacingOccurrences(of: "file://", with: "")
                  .replacingOccurrences(of: "%20", with: " ")
                  .replacingOccurrences(of: ".app/", with: ".app")
                Text("\(filePathString)  \(Image(systemName: "arrow.forward.circle.fill"))")
              }
              .buttonStyle(PlainButtonStyle())
//            Button {
//              let config = NSWorkspace.OpenConfiguration.init()
//              config.allowsRunningApplicationSubstitution = false
//              NSWorkspace.shared.openApplication(at: archiveRelease.filePath!, configuration: config)
//            } label: {
//              Text("Launch")
//            }
          }
          
          let suggestDownloads = archiveRelease.downloadLinks.filter({ downloadLink in
            downloadLink.platform == getPlatform() && downloadLink.type == DownloadType.Zip
          })
          let otherDownloads = archiveRelease.downloadLinks.filter({ downloadLink in
            downloadLink.platform != getPlatform()
          })
          DownloadLinksSection(title: "Suggested Download", downloadLinks: suggestDownloads)
          DownloadLinksSection(title: "Other Download", downloadLinks: otherDownloads)
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
  
  func getPlatform() -> Platform {
    var utsname = utsname()
    uname(&utsname)
    let rawPlatform = withUnsafePointer(to: &utsname.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
        String(cString: $0)
      }
    }
    
    let platform: Platform
    if (rawPlatform == "arm64") {
      platform = Platform.MacSilicon
    } else {
      platform = Platform.MacIntel
    }
    return platform
  }
}

struct ReleaseDownloadListItem: Identifiable {
  let id = UUID()
  let title: String
  let items: [DownloadLink]
}

struct ReleaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
      ReleaseDetailView(archiveRelease: ArchiveRelease(
        id: 1,
        title: "Hedgehog 2023.1.1 Canary 13",
        date: "July 18, 2023",
        name: "Hedgehog",
        version: "2023.1.1 Canary 13",
        channel: ReleaseChannel.Canary,
        downloadLinks: [
          DownloadLink(
            id: 1,
            fileName: "android-studio-2023.1.1.13-mac_arm.zip",
            url: "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.13/android-studio-2023.1.1.13-mac_arm.zip",
            type: DownloadType.Zip,
            platform: Platform.MacSilicon
          ),
          DownloadLink(
            id: 1,
            fileName: "android-studio-2023.1.1.13-mac.zip",
            url: "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.13/android-studio-2023.1.1.13-mac.zip",
            type: DownloadType.Zip,
            platform: Platform.MacIntel
          )
        ],
        isInstalled: true,
        filePath: nil
      ))
    }
}
