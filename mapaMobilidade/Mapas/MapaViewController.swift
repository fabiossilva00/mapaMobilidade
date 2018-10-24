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

class MapaViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var coordenadaLabel: UILabel!
    @IBOutlet weak var configuracoesIphoneButton: UIButton!
    @IBOutlet var gpsDesativadoView: UIView!
    
    @IBOutlet weak var mapaGMSView: GMSMapView!
    
    @IBOutlet var markerView: UIView!
    @IBOutlet weak var nomeEstacaoLabel: UILabel!
    @IBOutlet weak var latitudeEstacaoLabel: UILabel!
    @IBOutlet weak var longitudeEstacaoLabel: UILabel!
    
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
                self.mapaConfiguracoes(latitude: self.geoLocationService.locationManager.location?.coordinate.latitude ?? self.latitude , longitude: self.geoLocationService.locationManager.location?.coordinate.longitude ?? self.longitude)
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
        mapaGMSView.delegate = self
        mapaGMSView.setMinZoom(9.0, maxZoom: 19.0)
        let mapaSettings = mapaGMSView.settings
        mapaSettings.compassButton = true
        mapaSettings.myLocationButton = true
        mapaSettings.tiltGestures = false
        mapaSettings.indoorPicker = true
        mapaSettings.zoomGestures = true
        
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
    
    func deuMerdaLinha(nomeArquivo: String) {
        PathCoordenadas.mutablePathtoPolyline(nomeArquivo: nomeArquivo) { (path) in
            let polyline = GMSPolyline(path: path)
            let styles = [GMSStrokeStyle.solidColor(.yellow), GMSStrokeStyle.solidColor(.black)]
            let lengths: [NSNumber] = [50, 50]
            polyline.spans = GMSStyleSpans(polyline.path!, styles, lengths, .rhumb)
            polyline.strokeWidth = 4
            polyline.map = self.mapaGMSView
        }
        
    }
    
    func deuMerdaBotao() {
        
        let deuMerdaButton = UIButton(type: .custom)
        deuMerdaButton.setTitle("Deu Merda", for: .normal)
        deuMerdaButton.backgroundColor = UIColor.black
        deuMerdaButton.rx.tap
            .bind {
                self.deuMerdaLinha(nomeArquivo: "deuMerda")
                self.calcularDistancia()
            }
            .disposed(by: disposeBag)
//        self.view.addConstraints([NSLayoutConstraint(item: deuMerdaButton,
//                                                     attribute: .height,
//                                                     relatedBy: .equal,
//                                                     toItem: self.view,
//                                                     attribute: .width,
//                                                     multiplier: (65 / 45),
//                                                     constant: 0),
//
//                                  NSLayoutConstraint(item: deuMerdaButton,
//                                                     attribute: .trailingMargin,
//                                                     relatedBy: .equal,
//                                                     toItem: self,
//                                                     attribute: .trailingMargin,
//                                                     multiplier: 1.0,
//                                                     constant: 24),
//                                  NSLayoutConstraint(item: deuMerdaButton,
//                                                     attribute: .bottomMargin,
//                                                     relatedBy: .equal,
//                                                     toItem: self.view,
//                                                     attribute: .bottomMargin,
//                                                     multiplier: 1.0,
//                                                     constant: 86)
//
//        ])
        view.addSubview(deuMerdaButton)
        deuMerdaButton.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.layoutMarginsGuide

        deuMerdaButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
        deuMerdaButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -80.0).isActive = true
        deuMerdaButton.heightAnchor.constraint(equalTo: deuMerdaButton.widthAnchor, multiplier: 1/1).isActive = true
        
    }
    
    func linhasJSONButton(){
        let margins = view.layoutMarginsGuide
//        let linhasButton = UIButton(frame: CGRect(x: 60, y: 180, width: 65, height: 65))
        let linhasButton = UIButton(type: .custom)
//        linhasButton.setImage(UIImage(named: "subway"), for: .normal)
        linhasButton.setTitle("Linhas", for: .normal)
        linhasButton.backgroundColor = UIColor.red
        self.view.addSubview(linhasButton)
        linhasButton.translatesAutoresizingMaskIntoConstraints = false
        
        linhasButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
        linhasButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -80.0).isActive = true
//        linhasButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
//        linhasButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 500.0).isActive = true
//        linhasButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 485.0).isActive = true
        
//        linhasButton.heightAnchor.constraint(equalTo: linhasButton.widthAnchor, multiplier: 1/1).isActive = true
        
        linhasButton.rx.tap
            .bind {
//                LinhasJSON.linhasJSON {
//                    print("Tap")
//                }
              
//                LinhaJSON.coordenadas()
            }
            .disposed(by: disposeBag)
        
    }
    
    func tracarLinhas(){
        LinhasJSON.linhasJSON(linhasArray: { (latitudeArray, longitudeArray) in
            //                    print(latitudeArray.count)
            let coresLinhas: Array<UIColor> = [
                UIColor(red: 255/255, green: 234/255, blue: 0, alpha: 1.0),//amarela
                UIColor(red: 0, green: 0, blue: 128/255, alpha: 1.0),//azul
                UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1.0),//diamante
                UIColor(red: 0, green: 151/255, blue: 167/255, alpha: 1.0),//esmeralda
                UIColor(red: 0, green: 173/255, blue: 100/2558, alpha: 1.0),//jade
                UIColor(red: 155/255, green: 56/255, blue: 148/255, alpha: 1.0),//lilas
                UIColor(red: 162/255, green: 169/255, blue: 177/255, alpha: 1.0),//prata
                UIColor(red: 155/255, green: 56/255, blue: 148/255, alpha: 1.0),//rubi
                UIColor(red: 40/255, green: 53/255, blue: 147/255, alpha: 1.0), //safira
                UIColor(red: 0, green: 172, blue: 193/255, alpha: 1.0),//turquesa
                UIColor(red: 0, green: 121/255, blue: 107/255, alpha: 1.0), //verde
                UIColor(red: 204/255, green: 0, blue: 0, alpha: 1.0) //vermelha
            ]
            for i in 0 ... (latitudeArray.count - 1) {
                let path = GMSMutablePath()
                //                        print(latitudeArray.count)
                //                        print(latitudeArray[i])
                for j in 0 ... (latitudeArray[i].count - 1) {
                    path.add(CLLocationCoordinate2D(latitude: latitudeArray[i][j], longitude: longitudeArray[i][j]))
                }
                //
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = coresLinhas[i]
                polyline.strokeWidth = 2
                polyline.map = self.mapaGMSView
            }
            
            //                    let path = GMSMutablePath()
            //                    print(latitude.count)
            //                    for i in 0 ... (latitude.count - 1) {
            //                        path.add(CLLocationCoordinate2D(latitude: latitude[i], longitude: longitude[i]))
            //                    }
            //
            //                    let polyline = GMSPolyline(path: path)
            //                    polyline.strokeColor = UIColor.black
            //                    polyline.strokeWidth = 4
            //                    polyline.map = self.mapaGMSView
            
        })
        
    }
    
    func markerEstacoes() {
        MarkerEstacoes.markerArray(markers: { (markers) in
            for marker in markers {
                self.mapaGMSView.map({ (map) in
                    if (map.bounds.contains(marker.groundAnchor)){
                        marker.map = self.mapaGMSView
                    }
                })
            }
        })
        
    }
    
    func overlayEstacoes() {
        
        EstacoesGroundOverlays.estacoesGround { (overlay) in
            overlay.map = self.mapaGMSView
            overlay.isTappable = true
        }
        
    }
    
    func  calcularDistancia() {
        let dist1 = CLLocation(latitude: latitude, longitude: longitude)
        print(latitude)
        let dist2 = CLLocation(latitude: -23.544375, longitude: -46.642815)
        let distancia = dist1.distance(from: dist2)
        print(distancia)
        
    }
    
//    let geocoder = GMSGeocoder()
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
//        mapaGMSView.map { (map)  in
//            print(map.camera.zoom)
//            if map.camera.zoom < 12.0 {
//                print("Algo")
////                mapaGMSView.clear()
//            }else{
////                print("Outra coisa")
//                markerEstacoes()
//            }
//        }
        
    }
        
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        geocoder.reverseGeocodeCoordinate(position.target) { (response, error) in
//            guard error == nil else {
//                return
//            }
//
//            if let result = response?.firstResult() {
//                let marker = GMSMarker()
//                marker.position = position.target
//                marker.title = result.lines?[0]
//                marker.snippet = result.lines?[1]
//                print(result)
//                marker.map = self.mapaGMSView
//
//            }
//
//        }
        
    }
    
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//
//
//
//
//        return true
//    }
    
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//
//        nomeEstacaoLabel.text = marker.title
//        latitudeEstacaoLabel.text = "Latitude \(marker.position.latitude)"
//        longitudeEstacaoLabel.text = "Longitude \(marker.position.longitude)"
//
//        return markerView
//    }
    
//    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
//
//        nomeEstacaoLabel.text = marker.title
//        latitudeEstacaoLabel.text = "Latitude \(marker.position.latitude)"
//        longitudeEstacaoLabel.text = "Longitude \(marker.position.longitude)"
//
//        return markerView
//    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let margins = view.layoutMarginsGuide
        
        nomeEstacaoLabel.text = marker.title
        latitudeEstacaoLabel.text = "Latitude \(marker.position.latitude)"
        longitudeEstacaoLabel.text = "Longitude \(marker.position.longitude)"
        
        self.view.addSubview(markerView)
        
        markerView.translatesAutoresizingMaskIntoConstraints = false
        markerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
        markerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
        markerView.heightAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 2.0/3.0).isActive = true
        
        return true
    }
    
//    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
//
//
//    }
    
//    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calcularDistancia()
        
        atualizaTela()
        configuracaoTapRx()
        atualizaGPS()
        gpsRx()
//        atualizaLinhaAzul()
//        deuMerdaBotao()
        markerEstacoes()
//        overlayEstacoes()
        linhasJSONButton()
        tracarLinhas()
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
