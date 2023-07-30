import SwiftUI


@MainActor
struct ObservationTimerView: View {
    
    @State
    var viewModel: ObservationTimerViewModel = ObservationTimerViewModelImpl.system()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, timer!")
            Text("\(viewModel.time.formatted())")
        }
        .padding()
    }
}


#Preview {
    ObservationTimerView()
}
