import Foundation
import SwiftUI
import Later

public enum SUIObjectError: Error {
    case invalidParameter
}
@dynamicMemberLookup
public class SUIObject: ObservableObject {
    public typealias SUIObjectFunction = (Any?) throws -> Any?
    /// Functions of the object
    @Published public var functions: [AnyHashable: SUIObjectFunction] = [:]
    /// Variables of the object
    @Published public var variables: [AnyHashable: Any] = [:]
    /// @dynamicMemberLookup
    public subscript(dynamicMember member: String) -> SUIObject {
        guard let value = variables[member] else {
            return SUIObject()
        }
        if let array = value as? [Any] {
            return SUIObject(array: array)
        }
        guard let object = value as? SUIObject else {
            return SUIObject(value)
        }
        return object
    }
    /// Retrieve a Function from the current object
    @discardableResult
    public func function(_ named: AnyHashable) -> SUIObjectFunction {
        guard let function = functions[named] else {
            return { _ in SUIObject() }
        }
        return function
    }
    /// Retrieve a Value from the current object
    @discardableResult
    public func variable(_ named: AnyHashable) -> SUIObject {
        guard let value = variables[named] else {
            return SUIObject()
        }
        if let array = value as? [Any] {
            return SUIObject(array: array)
        }
        guard let object = value as? SUIObject else {
            return SUIObject(unwrap(value))
        }
        return object
    }
    /// Add a Value with a name to the current object
    public func add(variable named: AnyHashable = "_value", value: Any) {
        variables[named] = value
    }
    /// Add a ChildObject with a name of `_object` to the current object
    public func add(childObject object: SUIObject) {
        variables["_object"] = object
    }
    /// Add an Array with a name of `_array` to the current object
    public func add(array: [Any]) {
        variables["_array"] = array
    }
    /// Add a Function with a name and a closure to the current object
    public func add(function named: AnyHashable, value: @escaping SUIObjectFunction) {
        functions[named] = value
    }
    /// Run a Function with or without a value
    @discardableResult
    public func run(function named: AnyHashable, value: Any = SUIObject()) -> SUIObject {
        SUIObject(try? function(named)(value))
    }
    ///Run a Function with a internal value
    @discardableResult
    public func run(function named: AnyHashable, withInteralValueName iValueName: AnyHashable) -> SUIObject {
        SUIObject(try? function(named)(variable(iValueName)))
    }
    /// Run an Async Function with or without a value
    @discardableResult
    public func aync(function named: AnyHashable, value: Any = SUIObject()) -> LaterValue<SUIObject> {
        Later.promise { [weak self] promise in
            do {
                promise.succeed(SUIObject(try self?.function(named)(value)))
            } catch {
                promise.fail(error)
            }
        }
    }
    ///Run an Async Function with a internal value
    @discardableResult
    public func async(function named: AnyHashable, withInteralValueName iValueName: AnyHashable) -> LaterValue<SUIObject> {
        let value = variable(iValueName)
        
        return Later.promise { [weak self] promise in
            do {
                promise.succeed(SUIObject(try self?.function(named)(value)))
            } catch {
                promise.fail(error)
            }
        }
    }
    /// Unwraps the <Optional> Any type
    private func unwrap(_ value: Any) -> Any {
        let mValue = Mirror(reflecting: value)
        let isValueOptional = mValue.displayStyle != .optional
        let isValueEmpty = mValue.children.isEmpty
        if isValueOptional { return value }
        if isValueEmpty { return NSNull() }
        guard let (_, unwrappedValue) = mValue.children.first else { return NSNull() }
        return unwrappedValue
    }
    
    // MARK: public init
    
    public init() { }
    public init(_ value: Any? = nil, _ closure: ((SUIObject) -> Void)? = nil) {
        defer {
            if let closure = closure {
                configure(closure)
            }
        }
        
        guard let value = value else {
            return
        }
        let unwrappedValue = unwrap(value)
        if let _ = unwrappedValue as? NSNull {
            return
        }
        if let object = unwrappedValue as? SUIObject {
            consume(object)
        } else if let array = unwrappedValue as? [Any] {
            consume(SUIObject(array: array))
        } else if let dictionary = unwrappedValue as? [AnyHashable: Any] {
            consume(SUIObject(dictionary: dictionary))
        } else if let data = unwrappedValue as? Data {
            consume(SUIObject(data: data))
        } else {
            consume(SUIObject {
                $0.add(value: unwrappedValue)
            })
        }
    }
    
    // MARK: private init
    
    private init(array: [Any]) {
        add(variable: "_array", value: array.map {
            SUIObject($0)
        })
    }
    private init(dictionary: [AnyHashable: Any]) {
        variables = dictionary
    }
    private init(data: Data) {
        defer {
            variables["_json"] = String(data: data, encoding: .utf8)
        }
        if let json = try? JSONSerialization.jsonObject(with: data,
                                                        options: .allowFragments) as? [Any] {
            add(variable: "_array", value: json)
            return
        }
        guard let json = try? JSONSerialization.jsonObject(with: data,
                                                           options: .allowFragments) as? [AnyHashable: Any] else {
                                                            return
        }
        consume(SUIObject(json))
        add(value: data)
    }
}
public extension SUIObject {
    
    @discardableResult
    func configure(_ closure: (SUIObject) -> Void) -> SUIObject {
        closure(self)
        
        return self
    }
    
    @discardableResult
    func consume(_ object: SUIObject) -> SUIObject {
        object.variables.forEach { (key, value) in
            self.add(variable: key, value: value)
        }
        object.functions.forEach { (key, closure) in
            self.add(function: key, value: closure)
        }
        
        return self
    }
}
extension SUIObject: CustomStringConvertible {
    public var description: String {
        variables
            .map { (key, value) in
                guard let object = value as? SUIObject else {
                    return "\t\(key): \(value)"
                }
                
                return object.description
        }
        .joined(separator: "\n")
    }
}
public extension SUIObject {
    var all: [AnyHashable: SUIObject] {
        var allVariables = [AnyHashable: SUIObject]()
        
        variables.forEach { key, value in
            print("Key: \(key) = \(value)")
            let uKey = ((key as? String) == "") ? UUID().uuidString : key
            if let objects = value as? [SUIObject] {
                allVariables[uKey] = SUIObject(array: objects)
                return
            }
            guard let object = value as? SUIObject else {
                allVariables[uKey] = SUIObject(value)
                return
            }
            allVariables[uKey] = SUIObject(dictionary: object.all)
        }
        
        return allVariables
    }
    
    var array: [SUIObject] {
        if let array = variables["_array"] as? [Data] {
            return array.map { SUIObject(data: $0) }
        } else if let array = variables["_array"] as? [Any] {
            return array.map { value in
                guard let json = value as? [AnyHashable: Any] else {
                    return SUIObject(value)
                }
                return SUIObject(dictionary: json)
            }
        }
        return []
    }
    
    var object: SUIObject {
        (variables["_object"] as? SUIObject) ?? SUIObject()
    }
    
    var value: Any {
        variables["_value"] ?? SUIObject()
    }
    
    func string() -> String? {
        value(as: String.self)
    }
    
    func value<T>(as type: T.Type? = nil) -> T? {
        value as? T
    }
    
    func value<T>(decodedAs type: T.Type) -> T? where T: Decodable {
        guard let data = value(as: Data.self) else {
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
public extension Data {
    var object: SUIObject {
        SUIObject(self)
    }
}
public extension Encodable {
    var object: SUIObject {
        guard let data =  try? JSONEncoder().encode(self) else {
            return SUIObject(self)
        }
        return SUIObject(data)
    }
}
