import Foundation
import NIO

protocol FutureType {

    associatedtype Expectation

    var eventLoop: EventLoop { get }

}
