//
//  EstacoesJSON.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 17/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation
import SwiftyJSON

class EstacoesJSON {
    
    class func estacoesDados(estacoes: @escaping (_ nome: Array<String>, _ latitude: Array<Double>, _ longitude: Array<Double>) -> Void) {
        
        guard let fileName = Bundle.main.path(forResource: "estacoes", ofType: "json") else { return }
        guard let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName)) else { return }
        
        do {
            let swiftJSONData =  try JSON(data: optionalData)
//            let estacoes = swiftJSONData["estacoes"].arrayValue
            let nomeArray = swiftJSONData["estacoes"].arrayValue.map({
                $0["nome"].stringValue
            })
//            print(nomeArray)
            let latitudeArray = swiftJSONData["estacoes"].arrayValue.map({
                $0["coordenadas"][0].doubleValue
            })
//            print(latitudeArray)
            let longitudeArray = swiftJSONData["estacoes"].arrayValue.map({
                $0["coordenadas"][1].doubleValue
            })
//            print(longitudeArray)
            
            estacoes(nomeArray, latitudeArray, longitudeArray)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
}
