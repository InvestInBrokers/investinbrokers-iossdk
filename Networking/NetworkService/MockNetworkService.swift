import Foundation

public class MockRequestQueue {
    
    private static var responses: Dictionary<String, String> = Dictionary<String, String>()
    
    public class func enqueueJsonResponseForRequestURL(urlString: String, responseFile: String) {
        
        let bundle = Bundle.main
        
        let filePath = bundle.path(forResource: responseFile, ofType: "json")
        
        responses[urlString] = filePath
    
    }
    
    public class func dequeueResponeFileForRequestURL(urlString: String) -> String? {
        
        let responseURL = responses[urlString]
        
        //        responses.removeValueForKey(urlString)
        
        return responseURL

    }
}

class MockNetworkService : NetworkService {
        
    func enqueueNetworkRequest(request: NetworkRequest) -> MOOperation? {
        
        let operation = MockRequestOperation(request: request.urlRequest)
        
        let completion = completionForRequest(request: request)
        
        operation.startConnection(completion: completion)
        
        return operation
    }
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: URL) -> UploadOperation? {
        
        let operation = MockRequestOperation(request: request.urlRequest)
        
        let completion = completionForRequest(request: request)
        
        operation.startConnection(completion: completion)
        
        return operation
        
    }
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: Data) -> UploadOperation? {
        
        let operation = MockRequestOperation(request: request.urlRequest)
        
        let completion = completionForRequest(request: request)
        
        operation.startConnection(completion: completion)
        
        return operation
        
    }
    
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
        
        return nil
        
    }
    
}

struct MockRequestOperation: UploadOperation {
    
    let request: URLRequest
    let log = LoggerFactory.logger()
    
    init(request: URLRequest) {
        self.request = request
    }
    
    func startConnection(completion: DataResponseCompletion) {
        
        let fileURL = MockRequestQueue.dequeueResponeFileForRequestURL(urlString: request.url!.absoluteString)
        
        if let url = fileURL {
            
            let url = URL(string: url)
            
            var data: Data?
            
            do {
                
                data = try? Data(contentsOf: url!)
                
            }
            
            completion(data, nil)
            
        } else {
            
            print("File url for request not found\n")
            
            let error = NSError(domain: "Network", code: 101, userInfo: nil)
            
            completion(nil, error)
        
        }
        
    }
    
    func cancel() {
        
        
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    func registerProgressUpdate(progressUpdate: @escaping ProgressUpdate) {
        
    }
    
}
