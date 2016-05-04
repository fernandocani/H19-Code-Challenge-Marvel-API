//
//  CharactersController.swift
//  Marvel API
//
//  Created by Fernando Cani on 5/4/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import Alamofire

class CharactersController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:   UITableView!
    
    var charactersCellArray         = NSMutableArray()
    var charactersArray             = NSMutableArray()
    var characterCell               = "characterCell"
    var charactersCellArrayCount    = 0
    var currentIndex                = 0
    var limit                       = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = ""
    }
    
    func createLoading() {
        let currentWindow = UIApplication.sharedApplication().keyWindow
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = self.view.bounds
        visualEffectView.tag = 1
        if (currentWindow!.viewWithTag(1) == nil) {
            currentWindow?.addSubview(visualEffectView)
        }
        
        let spinner = UIActivityIndicatorView()
        spinner.center = self.view.center
        spinner.activityIndicatorViewStyle = .WhiteLarge
        spinner.startAnimating()
        spinner.tag = 2
        if (currentWindow!.viewWithTag(2) == nil) {
            currentWindow?.addSubview(spinner)
        }
    }
    
    func removeLoading() {
        let currentWindow = UIApplication.sharedApplication().keyWindow
        if (currentWindow!.viewWithTag(1) != nil) {
            currentWindow!.viewWithTag(1)!.removeFromSuperview()
        }
        if (currentWindow!.viewWithTag(2) != nil) {
            currentWindow!.viewWithTag(2)!.removeFromSuperview()
        }
    }
    
    func openConnection() {
//        self.createLoading()
        let ts = String(Int(NSDate().timeIntervalSince1970) * 1000)
        let url = urlTotalCharacters + "limit=\(limit)" + "&offset=\(currentIndex + limit)" + "&apikey=\(publicKey)" + "&ts=\(ts)" + "&hash=\((ts+privateKey+publicKey).md5())"
        print(url)
        Alamofire.request(
            .GET,
            url,
            parameters: nil
            )
            .response { request, response, data, error in
                if error == nil {
                    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0))
                    guard let JSONDictionary :NSDictionary = json as? NSDictionary else {
                        print("Not a Dictionary")
//                        self.removeLoading()
                        return
                    }
                    let total = JSONDictionary.objectForKey("data")!.objectForKey("total")!
                    print(total)
                    if let resultJSON = JSONDictionary.objectForKey("data")!.objectForKey("results")! as? [[String: AnyObject]] {
                        for item in resultJSON {
                            let character = Character()
                            character.id        = String((item as NSDictionary).objectForKey("id")!)
                            character.name      = String((item as NSDictionary).objectForKey("name")!)
                            character.thumbnail = String((item as NSDictionary).objectForKey("thumbnail")!.objectForKey("path")!)
                            self.charactersArray.addObject(character)
                            self.currentIndex = self.currentIndex + 1
                        }
                    }
                    
                }
//                self.removeLoading()
                self.populateCell()
        }
    }

    func populateCell() {
        if charactersCellArray.count > 0 {
            charactersCellArray.removeAllObjects()
        }
        for valor in 0...(self.charactersArray.count - 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier(characterCell) as! CharactersTableViewCell
            cell.selectionStyle = .None
            cell.imgCharacter.image = UIImage()//aux1[valor] as! UIImage
            cell.imgCharacter.backgroundColor = UIColor.redColor()
            cell.character = charactersArray[valor] as! Character
            cell.lblCharacterName.text = cell.character.name
            charactersCellArray.addObject(cell)
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell") as! LoadingTableViewCell
        cell.userInteractionEnabled = false
        charactersCellArray.addObject(cell)
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charactersCellArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return charactersCellArray[indexPath.row] as! UITableViewCell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastElement = charactersCellArray.count - 20
        if indexPath.row == lastElement {
            openConnection()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

class CharactersTableViewCell: UITableViewCell {
    @IBOutlet weak var imgCharacter: UIImageView!
    @IBOutlet weak var lblCharacterName: UILabel!
    
    var character = Character()
}

class LoadingTableViewCell: UITableViewCell {
    @IBOutlet weak var loading: UIActivityIndicatorView!
}