/// Core data models for IntegraLive Swift port
///
/// This file contains the fundamental data structures that represent
/// the IntegraLive domain model, ported from the original ActionScript/C++ implementation.

import Foundation
import SwiftUI

// MARK: - Project Model

/// Represents an IntegraLive project
/// Corresponds to the Project.as in the original GUI
public class Project {
    public var id: UUID
    public var name: String
    public var scenes: [Scene]
    public var createdDate: Date
    public var modifiedDate: Date
    
    public init(name: String) {
        self.id = UUID()
        self.name = name
        self.scenes = []
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}

// MARK: - Scene Model

/// Represents a scene within a project
/// Corresponds to Scene.as in the original GUI
public class Scene {
    public var id: UUID
    public var name: String
    public var blocks: [Block]
    
    public init(name: String) {
        self.id = UUID()
        self.name = name
        self.blocks = []
    }
}

// MARK: - Block Model

/// Represents a block (audio/processing module) in a scene
/// Corresponds to Block.as in the original GUI
public class Block: ObservableObject {
    public var id: UUID
    @Published public var name: String
    @Published public var moduleInstance: ModuleInstance?
    @Published public var connections: [Connection]
    @Published public var position: CGPoint
    @Published public var size: CGSize

    public init(name: String, position: CGPoint = .zero) {
        self.id = UUID()
        self.name = name
        self.connections = []
        self.position = position
        self.size = CGSize(width: 120, height: 80)
    }
}

// MARK: - Module Model

/// Represents a module instance
/// Corresponds to ModuleInstance.as in the original GUI
public class ModuleInstance {
    public var id: UUID
    public var moduleDefinitionID: String
    public var name: String
    public var parameters: [String: Any]
    
    public init(moduleDefinitionID: String, name: String) {
        self.id = UUID()
        self.moduleDefinitionID = moduleDefinitionID
        self.name = name
        self.parameters = [:]
    }
}

// MARK: - Connection Model

/// Represents a connection between blocks
/// Corresponds to Connection.as in the original GUI
public struct Connection {
    public var id: UUID
    public var sourceBlockID: UUID
    public var targetBlockID: UUID
    public var sourceEndpoint: String
    public var targetEndpoint: String
    
    public init(sourceBlockID: UUID, targetBlockID: UUID, 
         sourceEndpoint: String, targetEndpoint: String) {
        self.id = UUID()
        self.sourceBlockID = sourceBlockID
        self.targetBlockID = targetBlockID
        self.sourceEndpoint = sourceEndpoint
        self.targetEndpoint = targetEndpoint
    }
}

// MARK: - Interface Definition

/// Represents an interface definition for a module
/// Corresponds to InterfaceDefinition.as in the original GUI
public struct InterfaceDefinition {
    public var moduleID: String
    public var version: String
    public var endpoints: [EndpointDefinition]
    
    public init(moduleID: String, version: String) {
        self.moduleID = moduleID
        self.version = version
        self.endpoints = []
    }
}

// MARK: - Endpoint Definition

/// Represents an endpoint (parameter) in a module interface
/// Corresponds to EndpointDefinition.as in the original GUI
public struct EndpointDefinition {
    public var name: String
    public var type: EndpointType
    public var defaultValue: Any?
    public var range: ValueRange?
    
    public enum EndpointType {
        case audio
        case control
        case stream
    }
    
    public init(name: String, type: EndpointType, defaultValue: Any? = nil, range: ValueRange? = nil) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.range = range
    }
}

// MARK: - Value Range

/// Represents a value range for parameters
/// Corresponds to ValueRange.as in the original GUI
public struct ValueRange {
    public var minimum: Double
    public var maximum: Double
    public var defaultValue: Double
    
    public init(minimum: Double, maximum: Double, defaultValue: Double) {
        self.minimum = minimum
        self.maximum = maximum
        self.defaultValue = defaultValue
    }
}
