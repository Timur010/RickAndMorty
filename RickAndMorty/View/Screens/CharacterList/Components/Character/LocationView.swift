import SwiftUI

struct LocationView: View {
    let locationName: String
    
    var body: some View {
        HStack {
            Image("location")
                .foregroundColor(.gray)
            Text(locationName)
                .regularTextStyle(color: .ramGrey)
        }
    }
}
