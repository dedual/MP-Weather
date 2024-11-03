//
//  OpenWeatherError.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/2/24.
//

import Foundation

struct OpenWeatherError:Codable, Equatable
{
    let code:String
    let message:String
    
    enum CodingKeys:String, CodingKey
    {
        case code = "cod"
        case message
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try values.decode(String.self, forKey: .code)
        self.message = try values.decode(String.self, forKey: .message)
    }
        
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)
    }
        
}
