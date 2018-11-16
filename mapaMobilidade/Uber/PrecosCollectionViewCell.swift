//
//  PrecosCollectionViewCell.swift
//  mapaMobilidade
//
//  Created by fabio.sousa on 14/11/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import UIKit

class PrecosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var uberImagem: UIImageView!
    @IBOutlet weak var tipoUberLabel: UILabel!
    @IBOutlet weak var distanciaLabel: UILabel!
    @IBOutlet weak var duracaoLabel: UILabel!
    @IBOutlet weak var estimativaLabel: UILabel!
    
    
    func conteudoUber(tipo: String, distancia: Double, duracao: Int, estimatica: String){
        tipoUberLabel.text = tipo
        distanciaLabel.text = "Distancia \((distancia /  0.62137))"
        duracaoLabel.text = "Tempo \((duracao / 60)) min"
        estimativaLabel.text = "Valor \(estimatica)"
        uberImagem.image = UIImage(named: "subway")
    }
    
}
