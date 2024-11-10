import Foundation
import Combine
import CoreData

class JobViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var isFetching = false
    @Published var fetchProgress: Float = 0.0
    @Published var keyword: String = ""
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAndStoreJobs() {
        self.isFetching = true
        self.fetchProgress = 0.0
        NetworkManager.shared.fetchJobStories { jobIds in
            let totalJobs = jobIds.prefix(20).count
            var completedJobs = 0
            
            jobIds.prefix(20).forEach { jobId in
                NetworkManager.shared.fetchJobDetails(jobId: jobId, context: self.context) { job in
                    if let job = job {
                        // Convert `Job` to `JobData`
                        let jobData = JobData(
                            id: job.id,
                            title: job.title ?? "",
                            url: job.url ?? "",
                            score: job.score,
                            by: job.by ?? "",
                            time: job.time ?? Date(),
                            text: job.text,
                            webpageContent: job.webpageContent
                        )
                        do {
                            try DatabaseManager.shared.insertJob(jobData)  // Insert the converted `JobData`
                            self.searchJobs(keyword: "")  // Refresh jobs
                        } catch {
                            print("Error inserting job: \(error)")
                        }
                    }
                    completedJobs += 1
                    self.fetchProgress = Float(completedJobs) / Float(totalJobs)
                    if completedJobs == totalJobs {
                        self.isFetching = false
                    }
                }
            }
        }
    }
    
    
    func searchJobs(keyword: String) {
        do {
            if keyword.isEmpty {
                // Fetch all jobs if keyword is empty
                jobs = try DatabaseManager.shared.fetchAllJobs()
            } else {
                // Search with the given keyword
                jobs = try DatabaseManager.shared.searchJobs(keyword: keyword)
            }
        } catch {
            print("Error searching jobs: \(error)")
        }
    }
}
