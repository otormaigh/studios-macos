//
//  HomeView.swift
//  Studios
//
//  Created by Elliot on 22/07/2023.
//

import SwiftUI
import os

struct HomeView: View {
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: HomeViewModel.self)
  )
  
  @ObservedObject var viewModel: HomeViewModel
  @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
  @State private var selectedItemId: ArchiveRelease.ID?
  @State private var releaseChannelFilter: ReleaseChannel? = nil
  
  var body: some View {
    VStack {
      NavigationSplitView(columnVisibility: $columnVisibility) {
        Text("").navigationSplitViewColumnWidth(0)
      } content: {
        List(viewModel.listItems.filter({ item in
          if releaseChannelFilter == nil {
            return true
          } else {
            return item.channel == releaseChannelFilter
          }
        }), selection: $selectedItemId) { item in
          HStack {
            Text("\(item.name) \(item.version)")
            Spacer()
            if item.isInstalled {
              Image(systemName: "checkmark.circle.fill")
            }
          }
        }
      } detail: {
        if let archiveRelease = viewModel.listItems.first(where: { archiveRelease in archiveRelease.id == selectedItemId }) {
          ReleaseDetailView(archiveRelease: archiveRelease)
            .navigationSplitViewColumnWidth(400)
        } else {
          Text("No Version Selected")
        }
      }
      .navigationSplitViewStyle(.balanced)
    }
    
    .onAppear { self.viewModel.fetch() }
    .toolbar {
        Menu {
          Button("All") {
            releaseChannelFilter = nil
          }
          ForEach(ReleaseChannel.allCases, id: \.self) { channel in
            Button(channel.name) {
              releaseChannelFilter = channel
            }
          }
        } label: {
          Label(releaseChannelFilter == nil ? "" : "\(releaseChannelFilter!.name) Only", systemImage: "line.3.horizontal.decrease.circle")
            .foregroundColor(.blue)
            .labelStyle(.titleAndIcon)
            .border(.red)
        }
        .menuIndicator(.hidden)
    }
  }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
      HomeView(viewModel: HomeViewModel())
    }
}
