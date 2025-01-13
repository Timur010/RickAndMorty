import SwiftUI

extension View {
    func errorAlert(errorMessage: Binding<String?>) -> some View {
        alert(isPresented: Binding<Bool>(
            get: { errorMessage.wrappedValue != nil },
            set: { _ in errorMessage.wrappedValue = nil }
        )) {
            Alert(
                title: Text("Ошибка"),
                message: Text(errorMessage.wrappedValue ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
