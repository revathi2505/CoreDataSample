//
//  ViewController.swift
//  CoreDataSample
//
//  Created by Easyway_Mac2 on 09/04/19.
//  Copyright © 2019 Easyway_Mac2. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class RoomViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var roomArray:[Room] = [Room]()
    
    let cellId = "roomCell"

    @IBOutlet var roomsTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getRooms()
        
    }

  
}

extension RoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Tableview delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = roomsTableview.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RoomCell
        
        let room = self.roomArray[indexPath.row]
        
        cell.roomNameLabel.text = room.roomName
        cell.roomIdLabel.text = room.roomId
        cell.floorIdLabel.text = room.floorId
        
        return cell
    }
    
    //MARK: - Tableview datasource methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)

        roomsTableview.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ItemViewController
        
        if let selectedIndexpath = roomsTableview.indexPathForSelectedRow {
            destinationVC.selectedRoom = self.roomArray[(selectedIndexpath.row)]
        }
        
    }
}

//MARK: - Get data

extension RoomViewController {
    
    //MARK: Get Rooms
    
    func getRooms() {
        
        destroyData(with: Room.fetchRequest())
        
        let getRoomApi = "http://183.82.99.124/getrooms.cmd"
        
        Alamofire.request(getRoomApi).responseJSON{
            response in
            if response.result.isSuccess {
                
                let roomsJSON : JSON = JSON(response.result.value!)
                
                self.updateRoomsInDataModel(json: roomsJSON)
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
        
    }
    
    func updateRoomsInDataModel(json: JSON) {
        
        for roomDetails in json.array! {
            
            let newRoom = Room(context:context)
            newRoom.roomId = roomDetails["roomid"].string
            newRoom.floorId = roomDetails["floorid"].string
            
            var roomName: String = roomDetails["roomname"].string!
            roomName = roomName.replacingOccurrences(of: "+", with: " ")
            
            newRoom.roomName = roomName
            
            self.roomArray.append(newRoom)
            
        }
        
        saveData()
        
        roomsTableview.reloadData()
        
        getItems()
    }
    
    //MARK: Get Items
    
    func getItems() {
        
        //destroyData(with: Item.fetchRequest())
        
        let getItemsAPI = "http://183.82.99.124/getitems.cmd"
        
        Alamofire.request(getItemsAPI).responseJSON{
            response in
            if response.result.isSuccess {
                
                let itemsJSON : JSON = JSON(response.result.value!)
                
                self.updateItemsInDataModel(json: itemsJSON)
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    func updateItemsInDataModel(json: JSON) {
        
        for itemDetails in json.array! {
            let newItem = Item(context: context)
            
            newItem.itemId = itemDetails["itemid"].string
            newItem.type = itemDetails["type"].string
            newItem.status = itemDetails["status"].string
            newItem.itemName = itemDetails["itemname"].string
            let roomId = itemDetails["rid"].string!
    
            let room = getRoomDetails(roomId: roomId)
            newItem.parentRoom = room
        }
        
        saveData()
        
        getStatus()
    }
    
    //MARK: - Get Status
    
    func getStatus() {
        
        let getStatusAPI = "http://183.82.99.124/getstatus.cmd"
        
        Alamofire.request(getStatusAPI).responseJSON{
            response in
            if response.result.isSuccess {
                
                let statusJSON : JSON = JSON(response.result.value!)
                
                self.parseStatusJson(json: statusJSON)
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
        
    }
    
    func parseStatusJson(json:JSON) {
        
        for itemDetails in json.array! {
            
            let itemId = itemDetails["itemid"].string
            let status = itemDetails["status"].string
            
            updateItemStatusInDataModel(itemId: itemId!, status: status!)
            
        }
        
    }
    
}

//MARK: - Data Model  Manipulation Methods

extension RoomViewController {
    
    func destroyData(with request:NSFetchRequest<NSFetchRequestResult>) {
    
       // let deleteRequest = NSBatchDeleteRequest(fetchRequest: request )
        
        do {
            let result = try context.fetch(request)
            
            for object in result {
                context.delete(object as! NSManagedObject)
            }
            
            try context.save()
            
        } catch {
            print("error deleting data \(error)")
        }
        
    }
    
    func saveData(with executeRequest:NSBatchDeleteRequest? = nil) {
        
        do {
            try context.save()
        } catch {
            print("Error Context Saving \(error)")
        }
        
    }
    
    func loadData(with request: NSFetchRequest<Room> = Room.fetchRequest()) {
        
        do {
            self.roomArray = try context.fetch(request)
        } catch {
            print("Error fetching request \(error)")
        }
        
        roomsTableview.reloadData()
        
    }
    
    func getRoomDetails(with request: NSFetchRequest<Room> = Room.fetchRequest(), roomId:String) -> Room? {
        request.predicate = NSPredicate(format: "roomId MATCHES %@", roomId)
        
        do {
            let rooms:[Room] =  try context.fetch(request)
            return rooms.first
        } catch {
            print("Error fetching room \(error)")
            return nil
        }
    }
    
    func updateItemStatusInDataModel(with request: NSFetchRequest<Item> = Item.fetchRequest(), itemId:String, status: String) {
        
        request.predicate = NSPredicate(format: "itemId MATCHES %@", itemId)
        
        do {
            let items:[Item] = try context.fetch(request)
            
            let item = items.first
            
            item?.status = status
            
        } catch {
            print("Error fetching Item \(error)")
        }
        
        saveData()
    }
}

class RoomCell: UITableViewCell {
    
    @IBOutlet var roomNameLabel: UILabel!
    @IBOutlet var roomIdLabel: UILabel!
    @IBOutlet var floorIdLabel: UILabel!
    
}

