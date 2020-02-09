import Foundation

/// Value type based on a string which may contain privacy or security sensitive data.
public protocol SensitiveStringValue: StringValue {}

protocol DomainSensitiveStringValue: DomainStringValue, SensitiveStringValue {}
