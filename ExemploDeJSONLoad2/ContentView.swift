//
//  ContentView.swift
//  ExemploDeJSONLoad
//
//  Created by Antônio Vieira on 19/03/20.
//  Copyright © 2020 Antônio Vieira. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

class Lista : ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    let receiver = CombineNotificationReceiver()
    let pageSize : Int = 4
    var loaded : Int = 0
    
    var array : Array<ListaItem> = Array()
    
    
    var isLoading : Bool = true {
       willSet { self.objectWillChange.send() }
    }

    var cancelSet: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: CombineNotificationSender.combineNotification)
            .compactMap{$0.object as? CombineNotificationSender}
            .map{$0.message}
            .sink() {
                [weak self] message in
                self?.handleNotification(message)
            }
            .store(in: &cancelSet)

        _ = [
            "https://image.tmdb.org/t/p/original/pThyQovXQrw2m0s9x82twj48Jq4.jpg",
            "https://image.tmdb.org/t/p/original/vqzNJRH4YyquRiWxCCOH0aXggHI.jpg",
            "https://image.tmdb.org/t/p/original/6ApDtO7xaWAfPqfi2IARXIzj8QS.jpg",
            "https://image.tmdb.org/t/p/original/7GsM4mtM0worCtIVeiQt28HieeN.jpg"
        ].map {
            array.append(ListaItem(item: ImageLoader2(url: (URL(string: $0)!)))  )
        }
    }
    
    func handleNotification(_ message: Int) {
        print(" handleNotification! ")
        self.loaded = self.loaded + message
        if (self.loaded == self.pageSize) {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
}

struct ListaItem : Identifiable {
    var id = UUID()
    var item : ImageLoader2
}

struct ContentView: View {
    
    @ObservedObject var lista = Lista()

    var body: some View {
        VStack() {
            if lista.isLoading {
                Spacer()
                Text("Carregando ...")
                Spacer()
            } else {
                List {
                    ForEach(lista.array) { result in
                        Image(uiImage: result.item.image!)
                            .resizable()
                        .scaledToFit()
                        .frame(width: 150.0,height:150)
                    }
                }
            }
        }
    }
}

class ImageLoader2 : ObservableObject {
    let sender = CombineNotificationSender(0);
    @Published var image : UIImage?
    private let url : URL
    private var cancellable : AnyCancellable?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing") //
    
    init (url : URL) {
        self.url = url
        self.load()
    }
    
    func load() {

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
        .subscribe(on: Self.imageProcessingQueue) //
        .map { UIImage(data: $0.data) }
        .replaceError(with: nil)
        // 3.
        .handleEvents(receiveSubscription: { [unowned self] _ in self.onStart() },
                      receiveCompletion: { [unowned self] _ in self.onFinish() },
                      receiveCancel: { [unowned self] in self.onFinish() })
        .receive(on: DispatchQueue.main)
        .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        sender.message = -1
        //NotificationCenter.default.post(name: CombineNotificationSender.combineNotification, object: sender)
    }
    
    private func onFinish() {
        sender.message = +1
        NotificationCenter.default.post(name: CombineNotificationSender.combineNotification, object: sender)
    }

}

class CombineNotificationSender {

    var message : Int

    init(_ messageToSend: Int) {
        message = messageToSend
    }

    static let combineNotification = Notification.Name("CombineNotification")
}

class CombineNotificationReceiver {
    var cancelSet: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: CombineNotificationSender.combineNotification)
            .compactMap{$0.object as? CombineNotificationSender}
            .map{$0.message}
            .sink() {
                [weak self] message in
                self?.handleNotification(message)
            }
            .store(in: &cancelSet)
    }

    func handleNotification(_ message: Int) {
        print(message)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
