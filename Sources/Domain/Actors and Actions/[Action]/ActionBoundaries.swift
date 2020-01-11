import Foundation
import NIO

protocol ActionBoundaries {

    var worker: EventLoop { get }

}

protocol AutoActionBoundaries: ActionBoundaries {
}
