//
//  AppClient.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 21/07/21.
//

import Foundation
import SystemConfiguration

class AppClient: NSObject {

    struct Auth {
        static var sessionId: String? = nil
        static var key = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
    }
    
    enum ApiType: String {
        case Udacity = "Udacity"
        case Parse = "Parse"
    }
    
    enum HttpMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
    }
    
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case udacitySignUp
        case udacityLogin
        case getStudentLocations
        case addLocation
        case updateLocation
        case getLoggedInUserProfile
        
        var stringValue: String {
            switch self {
            case .udacitySignUp:
                return "https://auth.udacity.com/sign-up"
            case .udacityLogin:
                return Endpoints.base + "/session"
            case .getStudentLocations:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .addLocation:
                return Endpoints.base + "/StudentLocation"
            case .updateLocation:
                return Endpoints.base + "/StudentLocation/" + Auth.objectId
            case .getLoggedInUserProfile:
                return Endpoints.base + "/users/" + Auth.key
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    override init() {
        super.init()
    }
    
    // MARK: Log In
    
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        taskForRequest(url: Endpoints.udacityLogin.url, method: HttpMethod.POST.rawValue, apiType: ApiType.Udacity.rawValue, body: body, responseType: LoginResponse.self) { response, error in
            guard let response = response else {
                DispatchQueue.main.async {
                    completion(false,error)
                }
                return
            }
            Auth.sessionId = response.session.id
            Auth.key = response.account.key
            getLoggedInUserProfile(completion: { (success, error) in
                DispatchQueue.main.async {
                    success == true ? completion(true, nil) : completion(false, error)
                }
            })
        }
    }
    
    // MARK: Get Logged In User Profile
    
    class func getLoggedInUserProfile(completion: @escaping (Bool, Error?) -> Void) {
        AppClient.taskForRequest(url: Endpoints.getLoggedInUserProfile.url, method: "GET", apiType: ApiType.Udacity.rawValue, body: "", responseType: UserProfile.self) { response, error in
            if let response = response {
                print("First Name : \(response.firstName) && Last Name : \(response.lastName) && Full Name: \(response.nickname)")
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                print("Failed to get user's profile.")
                completion(false, error)
            }
        }
    }
    
    // MARK: Log Out
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.udacityLogin.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error logging out.")
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    // MARK: Get All Students Locations
    
    class func getStudentLocations(completion: @escaping ([StudentInformation]?, Error?) -> Void) {
        AppClient.taskForRequest(url: Endpoints.getStudentLocations.url, method: HttpMethod.GET.rawValue, apiType: ApiType.Parse.rawValue, body: "", responseType: StudentsLocation.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    // MARK: Add a Student's Location
   
    class func addStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        AppClient.taskForRequest(url: Endpoints.addLocation.url, method: HttpMethod.POST.rawValue, apiType: ApiType.Parse.rawValue, body: body, responseType: PostLocationResponse.self) { response, error in
            if let response = response, response.createdAt != nil {
                Auth.objectId = response.objectId ?? ""
                completion(true, nil)
            }
            completion(false, error)
        }
    }
    
    // MARK: Update Location
 
    class func updateStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        AppClient.taskForRequest(url: Endpoints.updateLocation.url, method: HttpMethod.PUT.rawValue, apiType: ApiType.Parse.rawValue, body: body, responseType: UpdateLocationResponse.self) { response, error in
            if let response = response, response.updatedAt != nil {
                completion(true, nil)
            }
            completion(false, error)
        }
    }

    // MARK: Task For Request
    
    class func taskForRequest<ResponseType:Decodable>(
        url: URL,
        method: String,
        apiType: String,
        body: String,
        responseType: ResponseType.Type,
        completion: @escaping(ResponseType?, Error?) -> Void
    ) {
        guard AppClient.isConnectedToNetwork() == true else {
            completion(nil, AppError.networkError)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                switch AppClient.ApiType(rawValue: apiType) {
                case .Udacity:
                    let range = 5..<data.count
                    let newData = data.subdata(in: range)
                    let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                case .Parse:
                    let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                case .none:
                    DispatchQueue.main.async {
                        completion(nil, nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    
    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
           $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
               SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
           }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
           return false
        }

        /* Only Working for WIFI
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired

        return isReachable && !needsConnection
        */

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret
    }        
}
