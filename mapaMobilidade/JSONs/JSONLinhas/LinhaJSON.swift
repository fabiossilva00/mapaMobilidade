//
//  LinhaJSON.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 19/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation

class LinhaJSON {
    class func coordenadas(){
        guard let fileName = Bundle.main.path(forResource: "linha_azul", ofType: "json") else { return }
        guard let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName)) else { return }
        
        guard let trilhos = try? JSONDecoder().decode(LinhasTrilhos.self, from: optionalData) else { return }
        let coordenadas = trilhos.features.map({
            $0.geometry.coordinates
        })
        let longitude = coordenadas.map({
            $0.map({
                $0[0]
            })
        })
        print(longitude.map({
            $0.map({
                $0
            })
        }))
    }
    
}

struct LinhasTrilhos: Codable {
    let features: [Feature]
}

struct Feature: Codable {
    let properties: Properties
    let geometry: Geometry
}

struct Geometry: Codable {
    let coordinates: [[Double]]
}

struct Properties: Codable {
    let stroke: Stroke
    let estacao: String
}

enum Stroke: String, Codable {
    case the000080 = "#000080"
}
