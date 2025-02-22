import SwiftUI

struct StatusBadgeView: View {
    let status: CharacterStatus
    
    var body: some View {
        Text(status.rawValue.uppercased())
            .regularTextStyle(color: status.textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(status.backgroundColor)
            )
    }
}
