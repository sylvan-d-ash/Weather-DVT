//
//  MockModelContext.swift
//  Weather-DVTTests
//
//  Created by Sylvan  on 30/08/2025.
//

import Foundation
import SwiftData
@testable import Weather_DVT

final class MockModelContext: ModelContextProtocol {
    var shouldThrowOnFetchCountError = false
    var shouldThrowOnSaveError = false
    var mockCountResult = 0

    private(set) var didCallFetch = false
    private(set) var didCallFetchCount = false
    private(set) var didCallInsert = false
    private(set) var didCallDelete = false
    private(set) var didCallSave = false
    private(set) var insertedObjects: [any PersistentModel] = []
    private(set) var deleteObjects: [any PersistentModel] = []

    func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T : PersistentModel {
        didCallFetch = true
        return []
    }
    
    func fetchCount<T>(_ descriptor: FetchDescriptor<T>) throws -> Int where T : PersistentModel {
        didCallFetchCount = true
        if shouldThrowOnFetchCountError {
            throw MockTestError.dummyError
        }
        return mockCountResult
    }
    
    func insert<T>(_ model: T) where T : PersistentModel {
        didCallInsert = true
        insertedObjects.append(model)
    }
    
    func delete<T>(_ model: T) where T : PersistentModel {
        didCallDelete = true
        deleteObjects.append(model)
    }
    
    func save() throws {
        didCallSave = true
        if shouldThrowOnSaveError {
            throw MockTestError.dummyError
        }
    }

    func getInsertedObject<T>(ofType: T.Type) -> T? {
        return insertedObjects.first { $0 is T } as? T
    }
}
