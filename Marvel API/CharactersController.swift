//
//  CharactersController.swift
//  Marvel API
//
//  Created by Fernando Cani on 5/4/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SDWebImage

class CharactersController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:   UITableView!
    
    var charactersCellArray         = NSMutableArray()
    var charactersArray             = NSMutableArray()
    var characterCell               = "characterCell"
    var charactersCellArrayCount    = 0
    var currentIndex                = 0
    var limit                       = 50
    var total                       = Int()
    
    var cellHeight                  = CGFloat(150.0)
    var imageVisibleHeight          = CGFloat(150.0)
    let parallaxOffsetSpeed         = CGFloat(25)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if DataStore.sharedInstance.hasCharacter() {
            charactersArray.addObjectsFromArray(DataStore.sharedInstance.getCharacter() as [AnyObject])
            total = charactersArray.count
            populateCell()
        } else {
            self.createLoading()
            openConnection()
        }
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
        let ts = String(Int(NSDate().timeIntervalSince1970) * 1000)
        let url = urlTotalCharacters + "&limit=\(limit)" + "&offset=\(currentIndex + limit)" + "&apikey=\(publicKey)" + "&ts=\(ts)" + "&hash=\((ts+privateKey+publicKey).md5())"
        print("\(currentIndex)" + " | " + "\(url)")
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
                        return
                    }
                    if let resultJSON = JSONDictionary.objectForKey("data")?.objectForKey("results")! as? [[String: AnyObject]] {
                        for item in resultJSON {
                            let character = Character()
                            character.id            = String((item as NSDictionary).objectForKey("id")!)
                            character.name          = String((item as NSDictionary).objectForKey("name")!)
                            character.thumbnailURL  = String((item as NSDictionary).objectForKey("thumbnail")!.objectForKey("path")!) + ".jpg"
                            self.charactersArray.addObject(character)
                            self.currentIndex = self.currentIndex + 1
                            self.total = Int(JSONDictionary.objectForKey("data")!.objectForKey("total")! as! NSNumber)
                            DataStore.sharedInstance.createCharacter(character.id!, name: character.name!, thumbnailURL: character.thumbnailURL!, thumbnail: nil)
                        }
                        print("foi")
                    } else {
                        self.currentIndex = self.currentIndex + self.limit
                        print("não foi")
                    }
                    print("\(self.currentIndex) | \(self.total) ")
                    if (self.currentIndex + self.limit) < self.total {
                        self.openConnection()
                    } else {
                        print(self.charactersArray.count)
                        self.populateCell()
                        self.removeLoading()
                    }
                }
        }
    }
    
    func populateCell() {
        if charactersCellArray.count > 0 {
            charactersCellArray.removeAllObjects()
        }
        for valor in 0...(self.charactersArray.count - 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier(characterCell) as! CharactersTableViewCell
            cell.selectionStyle = .None
            let char = charactersArray[valor] as! Character
            cell.character = char
            if char.thumbnail != nil {
                cell.imgCharacter.image = UIImage(data: char.thumbnail!)
            } else {
                cell.imgCharacter.sd_setImageWithURL(NSURL(string: char.thumbnailURL!), placeholderImage: UIImage())
            }
            cell.imgCharacterHeightConstraint.constant = parallaxImageHeight
            cell.imgCharacterTopConstraint.constant = parallaxOffsetFor(tableView.contentOffset.y, cell: cell)
            
            cell.lblCharacterName.text = cell.character.name
            charactersCellArray.addObject(cell)
        }
        tableView.reloadData()
    }
    
    // Start Parallax
    
    var parallaxImageHeight: CGFloat {
        let maxOffset = (sqrt(pow(cellHeight, 2) + 4 * parallaxOffsetSpeed * tableView.frame.height) - cellHeight) / 2
        return imageVisibleHeight + maxOffset
    }
    
    func parallaxOffsetFor(newOffsetY: CGFloat, cell: UITableViewCell) -> CGFloat {
        return ((newOffsetY - cell.frame.origin.y) / parallaxImageHeight) * parallaxOffsetSpeed
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = tableView.contentOffset.y
        for cell in tableView.visibleCells as! [CharactersTableViewCell] {
            cell.imgCharacterTopConstraint.constant = parallaxOffsetFor(offsetY, cell: cell)
        }
    }
    
    // End Parallax
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charactersCellArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return charactersCellArray[indexPath.row] as! CharactersTableViewCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print((charactersArray[indexPath.row] as! Character).name!)
    }
    
}

class CharactersTableViewCell: UITableViewCell {
    @IBOutlet weak var imgCharacter: UIImageView!
    @IBOutlet weak var lblCharacterName: UILabel!
    
    @IBOutlet weak var imgCharacterHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgCharacterTopConstraint: NSLayoutConstraint!
    
    var character = Character()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        imgCharacter.contentMode = .ScaleAspectFill
        imgCharacter.clipsToBounds = false
    }
}