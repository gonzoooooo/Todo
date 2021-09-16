import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isFlagged: Bool
    @NSManaged public var notifiedDate: Date?
    @NSManaged public var order: Int64
    @NSManaged public var createdDate: Date
    @NSManaged public var modifiedDate: Date

}

extension Todo : Identifiable {

}
