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
import UIActivityIndicator_for_SDWebImage

class CharactersController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var spinner:     UIActivityIndicatorView!
    @IBOutlet weak var btnSearch: UIBarButtonItem!
    
    @IBOutlet weak var tableView:   UITableView!
    
    let searchController            = UISearchController(searchResultsController: nil)
    
    var filteredCharactersNameArray = [Character]()
    var charsForSearch              = [Character]()
    var charactersCellArray         = NSMutableArray()
    var charactersArray             = NSMutableArray()
    var characterCell               = "characterCell"
    var charactersCellArrayCount    = 0
    var currentIndex                = 0
    var limit                       = 20
    var total                       = Int()
    var loadingData                 = false
    
    var cellHeight                  = CGFloat(150.0)
    var imageVisibleHeight          = CGFloat(150.0)
    let parallaxOffsetSpeed         = CGFloat(25)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        spinner.hidden = true
        
        if DataStore.sharedInstance.hasCharacters() {
            charactersArray.addObjectsFromArray(DataStore.sharedInstance.getCharacters() as [AnyObject])
            for item in charactersArray {
                charsForSearch.append(item as! Character)
            }
            currentIndex = charactersArray.count
            total = charactersArray.count
            populateCell()
        } else {
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
        let url = urlTotalCharacters + "?orderBy=name&limit=\(limit)" + "&offset=\(currentIndex + limit)" + "&apikey=\(publicKey)" + "&ts=\(ts)" + "&hash=\((ts+privateKey+publicKey).md5())"
        print("\(currentIndex)" + " | " + "\(url)")
        self.createLoading()
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
                            let it                      = (item as NSDictionary)
                            character.id                = String(it.objectForKey("id")!)
                            character.name              = String(it.objectForKey("name")!)
                            character.thumbnailURL      = String(it.objectForKey("thumbnail")!.objectForKey("path")!) + ".jpg"
                            if String(it.objectForKey("description")!) != nil {
                                character.heroDescription = String(it.objectForKey("description")!)
                            } else {
                                character.heroDescription = "no description"
                            }
                            character.comics            = ""
                            let comicsDIC               = it.objectForKey("comics")!.objectForKey("items") as? [[String: AnyObject]]
                            for item in comicsDIC! {
                                let it                  = (item as NSDictionary)
                                let resourceURI         = String(it.objectForKey("resourceURI")!)
                                let name                = String(it.objectForKey("name")!)
                                character.comics        = "\(character.comics!)\(resourceURI)\(lineBreak2)\(name)\(lineBreak1)"
                            }
                            character.series            = ""
                            let seriesDIC               = it.objectForKey("series")!.objectForKey("items") as? [[String: AnyObject]]
                            for item in seriesDIC! {
                                let it                  = (item as NSDictionary)
                                let resourceURI         = String(it.objectForKey("resourceURI")!)
                                let name                = String(it.objectForKey("name")!)
                                character.series        = "\(character.series!)\(resourceURI)\(lineBreak2)\(name)\(lineBreak1)"
                            }
                            character.stories           = ""
                            let storiesDIC              = it.objectForKey("stories")!.objectForKey("items") as? [[String: AnyObject]]
                            for item in storiesDIC! {
                                let it                  = (item as NSDictionary)
                                let resourceURI         = String(it.objectForKey("resourceURI")!)
                                let name                = String(it.objectForKey("name")!)
                                character.stories       = "\(character.stories!)\(resourceURI)\(lineBreak2)\(name)\(lineBreak1)"
                            }
                            character.events            = ""
                            let eventsDIC               = it.objectForKey("events")!.objectForKey("items") as? [[String: AnyObject]]
                            for item in eventsDIC! {
                                let it                  = (item as NSDictionary)
                                let resourceURI         = String(it.objectForKey("resourceURI")!)
                                let name                = String(it.objectForKey("name")!)
                                character.events        = "\(character.events!)\(resourceURI)\(lineBreak2)\(name)\(lineBreak1)"
                            }
                            character.urls              = ""
                            let urls                    = it.objectForKey("urls")! as? [[String: AnyObject]]
                            for item in urls! {
                                let it                  = (item as NSDictionary)
                                let type                = String(it.objectForKey("type")!)
                                let url                 = String(it.objectForKey("url")!)
                                character.urls          = "\(character.urls!)\(type)\(lineBreak2)\(url)\(lineBreak1)"
                            }
                            self.charactersArray.addObject(character)
                            self.charsForSearch.append(character)
                            self.currentIndex = self.currentIndex + 1
                            self.total = Int(JSONDictionary.objectForKey("data")!.objectForKey("total")! as! NSNumber)
                            DataStore.sharedInstance.createCharacter(
                                                    character.id!,
                                name:               character.name!,
                                thumbnailURL:       character.thumbnailURL!,
                                thumbnail:          nil,
                                heroDescription:    character.heroDescription!,
                                comics:             character.comics!,
                                series:             character.series!,
                                stories:            character.stories!,
                                events:             character.events!,
                                urls:               character.urls!
                            )
                        }
                    } else {
                        self.currentIndex = self.currentIndex + self.limit
                    }
                    self.populateCell()
                }
                self.removeLoading()
        }
    }
    
    func refreshResults2() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            let ts = String(Int(NSDate().timeIntervalSince1970) * 1000)
            let url = urlTotalCharacters + "?orderBy=name&limit=\(self.limit)" + "&offset=\(self.currentIndex + self.limit)" + "&apikey=\(publicKey)" + "&ts=\(ts)" + "&hash=\((ts+privateKey+publicKey).md5())"
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
                            return
                        }
                        if let resultJSON = JSONDictionary.objectForKey("data")?.objectForKey("results")! as? [[String: AnyObject]] {
                            for item in resultJSON {
                                let character = Character()
                                let it                      = (item as NSDictionary)
                                character.id                = String(it.objectForKey("id")!)
                                if DataStore.sharedInstance.hasCharacter(character.id!) == false {
                                    character.name              = String(it.objectForKey("name")!)
                                    character.thumbnailURL      = String(it.objectForKey("thumbnail")!.objectForKey("path")!) + ".jpg"
                                    if String(it.objectForKey("description")!) != nil {
                                        character.heroDescription = String(it.objectForKey("description")!)
                                    } else {
                                        character.heroDescription = "no description"
                                    }
                                    character.comics            = ""
                                    let comicsDIC               = it.objectForKey("comics")!.objectForKey("items") as? [[String: AnyObject]]
                                    for item in comicsDIC! {
                                        let it                  = (item as NSDictionary)
                                        let resourceURI         = String(it.objectForKey("resourceURI")!)
                                        let name                = String(it.objectForKey("name")!)
                                        character.comics        = "\(character.comics!)\(resourceURI)\(lineBreak2)\(name)\(lineBreak1)"
                                    }
                                    character.series            = ""
                                    let seriesDIC               = it.objectForKey("series")!.objectForKey("items") as? [[String: AnyObject]]
                                    for item in seriesDIC! {
                                        let it                  = (item as NSDictionary)
                                        let resourceURI         = String(it.objectForKey("resourceURI")!)
                                        let name                = String(it.objectForKey("name")!)
                                        character.series        = "\(character.series!)\(resourceURI)\(lineBreak2)\(name)\(lineBreak1)"
                                    }
                                    character.stories           = ""
                                    let storiesDIC              = it.objectForKey("stories")!.objectForKey("items") as? [[String: AnyObject]]
                                    for item in storiesDIC! {
                                        let it                  = (item as NSDictionary)
                                        let resourceURI         = String(it.objectForKey("resourceURI")!)
                                        let name                = String(it.objectForKey("name")!)
                                        character.stories       = "\(character.stories!)\(resourceURI)\(lineBreak2)\(name)\(lineBreak1)"
                                    }
                                    character.events            = ""
                                    let eventsDIC               = it.objectForKey("events")!.objectForKey("items") as? [[String: AnyObject]]
                                    for item in eventsDIC! {
                                        let it                  = (item as NSDictionary)
                                        let resourceURI         = String(it.objectForKey("resourceURI")!)
                                        let name                = String(it.objectForKey("name")!)
                                        character.events        = "\(character.events!)\(resourceURI)\(lineBreak2)\(name)\(lineBreak1)"
                                    }
                                    character.urls              = ""
                                    let urls                    = it.objectForKey("urls")! as? [[String: AnyObject]]
                                    for item in urls! {
                                        let it                  = (item as NSDictionary)
                                        let type                = String(it.objectForKey("type")!)
                                        let url                 = String(it.objectForKey("url")!)
                                        character.urls          = "\(character.urls!)\(type)\(lineBreak2)\(url)\(lineBreak1)"
                                    }
                                    self.charactersArray.addObject(character)
                                    self.charsForSearch.append(character)
                                    self.currentIndex = self.currentIndex + 1
                                    self.total = Int(JSONDictionary.objectForKey("data")!.objectForKey("total")! as! NSNumber)
                                    DataStore.sharedInstance.createCharacter(
                                        character.id!,
                                        name:               character.name!,
                                        thumbnailURL:       character.thumbnailURL!,
                                        thumbnail:          nil,
                                        heroDescription:    character.heroDescription!,
                                        comics:             character.comics!,
                                        series:             character.series!,
                                        stories:            character.stories!,
                                        events:             character.events!,
                                        urls:               character.urls!
                                    )
                                    self.insertCell(self.charactersArray.count - 1)
                                    self.tableView.beginUpdates()
                                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: (self.charactersArray.count - 1), inSection: 0)], withRowAnimation: .Automatic)
                                    self.tableView.endUpdates()
                                }
                            }
                        } else {
                            self.currentIndex = self.currentIndex + self.limit
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            // this runs on the main queue
                            self.spinner.hidden = true
                            self.loadingData = false
                        }
                    }
            }
        }
    }
    
    func populateCell() {
        for valor in 0...(self.charactersArray.count - 1) {
            insertCell(valor)
        }
        tableView.reloadData()
    }
    
    func insertCell(index: Int) {
        let cell = tableView.dequeueReusableCellWithIdentifier(characterCell) as! CharactersTableViewCell
        cell.selectionStyle = .None
        let char = charactersArray[index] as! Character
        cell.character = char
        if char.thumbnail == nil {
            if char.thumbnailURL! == "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg" {
                cell.imgCharacter.image = UIImage(named: "imgNotAvaliable")
                DataStore.sharedInstance.updateCharacter(
                    char.id!,
                    name:               char.name!,
                    thumbnailURL:       char.thumbnailURL!,
                    thumbnail:          NSData(data: UIImagePNGRepresentation(cell.imgCharacter.image!)!),
                    heroDescription:    char.heroDescription!,
                    comics:             char.comics!,
                    series:             char.series!,
                    stories:            char.stories!,
                    events:             char.events!,
                    urls:               char.urls!
                )
            } else {
                cell.imgCharacter.sd_setImageWithURL(NSURL(string: char.thumbnailURL!), placeholderImage: UIImage(named: "imgNotAvaliable"), completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) in
                    if error == nil {
                        DataStore.sharedInstance.updateCharacter(
                            char.id!,
                            name:               char.name!,
                            thumbnailURL:       char.thumbnailURL!,
                            thumbnail:          NSData(data: UIImagePNGRepresentation(image)!),
                            heroDescription:    char.heroDescription!,
                            comics:             char.comics!,
                            series:             char.series!,
                            stories:            char.stories!,
                            events:             char.events!,
                            urls:               char.urls!
                        )
                    } else {
                        cell.imgCharacter.image = UIImage(named: "imgNotAvaliable")
                        DataStore.sharedInstance.updateCharacter(
                            char.id!,
                            name:               char.name!,
                            thumbnailURL:       char.thumbnailURL!,
                            thumbnail:          NSData(data: UIImagePNGRepresentation(cell.imgCharacter.image!)!),
                            heroDescription:    char.heroDescription!,
                            comics:             char.comics!,
                            series:             char.series!,
                            stories:            char.stories!,
                            events:             char.events!,
                            urls:               char.urls!
                        )
                    }
                    }
                )
            }
        } else {
            cell.imgCharacter.image = UIImage(data: char.thumbnail!)
        }
        cell.imgCharacterHeightConstraint.constant = parallaxImageHeight
        cell.imgCharacterTopConstraint.constant = parallaxOffsetFor(tableView.contentOffset.y, cell: cell)
        
        cell.lblCharacterName.text = cell.character.name
        cell.imgCharacterBG.backgroundColor = UIColor.clearColor()
        let bgH = cell.imgCharacterBG.frame.size.height
        let point = CGFloat(20)
        let layer = CAShapeLayer()
        let cutDirection = UIBezierPath()
        cutDirection.moveToPoint(   CGPoint(x: point,                       y: 0))
        cutDirection.addLineToPoint(CGPoint(x: screenWidth - 16,            y: 0))
        cutDirection.addLineToPoint(CGPoint(x: screenWidth - 16 - point,    y: bgH))
        cutDirection.addLineToPoint(CGPoint(x: 0,                           y: bgH))
        layer.path = cutDirection.CGPath
        layer.fillColor = UIColor.whiteColor().CGColor
        cell.imgCharacterBG.layer.addSublayer(layer)
        
        charactersCellArray.addObject(cell)
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
        if searchController.active && searchController.searchBar.text != "" {
            return filteredCharactersNameArray.count
        }
        return charactersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchController.active && searchController.searchBar.text != "" {
            let filter = filteredCharactersNameArray[indexPath.row].id!
            var cell = CharactersTableViewCell()
            for item in charactersCellArray {
                if (item as! CharactersTableViewCell).character.id! == filter {
                    cell = item as! CharactersTableViewCell
                }
            }
            return cell
        } else {
            return charactersCellArray[indexPath.row] as! CharactersTableViewCell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !searchController.active {
            if (!loadingData && (indexPath.row == (charactersArray.count - 1))) {
                spinner.hidden = false
                loadingData = true
                refreshResults2()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell        = sender as! UITableViewCell
        let indexPath   = tableView.indexPathForCell(cell)!
        if segue.identifier == "toCharacterDetail" {
            let vc      = segue.destinationViewController as! CharacterDetailViewController
            if searchController.active && searchController.searchBar.text != "" {
                vc.char = filteredCharactersNameArray[indexPath.row]
            } else {
                vc.char = self.charactersArray[indexPath.row] as! Character
            }
        }
    }
    
    @IBAction func btnSearch(sender: UIBarButtonItem) {
        searchController.searchResultsUpdater                   = self
        searchController.dimsBackgroundDuringPresentation       = false
        searchController.hidesNavigationBarDuringPresentation   = false
        definesPresentationContext                              = true
        self.presentViewController(self.searchController, animated: true, completion: nil)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredCharactersNameArray = charsForSearch.filter{ char in
            return char.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }

}

extension CharactersController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class CharactersTableViewCell: UITableViewCell {
    @IBOutlet weak var imgCharacter: UIImageView!
    @IBOutlet weak var imgCharacterBG: UIView!
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