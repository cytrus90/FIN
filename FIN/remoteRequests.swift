//
//  updateRemote.swift
//  NicosGame
//
//  Created by Florian Riel on 13.05.21.
//

import Foundation

class alpakoPHPRequest {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    func sendMail(parameters: [String: String], url: String) {
        let request = networkModel.request(parameters: parameters, url: url)
        networkModel.response(request: request) { (data) in
            print("Remote Requested")
        }
    }
}
