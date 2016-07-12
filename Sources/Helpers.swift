//
//  Helpers.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

extension NSNumber {
    
    func isBoolNumber() -> Bool{
        return CFGetTypeID(self) == CFBooleanGetTypeID()
    }
    
    func isDoubleNumber() -> Bool{
        return CFNumberGetType(self) == CFNumberType.DoubleType || CFNumberGetType(self) == CFNumberType.Float64Type
    }
    
}

func varargs<C: CollectionType where C.Generator.Element == Expr>(collection: C) -> Value{
    switch  collection.count {
    case 1:
        return collection.first!.value
    default:
        return Arr(collection.map { $0.value })
    }
}

func varargs<C: CollectionType where C.Generator.Element: ExprConvertible>(collection: C) -> Value{
    switch  collection.count {
    case 1:
        return collection.first!.value
    default:
        return Arr(collection.map { $0.value })
    }
}

func varargs<C: CollectionType where C.Generator.Element == PathComponentType>(collection: C) -> Value{
    switch  collection.count {
    case 1:
        return collection.first!.value
    default:
        return Arr(collection.map { $0.value })
    }
    
}

struct Mapper {
    
    static func fromFaunaResponseData(data: NSData) throws -> Value{
        let jsonData: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        let resource = jsonData.objectForKey("resource")
        guard let res = resource else {
            throw Error.DriverException(data: jsonData, msg: "Fauna response does not contain a resource key")
        }
        return try Mapper.fromData(res)
    }
    
    static func fromData(data: AnyObject) throws -> Value {
        switch data {
        case let strValue as String:
            return strValue
        case let nsNumber as NSNumber where nsNumber.isBoolNumber():
            return nsNumber.boolValue
        case let doubleValue as Double:
            return doubleValue
        case let intValue as Int:
            return intValue
        case _ as NSNull:
            return Null()
        case let value as [AnyObject]:
            guard let result = Arr(json: value) else { throw Error.DriverException(data: value, msg: "Cannot decode data") }
            return result
        case let value as [String: AnyObject]:
            guard let result: Value = Ref(json: value) ?? Timestamp(json: value) ?? Date(json: value) ?? Obj(json: value)  else { throw Error.DriverException(data: value, msg: "Cannot decode data") }
            return result
        default:
            throw Error.DriverException(data: data, msg: "Cannot decode data")
        }
    }
}


extension NSObject {
    
    func value() -> Value {
        switch  self {
        case let str as NSString:
            return str as String
        case let int as NSNumber:
            if int.isDoubleNumber() {
                return int as Double
            }
            else if int.isBoolNumber() {
                return int as Bool
            }
            else {
                return int as Int
            }
        case let date as NSDate:
            return date
        case let dateComponents as NSDateComponents:
            return dateComponents
        case let nsArray as NSArray:
            var result: Arr = []
            for item in nsArray {
                result.append((item as! NSObject).value())
            }
            return result
        case let nsDictionary as NSDictionary:
            var result: Obj = [:]
            for item in nsDictionary {
                result[item.key as! String] = (item.value as! NSObject).value()
            }
            return result
        default:
            assertionFailure()
            return ""
        }
    }
}

func fn(obj: Obj) -> Obj{
    var obj = obj
    obj.fn = true
    return obj
}
