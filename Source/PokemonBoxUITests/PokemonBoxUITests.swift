//
//  PokemonBoxUITests.swift
//  PokemonBoxUITests
//
//  Created by Matt Novoselov on 01/07/25.
//

import XCTest

final class PokemonBoxUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITestsDisableAnimations"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    @MainActor
    func testInitialLoadShowsFirstPokemon() throws {
        XCTAssertTrue(app.staticTexts["Bulbasaur"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testPullToRefreshMaintainsList() throws {
        let table = app.tables.element(boundBy: 0)
        table.swipeDown()
        XCTAssertTrue(app.staticTexts["Bulbasaur"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testInfiniteScrollLoadsMorePokemons() throws {
        XCTAssertTrue(app.staticTexts["Bulbasaur"].waitForExistence(timeout: 10))
        let table = app.tables.element(boundBy: 0)
        for _ in 0..<10 where !app.staticTexts["Spearow"].exists {
            table.swipeUp()
        }
        XCTAssertTrue(app.staticTexts["Spearow"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testSearchByNameShowsPokemonsMatchingName() throws {
        let searchField = app.searchFields["Search name or type"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("pikachu")
        XCTAssertTrue(app.staticTexts["Pikachu"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testSearchByTypeShowsPokemonsMatchingType() throws {
        let searchField = app.searchFields["Search name or type"]
        searchField.tap()
        searchField.typeText("electric")
        XCTAssertTrue(app.staticTexts["Pikachu"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
