import SwiftUI


@MainActor
struct CombineTimerView<Model: CombineTimerViewModel>: View {
    
    @StateObject
    var viewModel: Model
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Combine!")
            Text("\(viewModel.time.formatted())")
        }
        .padding()
    }
}


#Preview {
    CombineTimerView(viewModel: CombineTimerViewModelImpl.static(time: .seconds(12)))
}
