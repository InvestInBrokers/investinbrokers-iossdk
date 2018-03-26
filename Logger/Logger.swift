import Foundation
import XCGLogger

protocol Logger {
    
    func verbose(message: String)
    func debug(message: String)
    func info(message: String)
    func warning(message: String)
    func error(message: String)
    func severe(message: String)
}

struct LoggerImpl: Logger {
    
    let log = XCGLogger.default
    
    init(logLevel: XCGLogger.Level) {
        
        log.setup(level: logLevel, showLogIdentifier: true, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: false, writeToFile: nil, fileLevel: logLevel)
        
    }
    
    func verbose(message: String) {
        
        log.verbose(message)
    }
    
    func debug(message: String) {
        
        log.debug(message)
    }
    
    func info(message: String) {
        
        log.info(message)
    }
    
    func warning(message: String) {
        
        log.warning(message)
    }
    
    func error(message: String) {
        
        log.error(message)
    }
    
    func severe(message: String) {
        
        log.severe(message)
    }
}


struct LoggerFactory {
    
    static func logger() -> Logger {
        
        return LoggerImpl(logLevel: .verbose)
    }

}
