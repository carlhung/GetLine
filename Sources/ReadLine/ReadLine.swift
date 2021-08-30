import Foundation

public enum ReadLineError: Error {
    case fileDoesNotExist
    case couldNotOpenFile
}

public class ReadLine {
    private let url: URL
    private var filePointer: UnsafeMutablePointer<FILE>
    private var pointerIsReleased = false
    private var bytesRead: Int
    
    // a pointer to a null-terminated, UTF-8 encoded sequence of bytes
    private var lineByteArrayPointer: UnsafeMutablePointer<CChar>? = nil

    // the smallest multiple of 16 that will fit the byte array for this line
    private var lineCap: Int = 0

    public init(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ReadLineError.fileDoesNotExist
        }
        self.url = url

        // open the file for reading
        // note: user should be prompted the first time to allow reading from this location
        guard let filePointer:UnsafeMutablePointer<FILE> = fopen(self.url.path,"r") else {
            throw ReadLineError.couldNotOpenFile
        }
        self.filePointer = filePointer

        // initial iteration
        self.bytesRead = getline(&self.lineByteArrayPointer, &self.lineCap, self.filePointer)
    }

    public func close() {
        guard !self.pointerIsReleased else {
            return
        } 
        // self.lineByteArrayPointer?.deallocate()
        fclose(self.filePointer)
        self.pointerIsReleased = true
    }

    public func nextLine() -> String? {
        guard self.bytesRead > 0  && self.lineByteArrayPointer != nil else {
            self.close()
            return nil
        }
        
        // note: this translates the sequence of bytes to a string using UTF-8 interpretation
        let lineAsString = String(cString:self.lineByteArrayPointer!)
            
        // updates number of bytes read, for the next iteration
        self.bytesRead = getline(&self.lineByteArrayPointer, &lineCap, filePointer)
            
        return lineAsString
    }

    deinit {
        self.close()
    }
}