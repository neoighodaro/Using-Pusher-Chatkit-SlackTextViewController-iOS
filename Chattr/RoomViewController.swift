//
//  RoomViewController.swift
//  Chattr
//
//  Created by Neo Ighodaro on 24/10/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit
import PusherChatkit
import SlackTextViewController


class RoomViewController: SLKTextViewController, PCRoomDelegate {
    var room: PCRoom!
    var messages = [Message]()
    var currentUser: PCCurrentUser!
    override var tableView: UITableView {
        get { return super.tableView! }
    }
}


// MARK: - Initialize -
extension RoomViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribeToRoom()
        self.setNavigationItemTitle()
        self.configureSlackTableViewController()
    }
    
    private func subscribeToRoom() -> Void {
        self.currentUser.subscribeToRoom(room: self.room, roomDelegate: self)
    }
    
    private func setNavigationItemTitle() -> Void {
        self.navigationItem.title = self.room.name
    }
    
    private func configureSlackTableViewController() -> Void {
        self.bounces = true
        self.isInverted = true
        self.shakeToClearEnabled = true
        self.isKeyboardPanningEnabled = true
        self.textInputbar.maxCharCount = 256
        self.tableView.separatorStyle = .none
        self.textInputbar.counterStyle = .split
        self.textInputbar.counterPosition = .top
        self.textInputbar.autoHideRightButton = true
        self.textView.placeholder = "Enter Message...";
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.textInputbar.editorTitle.textColor = UIColor.darkGray
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        self.tableView.register(MessageCell.classForCoder(), forCellReuseIdentifier: MessageCell.MessengerCellIdentifier)
        self.autoCompletionView.register(MessageCell.classForCoder(), forCellReuseIdentifier: MessageCell.AutoCompletionCellIdentifier)
    }
}


// MARK: - UITableViewController Overrides -
extension RoomViewController {
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.messages.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if tableView == self.tableView {
        return self.messageCellForRowAtIndexPath(indexPath)
        // }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            let message = self.messages[(indexPath as NSIndexPath).row]
            
            if message.text.characters.count == 0 {
                return 0
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .left
            
            let pointSize = MessageCell.defaultFontSize()
            
            let attributes = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: pointSize),
                NSAttributedStringKey.paragraphStyle: paragraphStyle
            ]
            
            var width = tableView.frame.width - MessageCell.kMessageTableViewCellAvatarHeight
            width -= 25.0
            
            let titleBounds = (message.username as NSString!).boundingRect(
                with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: attributes,
                context: nil
            )
            
            let bodyBounds = (message.text as NSString!).boundingRect(
                with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: attributes,
                context: nil
            )
            
            var height = titleBounds.height
            height += bodyBounds.height
            height += 40
            
            if height < MessageCell.kMessageTableViewCellMinimumHeight {
                height = MessageCell.kMessageTableViewCellMinimumHeight
            }
            
            return height
        }
        
        return MessageCell.kMessageTableViewCellMinimumHeight
    }
}


// MARK: - Overrides -
extension RoomViewController {
    override func keyForTextCaching() -> String? {
        return Bundle.main.bundleIdentifier
    }
    
    override func didPressRightButton(_ sender: Any!) {
        self.textView.refreshFirstResponder()
        self.sendMessage(textView.text)
        super.didPressRightButton(sender)
    }
}


// MARK: - Delegate Methods -
extension RoomViewController {
    public func newMessage(message: PCMessage) {
        let msg = self.PCMessageToMessage(message)
        let indexPath = IndexPath(row: 0, section: 0)
        let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
        let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.messages.insert(msg, at: 0)
            self.tableView.insertRows(at: [indexPath], with: rowAnimation)
            self.tableView.endUpdates()
            
            self.tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
}


// MARK: - Helpers -
extension RoomViewController {
    private func PCMessageToMessage(_ message: PCMessage) -> Message {
        return Message(id: message.id, username: message.sender.displayName, text: message.text)
    }
    
    private func sendMessage(_ message: String) -> Void {
        guard let room = self.room else { return }
        self.currentUser?.addMessage(text: message, to: room, completionHandler: { (messsage, error) in
            guard error == nil else { return }
        })
    }
    
    private func messageCellForRowAtIndexPath(_ indexPath: IndexPath) -> MessageCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: MessageCell.MessengerCellIdentifier) as! MessageCell
        let message = self.messages[(indexPath as NSIndexPath).row]
        
        cell.bodyLabel().text = message.text
        cell.titleLabel().text = message.username
        
        cell.usedForMessage = true
        cell.indexPath = indexPath
        cell.transform = self.tableView.transform
        
        return cell
    }
}
