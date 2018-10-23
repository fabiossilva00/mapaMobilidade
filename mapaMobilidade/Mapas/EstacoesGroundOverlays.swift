//
//  EstacoesGroundOverlays.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 17/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMaps

class EstacoesGroundOverlays {
    
    class func estacoesGround(overlayEstacoes: @escaping (_ overlay: GMSGroundOverlay) -> Void) {
        EstacoesJSON.estacoesDados { (nomeArray, latitudeArray, longitudeArray) in
//            let path = GMSMutablePath()
//
//            for i in 0 ... (nomeArray.count - 1) {
//                path.add(CLLocationCoordinate2D(latitude: latitudeArray[i], longitude: longitudeArray[i]))
//            }
            
//            let overlayBounds = GMSCoordinateBounds(path: path)
            let overlayBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: (latitudeArray[0] + 0.000100), longitude: (longitudeArray[0] + 0.000100)), coordinate: CLLocationCoordinate2D(latitude: (latitudeArray[0] - 0.000100), longitude: (longitudeArray[0] - 0.000100)))
            
            let icon = UIImage(named: "180")
            let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
            overlay.bearing = 0
            overlay.title = nomeArray[0]
            overlayEstacoes(overlay)
        }
        
    }
    
}
