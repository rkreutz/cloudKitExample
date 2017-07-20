//
//  cloudKitPokemonTests.swift
//  cloudKitPokemonTests
//
//  Created by Rodrigo Kreutz on 3/8/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import XCTest
import CloudKit
@testable import cloudKitPokemon

class cloudKitPokemonTests: XCTestCase, CloudKitModelDelegate {
    
    var iCloud: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCheckICloud() {
        self.iCloud = expectationWithDescription("iCloud")
        
        CloudKitModel.sharedInstance.delegate = self
        CloudKitModel.sharedInstance.checkICloudCredentials(CKContainer.defaultContainer())
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testRefreshData() {
        self.iCloud = expectationWithDescription("refresh")
        
        CloudKitModel.sharedInstance.delegate = self
        CloudKitModel.sharedInstance.container = CKContainer.defaultContainer()
        CloudKitModel.sharedInstance.refreshData(self)
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testAddPokemon() {
        self.iCloud = expectationWithDescription("add")
        
        CloudKitModel.sharedInstance.delegate = self
        CloudKitModel.sharedInstance.container = CKContainer.defaultContainer()
        CloudKitModel.sharedInstance.addPokemon(Pokemon(number: 20, name: "teste", icon: "teste", image: "teste", level: 20, type: "teste", type2: "teste", status: nil, skills: nil))
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func logStatus(error: NSError?) {
        self.iCloud.fulfill()
    }
    
    func refreshData(pokemons: [Pokemon]?, withError error: NSError?) {
        self.iCloud.fulfill()
    }
    
    func addedData(withError: NSError?) {
        self.iCloud.fulfill()
    }
    
}
