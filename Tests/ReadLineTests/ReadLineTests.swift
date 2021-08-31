
    import XCTest
    import Foundation

    @testable import ReadLine

/*
// get URL to the the documents directory in the sandbox
let home = FileManager.default.homeDirectoryForCurrentUser

// add a filename
let fileUrl = home
    .appendingPathComponent("Documents")
    .appendingPathComponent("my_file")
    .appendingPathExtension("txt")
*/

    final class ReadLineTests: XCTestCase {
        func testExample() {
            print("start")
            // let currentPath = FileManager.default.currentDirectoryPath // /home/carlhung/swiftProjects/ReadLine

            let currentPath = Bundle.main.bundlePath //  /home/carlhung/swiftProjects/ReadLine/.build/x86_64-unknown-linux-gnu/debug

            let filePath = currentPath + "/ReadLine_ReadLineTests.resources/budget_data.csv"
            let url = URL.init(fileURLWithPath: filePath)

            var result:(isSuccess: Bool, message: String?)
            do {
                let readLine = try ReadLine(url: url)
                while let _ = readLine.nextLine() {}
                try readLine.restart()
                while let _ = readLine.nextLine() {}
                result = (true, nil)
            } catch {
                result = (false, "\(error)")
            }
            
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.

            // XCTAssert(false, "test failed")
            XCTAssert(result.isSuccess, result.message ?? "")
        }
    }
