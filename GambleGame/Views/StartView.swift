import SwiftUI

struct StartView: View {
    var body: some View {
        ZStack {
            VStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 550, height: 550)
                Spacer().frame(height: 150)
            }
            .padding(.top, 0)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
