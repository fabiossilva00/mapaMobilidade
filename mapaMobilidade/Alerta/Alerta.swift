//
//  Alerta.swift
//  mapaMobilidade
//
//  Created by fabio.sousa on 25/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import UIKit

class AlertaCustom: UIAlertController {
    
    var alertaSimple: UIAlertController = {
        let alerta = UIAlertController(title: "Cuidado", message: "Deu Merda", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Corre", style: .destructive, handler: nil)
        alerta.addAction(cancelButton)
        
        return alerta
    }()
    
}
