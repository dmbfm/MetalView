//
//  File.swift
//  
//
//  Created by Daniel Fortes on 14/09/23.
//

import Foundation
import MetalKit

public protocol MetalViewRenderer {
    func start(_ view: MTKView)
    func frame(_ view: MTKView)
}
