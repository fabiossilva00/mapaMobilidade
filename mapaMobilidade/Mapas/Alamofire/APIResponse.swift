//
//  APIResponse.swift
//  mapaMobilidade
//
//  Created by fabio.sousa on 29/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation
import SwiftyJSON

class APIResponse {
    
    class func respostaAPI(_ jsonEstacoes: NSArray) -> (latitude: Array<Double>, longitude: Array<Double>, id: Array<String>, nome: Array<String>, linha: Array<String>) {
        let json = JSON(jsonEstacoes)
//        let localizacaoArray = json.arrayValue.map({
//            $0["localizacao"].dictionaryValue
//        })
        let coordenadasArray = json.arrayValue.map({
            $0["localizacao"]["coordinates"].arrayValue
        })
        
        var latitudeArray = Array<Double>()
        var longitudeArray = Array<Double>()
        for coordenada in coordenadasArray {
            latitudeArray.append(coordenada[1].doubleValue)
            longitudeArray.append(coordenada[0].doubleValue)
        }
        
        let idArray = json.arrayValue.map({
            $0["_id"].stringValue
            
        })
        
        let nomeArray = json.arrayValue.map({
            $0["nome"].stringValue
        })
        
        
        let linhaArray = json.arrayValue.map({
            $0["linha"].stringValue
        })
        
        return (latitudeArray, longitudeArray, idArray, nomeArray, linhaArray)
    }
    
}
