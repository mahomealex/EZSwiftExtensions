//
//  DictionaryExtensions.swift
//  EZSwiftExtensions
//
//  Created by Goktug Yilmaz on 15/07/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//
import UIKit

extension Dictionary {
    /// EZSE: Returns a random element inside Dictionary
    public func random() -> NSObject {
        let index: Int = Int(arc4random_uniform(UInt32(self.count)))
        return Array(self.values)[index] as! NSObject
    }
    
    /// EZSE: Union of self and the input dictionaries.
    func union(dictionaries: Dictionary...) -> Dictionary {
        var result = self
        dictionaries.forEach { (dictionary) -> Void in
            dictionary.forEach { (key, value) -> Void in
                _ = result.updateValue(value, forKey: key)
            }
        }
        return result
    }
    
    /// EZSE: Intersection of self and the input dictionaries.
    /// Two dictionaries are considered equal if they contain the same [key: value] copules.
    func intersection<K, V where K: Equatable, V: Equatable>(dictionaries: [K: V]...) -> [K: V] {
        //  Casts self from [Key: Value] to [K: V]
        let filtered = mapFilter { (item, value) -> (K, V)? in
            if item is K && value is V {
                return (item as! K, value as! V)
            }
            return nil
        }
        
        //  Intersection
        return filtered.filter { (key: K, value: V) -> Bool in
            //  check for [key: value] in all the dictionaries
            dictionaries.testAll { $0.has(key) && $0[key] == value }
        }
    }
    
    /// EZSE: Checks if a key exists in the dictionary.
    func has(key: Key) -> Bool {
        return indexForKey(key) != nil
    }
    
    /// EZSE: Creates an Array with values generated by running
    /// each [key: value] of self through the mapFunction.
    func toArray<V>(map: (Key, Value) -> V) -> [V] {
        var mapped: [V] = []
        forEach {
            mapped.append(map($0, $1))
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with the same keys as self and values generated by running
    /// each [key: value] of self through the mapFunction.
    func mapValues<V>(map: (Key, Value) -> V) -> [Key: V] {
        var mapped: [Key: V] = [:]
        forEach {
            mapped[$0] = map($0, $1)
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with the same keys as self and values generated by running
    /// each [key: value] of self through the mapFunction discarding nil return values.
    func mapFilterValues<V>(map: (Key, Value) -> V?) -> [Key: V] {
        var mapped: [Key: V] = [:]
        forEach {
            if let value = map($0, $1) {
                mapped[$0] = value
            }
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with keys and values generated by running
    /// each [key: value] of self through the mapFunction discarding nil return values.
    func mapFilter<K, V>(map: (Key, Value) -> (K, V)?) -> [K: V] {
        var mapped: [K: V] = [:]
        forEach {
            if let value = map($0, $1) {
                mapped[value.0] = value.1
            }
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with keys and values generated by running
    /// each [key: value] of self through the mapFunction.
    func map<K, V>(map: (Key, Value) -> (K, V)) -> [K: V] {
        var mapped: [K: V] = [:]
        forEach {
            let (_key, _value) = map($0, $1)
            mapped[_key] = _value
        }
        return mapped
    }
    
    /// EZSE: Constructs a dictionary containing every [key: value] pair from self
    /// for which testFunction evaluates to true.
    func filter(test: (Key, Value) -> Bool) -> Dictionary {
        var result = Dictionary()
        for (key, value) in self {
            if test(key, value) {
                result[key] = value
            }
        }
        return result
    }
    
    /// EZSE: Checks if test evaluates true for all the elements in self.
    func testAll(test: (Key, Value) -> (Bool)) -> Bool {
        for (key, value) in self {
            if !test(key, value) {
                return false
            }
        }
        return true
    }
}

extension Dictionary where Value: Equatable {
    /// EZSE: Difference of self and the input dictionaries.
    /// Two dictionaries are considered equal if they contain the same [key: value] pairs.
    func difference(dictionaries: [Key: Value]...) -> [Key: Value] {
        var result = self
        for dictionary in dictionaries {
            for (key, value) in dictionary {
                if result.has(key) && result[key] == value {
                    result.removeValueForKey(key)
                }
            }
        }
        return result
    }
}

/// EZSE: Combines the first dictionary with the second and returns single dictionary
public func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

/// EZSE: Difference operator
public func - <K, V: Equatable> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.difference(second)
}


/// EZSE: Intersection operator
public func & <K, V: Equatable> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.intersection(second)
}

/// EZSE: Union operator
public func | <K: Hashable, V> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.union(second)
}