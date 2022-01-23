
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

        let url = Bundle.module.url(forResource: "budget_data", withExtension: "csv")
        
        func testExample() {
            // let currentPath = FileManager.default.currentDirectoryPath // /home/carlhung/swiftProjects/ReadLine

            // let currentPath = Bundle.main.bundlePath //  /home/carlhung/swiftProjects/ReadLine/.build/x86_64-unknown-linux-gnu/debug
            // let filePath = currentPath + "/ReadLine_ReadLineTests.resources/budget_data.csv"
            // let url = URL.init(fileURLWithPath: filePath)
           
            guard let url = self.url else {
                XCTAssert(false, "wrong url path")
                return
            }

            var result:(isSuccess: Bool, message: String?)
            do {
                let readLine = try ReadLine(url: url)
                while case let .some(line) = readLine.nextLine(), !line.contains("Date") {
                    // print("yes, it contains: \(line)")
                    print("val: \(line)")
                }
                try readLine.restart()
                while case _? = readLine.nextLine() {

                }
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
