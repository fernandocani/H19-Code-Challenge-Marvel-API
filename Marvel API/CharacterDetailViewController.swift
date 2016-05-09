//
//  CharacterDetailViewController.swift
//  Marvel API
//
//  Created by Fernando Cani on 5/5/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import Alamofire
import ASHorizontalScrollView
import SDWebImage
import YHImageViewer
import SwiftFSImageViewer
import SafariServices

private let headerHeight    = CGFloat(260)
private let headerCut       = CGFloat(0)

class CharacterDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var imageViewer:YHImageViewer?
    
    var cellIdentifier = "charactersDetailCell"

    var headerView: UIView!
    var newHeaderLayer: CAShapeLayer!
    
    var char: Character!
    var charArray = NSMutableArray()
    
    var coverComicsArray  = NSMutableArray()
    var coverSeriesArray  = NSMutableArray()
    var coverStoriesArray = NSMutableArray()
    var coverEventsArray  = NSMutableArray()
    let coverArray        = NSMutableArray()
    
    var comicsCount  = Int()
    var seriesCount  = Int()
    var storiesCount = Int()
    var eventsCount  = Int()
    var urlsCount    = Int()
    
    var detailObject    = ""
    var wikiObject      = ""
    var comicLinkObject = ""
    
    let sectionTitle = [
        "NAME",
        "DESCRIPTION",
        "COMICS",
        "SERIES",
        "STORIES",
        "EVENTS",
        "RELATED LINKS",
        "",
        "",
        ""
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.blackColor()
        if char != nil {
            self.title = char.name!
            if char.thumbnail == nil {
                if char.thumbnailURL != nil {
                    imgHeader.sd_setImageWithURL(NSURL(string: char.thumbnailURL!), placeholderImage: UIImage(named: "imgNotAvaliable"), completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) in
                        if error == nil {
                            DataStore.sharedInstance.updateCharacter(
                                self.char.id!,
                                name:               self.char.name!,
                                thumbnailURL:       self.char.thumbnailURL!,
                                thumbnail:          NSData(data: UIImagePNGRepresentation(image)!),
                                heroDescription:    self.char.heroDescription!,
                                comics:             self.char.comics!,
                                series:             self.char.series!,
                                stories:            self.char.stories!,
                                events:             self.char.events!,
                                urls:               self.char.urls!
                            )
                        } else {
                            self.imgHeader.image = UIImage(named: "imgNotAvaliable")
                            DataStore.sharedInstance.updateCharacter(
                                self.char.id!,
                                name:               self.char.name!,
                                thumbnailURL:       self.char.thumbnailURL!,
                                thumbnail:          NSData(data: UIImagePNGRepresentation(self.imgHeader.image!)!),
                                heroDescription:    self.char.heroDescription!,
                                comics:             self.char.comics!,
                                series:             self.char.series!,
                                stories:            self.char.stories!,
                                events:             self.char.events!,
                                urls:               self.char.urls!
                            )
                        }
                        }
                    )
                } else {
                    imgHeader.image = UIImage(named: "imgNotAvaliable")
                }
            } else {
                imgHeader.image = UIImage(data:  char.thumbnail!)
            }
            charArray.addObject(char.name!)
            charArray.addObject(char.heroDescription!)
            let comicsArray     = breakString(char.comics!)
            comicsCount = comicsArray[0].count
            charArray.addObject(comicsArray)
            let seriesArray     = breakString(char.series!)
            seriesCount = seriesArray[0].count
            charArray.addObject(seriesArray)
            let storiesArray    = breakString(char.stories!)
            storiesCount = storiesArray[0].count
            charArray.addObject(storiesArray)
            let eventsArray     = breakString(char.events!)
            eventsCount = eventsArray[0].count
            charArray.addObject(eventsArray)
            let urlsArray       = breakString(char.urls!)
            if urlsArray[0].count > 0 {
                for valor in 0...((urlsArray.objectAtIndex(0) as! NSArray).count - 1) {
                    let item = urlsArray.objectAtIndex(0) as! NSArray
                           if item[valor] as! String == "detail" {
                        detailObject    = (urlsArray.objectAtIndex(1) as! NSArray).objectAtIndex(valor) as! String
                    } else if item[valor] as! String == "wiki" {
                        wikiObject      = (urlsArray.objectAtIndex(1) as! NSArray).objectAtIndex(valor) as! String
                    } else if item[valor] as! String == "comiclink" {
                        comicLinkObject = (urlsArray.objectAtIndex(1) as! NSArray).objectAtIndex(valor) as! String
                    }
                }
            }
            urlsCount = urlsArray[0].count
            charArray.addObject(urlsArray)
            populateCell()
            updateView()
            openConnection()
        }
    }
    func breakString(string: String) -> NSArray {
        let arrayA = NSMutableArray()
        let arrayB = NSMutableArray()
        let breakA = string.componentsSeparatedByString(lineBreak1)
        for item in breakA {
            if item != "" {
                let breakB = item.componentsSeparatedByString(lineBreak2)
                arrayA.addObject(breakB[0])
                if breakB.count > 1 {
                    arrayB.addObject(breakB[1])
                } else {
                    arrayB.addObject("No information.")
                }
            }
        }
        return [arrayA, arrayB]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        setNewView()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitle.count
    }
    
    let detailCell = NSMutableArray()
    
    func populateCell() {
        if detailCell.count > 0 {
            for valor in 0...(detailCell.count - 1) {
                let cell = detailCell[valor] as! CharacterDetailTableViewCell
                cell.lblSectionTitle!.text = sectionTitle[valor]
                if (valor == 0 || valor == 1) {
                    cell.lblText!.text = (charArray[valor] as! String)
                }
                if (valor == 2 || valor == 3 || valor == 4 || valor == 5) {
                    cell.lblText!.hidden = true
                    self.createHorizontalScroll(cell, index: valor)
                }
                if (valor == 6) {
                    cell.lblText.text = ""
                }
                if (valor == 7) {
                    cell.cstLblSectionTitleHeight.constant = 0
                    cell.lblText.text = "Detail"
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                }
                if (valor == 8) {
                    cell.cstLblSectionTitleHeight.constant = 0
                    cell.lblText.text = "Wiki"
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                }
                if (valor == 9) {
                    cell.cstLblSectionTitleHeight.constant = 0
                    cell.lblText.text = "Comic"
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                }
                detailCell.removeObjectAtIndex(valor)
                detailCell.insertObject(cell, atIndex: valor)
            }
        } else {
            for valor in 0...(sectionTitle.count - 1) {
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: NSIndexPath(forRow: valor, inSection: 0)) as! CharacterDetailTableViewCell
                cell.lblSectionTitle!.text = sectionTitle[valor]
                if (valor == 0) {
                    cell.lblText!.text = (charArray[valor] as! String)
                }
                if (valor == 1) {
                    cell.lblText!.text = (charArray[valor] as! String)
                }
                if (valor == 2 || valor == 3 || valor == 4 || valor == 5) {
                    cell.lblText!.hidden = true
                    self.createHorizontalScroll(cell, index: valor)
                }
                if (valor == 6) {
                	cell.lblText.text = ""
                }
                if (valor == 7) {
                    cell.cstLblSectionTitleHeight.constant = 0
                    cell.lblText.text = "Detail"
                    //detailObject
                }
                if (valor == 8) {
                    cell.cstLblSectionTitleHeight.constant = 0
                    cell.lblText.text = "Wiki"
                    //wikiObject
                }
                if (valor == 9) {
                    cell.cstLblSectionTitleHeight.constant = 0
                    cell.lblText.text = "Comic"
                    //comicLinkObject
                }
                detailCell.addObject(cell)
            }
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return detailCell[indexPath.row] as! CharacterDetailTableViewCell
    }
    
    func createHorizontalScroll(cell: CharacterDetailTableViewCell, index: Int) {
        for case let horizontalScrollView as ASHorizontalScrollView in cell.contentView.subviews {
            horizontalScrollView.removeFromSuperview()
        }
        let comicsItens = charArray[index] as! NSArray
        let comicsTitle = comicsItens[1] as! NSArray
        if comicsTitle.count > 0 {
            let recuo = CGFloat(-30)
            let horizontalScrollView:ASHorizontalScrollView = ASHorizontalScrollView(
                frame:CGRectMake(
                    cell.frame.origin.x,
                    recuo,
                    tableView.frame.size.width,
                    330
                )
            )
            horizontalScrollView.leftMarginPx = 6.0
            horizontalScrollView.miniMarginPxBetweenItems = 0.0
            horizontalScrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            horizontalScrollView.uniformItemSize = CGSizeMake(118.5, 180)
            //560/850
            horizontalScrollView.setItemsMarginOnce()
            horizontalScrollView.tag = index * 10
            for valor2 in 0...(comicsTitle.count - 1) {
                let button = UIButton(frame: CGRectMake(10, 0, 118.5, 180))
                let loading = UIActivityIndicatorView(frame: CGRectMake(0, 0, button.frame.size.width, button.frame.size.height))
                loading.activityIndicatorViewStyle = .Gray
                loading.startAnimating()
                loading.tag = Int("\(horizontalScrollView.tag)" + "\(valor2)42")!
                if coverArray.count > 0 {
                    if coverArray[index-2].count > 0 {
                        button.addSubview(loading)
                        let itemArray = self.coverArray[index-2] as! NSArray
                        button.sd_setBackgroundImageWithURL(
                            NSURL(string: itemArray[valor2] as! String),
                            forState: .Normal,
                            placeholderImage: UIImage(named: "comic_cover_placehoder"),
                            completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) in
                                if let viewWithTag = button.viewWithTag(Int("\(horizontalScrollView.tag)" + "\(valor2)42")!) {
                                    viewWithTag.removeFromSuperview()
                                }
                        })
                    }  else {
                        button.setBackgroundImage(
                            UIImage(
                                named: "comic_cover_placehoder"),
                            forState: .Normal
                        )
                    }
                } else {
                    button.addSubview(loading)
                    button.setBackgroundImage(
                        UIImage(
                            named: "comic_cover_placehoder"),
                        forState: .Normal
                    )
                }
                button.addTarget(
                    self,
                    action: #selector(CharacterDetailViewController.buttonPressed(_:)),
                    forControlEvents: .TouchUpInside
                )
                let titleLabel = UILabel()
                titleLabel.frame = CGRectMake(
                    0,
                    button.frame.size.height + button.frame.origin.y + 10,
                    button.frame.size.width,
                    30
                )
                titleLabel.font = UIFont.boldSystemFontOfSize(12.0)
                titleLabel.text = (comicsTitle[valor2] as! String)
                titleLabel.textAlignment = .Center
                titleLabel.textColor = UIColor.whiteColor()
                titleLabel.numberOfLines = 2
                titleLabel.lineBreakMode = .ByTruncatingTail
                button.addSubview(titleLabel)
                
                button.tag = Int("\(horizontalScrollView.tag)" + "\(valor2)")!
                
                horizontalScrollView.addItem(button)
                cell.contentView.addSubview(horizontalScrollView)
            }
        } else {
            let titleLabel = UILabel()
            titleLabel.frame = CGRectMake(
                0,
                0,
                cell.frame.size.width,
                cell.frame.size.width
            )
            titleLabel.font = UIFont.boldSystemFontOfSize(14.0)
            titleLabel.text = "No information."
            titleLabel.textAlignment = .Center
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.numberOfLines = 2
            titleLabel.lineBreakMode = .ByTruncatingTail
            cell.addSubview(titleLabel)
        }
    }
    
    func buttonPressed(sender: UIButton!) {
//        let tag = String(sender.tag)
//        let prefix = String(tag.characters.prefix(2))
//        let sufix  = String(tag.characters.suffixFrom(tag.startIndex.advancedBy(2)))
//        print("\(prefix)|\(sufix)")
        
        FSImageViewer.sharedFSImageViewer.showImageView(UIImageView(image: sender.backgroundImageForState(.Normal)), atPoint: self.view.center)
            
//        self.performSegueWithIdentifier("", sender: self)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let valor = indexPath.row
        switch valor {
        case 0:
            return 80.0
        case 1:
            if (charArray[valor] as! String) != "" {
                return (rectForText((charArray[valor] as! String), font: UIFont.systemFontOfSize(17.0), maxSize: CGSizeMake(tableView.frame.size.width, 999))).height + 80.0
            } else {
                return 0.0
            }
        case 2:
            let items = charArray[valor] as! NSArray
            if items[0].count > 0 {
                return 280.0
            } else {
                return 0.0
            }
        case 3:
            let items = charArray[valor] as! NSArray
            if items[0].count > 0 {
                return 280.0
            } else {
                return 0.0
            }
        case 4:
            let items = charArray[valor] as! NSArray
            if items[0].count > 0 {
                return 280.0
            } else {
                return 0.0
            }
        case 5:
            let items = charArray[valor] as! NSArray
            if items[0].count > 0 {
                return 280.0
            } else {
                return 0.0
            }
        case 6:
            let items = charArray[valor] as! NSArray
            if items[0].count > 0 {
                return 60.0
            } else {
                return 0.0
            }
        case 7:
            if detailObject != "" {
                return 50.0
            } else {
                return 0.0
            }
        case 8:
            if wikiObject != "" {
                return 50.0
            } else {
                return 0.0
            }
        case 9:
            if comicLinkObject != "" {
                return 50.0
            } else {
                return 0.0
            }
        default:
            return 280.0
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 7 {
            let svc = SFSafariViewController(URL: NSURL(string: detailObject)!)
            self.presentViewController(svc, animated: true, completion: nil)
        } else if indexPath.row == 8 {
            let svc = SFSafariViewController(URL: NSURL(string: wikiObject)!)
            self.presentViewController(svc, animated: true, completion: nil)
        } else if indexPath.row == 9 {
            let svc = SFSafariViewController(URL: NSURL(string: comicLinkObject)!)
            self.presentViewController(svc, animated: true, completion: nil)
        }
    }
    
    func updateView() {
        tableView.backgroundColor = UIColor(hex: "#172B37")//UIColor.clearColor()
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        newHeaderLayer = CAShapeLayer()
        newHeaderLayer.fillColor = UIColor.blackColor().CGColor
        headerView.layer.mask = newHeaderLayer
        let newHeight = headerHeight - headerCut / 2
        tableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        setNewView()
    }
    
    func setNewView() {
        let newHeight = headerHeight - headerCut / 2
        var getHeaderFrame = CGRect(x: 0, y: -newHeight, width: tableView.bounds.width, height: headerHeight)
        if tableView.contentOffset.y < newHeight {
            getHeaderFrame.origin.y = tableView.contentOffset.y
            getHeaderFrame.size.height = -tableView.contentOffset.y + headerCut / 2
        }
        headerView.frame = getHeaderFrame
        let cutDirection = UIBezierPath()
        cutDirection.moveToPoint(CGPoint(x: 0, y: 0))
        cutDirection.addLineToPoint(CGPoint(x: getHeaderFrame.width, y: 0))
        cutDirection.addLineToPoint(CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        cutDirection.addLineToPoint(CGPoint(x: 0, y: getHeaderFrame.height - headerCut))
        newHeaderLayer.path = cutDirection.CGPath
    }
    
    var major = 2
    var minor = 0
    
    func openConnection() {
        let ma = charArray[major] as! NSArray
        let me = ma[0] as! NSArray
        if me.count > 0 {
            let mi = me[minor] as! String
            print(mi)
            let ts = String(Int(NSDate().timeIntervalSince1970) * 1000)
            let url = mi + "?&apikey=\(publicKey)&ts=\(ts)&hash=\((ts+privateKey+publicKey).md5())"
            Alamofire.request(
                .GET,
                url,
                parameters: nil
                )
                .response { request, response, data, error in
//                    print(url)
                    if error == nil {
                        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0))
                        guard let JSONDictionary :NSDictionary = json as? NSDictionary else {
                            print("Not a Dictionary")
                            return
                        }
                        if let resultJSON = JSONDictionary.objectForKey("data")?.objectForKey("results")! as? [[String: AnyObject]] {
                            for item in resultJSON {
                                var coverURL = ""
                                if String((item as NSDictionary).objectForKey("thumbnail")!) != "<null>" {
                                    coverURL = String((item as NSDictionary).objectForKey("thumbnail")!.objectForKey("path")!) + ".jpg"
                                }
                                switch self.major {
                                case 2:
                                    self.minor = self.coverComicsArray.count
                                    self.coverComicsArray.addObject(coverURL)
                                    if self.minor < self.comicsCount - 1 {
                                        self.minor += 1
                                    } else {
                                        self.minor = 0
                                        self.major += 1
                                    }
                                case 3:
                                    self.minor = self.coverSeriesArray.count
                                    self.coverSeriesArray.addObject(coverURL)
                                    if self.minor < self.seriesCount - 1 {
                                        self.minor += 1
                                    } else {
                                        self.minor = 0
                                        self.major += 1
                                    }
                                case 4:
                                    self.minor = self.coverStoriesArray.count
                                    self.coverStoriesArray.addObject(coverURL)
                                    if self.minor < self.storiesCount - 1 {
                                        self.minor += 1
                                    } else {
                                        self.minor = 0
                                        self.major += 1
                                    }
                                case 5:
                                    self.minor = self.coverEventsArray.count
                                    self.coverEventsArray.addObject(coverURL)
                                    if self.minor < self.eventsCount - 1 {
                                        self.minor += 1
                                    }
                                default:
                                    print("deu ruim")
                                }
                            }
                            if self.major == 5 && self.minor == self.eventsCount {
                                print("openConnection() terminou")
                                self.coverArray.addObject(self.coverComicsArray)
                                self.coverArray.addObject(self.coverSeriesArray)
                                self.coverArray.addObject(self.coverStoriesArray)
                                self.coverArray.addObject(self.coverEventsArray)
                                self.populateCell()
                            } else {
                                self.openConnection()
                                print("openConnection(\(self.major)|\(self.minor))")
                            }
                        }
                    } else {
                        print(error!)
                    }
            }
        }
    }
    
    func rectForText(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:font])
        let rect = attrString.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let size = CGSizeMake(rect.size.width, rect.size.height)
        return size
    }
    
}

class CharacterDetailTableViewCell: UITableViewCell {
    @IBOutlet var lblSectionTitle:  UILabel!
    @IBOutlet var lblText:          UILabel!
    
    @IBOutlet weak var cstLblSectionTitleHeight: NSLayoutConstraint!
    
}