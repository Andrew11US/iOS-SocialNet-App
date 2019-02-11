//
//  MessageVC.swift
//  SocialNet
//
//  Created by Agent X on 2/7/18.
//  Copyright © 2018 Andrii Halabuda. All rights reserved.
//

import UIKit
import Firebase

class MessageVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var dialogName: UILabel!

    let userID = Auth.auth().currentUser?.uid
    var user = User(username: "", name: "", userPicUrl: "")
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Read data from database
        DataService.ds.REF_MESSAGES.child("messageID").child("data").queryOrdered(byChild: "timeStamp").observe(.value, with: { (snapshot) in
            
            // Fixes dublicate posts issue
            self.messages = []
            
            // Stores temporary data
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let messageDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let message = Message(messageKey: key, messageData: messageDict)
                        self.messages.append(message)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
        self.dialogName.text = user.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print(user.userId)
    }
    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        
        if inputField.text != nil || inputField.text != "" {
            sendMessage()
            inputField.text = nil
            print("Message sent!")
        }
    }
    
    @IBAction func inputEditingEnd(_ sender: UITextField) {
        
    }
    
    func sendMessage() {
        let message: Dictionary<String, AnyObject> = [
            
            "content": inputField.text! as AnyObject,
            "from": userID as AnyObject,
            "timeStamp": ServerValue.timestamp() as AnyObject,
            ]
        
        let key = DataService.ds.REF_POSTS.childByAutoId().key!
        
        let childUpdates = ["/messages/messageID/data/\(key)": message]
        DataService.ds.REF_BASE.updateChildValues(childUpdates)
        
    }

}

extension MessageVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as? MessageCell {
            
            DispatchQueue.main.async {
                cell.configureCell(message: message)
                if message.from == self.userID {
                    cell.layer.backgroundColor = UIColor.blue.cgColor
                }
            }
            
            return cell
            
        } else {
            
            return PostCell()
        }
    }


}
