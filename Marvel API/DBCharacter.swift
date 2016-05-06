//
//  DBCharacter.swift
//  Marvel API
//
//  Created by Fernando Cani on 5/4/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import CoreData

@objc(DBCharacter)
class DBCharacter: NSManagedObject {
    
    @NSManaged var id:              String?
    @NSManaged var name:            String?
    @NSManaged var thumbnailURL:    String?
    @NSManaged var thumbnail:       NSData?

}