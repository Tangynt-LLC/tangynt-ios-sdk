import Foundation

//MARK: - Main Tangynt Class -
open public class Tangynt {
    
    public static let api = Tangynt(TangyntCache.apiKey!)
    public static var requiresUsersToSignIn = true
    
    @discardableResult public init(_ apiKey: String) {
        TangyntCache.set(apiKey: apiKey)
    }
    
    public func createUser<T>(user: T, completion: @escaping (T?, ErrorResponse?) -> ()) where T: TangyntUser {
        TangyntClient.client.createUser(user: user, completion: completion)
    }
    
    public func login<T: TangyntUser>(_ userType: T.Type, email: String, password: String, completion: @escaping (T?, ErrorResponse?) -> ()) {
        TangyntClient.client.login(userType ,email: email, password: password, completion: completion)
    }
    
    public var onLogout: () -> () = {}
    
    public func logout() {
        onLogout()
        TangyntCache.clearCache()
    }
    
    public func refreshAuth(completion: @escaping (ErrorResponse?) -> ()) {
        TangyntClient.client.refreshAuth(completion: completion)
    }
    
    public func getUser<T>() -> T? where T: TangyntUser {
        return TangyntCache.getUser()
    }
    
    public func getAuthToken() -> TangyntAuthToken? {
        return TangyntCache.tangyntLoginResponse?.authToken
    }
    
    public func getRefreshToken() -> TangyntRefreshToken? {
        return TangyntCache.tangyntLoginResponse?.refreshToken
    }
    
    public func resendVerificationEmail(completion: @escaping (ErrorResponse?) -> ()) {
        if let user = Tangynt.api.getUser() {
            if user.emailVerified == false {
                TangyntClient.client.resendVerificationEmail { (error) in
                    if let error = error {
                        completion(error.toResponse)
                        return
                    }
                }
                TangyntClient.client.resendVerificationEmail(completion: completion)
            } else {
                completion(ErrorResponse("User is already email verified", status: 200))
            }
        }
    }
    
    public func updatePassword(newPassword: String, completion: @escaping (ErrorResponse?) -> ()) {
        TangyntClient.client.updatePassword(newPassword: newPassword, completion: completion)
    }
    
    public func resetPassword(email: String, completion: @escaping (ErrorResponse?) -> ()) {
        TangyntClient.client.resetPassword(email: email, completion: completion)
    }
    
    public func createUserAndLogin<T: TangyntUser>(user: T, completion: @escaping (T?, ErrorResponse?) -> ()) {
        createUser(user: user) { (user, errorRespnse) in
            if let errorRespnse = errorRespnse {
                completion(nil, errorRespnse)
                return
            }
            guard let user = user else { completion(nil, ErrorResponse("User object does not exist", status: 0)); return }
            self.login(T.self, email: user.email, password: user.password) { (loggedInUser, errorResponse) in
                guard let loggedInUser = loggedInUser else { completion(nil, ErrorResponse("Unable to log in", status: 0)); return }
                completion(loggedInUser, nil)
            }
        }
    }
    
    //MARK: - CRUD -
    public func createObject<T: TangyntObject>(object: T, fields: [String] = [], completion: @escaping (T?, Any?) -> ()) {
        TangyntClient.client.create(object, fields: fields) { (object, any, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil, nil)
                return
            }
            if fields.isEmpty {
                guard let object = object else { completion(nil, nil); return }
                print(object)
                completion(object, nil)
            } else {
                completion(nil, any)
            }
        }
    }
    
    public func getObject<T: TangyntObject>(object: T, fields: [String] = [], completion: @escaping (T?, Any?) -> ()) {
        TangyntClient.client.get(object, fields: fields) { (object, any, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil, nil)
                return
            }
            if fields.isEmpty {
                guard let object = object else { completion(nil, nil); return }
                print(object)
                completion(object, nil)
            } else {
                completion(nil, any)
            }
        }
    }
    
    public func getObjects<T: TangyntObject>(objectType: T.Type, listOptions: ListOptions? = nil, completion: @escaping (Any?, ErrorResponse?) -> ()) {
        TangyntClient.client.getObjects(objectType: objectType, listOptions: listOptions) { (object, any, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil, error)
                return
            }
            if listOptions?.fields == nil {
                guard let object = object else { completion(nil, nil); return }
                completion(object, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func update<T: TangyntObject>(_ object: T, fields: [String] = [], completion: @escaping (T?, Any?) -> ()) {
        TangyntClient.client.update(object, fields: fields) { (object, any, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil, nil)
                return
            }
            if fields.isEmpty {
                guard let object = object else { completion(nil, nil); return }
                print(object)
                completion(object, nil)
            } else {
                completion(nil, any)
            }
        }
    }
    
    public func delete<T: TangyntObject>(_ object: T, completion: @escaping (Bool) -> ()) {
        TangyntClient.client.delete(object) { (_, _, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    //MARK: - Files -
    public func uploadFile<T: TangyntFile>(fileData: Data, object: T, fields: [String], completion: @escaping (T?, Any?, ErrorResponse?) -> ()) {
        TangyntClient.client.uploadFile(fileData: fileData, object, fields: fields, completion: completion)
    }
    
    public func downloadFile(fileId: Int, completion: @escaping (Data?, Any?, ErrorResponse?) -> ()) {
        TangyntClient.client.downloadFile(fileId: fileId, completion: completion)
    }
    
    public func getFiles<T: TangyntFile>(objectType: T.Type, listOptions: ListOptions? = nil, completion: @escaping ([T]?, Any?) -> ()) {
        TangyntClient.client.getFiles(objectType: objectType, listOptions: listOptions) { (object, any, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil, nil)
                return
            }
            if listOptions?.fields == nil {
                guard let object = object else { completion(nil, nil); return }
                print(object)
                completion(object, nil)
            } else {
                completion(nil, any)
            }
        }
    }
    
    public func updateFile<T: TangyntFile>(fileData: Data?, object: T, fields: [String], completion: @escaping (T?, Any?, ErrorResponse?) -> ()) {
        TangyntClient.client.updateFile(fileData: fileData, object, fields: fields, completion: completion)
    }
    
    public func delete(fileId: Int, completion: @escaping (Bool?, ErrorResponse?) -> ()) {
        TangyntClient.client.deleteFile(fileId: fileId, completion: completion)
    }
    
    
}

//MARK: - Tangynt Login Response

public class TangyntLoginResponse: Codable {
    public var authToken: TangyntAuthToken
    public var refreshToken: TangyntRefreshToken
    
    public enum CodingKeys: CodingKey {
        case authToken
        case refreshToken
    }
    
    public init(authToken: TangyntAuthToken, refreshToken: TangyntRefreshToken) {
        self.authToken = authToken
        self.refreshToken = refreshToken
    }
    
    public static func create(from dictionary: [String: Any]) -> TangyntLoginResponse? {
        var authToken: TangyntAuthToken? = nil
        let authSection = dictionary["authToken"] as? [String: Any]
        let authId = authSection?["id"] as? String
        let authIssuedAt = authSection?["issuedAt"] as? Int64
        let authExpires = authSection?["expires"] as? Int64
        if authId != nil, authIssuedAt != nil, authExpires != nil {
            authToken = TangyntAuthToken(id: authId!, issuedAt: authIssuedAt!, expires: authExpires!)
        }
        
        var refreshToken: TangyntRefreshToken? = nil
        let refreshSection = dictionary["refreshToken"] as? [String: Any]
        let refreshId = refreshSection?["id"] as? String
        let refreshClient = refreshSection?["client"] as? String
        let refreshIssuedTo = refreshSection?["issuedTo"] as? Int64
        let refreshIssuedAt = refreshSection?["issuedAt"] as? Int64
        let refreshExpires = refreshSection?["expires"] as? Int64
        let refreshDeactivated = refreshSection?["deactivated"] as? Bool
        if refreshSection != nil, refreshId != nil, refreshClient != nil, refreshIssuedTo != nil, refreshIssuedAt != nil, refreshExpires != nil, refreshDeactivated != nil {
            refreshToken = TangyntRefreshToken(id: refreshId!, client: refreshClient!, issuedTo: refreshIssuedTo!, issuedAt: refreshIssuedAt!, expires: refreshExpires!, deactivated: refreshDeactivated!)
        }
        
        if authToken != nil, refreshToken != nil {
            return TangyntLoginResponse(authToken: authToken!, refreshToken: refreshToken!)
        }
        return nil
    }
    
}
open struct TangyntAuthToken: Codable {
    public var id: String
    public var issuedAt: Int64
    public var expires: Int64
}

open struct TangyntRefreshToken: Codable {
    public var id: String
    public var client: String
    public var issuedTo: Int64
    public var issuedAt: Int64
    public var expires: Int64
    public var deactivated: Bool
}


//MARK: - Tangynt Cache -
private class TangyntCache {
    
    private init() {}
    
    static var isAuthorized: Bool {
        return TangyntCache.getUser() != nil
    }
    static var apiKey: String? {
        return UserDefaults.standard.value(forKey: Constants.tangyntApiKey) as? String
    }
    static func set(apiKey: String) {
        UserDefaults.standard.set(apiKey, forKey: Constants.tangyntApiKey)
    }
    
    static var userPassword: String? {
        UserDefaults.standard.value(forKey: Constants.userPasswordKey) as? String
    }
    
    static func setPassword(_ password: String) {
        UserDefaults.standard.set(password, forKey: Constants.userPasswordKey)
    }
    
    static func getUser<T>() -> T? where T: TangyntUser {
        if let userDictionary = UserDefaults.standard.value(forKey: Constants.currentUserKey) as? [String: Any] {
            do {
                let userData = try JSONSerialization.data(withJSONObject: userDictionary, options: [])
                let user = try JSONDecoder().decode(T.self, from: userData)
                return user
            } catch {
                print("Error converting login responst dictionary to data: \(error.localizedDescription)")
            }
        }
        return nil
    }
    static func set<T>(user: T) where T: TangyntUser {
        do {
            user.password = userPassword ?? ""
            let userData = try JSONSerialization.jsonObject(with: JSONEncoder().encode(user), options: [])
            UserDefaults.standard.set(userData, forKey: Constants.currentUserKey)
        } catch {
            print("Error: unable to convert login response to data object: \(error.localizedDescription))")
        }
    }
    
    static var tangyntLoginResponse: TangyntLoginResponse? {
        if let loginResponseDictionary = UserDefaults.standard.value(forKey: Constants.tangyntLoginResponseKey) as? [String: Any] {
            do {
                let loginResponseData = try JSONSerialization.data(withJSONObject: loginResponseDictionary, options: [])
                let loginResponse = try JSONDecoder().decode(TangyntLoginResponse.self, from: loginResponseData)
                return loginResponse
            } catch {
                print("Error converting login responst dictionary to data: \(error.localizedDescription)")
            }
        }
        return nil
    }
    static func set(tangyntLoginResponse: TangyntLoginResponse) {
        do {
            let loginResponseData = try JSONSerialization.jsonObject(with: JSONEncoder().encode(tangyntLoginResponse), options: [])
            UserDefaults.standard.set(loginResponseData, forKey: Constants.tangyntLoginResponseKey)
        } catch {
            print("Error: unable to convert login response to data object: \(error.localizedDescription))")
        }
    }
    
    
    //TODO: Make sure everything that gets set gets cleared in this method
    static func clearCache() {
        UserDefaults.standard.set(nil, forKey: Constants.currentUserKey)
        UserDefaults.standard.set(nil, forKey: Constants.tangyntLoginResponseKey)
    }
    
}


public class ErrorResponse: Codable, Error {
    public var timestamp: Int64
    public var status: TangyntResponseStatusCode
    public var error: String
    
    public init(timeStamp: Int64 = Date().millisecondsSince1970, _ error: String, status: Int?) {
        self.timestamp = timeStamp
        self.status = status?.toTangyntResponseStatusCode() ?? .unknownErrorOccured
        self.error = error
    }
    
    public var localizedDescription: String {
        return "Status: \(status.rawValue) Error message: \(error) Timestamp: \(timestamp)"
    }
}

extension Int {
    public func toTangyntResponseStatusCode() -> TangyntResponseStatusCode {
        if let statusCode = TangyntResponseStatusCode(rawValue: self) {
            return statusCode
        } else {
            return TangyntResponseStatusCode.unknownErrorOccured
        }
    }
}


//MARK: - Tangynt Client -

open enum TangyntResponseStatusCode: Int, Codable {
    case success = 200
    case invalidIDProvided = 400
    case invalidCredentials = 401
    case missingTangyntAPIKeyHeader = 402
    case couldNotFindAppWithThatAPIKey = 404
    case invalidRequestPath = 406
    case mustProvideAuthToken = 407
    case unknownErrorOccured = 500
}

extension TangyntResponseStatusCode {
    func toDescription() -> String {
        switch self {
        case .success:
            return "Successful call"
        case .invalidIDProvided:
            return "Invalid ID was provided."
        case .invalidCredentials:
            return "Invalid credentials."
        case .missingTangyntAPIKeyHeader:
            return "Must provide an API key in the 'Tangynt-Api-Key' header."
        case .couldNotFindAppWithThatAPIKey:
            return "Could not find an app corresponding to that API key."
        case .invalidRequestPath:
            return "Invalid request path."
        case .mustProvideAuthToken:
            return "Must provide an auth token in the 'Authorization' header."
        case .unknownErrorOccured:
            return "Unknown error occurred."
        }
    }
}

public class ListOptions {
    
    public enum OrderDir: String {
        case asc, desc
    }
    
    public var fields: [String]? = nil
    public var skip: Int? = nil
    public var limit: Int? = nil
    public var orderBy: String? = nil
    public var orderDir: String? = nil
    
    public init(fields: [String]? = nil, skip: Int? = nil, limit: Int? = nil, orderBy: String? = nil, orderDir: OrderDir? = nil) {
        self.fields = fields
        self.skip = skip
        self.limit = limit
        self.orderBy = orderBy
        self.orderDir = orderDir?.rawValue
    }
}

private class TangyntClient {
    
    let baseURL = URL(string: "https://api.tangynt.com/api/v1")!
    
    enum TangyntClientResponseType: String {
        case success, errorResponse, invalidStatusCode, unknown
    }
    
    enum RequestHTTPMethod: String {
        case GET, POST, PUT, DELETE
    }
    
    static let client = TangyntClient()
    
    //MARK: Create User
    func createUser<T>(user: T, completion: @escaping (T?, ErrorResponse?) -> ()) where T: TangyntUser {
        do {
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(user)
            
            let (request, tangyntError) = createRequest(withURL: baseURL.appendingPathComponent(Endpoints.users), data: jsonData, httpMethod: .POST)
            if let tanError = tangyntError {
                completion(nil, tanError)
                return
            }
            request?.resultData { (data, response, errorResponse) in
                print("Status Code \(response?.statusCode ?? 0)")
                do {
                    guard let data = data else { return }
                    let createdUser = try JSONDecoder().decode(T.self, from: data)
                    TangyntCache.setPassword(user.password)
                    TangyntCache.set(user: user)
                    completion(createdUser, nil)
                } catch {
                    print("Error: \(error.localizedDescription)")
                    if let data = data {
                        let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
                        print(jsonData ?? "")
                    }
                    completion(nil, error.toResponse)
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    //MARK: Login
    func login<T: TangyntUser>(_ userType: T.Type, email: String, password: String, completion: @escaping (T?, ErrorResponse?) -> ()) {
        let str = "\(email):\(password)"
        let (request, tangyntError) = createRequest(withURL: baseURL.appendingPathComponent(Endpoints.usersAuth), data: nil, isBearer: false, httpMethod: .POST)
        if let tanError = tangyntError {
            completion(nil, tanError)
            return
        }
        let utf8str = str.data(using: .utf8)
        guard let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else { return }
        request?.addValue("Basic \(base64Encoded)", forHTTPHeaderField: "Authorization")
        request?.resultData { (data, response, errorResponse) in
            print(response?.statusCode ?? 0)
            do {
                guard let data = data else { completion(nil, ErrorResponse("Data is set to nil", status: 0)); return }
                let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let loginResponse = TangyntLoginResponse.create(from: dictionary)
                if let loginResponse = loginResponse {
                    TangyntCache.set(tangyntLoginResponse: loginResponse)
                    TangyntCache.setPassword(password)
                    let userDict = dictionary["user"] as! [String: Any]
                    let userDictData = try JSONSerialization.data(withJSONObject: userDict, options: [])
                    let user = try JSONDecoder().decode(userType.self, from: userDictData)
                    user.password = password
                    TangyntCache.set(user: user)
                    completion(user, nil)
                } else {
                    completion(nil, errorResponse ?? ErrorResponse("Data was not the correct format", status: 0))
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                completion(nil, error.toResponse)
            }
        }
    }
    
    //MARK: Refresh Auth
    func refreshAuth(completion: @escaping (ErrorResponse?) -> ()) {
        let urlString = baseURL.appendingPathComponent(Endpoints.usersAuth).absoluteString
        var urlComponents = URLComponents(string: urlString)
        urlComponents!.queryItems = [URLQueryItem(name: "grant_type", value: "refresh"),
                                     URLQueryItem(name: "token", value: "\(Tangynt.api.getRefreshToken()?.id ?? "")"),
                                     URLQueryItem(name: "userId", value: "\(Tangynt.api.getUser()?.id ?? 0)")]
        let url = (urlComponents?.url!)!
        let (request, tangyntError) = createRequest(withURL: url, data: nil, httpMethod: .POST)
        if let tanError = tangyntError {
            completion(tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            if errorResponse != nil {
                completion(errorResponse)
            }
            guard let data = data else { completion(ErrorResponse("Data does not exist", status: 0)); return }
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let loginResponse = TangyntLoginResponse.create(from: dictionary)
                if let loginResponse = loginResponse {
                    TangyntCache.set(tangyntLoginResponse: loginResponse)
                    completion(nil)
                } else {
                    completion(ErrorResponse("Error: data is not a login response", status: 0))
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                completion(error.toResponse)
            }
        }
    }
    
    //MARK:  Fetch User By ID
    func fetchUser<T>(_ type: T.Type, id: Int64, completion: @escaping (T?, ErrorResponse?) -> ()) where T: TangyntUser {
        let (request, tangyntError) = createRequest(withURL: baseURL.appendingPathComponent(Endpoints.usersId(id: id)), data: nil, httpMethod: .GET)
        if let tanError = tangyntError {
            completion(nil, tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            self.handleUserResponse(type, data: data, response: response, errorResponse: errorResponse) { (user, error) in
                completion(user, error)
            }
        }
    }
    
    //MARK: Resend Verification Email
    func resendVerificationEmail(completion: @escaping (ErrorResponse?) -> ()) {
        let urlString = baseURL.appendingPathComponent(Endpoints.resendVerificationEmail(id: TangyntCache.getUser()?.id ?? 0)).absoluteString
        var urlComponents = URLComponents(string: urlString)
        urlComponents!.queryItems = [URLQueryItem(name: "type", value: "verify_email")]
        let url = (urlComponents?.url!)!
        
        let (request, tangyntError) = createRequest(withURL: url, data: nil, httpMethod: .POST)
        if let tanError = tangyntError {
            completion(tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            completion(errorResponse)
        }
    }
    
    //MARK: Update Password
    func updatePassword(newPassword: String, completion: @escaping (ErrorResponse?) -> ()) {
        let user = TangyntCache.getUser()
        let payload: [String: String] = [
            "currentPassword": user?.password ?? "",
            "newPassword": newPassword
        ]
        let (request, tangyntError) = createRequest(withURL: baseURL.appendingPathComponent(Endpoints.updatePassword(id: user?.id ?? 0)), data: try! JSONSerialization.data(withJSONObject: payload, options: []), httpMethod: .PUT)
        if let tanError = tangyntError {
            completion(tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            if errorResponse != nil {
                completion(errorResponse)
                return
            }
            switch response?.statusCode ?? 0 {
            case 200...299:
                completion(nil)
            default:
                completion(ErrorResponse("Unknown Error", status: 0))
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (ErrorResponse?) -> ()) {
        let urlString = baseURL.appendingPathComponent(Endpoints.resetPassword).absoluteString
        var urlComponents = URLComponents(string: urlString)
        urlComponents!.queryItems = [URLQueryItem(name: "type", value: "password_reset"),
                                     URLQueryItem(name: "email", value: email)]
        let url = (urlComponents?.url!)!
        let (request, tangyntError) = createRequest(withURL: url, data: nil, httpMethod: .POST)
        if let tanError = tangyntError {
            completion(tanError)
            return
        }
        request?.resultData { (data, response, errorReponse) in
            if errorReponse != nil {
                completion(errorReponse)
                return
            }
            switch response?.statusCode ?? 0 {
            case 200...299:
                completion(nil)
            default:
                completion(ErrorResponse("Unknown Error", status: 0))
            }
        }
    }
    
    func createRequest(withURL url: URL, data: Data?, contentType: String = "application/json", isBearer: Bool = true, httpMethod: RequestHTTPMethod) -> (TangyntRequest?, ErrorResponse?) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = data
        request.addValue(TangyntCache.apiKey ?? "", forHTTPHeaderField: "Tangynt-Api-Key")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        if TangyntCache.getUser() != nil {
            if isBearer {
                if let tokenId = TangyntCache.tangyntLoginResponse?.authToken.id {
                    request.addValue("Bearer " + (tokenId), forHTTPHeaderField: "Authorization")
                } else {
                    return (nil, ErrorResponse("Auth Token Needed", status: 0))
                }
            }
        }
        print(request.url?.absoluteString ?? "No URL")
        return (TangyntRequest(request), nil)
    }
    
    
    func createMultipartRequestPart<T: TangyntFile>(data: Data, object: T) -> (contentType: String, body: Data) {
        let boundary = "MobileBoundary"
        let body = NSMutableData()
        var paramString = ""
        
        paramString += "--\(boundary)\r\n"
        paramString += "Content-Disposition: form-data; name=\"object\"\r\n\r\n"
        paramString += "{}}\r\n"
        
        paramString = "--\(boundary)\r\n"
        paramString += "Content-Disposition: form-data; object=\"{}}\"\r\n"
        paramString += "Content-Type: \(object.fileType)\r\n\r\n"
        
        body.append(paramString.data(using: String.Encoding.utf8)!)
        body.append(data)
        
        body.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        return (contentType, body as Data)
    }
    
    
    //MARK: - CRUD -
    
    
    
    //MARK: Create
    func create<T>(_ object: T, fields: [String] = [], completion: @escaping (T?, Any?, ErrorResponse?) -> ()) where T: TangyntObject {
        do {
            let data = try JSONEncoder().encode(object.self)
            let urlString = baseURL.appendingPathComponent(Endpoints.object(object.objectName)).absoluteString
            var urlComponents = URLComponents(string: urlString)
            if !fields.isEmpty {
                urlComponents!.queryItems = [URLQueryItem(name: "fields", value: fields.joined(separator: ","))]
            }
            let url = (urlComponents?.url!)!
            let (request, tangyntError) = createRequest(withURL: url, data: data, httpMethod: .POST)
            if let tanError = tangyntError {
                completion(nil, nil, tanError)
                return
            }
            request?.resultData { (data, response, errorResponse) in
                let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
                switch tanResponse {
                case .errorResponse:
                    print("Need to figure out what to do with this!")
                    completion(nil, nil, errorResponse!)
                case .invalidStatusCode:
                    print("Deal with status code here: \(response?.statusCode ?? 0)")
                    completion(nil, nil, errorResponse!)
                case .success:
                    print("Success!")
                    if fields.isEmpty {
                        completion(try? JSONDecoder().decode(T.self, from: data!), nil, nil)
                    } else {
                        completion(nil, try? JSONSerialization.jsonObject(with: data!, options: []), nil)
                    }
                case .unknown:
                    print("Unknown error")
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: Get Object
    func get<T>(_ object: T, fields: [String] = [], completion: @escaping (T?, Any?, ErrorResponse?) -> ()) where T: TangyntObject {
        let typeString = "\(object.objectName)"
        let urlString = baseURL.appendingPathComponent(typeString).appendingPathComponent("\(object.id)").absoluteString
        var urlComponents = URLComponents(string: urlString)
        if !fields.isEmpty {
            urlComponents!.queryItems = [URLQueryItem(name: "fields", value: fields.joined(separator: ","))]
        }
        let url = (urlComponents?.url!)!
        let (request, tangyntError) = createRequest(withURL: url, data: nil, httpMethod: .GET)
        if let tanError = tangyntError {
            completion(nil, nil, tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
            switch tanResponse {
            case .errorResponse:
                print("Need to figure out what to do with this!")
                completion(nil, nil, errorResponse!)
            case .invalidStatusCode:
                print("Deal with status code here: \(response?.statusCode ?? 0)")
                completion(nil, nil, errorResponse!)
            case .success:
                print("Success!")
                if fields.isEmpty {
                    completion(try? JSONDecoder().decode(T.self, from: data!), nil, nil)
                } else {
                    completion(nil, try? JSONSerialization.jsonObject(with: data!, options: []), nil)
                }
            case .unknown:
                print("Unknown error")
            }
        }
    }
    
    //MARK: Get List
    func getObjects<T>(objectType: T.Type, listOptions: ListOptions? = nil, completion: @escaping ([T]?, Any?, ErrorResponse?) -> ()) where T: TangyntObject {
        let urlString = baseURL.appendingPathComponent(Endpoints.getObjects("\(objectType.self)")).absoluteString
        var urlComponents = URLComponents(string: urlString)
        if let listOptions = listOptions {
            var queryItems: [URLQueryItem] = []
            if listOptions.fields != nil {
                queryItems.append(URLQueryItem(name: "fields", value: "\(listOptions.fields!.joined(separator: ","))"))
            }
            if listOptions.limit != nil {
                queryItems.append(URLQueryItem(name: "limit", value: "\(listOptions.limit!)"))
            }
            if listOptions.orderBy != nil {
                queryItems.append(URLQueryItem(name: "orderBy", value: "\(listOptions.orderBy!)"))
            }
            if listOptions.orderDir != nil {
                queryItems.append(URLQueryItem(name: "orderDir", value: "\(listOptions.orderDir!)"))
            }
            if listOptions.skip != nil {
                queryItems.append(URLQueryItem(name: "skip", value: "\(listOptions.skip!)"))
            }
            urlComponents!.queryItems = queryItems
        }
        let url = (urlComponents?.url!)!
        let (request, tangyntError) = createRequest(withURL: url, data: nil, httpMethod: .POST)
        if let tanError = tangyntError {
            completion(nil, nil, tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
            switch tanResponse {
            case .errorResponse:
                print("Need to figure out what to do with this!")
                completion(nil, nil, errorResponse!)
            case .invalidStatusCode:
                print("Deal with status code here: \(response?.statusCode ?? 0)")
                completion(nil, nil, errorResponse)
            case .success:
                print("Success!")
                if listOptions?.fields == nil {
                    completion(try? JSONDecoder().decode([T].self, from: data!), nil, nil)
                } else {
                    completion(nil, try? JSONSerialization.jsonObject(with: data!, options: []), nil)
                }
            case .unknown:
                print("Unknown error")
            }
        }
    }
    
    //MARK: Update Object
    func update<T>(_ object: T, fields: [String] = [], completion: @escaping (T?, Any?, ErrorResponse?) -> ()) where T: TangyntObject {
        do {
            let data = try JSONEncoder().encode(object.self)
            let urlString = baseURL.appendingPathComponent(Endpoints.objectWithId(objectName: object.objectName, id: "\(object.id)")).absoluteString
            var urlComponents = URLComponents(string: urlString)
            if !fields.isEmpty {
                urlComponents!.queryItems = [URLQueryItem(name: "fields", value: fields.joined(separator: ","))]
            }
            let url = (urlComponents?.url!)!
            let (request, tangyntError) = createRequest(withURL: url, data: data, httpMethod: .PUT)
            if let tanError = tangyntError {
                completion(nil, nil, tanError)
                return
            }
            request?.resultData { (data, response, errorResponse) in
                let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
                switch tanResponse {
                case .errorResponse:
                    print("Need to figure out what to do with this!")
                    completion(nil, nil, errorResponse!)
                case .invalidStatusCode:
                    print("Deal with status code here: \(response?.statusCode ?? 0)")
                    completion(nil, nil, errorResponse!)
                case .success:
                    print("Success!")
                    if fields.isEmpty {
                        completion(try? JSONDecoder().decode(T.self, from: data!), nil, nil)
                    } else {
                        completion(nil, try? JSONSerialization.jsonObject(with: data!, options: []), nil)
                    }
                case .unknown:
                    print("Unknown error")
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    //MARK: Delete Object
    func delete<T>(_ object: T, completion: @escaping (T?, Any?, ErrorResponse?) -> ()) where T: TangyntObject {
        do {
            let data = try JSONEncoder().encode(object.self)
            let url = baseURL.appendingPathComponent(Endpoints.objectWithId(objectName: object.objectName, id: "\(object.id)"))
            let (request, tangyntError) = createRequest(withURL: url, data: data, httpMethod: .DELETE)
            if let tanError = tangyntError {
                completion(nil, nil, tanError)
                return
            }
            request?.resultData { (data, response, errorResponse) in
                let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
                switch tanResponse {
                case .errorResponse:
                    print("Need to figure out what to do with this!")
                    completion(nil, nil, errorResponse!)
                case .invalidStatusCode:
                    print("Deal with status code here: \(response?.statusCode ?? 0)")
                    completion(nil, nil, errorResponse!)
                case .success:
                    print("Success!")
                    completion(nil, try? JSONSerialization.jsonObject(with: data!, options: []), nil)
                case .unknown:
                    print("Unknown error")
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    //MARK: Files CRUD
    
    
    
    //MARK: Create
    func uploadFile<T: TangyntFile>(fileData: Data, _ object: T, fields: [String] = [], completion: @escaping (T?, Any?, ErrorResponse?) -> ()) {
        let urlString = baseURL.appendingPathComponent(Endpoints.uploadFile).absoluteString
        var urlComponents = URLComponents(string: urlString)
        if !fields.isEmpty {
            urlComponents!.queryItems = [URLQueryItem(name: "fields", value: fields.joined(separator: ","))]
        }
        let url = (urlComponents?.url!)!
        let multiformPart = MultipartForm(parts: [.init(name: "file", data: fileData, filename: object.name, contentType: object.fileType), .init(name: "object", value: "{\"name\": \"\(object.name)\"}")], boundary: "MobileBoundary")
        let (request, tangyntError) = createRequest(withURL: url, data: multiformPart.bodyData, contentType: multiformPart.contentType, httpMethod: .POST)
        if let tanError = tangyntError {
            completion(nil, nil, tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
            switch tanResponse {
            case .errorResponse:
                print("Need to figure out what to do with this!")
                completion(nil, nil, errorResponse!)
            case .invalidStatusCode:
                print("Deal with status code here: \(response?.statusCode ?? 0)")
                completion(nil, nil, errorResponse ?? ErrorResponse("", status: response?.statusCode))
            case .success:
                print("Success!")
                if fields.isEmpty {
                    completion(try? JSONDecoder().decode(T.self, from: data!), nil, nil)
                } else {
                    completion(nil, try? JSONSerialization.jsonObject(with: data!, options: []), nil)
                }
            case .unknown:
                print("Unknown error")
            }
        }
    }
    
    //MARK: Read
    func downloadFile(fileId: Int, completion: @escaping (Data?, Any?, ErrorResponse?) -> ()) {
        let urlString = baseURL.appendingPathComponent(Endpoints.downloadFile(fileId: fileId)).absoluteString
        let urlComponents = URLComponents(string: urlString)
        let url = (urlComponents?.url!)!
        let (request, tangyntError) = createRequest(withURL: url, data: nil, httpMethod: .GET)
        if let tanError = tangyntError {
            completion(nil, nil, tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
            switch tanResponse {
            case .errorResponse:
                print("Need to figure out what to do with this!")
                completion(nil, nil, errorResponse!)
            case .invalidStatusCode:
                print("Deal with status code here: \(response?.statusCode ?? 0)")
                completion(nil, nil, errorResponse ?? ErrorResponse("", status: response?.statusCode))
            case .success:
                print("Success!")
                completion(data, nil, nil)
            case .unknown:
                print("Unknown error")
            }
        }
    }
    
    //MARK: Get Files
    func getFiles<T>(objectType: T.Type, listOptions: ListOptions? = nil, completion: @escaping ([T]?, Any?, ErrorResponse?) -> ()) where T: TangyntFile {
        let urlString = baseURL.appendingPathComponent(Endpoints.getObjects("files")).absoluteString
        var urlComponents = URLComponents(string: urlString)
        if let listOptions = listOptions {
            var queryItems: [URLQueryItem] = []
            if listOptions.fields != nil {
                queryItems.append(URLQueryItem(name: "fields", value: "\(listOptions.fields!.joined(separator: ","))"))
            }
            if listOptions.limit != nil {
                queryItems.append(URLQueryItem(name: "limit", value: "\(listOptions.limit!)"))
            }
            if listOptions.orderBy != nil {
                queryItems.append(URLQueryItem(name: "orderBy", value: "\(listOptions.orderBy!)"))
            }
            if listOptions.orderDir != nil {
                queryItems.append(URLQueryItem(name: "orderDir", value: "\(listOptions.orderDir!)"))
            }
            if listOptions.skip != nil {
                queryItems.append(URLQueryItem(name: "skip", value: "\(listOptions.skip!)"))
            }
            urlComponents!.queryItems = queryItems
        }
        let url = (urlComponents?.url!)!
        let (request, tangyntError) = createRequest(withURL: url, data: nil, httpMethod: .POST)
        if let tanError = tangyntError {
            completion(nil, nil, tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
            switch tanResponse {
            case .errorResponse:
                print("Need to figure out what to do with this!")
                completion(nil, nil, errorResponse!)
            case .invalidStatusCode:
                print("Deal with status code here: \(response?.statusCode ?? 0)")
                completion(nil, nil, errorResponse)
            case .success:
                print("Success!")
                if listOptions?.fields == nil {
                    completion(try? JSONDecoder().decode([T].self, from: data!), nil, nil)
                } else {
                    completion(nil, try? JSONSerialization.jsonObject(with: data!, options: []), nil)
                }
            case .unknown:
                print("Unknown error")
            }
        }
    }
    
    
    //MARK: Update
    func updateFile<T: TangyntFile>(fileData: Data?, _ object: T, fields: [String] = [], completion: @escaping (T?, Any?, ErrorResponse?) -> ()) {
        let urlString = baseURL.appendingPathComponent(Endpoints.updateFile(fileId: object.id)).absoluteString
        var urlComponents = URLComponents(string: urlString)
        if !fields.isEmpty {
            urlComponents!.queryItems = [URLQueryItem(name: "fields", value: fields.joined(separator: ","))]
        }
        let url = (urlComponents?.url!)!
        let multiformPart = MultipartForm(parts: [.init(name: "file", data: fileData, filename: object.name, contentType: object.fileType), .init(name: "object", value: "{\"name\": \"\(object.name)\"}")], boundary: "MobileBoundary")
        let (request, tangyntError) = createRequest(withURL: url, data: multiformPart.bodyData, contentType: multiformPart.contentType, httpMethod: .PUT)
        if let tanError = tangyntError {
            completion(nil, nil, tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
            switch tanResponse {
            case .errorResponse:
                print("Need to figure out what to do with this!")
                completion(nil, nil, errorResponse!)
            case .invalidStatusCode:
                print("Deal with status code here: \(response?.statusCode ?? 0)")
                completion(nil, nil, errorResponse ?? ErrorResponse("", status: response?.statusCode))
            case .success:
                print("Success!")
                if fields.isEmpty {
                    completion(try? JSONDecoder().decode(T.self, from: data!), nil, nil)
                } else {
                    completion(nil, try? JSONSerialization.jsonObject(with: data!, options: []), nil)
                }
            case .unknown:
                print("Unknown error")
            }
        }
    }
    
    //MARK: Delete
    func deleteFile(fileId: Int, completion: @escaping (Bool?, ErrorResponse?) -> ()) {
        let url = baseURL.appendingPathComponent(Endpoints.deleteFile(fileId: fileId))
        let (request, tangyntError) = createRequest(withURL: url, data: nil, httpMethod: .DELETE)
        if let tanError = tangyntError {
            completion(nil, tanError)
            return
        }
        request?.resultData { (data, response, errorResponse) in
            let tanResponse = self.checkIfGoodToGo(data: data, response: response, errorResponse: errorResponse)
            switch tanResponse {
            case .errorResponse:
                print("Need to figure out what to do with this!")
                completion(nil, errorResponse!)
            case .invalidStatusCode:
                print("Deal with status code here: \(response?.statusCode ?? 0)")
                completion(nil, errorResponse!)
            case .success:
                print("Success!")
                completion(true, nil)
            case .unknown:
                print("Unknown error")
            }
        }
    }
    
    func checkIfGoodToGo(data: Data?, response: URLResponse?, errorResponse: ErrorResponse?) -> TangyntClientResponseType {
        if errorResponse != nil {
            return .errorResponse
        }
        if let response = response?.httpURLResponse {
            switch response.statusCode {
            case 200...299:
                return .success
            default:
                return .invalidStatusCode
            }
        }
        if data != nil {
            return .success
        }
        return .unknown
    }
    
    func handleUserResponse<T>(_ type: T.Type?, data: Data?, response: URLResponse?, errorResponse: ErrorResponse?, completion: @escaping (T?, ErrorResponse?) -> ()) where T: Codable {
        if errorResponse != nil {
            completion(nil, errorResponse)
        } else {
            if let data = data, let response = response?.httpURLResponse {
                print("Tangynt Status Code: \(response.statusCode) for \(response.url?.absoluteString ?? "url unknown")")
                if type != nil {
                    do {
                        completion(try JSONDecoder().decode(type!, from: data), nil)
                    } catch {
                        print("Error: \(error.localizedDescription)")
                        completion(nil, error.toResponse)
                    }
                }
            } else {
                completion(nil, ErrorResponse("\(data == nil ? "Data response is empty" : "")\(response?.httpURLResponse == nil ? "\n Invalid response object" : "")", status: 0))
            }
        }
    }
    
    private var maxRetries = 3
    
    func decode<T>(modelType: T.Type, data: Data) -> T? where T : Codable {
        do {
            return try JSONDecoder().decode(modelType, from: data)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}


//MARK: - Request Data -

var retryCount: Int = 0
public class TangyntRequest {
    public var request: URLRequest
    public var maxRetryCount = 3
    
    public init(_ request: URLRequest) {
        self.request = request
    }
    
    public func refreshAndRetry(completion: @escaping (Data?, HTTPURLResponse?, ErrorResponse?) -> Void) {
        if retryCount == maxRetryCount {
            Tangynt.api.logout()
            completion(nil, nil, ErrorResponse("Max retries hit", status: 0))
        }
        retryCount += 1
        Tangynt.api.refreshAuth { (errorResponse) in
            if errorResponse != nil {
                completion(nil, nil, errorResponse)
                return
            }
            self.resultData(completion: completion)
        }
    }
                        
    public func resultData(completion: @escaping (Data?, HTTPURLResponse?, ErrorResponse?) -> Void) {
        if let expiresDate = TangyntCache.tangyntLoginResponse?.authToken.expires, expiresDate < Date().millisecondsSince1970 || (TangyntCache.tangyntLoginResponse?.authToken.expires == nil) {
            if let refreshDate = TangyntCache.tangyntLoginResponse?.refreshToken.expires, refreshDate < Date().millisecondsSince1970 || TangyntCache.tangyntLoginResponse?.refreshToken.expires == nil {
                Tangynt.api.logout()
                completion(nil, nil, ErrorResponse("Refresh Token Expired", status: 0))
            } else {
                refreshAndRetry(completion: completion)
            }
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let httpResponse = response?.httpURLResponse
            if httpResponse?.statusCode == 401 {
                if TangyntCache.isAuthorized {
                    self.refreshAndRetry(completion: completion)
                } else {
                    if retryCount == self.maxRetryCount {
                        Tangynt.api.logout()
                        retryCount = 0
                        completion(nil, nil, ErrorResponse("Max retries hit", status: 0))
                    } else {
                        retryCount += 1
                        self.resultData(completion: completion)
                    }
                }
            } else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data ?? Data()) {
                    completion(data, httpResponse, errorResponse)
                } else if let error = error {
                    completion(data, httpResponse, ErrorResponse(error.localizedDescription, status: httpResponse?.statusCode))
                } else {
                    completion(data, httpResponse, nil)
                }
            }
        }.resume()
    }
    
    public func addValue(_ value: String, forHTTPHeaderField field: String) {
        request.addValue(value, forHTTPHeaderField: field)
    }
}

extension URLResponse {
    public var httpURLResponse: HTTPURLResponse? {
        return self as? HTTPURLResponse
    }
}

extension Error {
    fileprivate var toResponse: ErrorResponse {
        return ErrorResponse(self.localizedDescription, status: 0)
    }
}


extension Date {
    public var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    
    public init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
}


extension Data {
    public mutating func append(_ string: String) {
        self.append(string.data(using: .utf8, allowLossyConversion: true)!)
    }
}

public struct MultipartForm: Hashable, Equatable {
    public struct Part: Hashable, Equatable {
        public var name: String
        public var data: Data?
        public var filename: String?
        public var contentType: String?
        
        public var value: String? {
            get {
                if let theData = data {
                    return String(bytes: theData, encoding: .utf8)
                }
                return nil
            }
            set {
                guard let value = newValue else {
                    self.data = Data()
                    return
                }
                
                self.data = value.data(using: .utf8, allowLossyConversion: true)!
            }
        }
        
        public init(name: String, data: Data?, filename: String? = nil, contentType: String? = nil) {
            self.name = name
            self.data = data
            self.filename = filename
            self.contentType = contentType
        }
        
        public init(name: String, value: String) {
            let data = value.data(using: .utf8, allowLossyConversion: true)!
            self.init(name: name, data: data, filename: nil, contentType: nil)
        }
    }
    
    public var boundary: String
    public var parts: [Part]
    
    public var contentType: String {
        return "multipart/form-data; boundary=\(self.boundary)"
    }
    
    public var bodyData: Data {
        var body = Data()
        for part in self.parts {
            body.append("--\(self.boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(part.name)\"")
            if let filename = part.filename?.replacingOccurrences(of: "\"", with: "_") {
                body.append("; filename=\"\(filename)\"")
            }
            body.append("\r\n")
            if let contentType = part.contentType {
                body.append("Content-Type: \(contentType)\r\n")
            }
            if let newData = part.data {
                body.append("\r\n")
                body.append(newData)
                body.append("\r\n")
            } else {
                body.append("\r\n")
                body.append("\r\n")
            }
        }
        body.append("--\(self.boundary)--\r\n")
        
        return body
    }
    
    public init(parts: [Part] = [], boundary: String = UUID().uuidString) {
        self.parts = parts
        self.boundary = boundary
    }
    
    public subscript(name: String) -> Part? {
        get {
            return self.parts.first(where: { $0.name == name })
        }
        set {
            precondition(newValue == nil || newValue?.name == name)
            
            var parts = self.parts
            parts = parts.filter { $0.name != name }
            if let newValue = newValue {
                parts.append(newValue)
            }
            self.parts = parts
        }
    }
}


//MARK: - Tangynt User -
protocol TangyntObject: Codable {
  public var id: Int64 {get set}
  public var objectName: String {get}
}

public class TangyntUser: Codable {
  public var id: Int64
  public var emailVerified: Bool
  public var email: String
  public var password: String
  public var displayName: String
  
  
  public enum CodingKeys: CodingKey {
    case id
    case emailVerified
    case email
    case password
    case displayName
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int64.self, forKey: .id)
    emailVerified = try container.decode(Bool.self, forKey: .emailVerified)
    email = try container.decode(String.self, forKey: .email)
    if let password = try container.decodeIfPresent(String.self, forKey: .password) {
      self.password = password
    } else {
      self.password = Constants.placeHolderPassword
    }
    displayName = try container.decode(String.self, forKey: .displayName)
  }
  
  init(id: Int64, emailVerified: Bool, email: String, password: String, displayName: String) {
    self.id = id
    self.emailVerified = emailVerified
    self.email = email
    self.password = password
    self.displayName = displayName
  }
}


//MARK: - Tangynt File -
public class TangyntFile: Codable {
  public var id: Int
  public var fileType: String
  public var name: String
  public var fileSize: Int = 0
  
  public enum CodingKeys: CodingKey {
    case id
    case fileType
    case name
    case fileSize
  }
  
  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int.self, forKey: .id)
    fileType = try container.decode(String.self, forKey: .fileType)
    name = try container.decode(String.self, forKey: .name)
    fileSize = try container.decode(Int.self, forKey: .fileSize)
  }
  
  public init(id: Int, fileType: String, name: String) {
    self.id = id
    self.fileType = fileType
    self.name = name
    self.fileSize = 0
  }
}


//MARK: - Constants -
public class Constants {
  
  static let tangyntApiKey = "TangyntApiKey"
  static let currentUserKey = "CurrentUserKey"
  static let userPasswordKey = "UserPasswordKey"
  static let tangyntLoginResponseKey = "TangyntLoginResponseKey"
  static let placeHolderPassword = "ThisSuperCrazyLongPasswordThatNobodyWillOrShouldEverDo2"
  
}

public class Endpoints {
  
  public static func object(_ objectName: String) -> String {
    return "\(objectName)"
  }
  public static func getObjects(_ objectName: String) -> String {
    return "\(objectName)/search"
  }
  public static func objectWithId(objectName: String, id: String) -> String {
    return "\(objectName)/\(id)"
  }
  public static var uploadFile: String {
    return "files"
  }
  public static func downloadFile(fileId: Int) -> String {
    return "files/\(fileId)"
  }
  public static func updateFile(fileId: Int) -> String {
    return "files/\(fileId)"
  }
  public static func deleteFile(fileId: Int) -> String {
    return "files/\(fileId)"
  }
  public static func usersId(id: Int64) -> String {
    return "users/\(id)"
  }
  public static func updatePassword(id: Int64) -> String {
    return "users/\(id)/password"
  }
  public static var resetPassword: String {
    return "users/0/sendEmail"
  }
  public static func resendVerificationEmail(id:Int64) -> String {
    return "users/\(id)/sendEmail"
  }
  public static let users = "users"
  public static let usersAuth = "users/auth"
  
}

