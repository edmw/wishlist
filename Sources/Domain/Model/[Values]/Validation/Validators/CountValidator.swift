import Foundation

extension ValueValidator where T: Collection {

    static func count(_ range: ClosedRange<Int>) -> ValueValidator<T> {
        return CountValidator(min: range.lowerBound, max: range.upperBound).validator()
    }

    static func count(_ range: PartialRangeThrough<Int>) -> ValueValidator<T> {
        return CountValidator(min: nil, max: range.upperBound).validator()
    }

    static func count(_ range: PartialRangeFrom<Int>) -> ValueValidator<T> {
        return CountValidator(min: range.lowerBound, max: nil).validator()
    }

    static func count(_ range: Range<Int>) -> ValueValidator<T> {
        return CountValidator(
            min: range.lowerBound,
            max: range.upperBound.advanced(by: -1)
        ).validator()
    }

}

private struct CountValidator<T>: ValueValidatorType where T: Collection {

    let min: Int?
    let max: Int?

    init(min: Int?, max: Int?) {
        self.min = min
        self.max = max
    }

    func validate(_ data: T) throws {
        if let min = self.min {
            guard data.count >= min else {
                throw ValueValidationError("is less than required minimum of \(min)")
            }
        }

        if let max = self.max {
            guard data.count <= max else {
                throw ValueValidationError("is greater than required maximum of \(max)")
            }
        }
    }

    var validatorReadable: String {
        if let min = self.min, let max = self.max {
            return "between \(min) and \(max)"
        }
        else if let min = self.min {
            return "at least \(min)"
        }
        else if let max = self.max {
            return "at most \(max)"
        }
        else {
            return "valid"
        }
    }

}
