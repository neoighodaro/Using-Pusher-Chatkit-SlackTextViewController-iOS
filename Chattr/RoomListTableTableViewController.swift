//
//  RoomListTableTableViewController.swift
//  Chattr
//
//  Created by Neo Ighodaro on 24/10/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit
import PusherChatkit

class RoomListTableViewController: UITableViewController {
    var username: String!
    var selectedRoom: PCRoom?
    var currentUser: PCCurrentUser!
    var availableRooms = [PCRoom]()
    var activityIndicator = UIActivityIndicatorView()
}


// MARK: - Initialize -
extension RoomListTableViewController: PCChatManagerDelegate {
    override func viewDidLoad() -> Void {
        super.viewDidLoad()
        self.setNavigationItemTitle()
        self.initActivityIndicator()
        self.initPusherChatkit()
    }
    
    private func setNavigationItemTitle() -> Void {
        self.navigationItem.title = "Rooms"
    }
    
    private func initActivityIndicator() -> Void {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    private func initPusherChatkit() -> Void {
        self.initPusherChatManager { [weak self] (currentUser) in
            guard let strongSelf = self else { return }
            strongSelf.currentUser = currentUser
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.tableView.reloadData()
        }
    }
    
    private func initPusherChatManager(completion: @escaping (_ success: PCCurrentUser) -> Void) -> Void {
        let chatManager = ChatManager(
            instanceId: AppConstants.INSTANCE_ID,
            tokenProvider: PCTokenProvider(url: AppConstants.ENDPOINT + "/auth", userId: username)
        )
        
        chatManager.connect(delegate: self) { (user, error) in
            guard error == nil else { return }
            guard let user = user else { return }
            
            // Get a list of all rooms. Attempt to join the room.
            user.getAllRooms { rooms, error in
                guard error == nil else { return }
                
                self.availableRooms = rooms!
                
                rooms!.forEach { room in
                    user.joinRoom(room) { room, error in
                        guard error == nil else { return }
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            DispatchQueue.main.async {
                completion(user)
            }
        }
    }
}


// MARK: - UITableViewController Overrides -
extension RoomListTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableRooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let roomTitle = self.availableRooms[indexPath.row].name
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        cell.textLabel?.text = "\(roomTitle)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRoom = self.availableRooms[indexPath.row]
        self.performSegue(withIdentifier: "segueToRoomViewController", sender: self)
    }
}


// MARK: - Navigation -
extension RoomListTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) -> Void {
        if segue.identifier == "segueToRoomViewController" {
            let roomViewController = segue.destination as! RoomViewController
            roomViewController.room = self.selectedRoom
            roomViewController.currentUser = self.currentUser
        }
    }
}
