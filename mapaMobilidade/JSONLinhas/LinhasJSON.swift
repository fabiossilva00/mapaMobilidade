//
//  LinhasJSON.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 16/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation
import SwiftyJSON

class LinhasJSON {
    
    class func coordenadasJSON(coordenadas: @escaping (_ latitude: Array<Double>, _ longitude: Array<Double>) -> Void) {
        guard let fileName = Bundle.main.path(forResource: "linhaJSON", ofType: "json") else { return }
        guard let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName)) else { return }
        
        do {
            let swiftJSONData = try JSON(data: optionalData)
//            let arrayLinhas = swiftJSONData["coordinates"].arrayValue
            let longitudeArray = swiftJSONData["coordinates"].arrayValue.map ({
                $0[0].doubleValue
            })
            let latitudeArray = swiftJSONData["coordinates"].arrayValue.map ({
                $0[1].doubleValue
            })
            
            coordenadas(latitudeArray, longitudeArray)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
