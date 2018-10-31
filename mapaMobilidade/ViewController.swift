//
//  ViewController.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 16/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    func verificaFisrtOpen() {
        let mapViewID = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapViewID")
        if UserDefaults.standard.value(forKey: "FirstOpen") == nil {
            UserDefaults.standard.set(true, forKey: "FirstOpen")
            print("First Open")
            APIRequest.estacoesInfo { (_) in
                self.present(mapViewID, animated: true)
            }
        }else{
            print("Already open another time")
            if UserDefaults.standard.value(forKey: "EstacoesSalvas") == nil {
                APIRequest.estacoesInfo { (_) in
                    self.present(mapViewID, animated: true)
                }
            }else{
                //                RetrieveData.recuperaEstacoes()
                present(mapViewID, animated: true)
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        verificaFisrtOpen()
    }


}

