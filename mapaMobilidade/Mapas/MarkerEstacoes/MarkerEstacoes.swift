//
//  MarkerEstacoes.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 17/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

class MarkerEstacoes {
    
    class func markerArray(markers: @escaping (_ markerArray: Array<GMSMarker>) -> Void){
//        EstacoesJSON.estacoesDados { (nome, latitude, longitude) in
//
//            var markerArray = Array<GMSMarker>()
//            for i in 0 ... (nome.count - 1) {
//                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude[i], longitude: longitude[i]))
//                marker.title = nome[i]
//                markerArray.append(marker)
//            }
//            markers(markerArray)
//        }
        
        APIRequest.estacoesInfo(infosEstacoes: { (dicioEstacoes) in
            var markerArray = Array<GMSMarker>()

            guard let id = dicioEstacoes["id"] as? Array<String> else { return }
            guard let nome = dicioEstacoes["nome"] as? Array<String> else { return }
            guard let linha = dicioEstacoes["linha"] as? Array<String> else { return }
            guard let latitude = dicioEstacoes["latitude"] as? Array<Double> else { return }
            guard let longitude = dicioEstacoes["longitude"] as? Array<Double> else { return }

            for j in 0 ... (id.count - 1) {
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude[j], longitude: longitude[j]))
                marker.title = nome[j]
                marker.snippet = linha[j]
                let spot: [String: Any] = ["id": id, "interacao": false, "score": 0]
                marker.userData = spot
                markerArray.append(marker)
            }

            markers(markerArray)
        })
    }
    
}
