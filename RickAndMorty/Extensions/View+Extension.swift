import SwiftUI

extension View {
    func largeTitleStyle() -> some View {
        modifier(LargeTitleStyle())
    }
    
    func titleStyle() -> some View {
        modifier(TitleStyle())
    }
    
    func regularTextStyle(color: Color = .ramBlack) -> some View {
        modifier(RegularTextStyle(color: color))
    }
}
