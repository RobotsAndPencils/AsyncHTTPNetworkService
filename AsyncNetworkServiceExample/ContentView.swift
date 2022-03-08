//
//  ContentView.swift
//  AsyncNetworkServiceExample
//
//  Created by Matt Kiazyk on 2022-01-21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GiphyViewModel(service: GiphyService())
    
    var body: some View {
        VStack {
            AsyncImage(url: viewModel.url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    // Since the AsyncImagePhase enum isn't frozen,
                    // we need to add this currently unused fallback
                    // to handle any new cases that might be added
                    // in the future:
                    EmptyView()
                }
            }
            Button {
                viewModel.fetchGif()
            } label: {
                Text("Fetch GIF")
                    .padding(20)
            }
            .contentShape(Rectangle())
         
        }
        .onAppear {
            viewModel.fetchGif()
        }
    }
    
}

@MainActor
class GiphyViewModel: ObservableObject {
    @Published var url: URL?
 
    var asyncService: GiphyService
    
    init(service: GiphyService) {
        self.asyncService = service
    }
    
    nonisolated func fetchGif() {
        Task {
            let fetchedURL = try await asyncService.getRandomGif(tag: "blow kiss")
            await updateURL(fetchedURL)
        }
    }
    
    func updateURL(_ url: URL?) async {
        self.url = url
    }
}

