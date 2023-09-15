// The Swift Programming Language
// https://docs.swift.org/swift-book

import MetalKit
import SwiftUI

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#else
typealias ViewRepresentable = UIViewRepresentable
#endif

public enum MetalViewError: String, Error {
    case noError = "No Error"
    case createDeviceError = "Device Creation Error"
}

public struct MetalView: View {
    var renderer: MetalViewRenderer
    @Binding var error: MetalViewError

    public init(renderer: MetalViewRenderer, error: Binding<MetalViewError>) {
        self._error = error
        self.renderer = renderer
    }

    public var body: some View {
        MetalViewRepresentable(renderer: renderer, error: $error)
    }
}

struct MetalViewRepresentable: ViewRepresentable {
    let renderer: MetalViewRenderer
    @Binding var error: MetalViewError

    #if os(macOS)
    typealias ViewType = NSView
    #else
    typealias ViewType = UIView
    #endif

    func makeView(context: Context) -> some ViewType {
        let view = MTKView()
        view.device = MTLCreateSystemDefaultDevice()
        if view.device == nil {
            error = .createDeviceError
        }
        view.delegate = context.coordinator
        return view
    }

    #if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        return makeView(context: context)
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {}
    #else
    func makeUIView(context: Context) -> some UIView {
        return makeView(context: context)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
    #endif

    func makeCoordinator() -> Coordinator {
        return Coordinator(renderer)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        let renderer: MetalViewRenderer
        var first = true

        init(_ renderer: MetalViewRenderer) {
            self.renderer = renderer
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            if first {
                renderer.start(view)
                first = false
            }
        }

        func draw(in view: MTKView) {
            renderer.frame(view)
        }
    }
}
