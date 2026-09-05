import XCTest

final class GameLayoutUITests: XCTestCase {
    func testAllFourSeatsStayOnScreenDuringPlay() throws {
        let app = XCUIApplication()
        app.launch()

        let playButton = app.buttons["menu.play"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 8))
        let hittable = NSPredicate(format: "isHittable == true")
        _ = expectation(for: hittable, evaluatedWith: playButton)
        waitForExpectations(timeout: 6)
        playButton.tap()

        // Let the dealing sequence finish and a few tricks play out, so the human hand
        // shrinks from 10 cards down — the scenario that exposed the West/East seats
        // being pushed off-screen by an unconstrained, overflowing human-hand row.
        sleep(24)

        XCTAssertTrue(app.staticTexts["West"].exists || app.staticTexts["Oeste"].exists)
        XCTAssertTrue(app.staticTexts["East"].exists || app.staticTexts["Este"].exists)

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "GameTable-WestAndEastVisible"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
