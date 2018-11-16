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
        shareInstance.request("http://104.196.60.173:3001/pontos").validate().responseJSON { (response) in
            print(response.debugDescription)
            switch response.result {
            case .success:
                if let respostaServer = response.result.value as? NSArray {
                    let resposta = APIResponse.respostaAPI(respostaServer)
                    let dicionario: [String: Any] = ["latitude": resposta.latitude, "longitude": resposta.longitude, "id": resposta.id, "nome": resposta.nome, "linha": resposta.linha]
                    if APIResponse.respostaEstacoes(respostaServer) {
                        infosEstacoes(dicionario)
                    }
//                    infosEstacoes(dicionario)
                    
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
    
    class func interacaoEstacao(parametros: Parameters, habilitaLikes: @escaping () -> Void) {
        
//        habilitaLikes()
        
        shareInstance.request("http://104.196.60.173:3000/iteracao", method: .post, parameters: parametros, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            print(response.debugDescription)
            switch response.result {
            case .success:
                habilitaLikes()
//                print(response.result.value ?? "Náo sei o q retornou")
                if let respostaServer = response.result.value as? NSDictionary {
                    if APIResponse.respostaIncidenteInteracao(respostaServer){
                        habilitaLikes()
                    }
                }
                
                habilitaLikes()
                break
            case .failure:
                print(response.error?.localizedDescription ?? "Deu Merda na comunicacao")
                break
            }
        }
        
    }
    
    class func verificaDistanciaEstacao(estacao: String, latitude: Double, longitude: Double, habilitaInteracao: @escaping () -> Void) {
        //http://104.196.60.173:3001/localizacao/Republica/-23.505047/-46.642402
        
        guard let urlRequest = URL(string: "http://104.196.60.173:3000/localizacao/\(estacao)/\(latitude)/\(longitude)") else { return }
        
        shareInstance.request(urlRequest).validate().responseJSON { (response) in
//            print(response.debugDescription)
            switch response.result{
            case .success:
                habilitaInteracao()
                if let respotaServer = response.result.value as? NSDictionary {
                    if APIResponse.respostaInteracao(respotaServer) {
//                        habilitaInteracao()
                    }
                }else{
                    print("Esta longe da localizacao")
                }
                print(response.result.value ?? "Algo que nao sei o q é")
                break
            case .failure(let error):
                print(error.localizedDescription)
                print("Nao foi possivel verificar")
                break
            }
        }
        
    }
    
    class func chamadaUber(finalizaChamada: @escaping () -> Void) {
        
        let headers: HTTPHeaders = ["Authorization": "Token n1SDdbgvYCJWCwtmmBB3-xSKQyrL8Y_GmfCMCbew", "Accept-Language": "pt-br"]
        
        shareInstance.request("https://api.uber.com/v1.2/estimates/price?start_latitude=-23.543052&start_longitude=-46.644004&end_latitude=-23.543999&end_longitude=-46.645999", method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            print(response.debugDescription)
            
            APIResponse().respostaUberEstimativa(response.result.value as! NSDictionary, completion: {
                finalizaChamada()
            })
        }
        
    }
    
//    class func polygonTeste() {
//        
//        let parameters: Parameters=["stationID": "QualquerCoisa", "location": ["latitude": "-23.543052", "longitude": "-46.644004"]]
//        shareInstance.request("http:192.168.15.11:3050/api/v1/issues", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) in
//            
//            print(response.debugDescription)
//            
//        }
//        //stationID
//        //location { latitude, longitude }
//        
//    }
    
}

final class EstimativaUberAPI {
    
    static let shareInstance = EstimativaUberAPI()
    
    var estimativas: [EstimativaUber] = []
    
    func chamadaEstimativa(estimativaUber: @escaping () -> Void) {
     
        let headers: HTTPHeaders = ["Authorization": "Token n1SDdbgvYCJWCwtmmBB3-xSKQyrL8Y_GmfCMCbew", "Accept-Language": "pt-br"]
        
        APIRequest.shareInstance.request("https://api.uber.com/v1.2/estimates/price?start_latitude=-23.543052&start_longitude=-46.644004&end_latitude=-23.543999&end_longitude=-46.645999", method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            self.estimativas.removeAll()
            if let respostaServer = response.result.value as? EstimativaUberJSON {
                if let jsonPrices = respostaServer["prices"] as? Array<[String: Any]> {
                    for prices in jsonPrices {
                        let preco = EstimativaUber(dicionario: prices)
                        self.estimativas.append(preco)
                    }
                    estimativaUber()
                }
                
            }
            
        }
        
    }
    
    
}
