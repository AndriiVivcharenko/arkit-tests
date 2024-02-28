//
//  OpenAiResponse.swift
//  arkit-tests
//
//  Created by Andrii Vivcharenko on 28.02.2024.
//

import Foundation

struct OpenAiResponse : Decodable {

    let id: String
    let object: String
    let created: Int32
    let model: String
    let usage: Usage
    let choices: [Choice]

    struct Usage : Decodable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }

    struct Choice: Decodable {

        struct Message: Decodable {
            let role: String
            let content: String
        }

        let message: Message
        let finish_reason: String
        let index: Int

    }

}
