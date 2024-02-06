//
//  ViewController.swift
//  Multipart POST Request
//
//  Created by Macbook Air 2017 on 5. 2. 2024..
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        postRequest()
    }

    private func postRequest() {
            
        guard let url = URL(string: POST_IMAGE_ENDPOINT) else {
            return
        }
            
        var urlRequest = URLRequest(url: url)
            
        urlRequest.httpMethod = "POST"
            
        let boundary = generateBoundary()
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        // After we set some value, we want to append the rest values to it, to add them:
        urlRequest.addValue("Client-ID \(MY_CLIENT_ID)", forHTTPHeaderField: "Authorization")
            
        let parameters = [
            "name": "MyTestFile123123",
            "description": "This is my tutorial test for multipart POST request."
        ]
            
        guard let mediaImage = Media(withImage: UIImage(named: "goldenRetriver")!, forKey: "image") else {
            return
        }
            
        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        urlRequest.httpBody = dataBody
            
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
            data, response, error in
                
            if error != nil {
                print("Error occured.")
                return
            }
                
            if let response = response as? HTTPURLResponse {
                print("Status code: \(response.statusCode)")
            }
        })
        task.resume()
    }
    
    private func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    private func createDataBody(withParameters params: [String: String]?, media: [Media]?, boundary: String) -> Data {
            
        // Every server now should be able to read it as a line break
        let lineBreak = "\r\n"
            
        var body = Data()
            
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
            
        if let media = media {
            for item in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(item.key)\"; filename=\"\(item.filename)\"\(lineBreak)")
                body.append("Content-Type: \(item.mimeType + lineBreak + lineBreak)")
                body.append(item.data)
                body.append("\(lineBreak)")
            }
        }
            
        // This is where the boundary ends, this is the end where the data are related to each other
        body.append("--\(boundary)--\(lineBreak)")
            
        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
