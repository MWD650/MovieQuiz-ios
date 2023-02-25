//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Alex on /252/23.
//

import XCTest

class MovieQuizUITests: XCTestCase {
   
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]// находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        sleep(3)
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData,secondPosterData)
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]// находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её
        sleep(3)
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData,secondPosterData)
    }
    
    func testGameFinish() {
        sleep(5)
        for _ in 0..<10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts.firstMatch
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        sleep(5)
        for _ in 0..<10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts.firstMatch
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}

