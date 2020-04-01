//
//  ContentView.swift
//  ExemploDeJSONLoad
//
//  Created by Antônio Vieira on 19/03/20.
//  Copyright © 2020 Antônio Vieira. All rights reserved.
//

import SwiftUI
import Combine

struct Course : Decodable  {
    var name, link, imageUrl : String;
}

class NetworkManager : ObservableObject {
  let objectWillChange = ObservableObjectPublisher()

    var courses = [Course]() {
      willSet { self.objectWillChange.send() }
    }
    
    init () {
        guard let url = URL(string: "https://api.letsbuildthatapp.com/jsondecodable/courses") else  { return }
        URLSession.shared.dataTask(with: url) {
            (data, _, _) in
            
            guard let data = data else { return }
            let courses = try! JSONDecoder().decode([Course].self, from: data)
            
            DispatchQueue.main.async {
                self.courses = courses
            }
            
        }.resume()
        
    }
}

struct ContentView: View {
    
    @ObservedObject var networkManager = NetworkManager();
    
    var body: some View {
        NavigationView {
            List(
                networkManager.courses, id: \.name
                )
            {  course in
                CourseRowView(course: course)
            }.navigationBarTitle("Minha Lista")
        }

    }
}

struct CourseRowView : View {
    let course : Course
    var body: some View {
        
        VStack {
            ImageViewWidget(url: URL(string: course.imageUrl)!,
                            placeholder: Text("Loading ..."))
            Text(course.name)
            
        }
    }
}

class ImageLoader : ObservableObject {
    
    @Published var image : UIImage?
    private let url : URL
    private var cancellable : AnyCancellable?
    
    init (url : URL) {
        self.url = url
    }
    
    func load() {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct ImageViewWidget<Placeholder: View> : View {
    
    @ObservedObject private var loader: ImageLoader
    private let placeholder: Placeholder?
    
    init (url: URL, placeholder: Placeholder? = nil) {
        loader = ImageLoader(url:url)
        self.placeholder = placeholder
    }
    
    private var image: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
            } else {
                placeholder
            }
        }
    }
    
    var body : some View {
        image
            .onAppear(perform : loader.load)
            .onDisappear(perform: loader.cancel)
    }
 
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
