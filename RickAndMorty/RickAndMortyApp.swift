import SwiftUI
import Alamofire

@main
struct RickAndMortyApp: App {
    
    private let apiService: APIServiceProtocol = APIService()
    
    @StateObject private var viewModel: CharactersViewModel

    init() {
        let vm = CharactersViewModel(apiService: apiService)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CharacterListView()
                    .environmentObject(viewModel)
                    .navigationTitle("Characters")
            }
        }
    }
}
