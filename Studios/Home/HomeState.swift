//
//  HomeState.swift
//  Studios
//
//  Created by Fred on 10/09/2023.
//

import Foundation

enum HomeState {
  case loading
  case listItems([ArchiveRelease])
  case error
}
