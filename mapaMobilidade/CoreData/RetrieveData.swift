//
//  RetrieveData.swift
//  mapaMobilidade
//
//  Created by fabio.sousa on 30/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

class RetrieveData {
    
    class func recuperaEstacoesMarkers(markers: @escaping (_ markerArray: Array<GMSMarker>) -> Void){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Estacoes")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            var markerArray = Array<GMSMarker>()
            
            for data in result as! [NSManagedObject] {
                
//                print("Estacoes ID ", data.value(forKey: "id") as! String)
//                print("Estacoes Nome ", data.value(forKey: "nome") as! String)
//                print("Estacoes Linha ", data.value(forKey: "linha") as! String)
//                print("Estacoes Latitude ", data.value(forKey: "longitude") as! Double)
//                print("Estacoes Longitude ", data.value(forKey: "latitude") as! Double)
                
                let spot: [String: Any] = ["id": data.value(forKey: "id") as! String, "interacao": false]
                
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: data.value(forKey: "latitude") as! Double, longitude: data.value(forKey: "longitude") as! Double))
                marker.title = data.value(forKey: "nome") as! String
                marker.snippet = data.value(forKey: "linha") as! String
                marker.userData = spot
                markerArray.append(marker)
                
            }
            markers(markerArray)
            
        } catch let error as NSError {
            print("Deu Merda em recuperar, \(error), \(error.userInfo)")
        }
        
    }
    
}
