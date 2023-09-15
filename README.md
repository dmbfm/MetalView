# MetalView 

A simple wrapper for MTKView that works in macOS and iOS. 


# Usage

The view `MetalView` takes as parameters an instance of a class that conforms to
the `MetalViewRenderer` protocol, and a binding to a `MetalViewError`, that will
notify for any errors when creating the Metal device.

Here is a small sample of how to use the `MetalView`:


```swift
class Renderer: MetalViewRenderer {
    var commandQueue: MTLCommandQueue!
    var view: MTKView!

    var onAfterStart: (() -> Void)?
    
    func start(_ view: MTKView) {
        guard let device = view.device else { return }

        self.view = view
        view.clearColor = MTLClearColorMake(1, 1, 1, 1)
        view.preferredFramesPerSecond = 60

        commandQueue = device.makeCommandQueue()

        onAfterStart?()
    }

    func frame(_ view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { return }

        encoder.endEncoding()
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }

    func setClearColor(_ color: CGColor) {
        if let clearColor = color.mtlClearColor {
            view.clearColor = clearColor
        }
    }

    static let shared = Renderer()
}

struct ContentView: View {
    @State var error: MetalViewError = .noError
    @State var color: CGColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
    @State var renderer: Renderer = .shared
    var body: some View {
        VStack {
            MetalView(renderer: self.renderer, error: $error)

            VStack {
                if error != .noError {
                    Text("Error: \(error.rawValue)")
                }
                ColorPicker("Color", selection: $color)
            }
            .padding()
        }
        .onChange(of: color, initial: false) {
            self.renderer.setClearColor(color)
        }
        .onAppear {
            self.renderer.onAfterStart = {
                self.color = self.renderer.view.clearColor.cgColor
            }
        }
    }
}

extension MTLClearColor {
    var cgColor: CGColor {
        .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension CGColor {
    var mtlClearColor: MTLClearColor? {
        if let components = components {
            return MTLClearColorMake(components[0], components[1], components[2], 1)
        }
        return nil
    }
}
```
