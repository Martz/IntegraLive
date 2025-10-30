/// Tests for IntegraLive Swift models and core functionality
///
/// These tests validate the core data models and session management

import XCTest
@testable import IntegraLiveCore

final class IntegraLiveCoreTests: XCTestCase {
    
    // MARK: - Project Tests
    
    func testProjectCreation() {
        let project = Project(name: "Test Project")
        
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertTrue(project.scenes.isEmpty)
        XCTAssertNotNil(project.id)
    }
    
    func testProjectDates() {
        let project = Project(name: "Test Project")
        
        XCTAssertNotNil(project.createdDate)
        XCTAssertNotNil(project.modifiedDate)
        XCTAssertEqual(
            project.createdDate.timeIntervalSince1970,
            project.modifiedDate.timeIntervalSince1970,
            accuracy: 1.0
        )
    }
    
    // MARK: - Scene Tests
    
    func testSceneCreation() {
        let scene = Scene(name: "Test Scene")
        
        XCTAssertEqual(scene.name, "Test Scene")
        XCTAssertTrue(scene.blocks.isEmpty)
        XCTAssertNotNil(scene.id)
    }
    
    func testSceneAddToProject() {
        let project = Project(name: "Test Project")
        let scene = Scene(name: "Scene 1")
        
        project.scenes.append(scene)
        
        XCTAssertEqual(project.scenes.count, 1)
        XCTAssertEqual(project.scenes[0].name, "Scene 1")
    }
    
    // MARK: - Block Tests
    
    func testBlockCreation() {
        let block = Block(name: "Test Block")
        
        XCTAssertEqual(block.name, "Test Block")
        XCTAssertNil(block.moduleInstance)
        XCTAssertTrue(block.connections.isEmpty)
        XCTAssertNotNil(block.id)
    }
    
    func testBlockAddToScene() {
        let scene = Scene(name: "Test Scene")
        let block = Block(name: "Block 1")
        
        scene.blocks.append(block)
        
        XCTAssertEqual(scene.blocks.count, 1)
        XCTAssertEqual(scene.blocks[0].name, "Block 1")
    }
    
    // MARK: - Module Instance Tests
    
    func testModuleInstanceCreation() {
        let module = ModuleInstance(
            moduleDefinitionID: "test.module",
            name: "Test Module"
        )
        
        XCTAssertEqual(module.moduleDefinitionID, "test.module")
        XCTAssertEqual(module.name, "Test Module")
        XCTAssertTrue(module.parameters.isEmpty)
        XCTAssertNotNil(module.id)
    }
    
    // MARK: - Connection Tests
    
    func testConnectionCreation() {
        let sourceID = UUID()
        let targetID = UUID()
        
        let connection = Connection(
            sourceBlockID: sourceID,
            targetBlockID: targetID,
            sourceEndpoint: "output",
            targetEndpoint: "input"
        )
        
        XCTAssertEqual(connection.sourceBlockID, sourceID)
        XCTAssertEqual(connection.targetBlockID, targetID)
        XCTAssertEqual(connection.sourceEndpoint, "output")
        XCTAssertEqual(connection.targetEndpoint, "input")
        XCTAssertNotNil(connection.id)
    }
    
    // MARK: - Session Manager Tests
    
    func testSessionManagerInitialization() {
        let sessionManager = SessionManager()
        
        XCTAssertNil(sessionManager.currentProject)
        XCTAssertFalse(sessionManager.isConnected)
        XCTAssertFalse(sessionManager.statusMessage.isEmpty)
    }
    
    func testNewProjectCreation() {
        let sessionManager = SessionManager()
        
        sessionManager.newProject(named: "New Project")
        
        XCTAssertNotNil(sessionManager.currentProject)
        XCTAssertEqual(sessionManager.currentProject?.name, "New Project")
        XCTAssertEqual(sessionManager.currentProject?.scenes.count, 1)
    }
    
    func testAddSceneToProject() throws {
        let sessionManager = SessionManager()
        sessionManager.newProject(named: "Test Project")
        
        try sessionManager.addScene(named: "Scene 2")
        
        XCTAssertEqual(sessionManager.currentProject?.scenes.count, 2)
        XCTAssertEqual(sessionManager.currentProject?.scenes[1].name, "Scene 2")
    }
    
    func testAddSceneWithoutProject() {
        let sessionManager = SessionManager()
        
        XCTAssertThrowsError(try sessionManager.addScene(named: "Scene 1")) { error in
            XCTAssertTrue(error is SessionError)
            if case SessionError.noProjectLoaded = error {
                // Expected error
            } else {
                XCTFail("Expected SessionError.noProjectLoaded")
            }
        }
    }
    
    func testRemoveScene() throws {
        let sessionManager = SessionManager()
        sessionManager.newProject(named: "Test Project")
        try sessionManager.addScene(named: "Scene 2")
        
        guard let project = sessionManager.currentProject else {
            XCTFail("No project loaded")
            return
        }
        
        let sceneToRemove = project.scenes[1]
        try sessionManager.removeScene(sceneToRemove)
        
        XCTAssertEqual(project.scenes.count, 1)
    }
    
    // MARK: - Interface Definition Tests
    
    func testInterfaceDefinitionCreation() {
        var interfaceDef = InterfaceDefinition(
            moduleID: "test.module",
            version: "1.0.0"
        )
        
        XCTAssertEqual(interfaceDef.moduleID, "test.module")
        XCTAssertEqual(interfaceDef.version, "1.0.0")
        XCTAssertTrue(interfaceDef.endpoints.isEmpty)
        
        let endpoint = EndpointDefinition(
            name: "volume",
            type: .control,
            defaultValue: 0.5,
            range: ValueRange(minimum: 0.0, maximum: 1.0, defaultValue: 0.5)
        )
        
        interfaceDef.endpoints.append(endpoint)
        XCTAssertEqual(interfaceDef.endpoints.count, 1)
    }
    
    // MARK: - Value Range Tests
    
    func testValueRangeCreation() {
        let range = ValueRange(minimum: 0.0, maximum: 100.0, defaultValue: 50.0)
        
        XCTAssertEqual(range.minimum, 0.0)
        XCTAssertEqual(range.maximum, 100.0)
        XCTAssertEqual(range.defaultValue, 50.0)
    }
}
