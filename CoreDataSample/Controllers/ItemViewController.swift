//
//  ItemViewController.swift
//  CoreDataSample
//
//  Created by Easyway_Mac2 on 09/04/19.
//  Copyright © 2019 Easyway_Mac2. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UITableViewController {
    
    var selectedRoom:Room? {
        didSet {
            loadItems()
            self.navigationItem.title = selectedRoom?.roomName
        }
    }
    
    let cellId = "itemCell"
    
    var itemsArray: [Item] = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: cellId)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ItemCell

        let item = self.itemsArray[indexPath.row]
        cell.itemName.text = item.itemName
        cell.itemId.text = item.itemId
        cell.type.text = item.type
        cell.status.text = item.status

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
 
}

//MARK: - Data Model Manipulation methods

extension ItemViewController {
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest()) {
        
        request.predicate = NSPredicate(format: "parentRoom.roomId MATCHES %@",selectedRoom!.roomId! )
        
        do {
            self.itemsArray = try context.fetch(request)
        } catch {
            print("Error fetching Items from context \(error)")
        }
        
    }
}
