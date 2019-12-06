//
//  Test+CoreDataProperties.swift
//  superdiff
//
//  Created by Frank Foster on 12/6/19.
//  Copyright © 2019 Frank Foster. All rights reserved.
//
//

import Foundation
import CoreData


extension Test {

    @nonobjc public class func createfetchRequest() -> NSFetchRequest<Test> {
        return NSFetchRequest<Test>(entityName: "Test")
    }

    @NSManaged public var name: String?
    @NSManaged public var subtitle: String?

}
