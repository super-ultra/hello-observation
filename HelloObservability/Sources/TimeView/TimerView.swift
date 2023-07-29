import SwiftUI

@MainActor
struct TimerView: View {
    
    let viewModel: TimerViewModel = DefaultTimerViewModel.system()
    
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
    TimerView()
}
