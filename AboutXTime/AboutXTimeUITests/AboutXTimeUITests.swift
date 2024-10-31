//
//  AboutXTimeUITests.swift
//  AboutXTimeUITests
//
//  Created by Nicky Y on 2024/10/21.
//

import XCTest
import MapKit
@testable import AboutXTime

final class AboutXTimeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}

// MARK: - MapViewController Tests
class MapViewControllerTests: XCTestCase {

    var mapViewController: MapViewController!
    var mockCapsule: Capsule!

    let capsuleLocationLatitude = 24.228189608830593
    let capsuleLocationLongitude = 120.70639954039156
    let capsuleRadius: Int = 0

    // give
    override func setUpWithError() throws {
        let location = Location(latitude: capsuleLocationLatitude,
                                longitude: capsuleLocationLongitude,
                                radius: capsuleRadius)
        mockCapsule = Capsule(
            capsuleId: "1",
            creatorId: "nicky",
            recipients: [],
            content: [],
            emotionTagLabels: nil,
            imageTagLabels: nil,
            createdDate: Date(),
            openDate: Date(),
            location: location,
            isAnonymous: false,
            isLocationLocked: true,
            isShared: false,
            replyMessages: nil
        )

        mapViewController = MapViewController(capsule: mockCapsule)
    }

    override func tearDownWithError() throws {
        mapViewController = nil
        mockCapsule = nil
    }

    // when
    func testUpdateDistanceLabelWithinRange() {
        let userLocation =
        CLLocationCoordinate2D(latitude: capsuleLocationLatitude,
                               longitude: capsuleLocationLongitude)
        let targetLocation =
        CLLocationCoordinate2D(latitude: capsuleLocationLatitude,
                               longitude: capsuleLocationLongitude)

        mapViewController.testupdateDistanceLabel(distance: 0.0,
                                              userLocation: userLocation,
                                              targetLocation: targetLocation)

        // then
        XCTAssertEqual(mapViewController.distanceLabel.text, "您已在目標範圍內，點擊即可查看")
    }

    func testUpdateDistanceLabelOutsideRange() {
        let userLocation = CLLocation(latitude: capsuleLocationLatitude + 1,
                                      longitude: capsuleLocationLongitude + 1)
        let targetLocation = CLLocation(latitude: capsuleLocationLatitude,
                                        longitude: capsuleLocationLongitude)

        mapViewController.testupdateDistanceLabel(distance: 5.0,
                                              userLocation: userLocation.coordinate,
                                              targetLocation: targetLocation.coordinate)

        XCTAssertEqual(mapViewController.distanceLabel.text, "距離目標範圍還有 5.00 公里 (西南)")
    }

    func testCalculateDirectionSouthWest() {
        let userLocation = CLLocationCoordinate2D(latitude: 25.0, longitude: 122.0)
        let targetLocation = CLLocationCoordinate2D(latitude: 24.0, longitude: 121.0)

        let direction = mapViewController.testcalculateDirection(from: userLocation, to: targetLocation)

        XCTAssertEqual(direction, "西南")
    }
}

// MARK: - PendingCapsulesView Tests
class PendingCapsulesViewTests: XCTestCase {

    func testFilteredCapsules() {
        let capsules = [
            Capsule(
                capsuleId: "capsuleId1",
                creatorId: "nicky",
                recipients: [Recipient(id: "nicky", status: 0)],
                content: [],
                emotionTagLabels: nil,
                imageTagLabels: nil,
                createdDate: Date(),
                openDate: Date().addingTimeInterval(5000),
                location: nil,
                isAnonymous: false,
                isLocationLocked: false,
                isShared: false,
                replyMessages: nil
            ),
            Capsule(
                capsuleId: "capsuleId2",
                creatorId: "nicky",
                recipients: [Recipient(id: "nicky", status: 1)],
                content: [],
                emotionTagLabels: nil,
                imageTagLabels: nil,
                createdDate: Date(),
                openDate: Date().addingTimeInterval(1000),
                location: nil,
                isAnonymous: false,
                isLocationLocked: false,
                isShared: false,
                replyMessages: nil
            ),
            Capsule(
                capsuleId: "capsuleId3",
                creatorId: "nicky",
                recipients: [Recipient(id: "nicky", status: 0)],
                content: [],
                emotionTagLabels: nil,
                imageTagLabels: nil,
                createdDate: Date(),
                openDate: Date().addingTimeInterval(100),
                location: nil, isAnonymous: false,
                isLocationLocked: false,
                isShared: false,
                replyMessages: nil
            )
        ]

        let view = PendingCapsulesView(capsules: capsules)

        XCTAssertEqual(view.getFilteredCapsules().count, 2)
        XCTAssertEqual(view.getFilteredCapsules().first?.capsuleId, "capsuleId3")
        XCTAssertTrue(view.getFilteredCapsules().first?.isLocationLocked == false)
    }
}
