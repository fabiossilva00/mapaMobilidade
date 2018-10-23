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
    
    class func linhasJSON(linhasArray: @escaping (_ latitude: Array<Array<Double>>, _ longitude: Array<Array<Double>>) -> Void ) {
        
        let linhaNome = ["linha_amarela", "linha_azul", "linha_diamante", "linha_esmeralda", "linha_lilas", "linha_prata", "linha_rubi", "linha_safira", "linha_turquesa", "linha_verde", "linha_vermelha"]
        print(linhaNome)
        var latitudeLinhas = Array<Array<Double>>()
        var longitudeLinhas = Array<Array<Double>>()
//        var latitudee = Array<Double>()
//        var longitudee = Array<Double>()
        
        for i in 0 ... (linhaNome.count - 1) {
            guard let fileName = Bundle.main.path(forResource: linhaNome[i], ofType: "json") else { return }
            guard let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName)) else { return }
            do {
                let swiftJSONData = try JSON(data: optionalData)
                //            print(swiftJSONData["features"])
                //            print(swiftJSONData["features"].count)
                let latitudeArray = swiftJSONData["features"].arrayValue.map({
                    $0["geometry"]["coordinates"].map({
                        $1[1].doubleValue
                    })
                    
                })
                let longitudeArray = swiftJSONData["features"].arrayValue.map({
                    $0["geometry"]["coordinates"].map({
                        $1[0].doubleValue
                    })
                })
                
                let latitude = latitudeArray.map({
                    $0
                })
                
                let longitude = longitudeArray.map({
                    $0
                })
                
                //            print(latitude)
                var latiArray = Array<Double>()
                for lat in latitude {
                    for latiti in lat {
                        latiArray.append(latiti)
//                        latitudee.append(latiti)
                    }
                }
                latitudeLinhas.append(latiArray)
//                print(latiArray)
                
                var longArray = Array<Double>()
                for long in longitude {
                    for longigi in long {
                        longArray.append(longigi)
//                        longitudee.append(longigi)
                    }
                }
                longitudeLinhas.append(longArray)
//                print(longArray)
                
            } catch {
                print(error.localizedDescription)
                break
            }
        }
        linhasArray(latitudeLinhas, longitudeLinhas)
//        print(latitudeLinhas)
//        print(longitudeLinhas)
//        print(latitudee)
//        print(longitudee)
        
    }
    
    //features[0][geometry][coodinates].arrayValue.map ({ $0[0].doubleValue )}
    
}
