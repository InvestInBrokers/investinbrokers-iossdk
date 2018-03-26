import Foundation

public protocol NetworkRequest {
    
    var urlRequest: URLRequest { get set }
    
    func handleResponse(dataOptional: Data?, errorOptional: Error?)

}

// MARK: - JSON Task

public struct JSONRequestTask: NetworkRequest {
    
    let log = LoggerFactory.logger()

    public var urlRequest: URLRequest
    
    let taskCompletion: JSONResponseCompletion
    
    public init(urlRequest: URLRequest, taskCompletion: @escaping JSONResponseCompletion) {
        
        self.urlRequest = urlRequest
       
        self.taskCompletion = taskCompletion
    
    }
    
    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        
        let (json, jsonError) = convertResponseToJson(dataOptional: dataOptional)

        let error: Error? = jsonError == nil ? errorOptional : jsonError
        
        self.taskCompletion(json, error)
    
    }

}

// MARK: - Data Request Task

public struct DataRequestTask: NetworkRequest {
    
    public var urlRequest: URLRequest
    
    let taskCompletion: DataResponseCompletion
    
    init(urlRequest: URLRequest, taskCompletion: @escaping DataResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.taskCompletion = taskCompletion
    
    }
    
    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        
        self.taskCompletion(dataOptional, errorOptional)
    
    }
    
}

// MARK: - Data Upload Task

public struct DataUploadTask: NetworkUploadRequest {

    public var urlRequest: URLRequest
    
    public let name: String
    
    public let fileName: String
    
    public let mimeType: String
    
    let taskCompletion: DataResponseCompletion
    
    public init(urlRequest: URLRequest, name: String, fileName: String, mimeType: String, taskCompletion: @escaping DataResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.taskCompletion = taskCompletion
    }
    
    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        
        self.taskCompletion(dataOptional, errorOptional)
        
    }
    
}

// MARK: - Data Upload JSON Response Task

public struct DataUploadJsonResponseTask: NetworkUploadRequest {

    public var urlRequest: URLRequest
    
    public let name: String
    
    public let fileName: String
    
    public let mimeType: String
    
    let taskCompletion: JSONResponseCompletion
    
    public init(urlRequest: URLRequest, name: String, fileName: String, mimeType: String,  taskCompletion: @escaping JSONResponseCompletion) {
        
        self.urlRequest = urlRequest
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.taskCompletion = taskCompletion
    }
    
    public func handleResponse(dataOptional: Data?, errorOptional: Error?) {
        
        let (json, jsonError) = convertResponseToJson(dataOptional: dataOptional)
        
        let error: Error? = jsonError == nil ? errorOptional : jsonError
        
        self.taskCompletion(json, error)
        
    }
    
}

extension NetworkRequest {
    
    public func convertResponseToJson(dataOptional: Data?) -> (Any?, Error?) {
        
        var json: Any? = nil
        
        let jsonError: Error? = nil
        
        if let data = dataOptional {
            
            do {
                
                json = try JSONSerialization.jsonObject(with: data, options: [.mutableLeaves, .mutableContainers])
                
            } catch {}
            
        }
        
        return (json, jsonError)

    }

}
