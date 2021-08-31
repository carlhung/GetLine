import Foundation

public enum ReadLineError: Error {
    case fileDoesNotExist
    case couldNotOpenFile
}

public final class ReadLine {
    private let url: URL
    private var filePointer: UnsafeMutablePointer<FILE>!
    private var pointerIsReleased = false
    private var bytesRead: Int!
    
    // a pointer to a null-terminated, UTF-8 encoded sequence of bytes
    private var lineByteArrayPointer: UnsafeMutablePointer<CChar>? = nil

    // the smallest multiple of 16 that will fit the byte array for this line
    private var lineCap: Int = 0

    public init(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ReadLineError.fileDoesNotExist
        }
        self.url = url
        try self.start()
    }

    private func start() throws {
        // open the file for reading
        // note: user should be prompted the first time to allow reading from this location
        guard let filePointer:UnsafeMutablePointer<FILE> = fopen(self.url.path,"r") else {
            throw ReadLineError.couldNotOpenFile
        }
        self.filePointer = filePointer

        // initial iteration
        self.bytesRead = getline(&self.lineByteArrayPointer, &self.lineCap, self.filePointer)
    }

    public func restart() throws {
        self.close()
        self.lineCap = 0
        self.lineByteArrayPointer = nil
        self.filePointer = nil
        self.bytesRead = nil
        self.pointerIsReleased = false
        try self.start()
    }

    public func close() {
        guard !self.pointerIsReleased else {
            return
        } 
        
        // when getline is called for the first time, lineByteArrayPointer is nil and lineCap is 0.
        // getline will allocate memory automatcally. but user need to release by himself/herself.
        // for more detail, in bash, type, $ man getline
        self.lineByteArrayPointer?.deallocate()
        fclose(self.filePointer)
        self.pointerIsReleased = true
    }

    public func nextLine() -> String? {
        guard self.bytesRead > 0  && self.lineByteArrayPointer != nil else {
            self.close()
            return nil
        }
        
        // note: this translates the sequence of bytes to a string using UTF-8 interpretation
        let lineAsString = String(cString:self.lineByteArrayPointer!).trimmingCharacters(in: .whitespacesAndNewlines) 
        
        // updates number of bytes read, for the next iteration
        // return -1 on failure to read a line (including end-of-file condition). In the event  of  an error, errno is set to indicate the cause.
        self.bytesRead = getline(&self.lineByteArrayPointer, &lineCap, filePointer)
            
        return lineAsString
    }

    deinit {
        self.close()
    }
}