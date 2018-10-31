//
//  CreateData.swift
//  mapaMobilidade
//
//  Created by fabio.sousa on 30/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import UIKit
import CoreData

class CreateData {
    
    class func createEstacoes(nomeArray: Array<String>, linhaArray: Array<String>, idArray: Array<String>, latitudeArray: Array<Double>, longitudeArray: Array<Double>) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        let managedContext =  appDelegate.persistentContainer.viewContext
        
        guard let estacaoEntity = NSEntityDescription.entity(forEntityName: "Estacoes", in: managedContext) else { return false }
        
        for i in 0 ... (idArray.count - 1) {
            let estacao = NSManagedObject(entity: estacaoEntity, insertInto: managedContext)
            estacao.setValue(idArray[i], forKey: "id")
            estacao.setValue(nomeArray[i], forKey: "nome")
            estacao.setValue(linhaArray[i], forKey: "linha")
            estacao.setValue(latitudeArray[i], forKey: "latitude")
            estacao.setValue(longitudeArray[i], forKey: "longitude")
            
        }
        
        do {
            try managedContext.save()
            
            return true
        } catch let error as NSError {
            print("Deu Merda, \(error), \(error.userInfo)")
            
            return false
        }
        
    }
    
}
