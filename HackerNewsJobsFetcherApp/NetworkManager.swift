import Foundation
import CoreData

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://hacker-news.firebaseio.com/v0"

    func fetchJobStories(completion: @escaping ([Int]) -> Void) {
        guard let url = URL(string: "\(baseURL)/jobstories.json") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching job stories: \(error)")
                return
            }
            guard let data = data else { return }
            do {
                let jobIds = try JSONDecoder().decode([Int].self, from: data)
                DispatchQueue.main.async {
                    print("Fetched job IDs: \(jobIds)")
                    completion(jobIds)
                }
            } catch {
                print("Error decoding job stories: \(error)")
            }
        }
        task.resume()
    }

    func fetchJobDetails(jobId: Int, context: NSManagedObjectContext, completion: @escaping (Job?) -> Void) {
        guard let url = URL(string: "\(baseURL)/item/\(jobId).json") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching job details: \(error)")
                return
            }
            guard let data = data else { return }
            do {
                if let jobData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let fetchRequest: NSFetchRequest<Job> = Job.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %d", jobId)
                    
                    let existingJobs = try? context.fetch(fetchRequest)
                    let job = existingJobs?.first ?? Job(context: context) // Use existing job or create new
                    
                    // Set job properties
                    job.id = Int64(jobData["id"] as? Int ?? 0)
                    job.title = jobData["title"] as? String ?? ""
                    job.url = jobData["url"] as? String ?? ""
                    job.score = Int64(jobData["score"] as? Int ?? 0)
                    job.by = jobData["by"] as? String ?? ""
                    job.time = Date(timeIntervalSince1970: TimeInterval(jobData["time"] as? Int ?? 0))
                    job.text = jobData["text"] as? String
                    job.webpageContent = nil
                    
                    do {
                        try context.save()
                        print("👌 Data saved successfully for job ID: \(job.id)")
                    } catch {
                        print("Failed to save data: \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        print("Fetched job details for ID: \(jobId)")
                        completion(job)
                    }
                }
            } catch {
                print("Error decoding job details: \(error)")
            }
        }
        task.resume()
    }

}
