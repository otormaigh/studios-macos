//
//  StudiosApp.swift
//  Studios
//
//  Created by Elliot on 22/07/2023.
//

import SwiftUI

@main
struct StudiosApp: App {
    var body: some Scene {
        WindowGroup {
          HomeView(viewModel: HomeViewModel())
        }
    }
}
