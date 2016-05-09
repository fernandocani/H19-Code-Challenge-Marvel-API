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
    
    func createCharacter(
        id: String,
        name: String,
        thumbnailURL: String,
        thumbnail: UIImage?,
        heroDescription: String,
        comics: String,
        series: String,
        stories: String,
        events: String
        ) -> Bool {
        
        let dbCharacterEntity = NSEntityDescription.entityForName("DBCharacter", inManagedObjectContext: managedContext)
        let dbCharacter = DBCharacter(entity: dbCharacterEntity!, insertIntoManagedObjectContext: managedContext)
        
        dbCharacter.id              = id
        dbCharacter.name            = name
        dbCharacter.thumbnailURL    = thumbnailURL
        dbCharacter.heroDescription = heroDescription
        dbCharacter.comics          = comics
        dbCharacter.series          = series
        dbCharacter.stories         = stories
        dbCharacter.events          = events
        if thumbnail != nil{
            dbCharacter.thumbnail = UIImagePNGRepresentation(thumbnail!)
        }
        (try! managedContext.save())
        return true
    }
    
    func hasCharacters() -> Bool {
        let request = NSFetchRequest(entityName: "DBCharacter")
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        if objects!.count > 0 {
            return true
        }
        return false
    }
    
    func hasCharacter(id: String) -> Bool {
        let request = NSFetchRequest(entityName: "DBCharacter")
        request.predicate = NSPredicate(format: "id contains[c] %@", id)
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        if objects!.count > 0 {
            return true
        }
        return false
    }
    
    func getCharacters() -> NSMutableArray {
        let request = NSFetchRequest(entityName: "DBCharacter")
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        let result = NSMutableArray()
        for item in objects! {
            let char             = Character()
            char.id              = (item as! DBCharacter).id!
            char.name            = (item as! DBCharacter).name!
            char.thumbnailURL    = (item as! DBCharacter).thumbnailURL!
            char.heroDescription = (item as! DBCharacter).heroDescription!
            char.comics          = (item as! DBCharacter).comics!
            char.series          = (item as! DBCharacter).series!
            char.stories         = (item as! DBCharacter).stories!
            char.events          = (item as! DBCharacter).events!
            if (item as! DBCharacter).thumbnail != nil {
                char.thumbnail  = (item as! DBCharacter).thumbnail!
            }
            result.addObject(char)
        }
        return result
    }
    
    func updateCharacter(
        id: String,
        name: String,
        thumbnailURL: String,
        thumbnail: NSData?,
        heroDescription: String,
        comics: String,
        series: String,
        stories: String,
        events: String
        ) -> Bool {
        let request = NSFetchRequest(entityName: "DBCharacter")
        request.predicate = NSPredicate(format: "id contains[c] %@", id)
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        if objects!.count > 0 {
            let dbCharacterToUpdate = objects!.first as! DBCharacter
            dbCharacterToUpdate.id              = id
            dbCharacterToUpdate.name            = name
            dbCharacterToUpdate.thumbnailURL    = thumbnailURL
            dbCharacterToUpdate.heroDescription = heroDescription
            dbCharacterToUpdate.comics          = comics
            dbCharacterToUpdate.series          = series
            dbCharacterToUpdate.stories         = stories
            dbCharacterToUpdate.events          = events
            if thumbnail != nil{
                dbCharacterToUpdate.thumbnail = thumbnail
            }
            (try! managedContext.save())
            return true
        }
        return false
    }
    
    func whipeCD () -> Bool {
        let fetchRequest1 = NSFetchRequest(entityName: "DBCharacter")
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        (try! managedContext.executeRequest(deleteRequest1))
        
        return true
    }
    
}