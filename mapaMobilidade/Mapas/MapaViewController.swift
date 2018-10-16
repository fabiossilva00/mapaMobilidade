//
//  MapaViewController.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 16/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import GoogleMaps
import GooglePlaces

class MapaViewController: UIViewController {
    
    @IBOutlet weak var coordenadaLabel: UILabel!
    @IBOutlet weak var configuracoesIphoneButton: UIButton!
    @IBOutlet var gpsDesativadoView: UIView!
    @IBOutlet weak var mapaGMSView: GMSMapView!
    
    private let geoLocationService = GeolocationService.instance
    var disposeBag = DisposeBag()
    
    var latitude = Double()
    var longitude = Double()
    
    private func atualizaTela(){
        view.addSubview(gpsDesativadoView)
        gpsDesativadoView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
    }
    
    private func gpsRx() {
        geoLocationService.authorized
            .drive(gpsDesativadoView.rx.isHidden)
            .disposed(by: disposeBag)
        
        geoLocationService.authorized
            .drive(onNext: { (_) in
                self.mapaConfiguracoes(latitude: self.geoLocationService.locationManager.location?.coordinate.latitude ?? 0.0, longitude: self.geoLocationService.locationManager.location?.coordinate.longitude ?? 0.0)
            })
            .disposed(by: disposeBag)
    }
    
    private func configuracaoTapRx() {
        configuracoesIphoneButton.rx.tap
            .bind {
                self.abreConfiguracoes()
            }
            .disposed(by: disposeBag)
    }
    
    private func abreConfiguracoes() {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    func atualizaGPS(){
        geoLocationService.location
            .drive(onNext: { (location) in
                self.coordenadaLabel.text = "Lat: \(location.latitude), Lon: \(location.longitude)"
                self.latitude = location.latitude
                self.longitude = location.longitude
            })
            .disposed(by: disposeBag)
    }
    
    func mapaConfiguracoes(latitude: Double, longitude: Double) {
        let coordenadasCamera = CLLocationCoordinate2DMake(latitude, longitude)
        let camera = GMSCameraPosition.camera(withTarget: coordenadasCamera, zoom: 16.0)
        mapaGMSView.camera = camera
        mapaGMSView.mapType = .normal
        mapaGMSView.isMyLocationEnabled = true
        let mapaSettings = mapaGMSView.settings
        mapaSettings.compassButton = true
        mapaSettings.myLocationButton = true
        
        do {
            guard let urlStyle = Bundle.main.url(forResource: "style_maps1", withExtension: "json") else { return }
            mapaGMSView.mapStyle = try GMSMapStyle(contentsOfFileURL: urlStyle)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func atualizaLinhaAzul() {
        PathCoordenadas.mutablePath(mutablePath: { (path) in
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = UIColor.blue
            polyline.strokeWidth = 4
            polyline.map = self.mapaGMSView
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        atualizaTela()
        configuracaoTapRx()
        atualizaGPS()
        gpsRx()
        atualizaLinhaAzul()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
