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
    
    @IBOutlet var votoView: UIView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var dislikeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var incidenteButton: UIButton!
    @IBOutlet weak var incidenteText: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var estacaoLabel: UILabel!
    @IBOutlet weak var linhaLabel: UILabel!
    @IBOutlet weak var incidenteLabel: UILabel!
    
    private let geoLocationService = GeolocationService.instance
    var disposeBag = DisposeBag()
    
    var latitude = Double()
    var longitude = Double()
    var pickerOption = ["Usuário na via", "Maior tempo de parada", "Outro incidente"]
    var estacaoMarker = String()
    var markersMapa = [GMSMarker()]
    
    private func atualizaTela(){
        view.addSubview(gpsDesativadoView)
        gpsDesativadoView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        likeButton.alpha = 0.0
        dislikeButton.alpha = 0.0
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
        mapaGMSView.setMinZoom(9.0, maxZoom: 19.0)
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
        linhasButton.setTitle("Polygon", for: .normal)
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
                
                let circleCenter = CLLocationCoordinate2D(latitude: -23.543052, longitude: -46.644004)
                let circ = GMSCircle(position: circleCenter, radius: 20)
                circ.map = self.mapaGMSView
                
                
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
    
    func markersEstacoes() {
        RetrieveData.recuperaEstacoesMarkers { (markers) in
            self.markersMapa = markers
            for marker in self.markersMapa {
                marker.map = self.mapaGMSView
                
            }
        }
    }

    func markersEstacoesNil() {
            
        
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
    
//    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
//
////        mapaGMSView.map { (map)  in
////            print(map.camera.zoom)
////            if map.camera.zoom < 12.0 {
////                print("Algo")
//////                mapaGMSView.clear()
////            }else{
//////                print("Outra coisa")
////                markerEstacoes()
////            }
////        }
//
//    }
    
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

                APIRequest.verificaDistanciaEstacao(estacao: self.estacaoMarker.components(separatedBy: .whitespaces).joined().folding(options: .diacriticInsensitive, locale: .current), latitude: self.latitude, longitude: self.longitude, habilitaInteracao: {
                    let parameters: Parameters=["id_usuario": "1", "latitude": self.latitude, "longitude": self.longitude, "incidente": self.incidenteText.text!]
                    
                    APIRequest.interacaoEstacao(parametros: parameters, habilitaLikes: {
                        self.incidenteButton.alpha = 0.0
                        self.incidenteButton.isEnabled = false
                        self.incidenteText.isEnabled = false
                        self.likeButton.alpha = 1.0
                        self.dislikeButton.alpha = 1.0
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
        
        var markerData = marker.userData as! [String: Any]
        print(markerData["interacao"])
        
        let interacao = markerData["interacao"] as! Bool
        
        if interacao {
            self.incidenteButton.alpha = 0.0
            self.incidenteButton.isEnabled = false
            self.incidenteText.isEnabled = false
            self.likeButton.alpha = 1.0
            self.dislikeButton.alpha = 1.0
            self.dislikeLabel.alpha = 1.0
        }else{
            self.incidenteButton.alpha = 1.0
            self.incidenteButton.isEnabled = true
            self.incidenteText.isEnabled = true
            self.likeButton.alpha = 0.0
            self.dislikeButton.alpha = 0.0
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
        var voto = 0
        dislikeButton.rx.tap
            .bind{
                voto += 1
                self.dislikeLabel.text = "\(voto)"
            }
        .disposed(by: disposeBag)
        
    }
    
    func observableScore(){
     
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        atualizaTela()
        configuracaoTapRx()
        atualizaGPS()
        gpsRx()
//        atualizaLinhaAzul()
//        deuMerdaBotao()
//        markerEstacoes()
//        overlayEstacoes()
        linhasJSONButton()
        tracarLinhas()
        dislikeBotao()
        pickerViewIncidentes()
        inserirIncidenteTextField()
        
//        WebSocketa.scoreWebSocket()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapaGMSView.stopRendering()
        verificaFisrtOpen()
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
