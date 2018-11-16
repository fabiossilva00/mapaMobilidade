//
//  UberViewController.swift
//  mapaMobilidade
//
//  Created by fabio.sousa on 13/11/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import UIKit
import UberRides
import UberCore
import CoreLocation
import Alamofire

typealias EstimativaUberJSON = [String: Any]

//
struct EstimativaUber {
    let tipoUber: String
    let distanciaMi: Double
    let tempoSegundos: Int
    let estimativaValor: String
    
    init(dicionario: EstimativaUberJSON){
        self.tipoUber = dicionario["localized_display_name"] as! String
        self.distanciaMi = dicionario["distance"] as! Double
        self.tempoSegundos = dicionario["duration"] as! Int
        self.estimativaValor = dicionario["estimate"] as! String
        
    }
    
}
//
//final class DataSource {
//    static let shareInstance = DataSource()
//    fileprivate init() {}
//    
//    var viagensUber: [EstimativaUber] = []
//
//    func getViagens(completion: @escaping () -> Void) {
//        
//        
//    }
//    
//    
//}

class UberViewController: UIViewController {
    
    @IBOutlet weak var uberButton: UberButton!
    
    @IBAction func uberButton(_ sender: Any) {
        
//        let builder = RideParametersBuilder()
//        let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
//        let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
//        builder.pickupLocation = pickupLocation
//        builder.dropoffLocation = dropoffLocation
//        builder.dropoffNickname = "UberHQ"
//        builder.dropoffAddress = "1455 Market Street, San Francisco, California"
//        let rideParameters = builder.build()
//        
//        let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .mobileWeb)
//        deeplink.execute()
//        
        APIRequest.chamadaUber(finalizaChamada: {
            
        })
    }

    func habilitaButton() {
        let button = RideRequestButton()
        button.center = view.center
        view.addSubview(button)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        habilitaButton()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

