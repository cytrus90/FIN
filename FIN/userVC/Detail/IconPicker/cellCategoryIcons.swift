//
//  cellCategoryIcons.swift
//  FIN
//
//  Created by Florian Riel on 19.02.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellCategoryIcons: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var outlineView: UIView!
    
    weak var delegate: cellCategoryIconsDelegate?
    
    var selectedIconInt = 0
    var selectedIcon:String?
    
    var iconList = [String]()
    var light = false
    
    var selectedLabelText = NSLocalizedString("previewIcon", comment: "Preview")
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        let nib = UINib(nibName: "iconCarouselCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "iconCarouselCell")
        setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        collectionView.delegate = self
        
        // initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }

    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = UIColor.white.cgColor
            light = false
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = UIColor.black.cgColor
            light = true
        }
        changeLightDark(white:light)
    }

    func changeLightDark(white:Bool) {
        light = white
        iconList.removeAll()
        iconList = getImageArray(white: white)
        
        selectedIcon = selectedIcon?.replacingOccurrences(of: "_white", with: "")
        if light && (selectedIcon?.count ?? 0) > 0 {
            selectedIcon = (selectedIcon ?? "") + "_white"
        }
        
        if (selectedIcon?.count ?? 0) > 0 {
            if let index = find(value: selectedIcon ?? "this-is_no_icon", in: iconList) {
                selectedIconInt = index+1
            }
            print(iconList[selectedIconInt])
        }
        print(selectedIconInt)
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func setSelectedIcon(selectedIconToSet:String) {
        selectedIcon = selectedIconToSet
    }
    
    func find(value searchValue: String, in array: [String]) -> Int? {
        for (index, value) in array.enumerated() {
            if value == searchValue {
                return index
            }
        }
        return nil
    }
    
    // MARK: -Collection View
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        // carousel.delegate = dataSourceDelegate
        collectionView.delegate = self
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconList.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCarouselCell", for: indexPath) as! iconCarouselCell
        if indexPath.row == 0 {
            cell.iconImage.isHidden = true
            cell.label.isHidden = false
            if selectedLabelText.count == 1 {
                cell.label.text = selectedLabelText.prefix(1).uppercased()
            } else {
                cell.label.text = selectedLabelText.prefix(2).uppercased()
            }
        } else {
            cell.iconImage.isHidden = false
            cell.label.isHidden = true
            
            cell.iconImage.image = UIImage(named: iconList[(indexPath.row-1)])
        }
        
        if indexPath.row == selectedIconInt {
            cell.iconImage.alpha = 0.4
            cell.label.alpha = 0.4
        } else {
            cell.iconImage.alpha = 1.0
            cell.label.alpha = 1.0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellToSelect = collectionView.cellForItem(at: indexPath) as? iconCarouselCell
        let cellToDeselect = collectionView.cellForItem(at: IndexPath(row: self.selectedIconInt, section: 0)) as? iconCarouselCell
        UIView.animate(withDuration: 0.1, animations: {
            cellToSelect?.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            cellToDeselect?.iconImage.alpha = 1.0
            cellToDeselect?.label.alpha = 1.0
        }, completion: { _ in
            if indexPath.row > 0 {
                self.delegate?.iconSelected(selectedName: self.iconList[(indexPath.row-1)])
            } else {
                self.delegate?.iconSelected(selectedName: "")
            }
            UIView.animate(withDuration: 0.1, animations: {
                cellToSelect?.transform = CGAffineTransform.identity
                cellToSelect?.iconImage.alpha = 0.4
                cellToSelect?.label.alpha = 0.4
            })
        })
        selectedIconInt = indexPath.row
    }
    
}

protocol cellCategoryIconsDelegate: AnyObject {
    func iconSelected(selectedName:String)
}

extension cellCategoryIcons {
    func getImageArray(white:Bool) -> [String] {
        let icons = [
            "account",
            "agent",
            "alcoholic",
            "baby",
            "babys-room-2",
            "babysroom_full",
            "balletdancer",
            "bandit",
            "bodyguardfemale",
            "bodyguardmale",
            "businessman-2",
            "businessman",
            "businesswoman",
            "cartoonboy",
            "caveman",
            "crowd",
            "crying-baby-2",
            "cryingbaby",
            "developer",
            "dj",
            "einstein",
            "elderlyperson",
            "employee",
            "engineer",
            "face",
            "family",
            "familytwomen",
            "familytwowomen",
            "farmer",
            "fatcop",
            "femaleprofile",
            "femaleuser",
            "femaleworker",
            "firefighter",
            "fraud",
            "gay",
            "gaymarriage",
            "geisha",
            "graduate",
            "grandfather",
            "handshake",
            "herald",
            "humanhead",
            "infant",
            "legohead",
            "lesbian",
            "lifecycle",
            "littlegirl",
            "maleuser",
            "man",
            "manwithmoney",
            "millennial",
            "monarch",
            "napping",
            "old-man-2",
            "oldman",
            "oldwoman",
            "onlinesupport",
            "pensioner",
            "pirate",
            "politician",
            "pram",
            "punk",
            "queue",
            "rap",
            "relax",
            "samesexmarriage",
            "slenderman",
            "son",
            "spy",
            "streetview",
            "stroller",
            "studentmale",
            "technicalsupport",
            "themis",
            "toddler",
            "usermale",
            "walterwhite",
            "welder",
            "angryfacememe",
            "anonymousmask",
            "bartsimpson",
            "batmanlogo",
            "dayofthetentacle",
            "futuramaamywong",
            "futuramabender",
            "futuramafry",
            "futuramahermesconrad",
            "futuramaleela",
            "futuramamom",
            "futuramanibbler",
            "futuramaprofessorfarnsworth",
            "futuramazappbrannigan",
            "futuramazoidberg",
            "ghost",
            "greekhelmet",
            "headprofile",
            "homersimpson",
            "ironman",
            "jake",
            "legohead",
            "lisasimpson",
            "maggiesimpson",
            "margesimpson",
            "mummy",
            "punk",
            "reggae",
            "scream",
            "sonicthehedgehog",
            "spyro",
            "stormtrooper",
            "superman",
            "supermario",
            "teddybear",
            "theatremask",
            "theflashsign",
            "thejigsawkiller",
            "victoriasecretangel",
            "welder",
            "witch",
            "zombie-2",
            "zombie",
            "broker",
            "caretaker",
            "citychurch",
            "countryhouse",
            "department",
            "doghouse",
            "downtown",
            "farmhouse",
            "foreclosure",
            "garage",
            "home",
            "homeaddress",
            "house",
            "hut",
            "lighthouse",
            "logcabin",
            "monastery",
            "museum",
            "polygonaltent",
            "prefabhouse",
            "realestate",
            "rent",
            "residence",
            "shop",
            "barbecue",
            "bread",
            "brezel",
            "cake",
            "carrot", 
            "cheese",
            "chilipepper",
            "cookingbook",
            "cupcake",
            "doughnut",
            "food",
            "frenchfries",
            "hamburger",
            "internationalfood",
            "iraniankebab",
            "mushroom",
            "naturalfood",
            "nut",
            "popcorn",
            "pumpkin",
            "raspberry",
            "salmonsushi",
            "sausage",
            "seafood",
            "soupplate",
            "strawberry",
            "vegetarianmark",
            "wrap",
            "zdrinks_bar",
            "zdrinks_beer",
            "zdrinks_cafe",
            "zdrinks_cocktail",
            "zdrinks_coconutcocktail",
            "zdrinks_coffeebeans",
            "zdrinks_cola",
            "zdrinks_emiratitraditionalcoffeepot",
            "zdrinks_energydrink",
            "zdrinks_milkbottle",
            "zdrinks_moonshinejug",
            "zdrinks_soda",
            "zdrinks_teapot",
            "zdrinks_whiskey",
            "alpaca",
            "angrydog",
            "bearfootprint",
            "bee",
            "bird",
            "black-cat-2",
            "blackcat",
            "bug",
            "cat-head-2",
            "catbackview",
            "cathead",
            "cheburashka",
            "chicken",
            "chimpanzee",
            "chinchilla",
            "clownfish",
            "crab",
            "crow",
            "cutehamster",
            "deer-2",
            "deer",
            "dog",
            "dogjump",
            "dogpaw",
            "dolphin",
            "eel",
            "elephant",
            "europeandragon",
            "fish",
            "horse-2",
            "horse",
            "kangaroo",
            "kiwibird",
            "koala",
            "octopus",
            "orca",
            "peacepigeon",
            "penguin",
            "pig-2",
            "pig",
            "prawn",
            "rabbit",
            "seahorse",
            "shark",
            "snail",
            "sparrowhawk",
            "starfish",
            "tailofwhale",
            "teddybear",
            "unicorn",
            "whale",
            "binoculars",
            "bowlingpin",
            "carabiner",
            "climbing",
            "concert",
            "cycling",
            "dinghy",
            "expeditionbackpack",
            "handball",
            "hockey",
            "motocrosshelmet",
            "paragliding",
            "party",
            "sailboat",
            "scubadiving",
            "soccer",
            "softballmitt",
            "sport",
            "strength",
            "swimming",
            "swing",
            "tennisracquet",
            "trekking",
            "trophy",
            "watersport",
            "weightlifting",
            "account",
            "average",
            "bankcards",
            "banksafe",
            "candlestickchart",
            "coins",
            "debt",
            "decline",
            "discountfinder",
            "donate",
            "euro",
            "financialsuccess",
            "generalledger",
            "layers",
            "linechart",
            "manwithmoney",
            "moneybox",
            "onlineshop",
            "paidparking",
            "papermoney",
            "piechart",
            "safe",
            "shoppingcart",
            "tax",
            "topuppayment",
            "trolley",
            "usdollar",
            "usedproduct",
            "wallet-2",
            "wallet",
            "airplanetakeoff",
            "america",
            "aroundtheglobe",
            "asia",
            "camper",
            "compass",
            "europe",
            "forest",
            "globe-earth-2",
            "globeearth",
            "islandonwater",
            "map",
            "middle-east-2",
            "middleeast",
            "mountain",
            "path",
            "signpost",
            "suitcase",
            "sun",
            "windrose",
            "world-2",
            "world",
            "apachehelicopter",
            "car",
            "cargoship",
            "carservice",
            "f1car",
            "fighterjet",
            "helicopter",
            "historicship",
            "londoncab",
            "peopleincar",
            "peopleincarsideview",
            "satellite",
            "shuttle",
            "tank",
            "tourbus",
            "tram",
            "watertransportation",
            "yacht",
            "bitcoin",
            "blockchain",
            "cardano",
            "iota",
            "litecoin",
            "moneybagbitcoin",
            "ripple",
            "androidos",
            "auction",
            "barbershop",
            "catbed",
            "cigar",
            "coral",
            "eyelash",
            "foryou",
            "gift",
            "heart",
            "heart3",
            "heart-2",
            "joint",
            "journey",
            "lightningbolt",
            "lips",
            "lyre",
            "macclient",
            "markerstorm",
            "markersun",
            "millenniumrod",
            "mindmap",
            "musical",
            "musicalnotes",
            "news",
            "nosmoking",
            "nuclear",
            "officephone",
            "packaging",
            "pliers",
            "pricetag",
            "rockmusic",
            "satellites",
            "schedule",
            "signlanguageh",
            "signlanguagei",
            "smoking",
            "support",
            "synchronize",
            "telephone",
            "twotickets",
            "unavailable",
            "unlike",
            "wet",
            "work"
        ]
        
        if white {
            var iconWhite = [String]()
            icons.forEach({icon in
                iconWhite.append(icon + "_white")
            })
            return iconWhite
        }
        
        return icons
    }
}
