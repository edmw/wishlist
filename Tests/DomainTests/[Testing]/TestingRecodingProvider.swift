@testable import Domain

struct TestingRecordingProvider: EventRecordingProvider {

    class Records {
        var event = [String]()
    }

    let records = Records()

    func record(_ string: String, file: String, function: String, line: UInt, column: UInt) {
        records.event.append(string)
    }

}
