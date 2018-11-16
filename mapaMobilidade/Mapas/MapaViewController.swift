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
import Alamofire
import SocketIO
import UberRides
import UberCore

class MapaViewController: UIViewController, GMSMapViewDelegate{
    
    @IBOutlet weak var coordenadaLabel: UILabel!
    @IBOutlet weak var configuracoesIphoneButton: UIButton!
    @IBOutlet var gpsDesativadoView: UIView!
    
    @IBOutlet weak var mapaGMSView: GMSMapView!
    
    @IBOutlet var markerView: UIView!
//    @IBOutlet weak var nomeEstacaoLabel: UILabel!
    @IBOutlet weak var nomeEstacaoLabel: UILabel!
    @IBOutlet weak var latitudeEstacaoLabel: UILabel!
    @IBOutlet weak var longitudeEstacaoLabel: UILabel!
    
    @IBOutlet var uber99View: UIView!
    @IBOutlet var votoView: UIView!
    @IBOutlet weak var dislikeLabel: UILabel!
    @IBOutlet weak var uber99Button: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var incidenteButton: UIButton!
    @IBOutlet weak var incidenteText: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var estacaoLabel: UILabel!
    @IBOutlet weak var linhaLabel: UILabel!
    @IBOutlet weak var incidenteLabel: UILabel!
    
    @IBOutlet weak var uberButton: UberButton!
    @IBOutlet weak var precosCollection: UICollectionView!
    
    private let geoLocationService = GeolocationService.instance
    var disposeBag = DisposeBag()
    
    var latitude = Double()
    var longitude = Double()
    var pickerOption = ["Usuário na via", "Maior tempo de parada", "Outro incidente"]
    var estacaoMarker = String()
    var markersMapa = [GMSMarker()]
    let valoresUber = EstimativaUberAPI.shareInstance
    
    private var zoomMap = Double()
    
    private func atualizaTela(){
        view.addSubview(gpsDesativadoView)
        gpsDesativadoView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        likeButton.alpha = 0.0
        uber99Button.alpha = 0.0
        dislikeLabel.alpha = 0.0
        incidenteLabel.text = "Preencha um incidente antes de enviar"
        incidenteButton.isEnabled = false
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
//        mapaGMSView.setMinZoom(9.0, maxZoom: 19.0)
        mapaGMSView.isBuildingsEnabled = false
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
    
//    func atualizaLinhaAzul() {
//        PathCoordenadas.mutablePath(mutablePath: { (path) in
//            let polyline = GMSPolyline(path: path)
//            polyline.strokeColor = UIColor.blue
//            polyline.strokeWidth = 4
//            polyline.map = self.mapaGMSView
//        })
//    }
    
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
        linhasButton.setTitle("Uber - 99", for: .normal)
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
                
//                let circleCenter = CLLocationCoordinate2D(latitude: -23.543052, longitude: -46.644004)
//                let circ = GMSCircle(position: circleCenter, radius: 20)
//                circ.map = self.mapaGMSView
//
//                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: -23.530541665232146, longitude:  -46.983933448791504))
//                marker.map = self.mapaGMSView
                self.uber99View.center = self.view.center
                self.view.addSubview(self.uber99View)
                
            }
            .disposed(by: disposeBag)
        
    }
    
    func tracarLinhas(){
        LinhasJSON.linhasJSON(linhasArray: { (latitudeArray, longitudeArray) in
            //                    print(latitudeArray.count)
            let coresLinhas: Array<UIColor> = [
                UIColor(red: 255/255, green: 234/255, blue: 0, alpha: 1.0),//amarela
                UIColor(red: 0, green: 0, blue: 128/255, alpha: 1.0),//azul
                UIColor(red: 255/255, green: 138/255, blue: 101/255, alpha: 1.0),//coral
                UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1.0),//diamante
                UIColor(red: 0, green: 151/255, blue: 167/255, alpha: 1.0),//esmeralda
                UIColor(red: 0, green: 200/255, blue: 83/2558, alpha: 1.0),//jade
                UIColor(red: 155/255, green: 56/255, blue: 148/255, alpha: 1.0),//lilas
                UIColor(red: 162/255, green: 169/255, blue: 177/255, alpha: 1.0),//prata
                UIColor(red: 197/255, green: 17/255, blue: 98/255, alpha: 1.0),//rubi
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
            self.markersMapa = markers
            for marker in self.markersMapa {
//                self.mapaGMSView.map({ (map) in
//                    if (map.bounds.contains(marker.groundAnchor)){
//                        marker.map = self.mapaGMSView
//                    }
//                })
                marker.map = self.mapaGMSView
            }
        })
        
    }
    
    func markersEstacoes() {
        RetrieveData.recuperaEstacoesMarkers { (markers) in
            self.markersMapa = markers
            for marker in self.markersMapa {
                marker.map = self.mapaGMSView
                
            }
        }
    }

    func markersEstacoesNil() {
        for marker in self.markersMapa {
            marker.map = nil
            
        }
    }
    
    func overlayEstacoes() {
        
        EstacoesGroundOverlays.estacoesGround { (overlay) in
            overlay.map = self.mapaGMSView
            overlay.isTappable = true
        }
        
    }
    
    func  calcularDistancia(localizacao: CLLocationCoordinate2D) -> Double {
        let dist1 = CLLocation(latitude: latitude, longitude: longitude)
        print(latitude)
        let dist2 = CLLocation(latitude: localizacao.latitude, longitude: localizacao.longitude)
        let distancia = dist1.distance(from: dist2)
        print(distancia.rounded(.up))
        
        return distancia.rounded(.down)
    }
    
    func alertaDistancia(localizacao: CLLocationCoordinate2D) -> UIAlertController {
        
        let alerta = UIAlertController(title: "Distacia", message: "\(self.calcularDistancia(localizacao: localizacao))", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alerta.addAction(cancel)
        
        return alerta
    }
    
    func pickerViewIncidentes(){
        
        let pickerView = UIPickerView()
        pickerView.alpha = 0.8
        pickerView.delegate = self
        incidenteText.inputView = pickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let okButton = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(okClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, okButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        incidenteText.inputAccessoryView = toolBar
        
    }
    
    @objc func okClick(){
        incidenteText.resignFirstResponder()
        
    }
    
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
//        zoomMarkerMostra()
//        votoView.removeFromSuperview()
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
    
    func closePopUp(){
        closeButton.rx.tap
            .bind {
                self.votoView.removeFromSuperview()
            }
            .disposed(by: disposeBag)
    }
    
    func calculaDistanciaSaidas() {
        let saidasRepublica =   [
                                    [-23.54374186150479, -46.64389103651047],
                                    [-23.543026311055478, -46.64396882057189],
                                    [-23.543990213156004, -46.64274305105209],
                                    [-23.544196762686873, -46.64252310991287],
                                    [-23.54391644538778, -46.6420966386795],
                                    [-23.544375, -46.642815]
                                ]
    
        let localizacaoAtual = CLLocation(latitude: geoLocationService.locationManager.location?.coordinate.latitude ?? latitude, longitude: geoLocationService.locationManager.location?.coordinate.longitude ?? longitude)
        for saida in saidasRepublica {
            let distancia = localizacaoAtual.distance(from: CLLocation(latitude: saida[0], longitude: saida[1]))
            print(distancia)
            if distancia <= 11 {
                print("Perto da estacao")
                
                break
            }else{
                print("Nao pode votar")
            }
            
        }

    }
    
    
    func inserirIncidenteButton(interacao: @escaping () -> Void){
        incidenteButton.rx.tap
            .bind {
                let estacaoAPI = self.estacaoMarker.components(separatedBy: .whitespaces).joined().folding(options: .diacriticInsensitive, locale: .current)
                APIRequest.verificaDistanciaEstacao(estacao: estacaoAPI, latitude: self.latitude, longitude: self.longitude, habilitaInteracao: {
                    let parameters: Parameters=["id_usuario": "23", "latitude": self.latitude, "longitude": self.longitude, "incidente": self.incidenteText.text!, "estacao": estacaoAPI]
                    
                    APIRequest.interacaoEstacao(parametros: parameters, habilitaLikes: {
                        self.incidenteButton.alpha = 0.0
                        self.incidenteButton.isEnabled = false
                        self.incidenteText.isEnabled = false
                        self.likeButton.alpha = 1.0
                        self.uber99Button.alpha = 1.0
                        self.dislikeLabel.alpha = 1.0
                        interacao()
                    })
                    
                })
                
            }
            .disposed(by: disposeBag)
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        
        let margins = view.layoutMarginsGuide

        UIView.animate(withDuration: 1.0, animations: {
            let coordenadasCamera = CLLocationCoordinate2DMake(marker.position.latitude, marker.position.longitude)
            let camera = GMSCameraPosition.camera(withTarget: coordenadasCamera, zoom: 16.0)
            mapView.animate(to: camera)
            
        }, completion: { (finished) in
            self.estacaoLabel.text = marker.title
            self.linhaLabel.text = marker.snippet
            
            self.view.addSubview(self.votoView)
            
            self.votoView.layer.cornerRadius = 20.0
            self.votoView.translatesAutoresizingMaskIntoConstraints = false
            self.votoView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -16).isActive = true
            self.votoView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 16).isActive = true
            self.votoView.heightAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 2.0/3.0).isActive = true
            self.votoView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -80.0).isActive = true
            
        })
        
        Observable.of(scoreObs).merge()
            .subscribe({
                $0.event.map({ (event) in
                    if let evento = event as? [String: Any] {
                        if let estacao = evento["estacao"] as? String {
                            if estacao == marker.title?.folding(options: .diacriticInsensitive, locale: .current) {
                                self.dislikeLabel.text = String(evento["score"] as? Int ?? 0)
                                var userData = marker.userData as! [String: Any]
                                userData.updateValue(evento["score"] as! Int, forKey: "score")
                                marker.userData = userData
                            }
                        }
                    }
                })
            })
            .disposed(by: disposeBag)
        
        var markerData = marker.userData as! [String: Any]
        print(markerData["score"])
        
        let interacao = markerData["interacao"] as! Bool
        
        if interacao {
            self.incidenteButton.alpha = 0.0
            self.incidenteButton.isEnabled = false
            self.incidenteText.isEnabled = false
            self.likeButton.alpha = 1.0
            self.uber99Button.alpha = 1.0
            self.dislikeLabel.alpha = 1.0
        }else{
            self.incidenteButton.alpha = 1.0
            self.incidenteButton.isEnabled = true
            self.incidenteText.isEnabled = true
            self.likeButton.alpha = 0.0
            self.uber99Button.alpha = 0.0
            self.dislikeLabel.alpha = 0.0
        }
        
        estacaoMarker = marker.title ?? ""
        
        inserirIncidenteButton(interacao: {
            markerData.updateValue(true, forKey: "interacao")
            marker.userData = markerData
        })
        
        closePopUp()

        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
        print(location)
    }
        
//    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
//
//
//    }
    
//    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//
//        return true
//    }
    
    func verificaFisrtOpen() {
//        let mapViewID = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapViewID")
        if UserDefaults.standard.value(forKey: "FirstOpen") == nil {
            UserDefaults.standard.set(true, forKey: "FirstOpen")
            print("First Open")
            APIRequest.estacoesInfo { (_) in
//                self.present(mapViewID, animated: true)
                self.markersEstacoes()
                self.mapaGMSView.startRendering()
            }
        }else{
            print("Already open another time")
            if UserDefaults.standard.value(forKey: "EstacoesSalvas") == nil {
                APIRequest.estacoesInfo { (_) in
//                    self.present(mapViewID, animated: true)
                    self.markersEstacoes()
                    self.mapaGMSView.startRendering()
                }
            }else{
                //                RetrieveData.recuperaEstacoes()
//                present(mapViewID, animated: true)
                self.markersEstacoes()
                self.mapaGMSView.startRendering()
            }
        }

    }
    
    func inserirIncidenteTextField() {
        let incidenteLabelRx = incidenteText.rx.text.orEmpty
                                .map{ !$0.isEmpty }
                                .share(replay: 1)

        incidenteLabelRx
            .bind(to: incidenteLabel.rx.isHidden)
            .disposed(by: disposeBag)

        let incidenteButtonRx = incidenteText.rx.text.orEmpty
                                    .map{ !$0.isEmpty }
                                    .share(replay: 1)
        
            incidenteButtonRx
                .bind(to: incidenteButton.rx.isEnabled)
                .disposed(by: disposeBag)
        
    }
    
    func dislikeBotao() {
        uber99Button.rx.tap
            .bind{
                UIView.animate(withDuration: 1.0, animations: {
                    
                }, completion: { _ in
                    self.votoView.removeFromSuperview()
                    self.view.addSubview(self.uber99View)
                })
            }
        .disposed(by: disposeBag)
        
    }
    
    var publishZoom = PublishSubject<Float>()
    
    
    func verificaZoom() {
        
        
    }
    
    var mostraMarkerZoom: Float = 12.0
    var markerMostra = true
    
    func zoomMarkerMostra() {
        let zoom = mapaGMSView.camera.zoom
        print(markerMostra)
        print(zoom)
        if markerMostra && zoom > mostraMarkerZoom {
            markerMostra = false
            print("Mostra")
        }else {
            if !markerMostra && zoom <= mostraMarkerZoom{
                markerMostra = true
                print(" Nao Mostra")
            }
        }
    }
    
    func obsEstacao() {
        Observable.of(scoreObs).merge()
            .subscribe({
                $0.event.map({ (event) in
//                    if let evento = event as? [String: Any] {
//
//                    }
                    self.verificaEstacao(estacao: event["estacao"] as? String ?? "", score:  event["estacao"] as? Int ?? 0)
                })
            })
            .disposed(by: disposeBag)
    }
    
    func verificaEstacao(estacao: String, score: Int) {
        
        let estacaoVerifica = estacao.components(separatedBy: .whitespaces).joined().folding(options: .diacriticInsensitive, locale: .current)
        
        for marker in markersMapa {
            let estacaoMarker = (marker.title ?? "").components(separatedBy: .whitespaces).joined().folding(options: .diacriticInsensitive, locale: .current)
            if estacaoVerifica == estacaoMarker {
                print("Igual")
                var userData = marker.userData as! [String: Any]
                userData.updateValue(score, forKey: "score")
                
                break
            }
        }
    }
    
    func uberChamada(){
        uberButton.rx.tap
            .bind{
                //uber://?client_id=<CLIENT_ID>&action=setPickup&pickup[latitude]=37.775818&pickup[longitude]=-122.418028&pickup[nickname]=UberHQ&pickup[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103&dropoff[latitude]=37.802374&dropoff[longitude]=-122.405818&dropoff[nickname]=Coit%20Tower&dropoff[formatted_address]=1%20Telegraph%20Hill%20Blvd%2C%20San%20Francisco%2C%20CA%2094133&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d&link_text=View%20team%20roster&partner_deeplink=partner%3A%2F%2Fteam%2F9383
                
//                let builder = RideParametersBuilder()
//                let pickupLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
//                let dropoffLocation = CLLocation(latitude: -23.543775, longitude: -46.638778)//-23.543775, -46.638778
//                builder.pickupLocation = pickupLocation
//                builder.dropoffLocation = dropoffLocation
//                builder.dropoffNickname = "UberHQ"
//                builder.dropoffAddress = "1455 Market Street, San Francisco, California"
//                let rideParameters = builder.build()
//
//                let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .mobileWeb)
//                deeplink.execute()
                
                self.valoresUber.chamadaEstimativa(estimativaUber: {
                    self.precosCollection.reloadSections(IndexSet(integer: 0))
                })
                
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        dislikeBotao()
//        observableScore()
        pickerViewIncidentes()
        inserirIncidenteTextField()
        obsEstacao()
//        WebSocketa.scoreWebSocket()
        uberChamada()
//        APIRequest.polygonTeste()
        precosCollection.delegate = self
        precosCollection.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        mapaGMSView.stopRendering()
//        verificaFisrtOpen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        WebSocketIO.scoreWebSocket()
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

extension MapaViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        incidenteText.text = pickerOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOption[row]
    }
    
}

extension MapaViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(valoresUber.estimativas.count)
        return valoresUber.estimativas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = precosCollection.dequeueReusableCell(withReuseIdentifier: "uberCell", for: indexPath) as! PrecosCollectionViewCell
        
        let valores = valoresUber.estimativas[indexPath.row]
        
        cell.conteudoUber(tipo: valores.tipoUber, distancia: valores.distanciaMi, duracao: valores.tempoSegundos, estimatica: valores.estimativaValor)
        
        return cell
    }
    
    
}
