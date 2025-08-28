//
//  ThemeModelTests.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 28/08/2025.
//

import Foundation
import Testing
@testable import Weather_DVT

@MainActor
struct ThemeModelTests {
    @Test("id")
    func testId() {
        #expect(Theme.forest.id == "forest")
        #expect(Theme.sea.id == "sea")
    }

    @Test("display name")
    func testDisplayName() {
        #expect(Theme.forest.displayName == "Forest")
        #expect(Theme.sea.displayName == "Sea")
    }

    @Test("base")
    func testBase() {
        #expect(Theme.forest.base == "forest_")
        #expect(Theme.sea.base == "sea_")
    }

    @Test("image")
    func testImage() {
        #expect(Theme.forest.image == "forest_sunny")
        #expect(Theme.sea.image == "sea_sunny")
    }
}
