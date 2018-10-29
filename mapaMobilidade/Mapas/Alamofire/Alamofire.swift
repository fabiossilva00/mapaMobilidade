//
//  Alamofire.swift
//  mapaMobilidade
//
//  Created by Fabio Sousa da Silva on 24/10/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIRequest {
    
    static let shareInstance: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
        
        return SessionManager(configuration: configuration)
    }()
    
    class func estacoesInfo(infosEstacoes: @escaping (_ dicionarioArrayEstacoes: [String: Any]) -> Void) {
        shareInstance.request("http://104.196.60.173:3000/pontos").validate().responseJSON { (response) in
            switch response.result {
            case .success:
                if let respostaServer = response.result.value as? NSArray {
                    let resposta = APIResponse.respostaAPI(respostaServer)
                    let dicionario: [String: Any] = ["latitude": resposta.latitude, "longitude": resposta.longitude, "id": resposta.id, "nome": resposta.nome, "linha": resposta.linha]
                    
                    infosEstacoes(dicionario)
                    
                }else{
                    print(response)
                }
                
                break
            case .failure:
                print(response.error?.localizedDescription ?? "Deu Merda")
                break
            }
            
        }
        
    }
    
}
