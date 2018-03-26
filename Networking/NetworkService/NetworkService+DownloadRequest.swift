import Foundation
import Alamofire

public protocol NetworkDownloadRequest: NetworkRequest {
    
    var downloadModel: MODownloadModel? { get }
    
    func handleDownloadLocation(fileLocation: URL, options: DownloadRequest.DownloadOptions) -> (URL, DownloadRequest.DownloadOptions)
    
    func handleDownloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void
    
}

public protocol DownloadOperation: MOOperation {
    
    func pause()
    
    func resume()
    
}

public struct MODownloadModel: Storable {
    
    public let fileName: String?
    public let fileURL: String?
    public var downloadOperation: DownloadOperation?
    
    //MARK: Storable Protocol
    
    public var id: String?
    
    public static var typeName = "MODownloadModel"
    
    public init(dictionary: StorableDictionary) {
        
        self.id = dictionary["id"] as? String
        
        self.fileName = dictionary["fileName"] as? String
        
        self.fileURL = dictionary["fileURL"] as? String
        
    }
    
    public func toDictionary() -> [String : Any] {
        
        var dictionary: StorableDictionary = [:]
        
        dictionary["id"] = self.id
        
        dictionary["fileName"] = self.fileName
        
        dictionary["fileURL"] = self.fileURL
        
        return dictionary
        
    }
    
}

extension AlamofireNetworkService {
    
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
        
        let method = HTTPMethod(rawValue: request.urlRequest.httpMethod!.uppercased())
        
        let downloadProgress = completionForDownloadProgress(request: request)
        
        let downloadLocationCompletion = completionForDownloadLocation(request: request, options: DownloadRequest.DownloadOptions.removePreviousFile)
        
        let downloadCompletion = completionForDownloadRequest(request: request)
        
        let headers = request.urlRequest.allHTTPHeaderFields

        let urlRequest = request.urlRequest as! URLConvertible
        
        var alamofireDownloadOperation = AlamofireDownloadOperation(downloadProgress: downloadProgress, downloadLocationCompletion: downloadLocationCompletion, downloadCompletion: downloadCompletion)
        
        alamofireDownloadOperation.request = self.manager.download(urlRequest, method: method!, parameters: nil, encoding: JSONEncoding.default, headers: headers, to: alamofireDownloadOperation.handleDownloadLocation)
            
            .downloadProgress(closure: alamofireDownloadOperation.handleDownloadProgress)
            
            .response(completionHandler: alamofireDownloadOperation.handleDownloadCompletion)
        
        return alamofireDownloadOperation
        
    }
    
}

struct AlamofireDownloadOperation: DownloadOperation {
    
    //    internal let downloadModel: MODownloadModel
    var request: DownloadRequest?
    
    private let downloadLocationCompletion: DownloadLocationCompletion
    private let downloadProgress: DownloadProgress
    private let downloadCompletion: ErrorCompletion
    
    init(downloadProgress: @escaping DownloadProgress, downloadLocationCompletion: @escaping DownloadLocationCompletion, downloadCompletion: @escaping ErrorCompletion) {
        
        self.downloadProgress = downloadProgress
        self.downloadLocationCompletion = downloadLocationCompletion
        self.downloadCompletion = downloadCompletion
        
    }
    
    func handleDownloadProgress(completion: Progress) {
        
        downloadProgress(Int64(completion.fractionCompleted), completion.completedUnitCount, completion.totalUnitCount)
        
    }
    
    func handleDownloadLocation(_ temporaryURL: URL, _ response: HTTPURLResponse) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) {
        
        return downloadLocationCompletion(temporaryURL, DownloadRequest.DownloadOptions.removePreviousFile)
        
    }

    func handleDownloadCompletion(completion: DefaultDownloadResponse) {
        
        downloadCompletion(completion.error)
        
    }
    
    func cancel() {
        
        request?.cancel()
        
    }
    
    func resume() {
        
        request?.resume()
        
    }
    
    func pause() {
        
        request?.suspend()
        
    }
    
}
