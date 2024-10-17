//
//  MapViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/16.
//

import UIKit
import MapKit
import SwiftUI

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    private let capsule: Capsule
    private var locationManager = CLLocationManager()
    private var mapView = MKMapView()
    private var distanceLabel = UILabel()
    private var userLocationAnnotation: MKPointAnnotation?

    init(capsule: Capsule) {
        self.capsule = capsule
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        navigationController?.setNavigationBarHidden(true, animated: false)

        setupMapView()
        setupLocationManager()
        setupDistanceLabel()
        showTargetLocation()
    }

    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)

        UINavigationBar.setGlobalBackButtonAppearance()
        setGlobalNavigaionBarAppearance()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupDistanceLabel() {
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.textAlignment = .center
        distanceLabel.textColor = .white
        distanceLabel.backgroundColor = .black
        distanceLabel.layer.cornerRadius = 10
        distanceLabel.clipsToBounds = true
        distanceLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(distanceLabel)

        NSLayoutConstraint.activate([
            distanceLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distanceLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            distanceLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func showTargetLocation() {
        guard let location = capsule.location else { return }
        let targetCoordinate =
        CLLocationCoordinate2D(latitude: location.latitude ?? 0.0, longitude: location.longitude ?? 0.0)
        let region =
        MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 10000, longitudinalMeters: 10000) // 使用公里範圍
        mapView.setRegion(region, animated: true)

        // 添加範圍圓圈（需要將範圍轉換為米）
        let circle = MKCircle(center: targetCoordinate,
                              radius: CLLocationDistance((location.radius ?? 0) * 1000))  // 將公里轉換為米
        mapView.addOverlay(circle)

        let annotation = MKPointAnnotation()
        annotation.coordinate = targetCoordinate
        annotation.title = "Your Capsule Location"
        mapView.addAnnotation(annotation)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
            circleRenderer.strokeColor = STColor.CC2.uiColor
            circleRenderer.fillColor = STColor.C1.uiColor.withAlphaComponent(0.3)
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last, let location = capsule.location else { return }

        let targetLocation = CLLocation(latitude: location.latitude ?? 0.0, longitude: location.longitude ?? 0.0)
        let distance = userLocation.distance(from: targetLocation)

        if distance <= CLLocationDistance((location.radius ?? 0) * 1000) {
            updateDistanceLabel(distance: 0,
                                userLocation: userLocation.coordinate,
                                targetLocation: targetLocation.coordinate)
            print("User is within the target area")

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
            mapView.addGestureRecognizer(tapGesture)

        } else {
            updateDistanceLabel(distance: distance / 1000.0,
                                userLocation: userLocation.coordinate,
                                targetLocation: targetLocation.coordinate)
        }
    }

    private func updateDistanceLabel(distance: CLLocationDistance,
                                     userLocation: CLLocationCoordinate2D,
                                     targetLocation: CLLocationCoordinate2D) {
        let direction = calculateDirection(from: userLocation, to: targetLocation)

        if distance == 0 {
            distanceLabel.text = "您已在目標範圍內，點擊即可查看"

        } else {
            distanceLabel.text = String(format: "距離目標範圍還有 %.2f 公里 (%@)", distance, direction)
        }
    }

    private func calculateDirection(from userLocation: CLLocationCoordinate2D,
                                    to targetLocation: CLLocationCoordinate2D) -> String {
        let latDifference = targetLocation.latitude - userLocation.latitude
        let lonDifference = targetLocation.longitude - userLocation.longitude

        if abs(latDifference) > abs(lonDifference) {
            if latDifference > 0 {
                return "北"
            } else {
                return "南"
            }
        } else {
            if lonDifference > 0 {
                return "東"
            } else {
                return "西"
            }
        }
    }

    @objc private func mapTapped() {
        let showPageVC = ShowCapsulePageViewController(capsule: capsule)
        navigationController?.pushViewController(showPageVC, animated: true)
    }
}
