//
//  PathCoordenadas.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 16/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation
import GoogleMaps

class PathCoordenadas {
    
    class func mutablePath(mutablePath: @escaping (_ path: GMSMutablePath) -> Void) {
        LinhasJSON.coordenadasJSON { (latitude, longitude) in
            let path = GMSMutablePath()
            for i in 0 ... (latitude.count - 1) {
                path.add(CLLocationCoordinate2D(latitude: latitude[i], longitude: longitude[i]))
            }
            mutablePath(path)
        }
    }
    
    class func mutablePathtoPolyline(nomeArquivo: String, mutablePath: @escaping (_ path: GMSMutablePath) -> Void) {
        JSONDeuMerda.coordenadasJSON(nomeArquivo: nomeArquivo) { (latitude, longitude) in
            let path = GMSMutablePath()
            for i in 0 ... (latitude.count - 1) {
                path.add(CLLocationCoordinate2D(latitude: latitude[i], longitude: longitude[i]))
            }
            mutablePath(path)
        }
    }
    
}
