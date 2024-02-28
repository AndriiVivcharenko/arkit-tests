//
//  ARSessionWrapper.swift
//  arkit-tests
//
//  Created by Andrii Vivcharenko on 26.02.2024.
//

import Foundation
import ARKit
import Alamofire

class ARSessionWrapper: ObservableObject {
    @Published var arView = ARSCNView()
    @Published var timer: Timer?

    //
    static private let apiToken = " your openai api key here"
    static private let baseUrl = "https://api.openai.com/v1/chat/completions"

    static private let prompt: String = """
Provide an ideal position for placing the chair in the given image.
Please follow the format below for normalization:

Center: (0.0, 0.0)
Right: (1.0, 0.0)
Left: (-1.0, 0.0)
Top: (0.0, 1.0)
Bottom: (0.0, -1.0)

JSON Output Example:

    {
        "x": 0.0,
        "y": 0.0
    }

Please respond in JSON format only

"""

    static private let systemPrompt: String = """
You are an experienced furniture designer.
You will be provided with a photo of the room and the furniture the user would like to place.
You have to offer the user a good place to place the furniture.
If there is no space, suggest at least an approachable good location.
"""


    init() {
        arView.session.run(ARWorldTrackingConfiguration())
    }

    func deinitialize() {
        print("deinit ar session wrapper")
        arView.session.pause()
        timer?.invalidate()
        timer = nil
    }

    func captureImage(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.async {
            let snapshop = self.arView.snapshot()
            completion(snapshop)
        }
    }

    func requestGpt4V(completion: @escaping (OpenAIPositionResponse) -> Void) {

        captureImage {image in
            guard let image = image else {return}

            let newSize = CGSize(width: image.size.width * 0.25, height: image.size.height * 0.25)
            if let resizedImage = image.resize(targetSize: newSize) {
                if let imageData = resizedImage.pngData() {
                    let imageBase64 = imageData.base64EncodedString()

                    var imageSize: Int = NSData(data: imageData).count
                    print("actual size of image in KB: %f ", Double(imageSize) / 1000.0)

                    let headers: HTTPHeaders = [
                        "Content-Type": "application/json",
                        "Authorization":  "Bearer \(ARSessionWrapper.apiToken)"
                    ]

                    let payload = [
                        "model": "gpt-4-vision-preview",
                        "max_tokens": 32,
                        "messages": [
                            [
                                "role": "system",
                                "content": ARSessionWrapper.systemPrompt
                            ],
                            [
                                "role": "user",
                                "content": [
                                    [
                                        "type": "image_url",
                                        "image_url": [
                                            "url": "data:image/png;base64,\(imageBase64)"
                                        ]
                                    ] as! Any,
                                    [
                                        "type": "text",
                                        "text": ARSessionWrapper.prompt
                                    ] as! Any,
                                ]
                            ]
                        ]
                    ] as! [String : Any]

                    print(payload)

                    AF.request(ARSessionWrapper.baseUrl,
                               method: .post,
                               parameters: payload,
                               encoding: JSONEncoding.default,
                               headers: headers
                    ).responseString { data in

                        print(data.result)

                        do {

                            let openAiResponse: OpenAiResponse = try JSONDecoder().decode(
                                OpenAiResponse.self,
                                from: data.result.get().data(using: .utf8)!
                            )

                            print(openAiResponse)

                            let json_text = openAiResponse.choices.first!.message.content
                                .replacingOccurrences(of: "```json", with: "")
                                .replacingOccurrences(of: "```", with: "")

                            print(json_text)

                            let openAiPositionResponse: OpenAIPositionResponse = try JSONDecoder().decode(
                                OpenAIPositionResponse.self,
                                from: json_text.data(using: .utf8)!
                            )

                            completion(openAiPositionResponse)
                        } catch let error {
                            print("Error")
                            print(error.localizedDescription)
                        }

                    }
                }
            }
        }

    }
}
