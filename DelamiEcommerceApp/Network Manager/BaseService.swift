//
//  BaseService.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 22/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//
import UIKit
import Alamofire

struct AlamofireRequestModal {
    var method: Alamofire.HTTPMethod
    var path: String
    var parameters: [String: AnyObject]?
    var encoding: ParameterEncoding
    var tokenType: ApiTokenType = .admin
    
    init() {
        method = .post
        path = ""
        parameters = nil
        encoding = JSONEncoding() as ParameterEncoding
    }
}

class MultipartDataModal {
    enum MultipartDataType {
        case image
//        case video
    }
    
    var type: MultipartDataType
    var fileName: String
    var data: Data
    
    init(type: MultipartDataType, fileName: String, data: Data) {
        self.type = type
        self.fileName = fileName
        self.data = data
    }
}

class BaseService: NSObject {
    let network = Reachability.init(hostname: "https://www.google.com")
    
    func callWebServiceAlamofire(_ alamoReq: AlamofireRequestModal, success:@escaping ((_ responseObject: AnyObject?) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        guard (network?.isReachable)! else {
            Loader.shared.hideLoading()
            Utils().showAlert(title: AlertTitle.none, message: AlertMessage.noInternet.localized())
            return
        }
        
        let storeCode = UserDefaults.standard.getStoreCode() ?? ""
        
        // creating api request url
        var requestUrl = API.baseURL + storeCode + alamoReq.path
        requestUrl += requestUrl.contains("?") ? "&___store=\(storeCode)" : "?___store=\(storeCode)" // Added "___store={storeCode}" for web multilingual translation
        
        // creating api request header
        let reqHeader = fetchRequestHeader(alamoReq)
        
        // preparing api request
        let request = Alamofire.request(requestUrl, method: alamoReq.method, parameters: alamoReq.parameters, encoding: alamoReq.encoding, headers: reqHeader)
        
        // Printing API description
        let api = "\(request.request?.httpMethod ?? "") \(String(describing: request.request?.url))"
        let header = "\(String(describing: request.request?.allHTTPHeaderFields))"
        let body = "\(getRequestJSONString(paramDict: alamoReq.parameters))"
        debugPrint("API Detail:", api, header, body, separator: "\n", terminator: "\n\n")
        
        // getting response: call response handler method of alamofire
        request.validate().responseJSON(completionHandler: { response in
            self.handleReceivedInfo(response, success: success, failure: failure)
        })
    }
    
    func handleReceivedInfo(_ response: DataResponse<Any>,
                            success:@escaping ((_ responseObject: AnyObject?) -> Void),
                            failure:@escaping ((_ error: NSError?) -> Void)) {
        
        let statusCode = response.response?.statusCode
        
        switch response.result {
        case .success(let data):
            if statusCode == 200 {
                if let result = data as? String {
                    success(result as AnyObject)
                    
                } else if let result = data as? Bool {
                    success(result as AnyObject)
                    
                } else if let result = data as? Int {
                    success(result as AnyObject)
                    
                } else {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
                        success(jsonData as AnyObject)
                    } catch let msg {
                        debugPrint("JSON serialization error:" + "\(msg)")
                        failure(nil)
                    }
                }
            } else {
                if let errorMessage = (data as? NSDictionary)?.value(forKey: "error") {
                    let errorTemp = NSError.init(domain: "", code: statusCode!, userInfo: ["error": errorMessage])
                    debugPrint("\n Failure: \(errorTemp.localizedDescription), errorMessage: \(errorMessage)")
                    failure(errorTemp as NSError?)
                }
            }
        case .failure(_):
            if let data = response.data {
                var errorData: NSError?
                
                do {
                    if  let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                        var message = ""
                        if let string = (responseObject as NSDictionary).value(forKey: "message") as? String {
                            message = string
                        }
                        errorData = NSError.init(domain: "", code: statusCode!, userInfo: ["message": message])
                        failure(errorData)
                    }
                } catch let error as NSError {
                    errorData = error
                    failure(errorData)
                }
            }
            //                    debugPrint("\n Failure: \(error.localizedDescription)")
            //                    failure(error as NSError?)
        }
    }
    
}

extension BaseService {
    func fetchRequestHeader(_ alamoReq: AlamofireRequestModal) -> [String: String]? {
        switch alamoReq.tokenType {
        case .admin:
            return [API.Headers.Authorization: getAdminToken()]
        case .customer:
            return [API.Headers.Authorization: getCustomerToken()]
        default:
            break
        }
        return nil
    }
    
    func getAdminToken() -> String {
        let adminToken =  API.Token.adminToken
        return "Bearer " + adminToken
    }
    
    func getCustomerToken() -> String {
        if let token = UserDefaults.standard.getUserToken() {
            return "Bearer \(token)"
        } else {
            debugPrint("customer token is not available")
            return ""
        }
    }
    
    // Call Alomofire for image attachment
    func callWebServiceAlamofireForAttachment(imageDict: [String: Data], fileName: String, alamoReq: AlamofireRequestModal, success:@escaping ((_ responseObject: AnyObject?) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        
        var params: [String: String]?
            if let val = alamoReq.parameters as? [String: String] {
                params = val
        }
        
        // creating api request url
//          let requestUrl = "http://192.168.10.66/delami/rest/V1/banktransfer/submit"
        
        let storeCode = UserDefaults.standard.getStoreCode() ?? ""
        
        // creating api request url
        let requestUrl = API.baseURL + storeCode + alamoReq.path

        // Call response handler method of alamofire
        Alamofire.upload(multipartFormData: { multipartFormData in
            //            guard let imageData = alamoReq.parameters!["attachment"] as? Data else {
            //                let encodingError = NSError()
            //                print("error: \(encodingError.localizedDescription)")
            //                failure(encodingError as NSError?)
            //                return
            //            }
            //            multipartFormData.append(imageData, withName: fileName, fileName: fileName + ".jpeg", mimeType: "image/jpeg")
            
            let imgData = Array(imageDict.values)[0]
            let imgName = Array(imageDict.keys)[0] as String
            multipartFormData.append(imgData, withName: imgName, fileName: fileName + ".jpeg", mimeType: "image/jpeg")
            
            for (key, value) in params! {
                // Appending parameters in the request
                multipartFormData.append((value.data(using: .utf8))!, withName: key)
            }
            
        }, to: requestUrl, method: alamoReq.method, headers: fetchRequestHeader(alamoReq), encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.validate(statusCode: 200..<300).responseJSON(completionHandler: { (receivedInfo) in
                        self.handleReceivedInfo(receivedInfo, success: success, failure: failure)
                    })
                case .failure(let encodingError):
                    print("error: \(encodingError.localizedDescription)")
                    failure(encodingError as NSError?)
                }
            })
    }
    
    func getRequestJSONString(paramDict: [String: AnyObject]?) -> String {
        var jsonString = ""
        if let param = paramDict {
            if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: []) {
                jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            }
        }
        return jsonString
    }
}
