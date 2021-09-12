//
//  TodoProvider.swift
//  TodoProvider
//
//  Created by gonzoooooo on 2021/09/06.
//

import Foundation
import CoreData

struct TodoProvider {
    var persistence: PersistenceController = .shared

    static let shared = TodoProvider()
    static let preview: TodoProvider = {
        let persistence = PersistenceController.preview

        let viewContext = persistence.container.viewContext

        for i in 0..<10 {
            let newTodo = Todo(context: viewContext)
            newTodo.id = UUID()
            newTodo.name = "Todo \(i)"
            newTodo.isCompleted = i % 2 == 0
            newTodo.isFlagged = i % 2 == 0
            newTodo.notifiedDate = Date()
            newTodo.createdDate = Date()
            newTodo.modifiedDate = Date()
            newTodo.order = Int64(i)
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return .init(persistence: persistence)
    }()

    func add(
        id: UUID,
        name: String,
        notifiedDate: Date?,
        isFlagged: Bool
    ) async throws {
        let viewContext = persistence.container.viewContext

        try await viewContext.perform {
            let todo: Todo = Todo(context: viewContext)
            todo.id = id
            todo.name = name
            todo.notifiedDate = notifiedDate
            todo.isFlagged = isFlagged
            todo.createdDate = Date()
            todo.modifiedDate = Date()

            todo.order = try maxOrder() + 1

            try viewContext.save()
        }
    }

    func update(
        id: UUID,
        name: String,
        isCompleted: Bool,
        notifiedDate: Date?,
        isFlagged: Bool
    ) async throws {
        let viewContext = persistence.container.viewContext

        let request = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        request.fetchLimit = 1

        try await viewContext.perform {
            let todo = try request.execute().first!

            todo.name = name
            todo.notifiedDate = notifiedDate
            todo.isCompleted = isCompleted
            todo.isFlagged = isFlagged
            todo.modifiedDate = Date()

            try viewContext.save()
        }
    }

    func updateOrder(objectIDs: [NSManagedObjectID]) throws {
        let viewContext = persistence.container.viewContext

//        try viewContext.perform {
            for (index, todo) in objectIDs.map({ viewContext.object(with: $0) as! Todo }).enumerated() {
                todo.order = Int64(index + 1)
            }

            try viewContext.save()
//        }
    }

    func delete(identifiedBy objectIDs: [NSManagedObjectID]) async throws {
        let viewContext = persistence.container.viewContext

        // FIXME: Should use background view context
        try await viewContext.perform {
            objectIDs.forEach { objectID in
                let todo = viewContext.object(with: objectID)
                viewContext.delete(todo)
            }

            try viewContext.save()
        }
    }

    func delete(ids: Set<UUID>) async throws {
        let viewContext = persistence.container.viewContext
        
        // FIXME: Should use background view context
        try await viewContext.perform {
            let request = Todo.fetchRequest()

            for id in ids {
                request.predicate = NSPredicate(format: "id = %@", id as CVarArg)

                guard let todos = try? viewContext.fetch(request) else { continue }

                todos.forEach { viewContext.delete($0) }
            }

            try viewContext.save()
        }
    }

    func maxOrder() throws -> Int64 {
        let keyPathExpression = NSExpression(forKeyPath: "order")
        let maxNumberExpression = NSExpression(forFunction: "max:", arguments: [keyPathExpression])

        let expressionDescription: NSExpressionDescription = {
            let expressionDescription = NSExpressionDescription()
            expressionDescription.name = "maxNumber"
            expressionDescription.expression = maxNumberExpression
            expressionDescription.expressionResultType = .decimalAttributeType

            return expressionDescription
        }()

        let expressionDescriptions = [expressionDescription]

        let request: NSFetchRequest<NSFetchRequestResult> = Todo.fetchRequest()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = expressionDescriptions

        guard let results = try persistence.container.viewContext.fetch(request) as? [[String: Int64]] else { return Int64(0) }

        return results.first?["maxNumber"] ?? Int64(0)
    }

    #if DEBUG
    var samples: [Todo] {
        let viewContext = persistence.container.viewContext
        let request = Todo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Todo.name, ascending: true)]

        let todos = try? viewContext.fetch(request)

        return todos ?? []
    }
    #endif
}
