import CoreData

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {}
    
    func insertJob(_ jobData: JobData) throws {
        let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
        
        try backgroundContext.performAndWait {
            // Set up fetch request to check if job with the same ID already exists
            let jobFetchRequest: NSFetchRequest<Job> = Job.fetchRequest()
            jobFetchRequest.predicate = NSPredicate(format: "id == %d", jobData.id)
            
            do {
                // Check if a job with the same ID already exists
                let existingJobs = try backgroundContext.fetch(jobFetchRequest)
                
                if let existingJob = existingJobs.first {
                    // Log that the job is a duplicate and skip saving
                    print("❗️Duplicate job detected. Job with ID \(existingJob.id) already exists. Skipping insert.")
                    return
                } else {
                    // Create a new job if it doesn't already exist
                    let job = Job(context: backgroundContext)
                    
                    // Set job properties
                    job.id = jobData.id
                    job.title = jobData.title
                    job.url = jobData.url
                    job.score = jobData.score
                    job.by = jobData.by
                    job.time = jobData.time
                    job.text = jobData.text
                    job.webpageContent = jobData.webpageContent
                    
                    // Save context
                    try backgroundContext.save()
                    print("👌 Data saved successfully: \(job.id)")
                }
                
            } catch {
                // If there's an error, print it and rethrow to handle it at a higher level
                print("Failed to save data: \(error)")
                throw error
            }
        }
    }
    
    
    func fetchAllJobs() throws -> [Job] {
        let context = PersistenceController.shared.viewContext
        let fetchRequest: NSFetchRequest<Job> = Job.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        
        return try context.fetch(fetchRequest)
    }
    
    func searchJobs(keyword: String) throws -> [Job] {
        let context = PersistenceController.shared.viewContext
        let fetchRequest: NSFetchRequest<Job> = Job.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR text CONTAINS[cd] %@ OR webpageContent CONTAINS[cd] %@", keyword, keyword, keyword)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        
        return try context.fetch(fetchRequest)
    }
    
}
