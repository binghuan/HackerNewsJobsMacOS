import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
           container = NSPersistentContainer(name: "HackerNewsJobsModel")
           
           if inMemory {
               container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
           }
           
           container.loadPersistentStores { description, error in
               if let error = error as NSError? {
                   fatalError("Unresolved error \(error), \(error.userInfo)")
               }
               
               // Log the SQLite file location
                           if let url = description.url {
                               print("Core Data SQLite file location: \(url.path)")
                           }
           }
       }

    // Access the main view context
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    // Create and provide a background context
    var newBackgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
}
