//
//  ContentView.swift
//  ApiMobile
//
//  Created by STICH, AIDEN S. on 4/15/24.
//

import SwiftUI
import Foundation
import URLImage

struct Meme: Codable, Identifiable {
    let id: String
    let name: String
    let url: URL
}

struct MemeResponse: Codable {
    let data: MemeData
}

struct MemeData: Codable {
    let memes: [Meme]
}

struct ContentView: View {
    @State private var memes: [Meme] = []

    var body: some View {
        VStack {
            Button(action: {
                fetchMemes()
                print("Button is clicked")
            }, label: {
                Text("Fetch Memes")
            })

            ScrollView {
                LazyVStack {
                    ForEach(memes) { meme in
                        VStack {
                            Text(meme.name)
                                .font(.title)
                            RemoteImage(url: meme.url)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                        }
                        .padding()
                    }
                }
            }
        }
        .padding()
    }

    func fetchMemes() {
        guard let url = URL(string: "https://api.imgflip.com/get_memes") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let jsonData = data {
                do {
                    let decoder = JSONDecoder()
                    let memeResponse = try decoder.decode(MemeResponse.self, from: jsonData)
                    DispatchQueue.main.async {
                        self.memes = memeResponse.data.memes
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

struct RemoteImage: View {
    let url: URL
    @State private var image: Image? = nil

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
            } else {
                ProgressView()
                    .onAppear(perform: loadImage)
            }
        }
    }

    private func loadImage() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            if let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }
}


#Preview {
    ContentView()
}
