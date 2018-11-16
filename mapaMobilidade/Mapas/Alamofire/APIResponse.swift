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
    
    class func respostaEstacoes(_ jsonEstacoes: NSArray) -> Bool {
        let json = JSON(jsonEstacoes)
        print(json)
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
        
        if CreateData.createEstacoes(nomeArray: nomeArray, linhaArray: linhaArray, idArray: idArray, latitudeArray: latitudeArray, longitudeArray: longitudeArray) {
             UserDefaults.standard.set(true, forKey: "EstacoesSalvas")
            return true
        }else{
            
            return false
        }
        
    }
    
    class func respostaInteracao(_ jsonInteracao: NSDictionary) -> Bool{
        let json = JSON(jsonInteracao)
        
        return json["iteracao"].bool ?? false
    }
    
    class func respostaIncidenteInteracao(_ jsonIncidente: NSDictionary) -> Bool {
        let json = JSON(jsonIncidente)
        
        return json["error"].bool ?? true
    }
    
    var estimativas: [EstimativaUber] = []
    

    func respostaUberEstimativa(_ jsonUberEstimativa: NSDictionary, completion: @escaping () -> Void) {
        
        let json = JSON(jsonUberEstimativa)
        let prices = json["prices"].arrayValue
        
        var displayName = Array<String>()
        var distanciaMi = Array<Double>()
        var duracaoSegundos = Array<Int>()
        var estimativaValor =  Array<String>()
        
        for price in prices {
            let tipoUber = price["localized_display_name"].stringValue
//            print(displayName)
            displayName.append(tipoUber)
            distanciaMi.append(price["distance"].doubleValue)
            duracaoSegundos.append(price["duration"].intValue)
            estimativaValor.append(price["estimate"].stringValue)
        }
        print(displayName)
        print(distanciaMi)
        print(duracaoSegundos)
        print(estimativaValor)
        
        print(type(of: jsonUberEstimativa))
        if let jsonPrices = jsonUberEstimativa["prices"] as? Array<[String: Any]> {
            for prices in jsonPrices {
                let preco = EstimativaUber(dicionario: prices as EstimativaUberJSON)
                estimativas.append(preco)
            }
            
        }
        
        print(estimativas)
        completion()
        
//        let tipoUber = json["prices"][0]["localized_display_name"].stringValue
//        print(tipoUber)
//        let distanciaMi = json["prices"][0]["distance"].doubleValue
//        print(distanciaMi)
//        let distanciaKm = distanciaMi / 0.62137
//        print(distanciaKm)
//        let duracaoSeg = json["prices"][0]["duration"].intValue
//        print(duracaoSeg)
//        let duracaoMin = duracaoSeg / 60
//        print(duracaoMin)
//        let estimativa = json["prices"][0]["estimate"].stringValue
//        print(estimativa)

    }
    
}

