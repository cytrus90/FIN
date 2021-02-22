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
    
    var iconList = [String]()
    var light = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconList = getImageArray(white: false)
        
        let nib = UINib(nibName: "iconCarouselCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "iconCarouselCell")
        setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        collectionView.delegate = self
        
        initView()
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
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = UIColor.black.cgColor
        }
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
            UIView.animate(withDuration: 0.1, animations: {
                cellToSelect?.transform = CGAffineTransform.identity
                cellToSelect?.iconImage.alpha = 0.4
                cellToSelect?.label.alpha = 0.4
            }, completion: { _ in
                if indexPath.row > 0 {
                    self.delegate?.iconSelected(selectedName: self.iconList[(indexPath.row-1)])
                } else {
                    self.delegate?.iconSelected(selectedName: "")
                }
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
            "baby",
            "babys_room",
            "babys_room_filled",
            "bandit",
            "businessman",
            "businesswoman",
            "caretaker",
            "cartoon_boy",
            "crowd",
            "crying_baby",
            "day_of_the_tentacle",
            "debt",
            "dj",
            "einstein",
            "elderly_person",
            "employee",
            "engineer",
            "family",
            "family_filled",
            "family_two_men",
            "family_two_women",
            "fat_cop",
            "female_profile",
            "female_user",
            "female_user_filled",
            "female_worker",
            "financial_success",
            "firefighter",
            "gay",
            "grandfather",
            "greek_helmet",
            "hand_cursor",
            "handshake",
            "head_profile",
            "human_head",
            "lesbian",
            "life_cycle",
            "lips",
            "monarch",
            "mummy",
            "napping",
            "old_man",
            "old_woman",
            "pacifier",
            "party",
            "pensioner",
            "punk",
            "pirate",
            "rap",
            "reggae",
            "relax",
            "sign_language_h",
            "sign_language_i",
            "street_view",
            "stroller",
            "student_male",
            "themis",
            "toddler",
            "user_male",
            "user_male_filled",
            "victoria_secret_angel",
            "walter_white",
            "witch",
            "zombie",
            "zombie_person",
            "broker",
            "city_church",
            "country_house",
            "department",
            "dog_house",
            "downtown",
            "farm_house",
            "foreclosure",
            "garage",
            "home",
            "home_2",
            "home_address",
            "house",
            "hut",
            "lighthouse",
            "log_cabin",
            "monastery",
            "museum",
            "polygonal_tent",
            "prefab_house",
            "real_estate",
            "rent",
            "residence",
            "shop",
            "alpaca",
            "angry_dog",
            "bear_footprint",
            "bee",
            "bird",
            "black_cat",
            "bug",
            "cat_back_view",
            "cat_bed",
            "cat_filled",
            "cat_head",
            "cat_head_filled",
            "cheburashka",
            "chicken",
            "chimpanzee",
            "chinchilla",
            "clown_fish",
            "crow",
            "cute_hamster",
            "deer",
            "deer_filled",
            "dog",
            "dog_jump",
            "dog_paw",
            "dolphin",
            "eel",
            "elephant",
            "european_dragon",
            "fish",
            "ghost",
            "horse",
            "horse_filled",
            "kangaroo",
            "kiwi_bird",
            "koala",
            "octopus",
            "orca",
            "peace_pigeon",
            "penguin",
            "pig",
            "prawn",
            "rabbit",
            "seahorse",
            "shark",
            "snail",
            "sparrowhawk",
            "spyro",
            "starfish",
            "tail_of_whale",
            "unicorn",
            "whale",
            "anonymousmask",
            "batmanlogo",
            "futuramabender",
            "futuramafry",
            "futuramahermesconrad",
            "futuramaleela",
            "futuramamom",
            "futuramanibbler",
            "futuramaprofessorfarnsworth",
            "futuramazappbrannigan",
            "futuramazoidberg",
            "homersimpson",
            "ironman",
            "jake",
            "scream",
            "sonicthehedgehog",
            "stormtrooper",
            "superman",
            "supermario",
            "theflashsign",
            "thejigsawkiller",
            "account",
            "accounting",
            "bankcards",
            "banksafe",
            "candlestickchart",
            "coins",
            "decline",
            "discountfinder",
            "donate",
            "generalledger",
            "linechart",
            "moneybox",
            "papermoney",
            "piechart96",
            "safe",
            "sigma",
            "tax",
            "topuppayment",
            "wallet",
            "wallet_filled",
            "euro",
            "us_dollar",
            "airplanetakeoff",
            "apachehelicopter",
            "automaticcarwash",
            "camper",
            "car",
            "cargoship",
            "carservice",
            "f1car",
            "fighterjet",
            "helicopter",
            "historicship",
            "londoncab",
            "paidparking",
            "peopleincar",
            "peopleincarsideview",
            "pliers",
            "sailboat",
            "shoppingcart",
            "shuttle",
            "tank",
            "tourbus",
            "tram",
            "trolley",
            "watertransportation",
            "work",
            "yacht",
            "bitcoin",
            "blockchain",
            "eth",
            "iota",
            "litecoin",
            "moneybagbitcoin",
            "ripple",
            "auction",
            "average",
            "barbershop",
            "beer",
            "binoculars",
            "calendar",
            "telephone",
            "cardano",
            "cigar",
            "clock",
            "connect",
            "coral",
            "eyelash",
            "food",
            "foryou",
            "gift",
            "heart",
            "heart_circle",
            "heart_filled",
            "idea",
            "joint",
            "journey",
            "key",
            "layers",
            "lightningbolt",
            "lock",
            "lyre",
            "macclient",
            "android_os",
            "mailbox",
            "markerstorm",
            "millenniumrod",
            "mindmap",
            "music",
            "news",
            "nosmoking",
            "officephone",
            "onlineshop",
            "packaging",
            "pricetag",
            "puzzle",
            "rockmusic",
            "satellite",
            "satellites",
            "schedule",
            "smoking",
            "speechbubble",
            "synchronize",
            "tickbox",
            "trash",
            "trophy",
            "unavailable",
            "unlike",
            "usedproduct",
            "wet",
            "whiskey",
            "nuclear"
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
