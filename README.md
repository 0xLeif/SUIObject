# SUIObject

## Example
```swift
import SwiftUI
import SUIObject

struct ContentView: View {
    @ObservedObject var object = Object("...")
    
    var body: some View {
        VStack {
            Text(object.stringValue() ?? "-1")
            Text(object.otherText.stringValue() ?? "-2")
            Button("Change") {
                self.object.run(function: "change")
            }
        }
        .onAppear {
            self.object.configure { obj in
                obj.add(value: "Hello World")
                obj.add(variable: "otherText", value: "Another one")
                obj.add(function: "change", value: { _ in
                    obj.variables["otherText"] = "\(obj.otherText.stringValue() ?? "")+"
                })
            }
        }
    }
}
```
