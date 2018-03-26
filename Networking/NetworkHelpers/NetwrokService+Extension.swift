import Foundation
import Alamofire

public protocol NetworkService {
    
    func enqueueNetworkRequest(request: NetworkRequest) -> MOOperation?
 
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: Data) -> UploadOperation?
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: URL) -> UploadOperation?
    
    func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation?

}

extension NetworkService {
    
    func completionForRequest(request: NetworkRequest) -> DataResponseCompletion {
        
        let completion = { (dataOptional: Data?, errorOptional: Error?) -> Void in
            
            if let errorOptional = errorOptional {
                
                let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]
                
                let error = NSError(domain: "NetworkService", code: errorOptional._code, userInfo: userInfo)
                
                request.handleResponse(dataOptional: dataOptional, errorOptional: error)

            } else {
                
                request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
            
            }
        
        }
        
        return completion
        
    }
    
    func completionForDownloadRequest(request: NetworkDownloadRequest) -> ErrorCompletion {
        
        let completion = { (errorOptional: Error?) in
            
            var error: Error?
            
            if let errorOptional = errorOptional {
                
                let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]
                
                error = NSError(domain: "NetworkService", code: errorOptional._code, userInfo: userInfo)
                
            }
            
            request.handleResponse(dataOptional: nil, errorOptional: error)
            
        }
        
        return completion
        
    }
    
    func completionForDownloadLocation(request: NetworkDownloadRequest, options: DownloadRequest.DownloadOptions) -> DownloadLocationCompletion {
        
        let completion = { (fileLocaion: URL, options: DownloadRequest.DownloadOptions) -> (URL, DownloadRequest.DownloadOptions) in
            
            request.handleDownloadLocation(fileLocation: fileLocaion, options: DownloadRequest.DownloadOptions.removePreviousFile)
            
        }
        
        return completion
    }
    
    func completionForDownloadProgress(request: NetworkDownloadRequest) -> DownloadProgress {
        
        let completion = { (bytesRead: Int64, totalBytesRead: Int64, totalBytesExpected: Int64) in
            
            request.handleDownloadProgress(bytesRead: bytesRead, totalBytesRead: totalBytesRead, totalBytesExpectedToRead: totalBytesExpected)
            
        }
        
        return completion
        
    }
}

protocol ServiceParser {
    
    func parseDataDictionary(tag: Int, dictionary: Dictionary<String, Any>) -> Bool
    
}
