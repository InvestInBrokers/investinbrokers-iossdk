import Foundation
import Alamofire

public protocol NetworkUploadRequest: NetworkRequest {
    
    var name: String { get }
    
    var fileName: String { get }
    
    var mimeType: String { get }

}

public protocol UploadOperation: MOOperation {
    
    func pause()
    
    func resume()
    
    func registerProgressUpdate(progressUpdate: @escaping ProgressUpdate)

}

extension AlamofireNetworkService {
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: Data) -> UploadOperation? {
        
        let method = HTTPMethod(rawValue: request.urlRequest.httpMethod!.uppercased())
        
        let dataResponseCompletion = completionForRequest(request: request)
        
        let alamofireUploadOperation = AlamofireUploadOperation(dataCompletion: dataResponseCompletion)
        
        let headers = request.urlRequest.allHTTPHeaderFields
        
        let urlRequest = request.urlRequest.url
        
        self.manager.upload(multipartFormData: { (formData) in
            
            formData.append(data, withName: request.name, fileName: request.fileName, mimeType: request.mimeType)
            
            }, usingThreshold: UInt64.init(), to: urlRequest!, method: method!, headers: headers, encodingCompletion: alamofireUploadOperation.handleEncodingCompletion())
    
        return alamofireUploadOperation

    }
    
    func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: URL) -> UploadOperation? {
        
        let method = HTTPMethod(rawValue: request.urlRequest.httpMethod!.uppercased())
        
        let dataResponseCompletion = completionForRequest(request: request)
        
        let alamofireUploadOperation = AlamofireUploadOperation(dataCompletion: dataResponseCompletion)
        
        let headers = request.urlRequest.allHTTPHeaderFields

        let urlRequest = request.urlRequest.url
        
        self.manager.upload(multipartFormData: { (formData) in
            
            formData.append(fileURL, withName: request.name, fileName: request.fileName, mimeType: request.mimeType)
            
            }, usingThreshold: UInt64.init(), to: urlRequest!, method: method!, headers: headers, encodingCompletion: alamofireUploadOperation.handleEncodingCompletion())
        
        return alamofireUploadOperation
    
    }

}

// WRITE UNIT TEST!

class AlamofireUploadOperation : UploadOperation {
    
    typealias EncodingCompletion = ((SessionManager.MultipartFormDataEncodingResult) -> Void)
    
    private var request: UploadRequest?
    private let dataCompletion: DataResponseCompletion
    
    init(dataCompletion: @escaping DataResponseCompletion) {
        
        self.dataCompletion = dataCompletion
    
    }
    
    private func performRequest() {
        
        request?.validate().responseData { (networkResponse: DataResponse<Data>) -> Void in
            
            self.log.verbose(message: "Request response for URL: \(self.request!.request!.url!.debugDescription)")

            self.handleResponse(networkResponse: networkResponse, completion: self.dataCompletion)
            
        }
        
    }
    
    func handleEncodingCompletion() -> EncodingCompletion {
        
        return  { (encodingResult) in
            
            switch encodingResult {
                
            case .success(request: let request, streamingFromDisk: _, streamFileURL: _):
                
                self.request = request

                self.performRequest()
                
                break
                
            case .failure(_):
                
                break
                
            }
        }
    }
    
    func registerProgressUpdate(progressUpdate: @escaping ProgressUpdate) {
        
        if let request = request {
            
            request.uploadProgress(closure: { progress in
                
                let completed = CGFloat(progress.fractionCompleted)
                
                progressUpdate(completed)
            
            })
            
        }
        
    }
        
    func pause() {
    
        request?.suspend()
    
    }
    
    func resume() {
    
        request?.resume()
    
    }
    
    func cancel() {
    
        request?.cancel()

    }

}
