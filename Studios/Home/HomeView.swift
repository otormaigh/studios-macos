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
  @State private var showWebView = false
  @State private var listItemIds: ArchiveRelease.ID?
  @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
  
  var body: some View {
    VStack {
      NavigationSplitView(columnVisibility: $columnVisibility) {
        Text("").navigationSplitViewColumnWidth(0)
      } content: {
        List(viewModel.listItems, selection: $listItemIds) { item in
          Text("\(item.name) \(item.version)")
        }
      } detail: {
        if let archiveRelease = viewModel.listItems.first(where: { archiveRelease in archiveRelease.id == listItemIds }) {
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
      Text("")
    }
  }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
      HomeView(viewModel: HomeViewModel())
    }
}
