//
//  DataStore.swift
//  Marvel API
//
//  Created by Fernando Cani on 5/4/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import CoreData

class DataStore {
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Singleton
    class var sharedInstance: DataStore {
        struct Static {
            static let instance: DataStore = DataStore()
        }
        return Static.instance
    }

    func createCharacter(id: String, name: String, thumbnailURL: String, thumbnail: UIImage?) -> Bool {
        
        let dbCharacterEntity = NSEntityDescription.entityForName("DBCharacter", inManagedObjectContext: managedContext)
        let dbCharacter = DBCharacter(entity: dbCharacterEntity!, insertIntoManagedObjectContext: managedContext)
        
        dbCharacter.id              = id
        dbCharacter.name            = name
        dbCharacter.thumbnailURL    = thumbnailURL
        if thumbnail != nil{
            dbCharacter.thumbnail = UIImagePNGRepresentation(thumbnail!)
        }
        (try! managedContext.save())
        return true
    }
    
    func hasCharacter() -> Bool {
        let request = NSFetchRequest(entityName: "DBCharacter")
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        if objects!.count > 0 {
            return true
        }
        return false
    }
    
    func getCharacter() -> NSMutableArray {
        let request = NSFetchRequest(entityName: "DBCharacter")
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        let res = NSMutableArray()
        for item in objects! {
            let char            = Character()
            char.id             = (item as! DBCharacter).id!
            char.name           = (item as! DBCharacter).name!
            char.thumbnailURL   = (item as! DBCharacter).thumbnailURL!
            if (item as! DBCharacter).thumbnail != nil {
                char.thumbnail  = (item as! DBCharacter).thumbnail!
            }
            res.addObject(char)
        }
        return res
    }

    func updateCharacter(id: String, name: String, thumbnailURL: String, thumbnail: NSData?) -> Bool {
        let request = NSFetchRequest(entityName: "DBCharacter")
        request.predicate = NSPredicate(format: "id contains[c] %@", id)
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        if objects!.count > 0 {
            let dbCharacterToUpdate = objects!.first as! DBCharacter
            dbCharacterToUpdate.id              = id
            dbCharacterToUpdate.name            = name
            dbCharacterToUpdate.thumbnailURL    = thumbnailURL
            if thumbnail != nil{
                dbCharacterToUpdate.thumbnail = thumbnail
            }
            (try! managedContext.save())
            return true
        }
        return false
    }
    
}