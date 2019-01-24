//
//  TableViewController.swift
//  gooey-cell
//
//  Created by Прегер Глеб on 22/01/2019.
//  Copyright © 2019 Cuberto. All rights reserved.
//
import UIKit
import gooey_cell

class TableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    private var objects: [Object] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        addCells()
    }
    
    @IBAction private func btnSearchTapped(_ sender: UIButton) {
        addCells()
    }
    
    private func addCells() {
        objects += Object.allCases
        tableView.reloadData()
    }
}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let cell = cell as? TableViewCell {
            
            let object = objects[indexPath.row]
            
            cell.imgIcon.image = object.icon
            cell.lblName.text = object.name
            cell.lblTitle.text = object.title
            cell.lblDescription.text = object.description
            cell.lblTime.text = object.time
            
            cell.gooeyEffectTableViewCellDelegate = self
        }
        
        return cell
    }
}

extension TableViewController: GooeyEffectTableViewCellDelegate {
    func gooeyEffectAction(for tableViewCell: UITableViewCell, direction: GooeyEffect.Direction) {
        guard let indexPath = tableView.indexPath(for: tableViewCell) else { return }
        objects.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    func gooeyEffectConfig(for tableViewCell: UITableViewCell, direction: GooeyEffect.Direction) -> GooeyEffect.Config? {
        return GooeyEffect.Config(color: #colorLiteral(red: 0.3019607843, green: 0.4980392157, blue: 0.3921568627, alpha: 1), image: #imageLiteral(resourceName: "imgCross"))
    }
}

private extension TableViewController {
    enum Object: CaseIterable {
        case tripAdvisor, figma, productHuntDaily, invision, pinterest
        
        var icon: UIImage {
            switch self {
            case .tripAdvisor: return #imageLiteral(resourceName: "icon4")
            case .figma: return #imageLiteral(resourceName: "icon5")
            case .productHuntDaily: return #imageLiteral(resourceName: "icon1")
            case .invision: return #imageLiteral(resourceName: "icon2")
            case .pinterest: return #imageLiteral(resourceName: "icon3")
            }
        }
        
        var name: String {
            switch self {
            case .tripAdvisor: return "TripAdvisor"
            case .figma: return "Figma"
            case .productHuntDaily: return "Product Hunt Daily"
            case .invision: return "invision"
            case .pinterest: return "Pinterest"
            }
        }
        
        var title: String {
            switch self {
            case .tripAdvisor: return "Your saved search to Vienna"
            case .figma: return "Figma @mentions are here!"
            case .productHuntDaily: return "Must-have Chrome Extensions"
            case .invision: return "First interview with a designer i admire :)"
            case .pinterest: return "You’ve got 18 new ideas waiting for you!"
            }
        }
        
        var description: String {
            switch self {
            case .tripAdvisor: return "Sed ut perspiciatis unde omnis iste…"
            case .figma: return "We forgot to give you your Valentin…"
            case .productHuntDaily: return "There’s a Chrome extensions for everyth…"
            case .invision: return "Hey guys, so I asked on instagram a cou…"
            case .pinterest: return "Football Transfer Window by Signal…"
            }
        }
        
        var time: String {
            switch self {
            case .tripAdvisor: return "20 FEB"
            case .figma: return "22 FEB"
            case .productHuntDaily: return "13:46"
            case .invision: return "15:12"
            case .pinterest: return "18:30"
            }
        }
    }
}

