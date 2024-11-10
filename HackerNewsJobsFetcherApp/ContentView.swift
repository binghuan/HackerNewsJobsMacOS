import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: JobViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: JobViewModel(context: context))
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search jobs...", text: $viewModel.keyword, onCommit: {
                    viewModel.searchJobs(keyword: viewModel.keyword)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Button(action: {
                    viewModel.searchJobs(keyword: viewModel.keyword)
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                }
                .padding()
                
                Button(action: {
                    viewModel.fetchAndStoreJobs()
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Fetch Jobs")
                    }
                }
                .padding()
            }
            
            if viewModel.isFetching {
                ProgressView(value: viewModel.fetchProgress)
                    .progressViewStyle(LinearProgressViewStyle())
            }
            
            Text("Found \(viewModel.jobs.count) jobs")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            List(viewModel.jobs.indices, id: \.self) { index in
                let job = viewModel.jobs[index]
                VStack(alignment: .leading) {
                    Text(job.title ?? "").font(.headline)
                    Text("Posted by \(job.by ?? "") on \(job.time ?? Date(), formatter: itemFormatter)")
                    Text(job.url ?? "").foregroundColor(.blue).underline()
                }
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.fetchAndStoreJobs()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an in-memory persistent container for preview
        let persistenceController = PersistenceController(inMemory: true)
        
        // Insert mock data into the preview context
        let viewContext = persistenceController.container.viewContext
        for i in 1...5 {
            let job = Job(context: viewContext)
            job.id = Int64(i)
            job.title = "Job Title \(i)"
            job.url = "https://example.com/\(i)"
            job.score = Int64(i * 10)
            job.by = "User \(i)"
            job.time = Date()
            job.text = "Description for job \(i)"
            job.webpageContent = "Webpage content for job \(i)"
        }
        
        // Save the context to make sure data is available for preview
        try? viewContext.save()
        
        return ContentView(context: viewContext)
            .environment(\.managedObjectContext, viewContext)
    }
}
