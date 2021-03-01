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
        }
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
            "femaleuser",
            "usermale",
            "femaleprofile",
            "maleuser",
            "bodyguardfemale",
            "bodyguardmale",
            "businessman",
            "businesswoman",
            "protection_mask",
            "face",
            "humanhead",
            "cartoonboy",
            "dj",
            "agent",
            "caveman",
            "developer",
            "einstein",
            "babys-room-2",
            "babysroom_full",
            "cryingbaby",
            "crying-baby-2",
            "engineer",
            "alcoholic",
            "farmer",
            "fatcop",
            "femaleworker",
            "firefighter",
            "fraud",
            "pirate",
            "politician",
            "bandit",
            "punk",
            "rap",
            "spy",
            "geisha",
            "graduate",
            "onlinesupport",
            "millennial",
            "monarch",
            "reggae",
            "herald",
            "welder",
            "walterwhite",
            "studentmale",
            "technicalsupport",
            "slenderman",
            "themis",
            "old-man-2",
            "oldman",
            "oldwoman",
            "gaymarriage",
            "samesexmarriage",
            "queue",
            "account_face",
            "handshake",
            "crowd",
            "streetview",
            "lifecycle",
            "employee",
            "grandfather",
            "littlegirl",
            "man",
            "manwithmoney",
            "napping",
            "pensioner",
            "baby",
            "elderlyperson",
            "familytwowomen",
            "familytwomen",
            "family",
            "gay",
            "lesbian",
            "relax",
            "son",
            "toddler",
            "stroller",
            "infant",
            "pram",
            "angryfacememe",
            "anonymousmask",
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
            "bartsimpson",
            "lisasimpson",
            "maggiesimpson",
            "margesimpson",
            "homersimpson",
            "ghost",
            "greekhelmet",
            "headprofile",
            "ironman",
            "jake",
            "legohead",
            "mummy",
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
            "witch",
            "zombie-2",
            "zombie",
            "account",
            "decline",
            "linechart",
            "candlestickchart",
            "piechart",
            "average",
            "banksafe",
            "safe",
            "debt",
            "discountfinder",
            "donate",
            "financialsuccess",
            "coins",
            "euro",
            "usdollar",
            "generalledger",
            "layers",
            "moneybox",
            "onlineshop",
            "paidparking",
            "papermoney",
            "tax",
            "topuppayment",
            "shoppingcart",
            "usedproduct",
            "bankcards",
            "wallet-2",
            "wallet",
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
            "zdrinks_soda",
            "zdrinks_coffeebeans",
            "zdrinks_cafe",
            "zdrinks_teapot",
            "zdrinks_emiratitraditionalcoffeepot",
            "zdrinks_bar",
            "zdrinks_cola",
            "zdrinks_energydrink",
            "zdrinks_milkbottle",
            "zdrinks_beer",
            "zdrinks_whiskey",
            "zdrinks_moonshinejug",
            "zdrinks_cocktail",
            "zdrinks_coconutcocktail",
            "alpaca",
            "angrydog",
            "bearfootprint",
            "bee",
            "bird",
            "black-cat-2",
            "blackcat",
            "catbackview",
            "cathead",
            "bug",
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
            "balletdancer",
            "concert",
            "swing",
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
            "tennisracquet",
            "trekking",
            "trophy",
            "watersport",
            "weightlifting",
            "trolley",
            "airplanetakeoff",
            "globe-earth-2",
            "globeearth",
            "aroundtheglobe",
            "america",
            "asia",
            "europe",
            "middle-east-2",
            "middleeast",
            "world-2",
            "world",
            "map",
            "compass",
            "windrose",
            "forest",
            "signpost",
            "path",
            "islandonwater",
            "mountain",
            "suitcase",
            "sun",
            "camper",
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
            "macclient",
            "androidos",
            "globe_network",
            "web",
            "internet_antenna",
            "auction",
            "barbershop",
            "catbed",
            "coral",
            "eyelash",
            "foryou",
            "heart",
            "heart3",
            "heart-2",
            "gift",
            "nosmoking",
            "smoking",
            "cigar",
            "joint",
            "journey",
            "lightningbolt",
            "lips",
            "lyre",
            "markerstorm",
            "markersun",
            "millenniumrod",
            "mindmap",
            "wet",
            "musical",
            "musicalnotes",
            "news",
            "phone",
            "phone_ringing",
            "speaker_phone",
            "officephone",
            "telephone",
            "rockmusic",
            "satellites",
            "signlanguageh",
            "signlanguagei",
            "pricetag",
            "twotickets",
            "schedule",
            "synchronize",
            "support",
            "work",
            "pliers",
            "nuclear",
            "unlike",
            "unavailable"
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
