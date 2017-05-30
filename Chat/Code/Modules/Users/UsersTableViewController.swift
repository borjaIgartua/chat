//
//  UsersTableViewController.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController, UsersInteractorDelegate {
    
    var interactor: UsersInteractor?

    override func viewDidLoad() {
        super.viewDidLoad()

        interactor = UsersInteractor()
        interactor!.delegate = self
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        interactor?.start()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.interactor?.users.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        if let name = self.interactor?.users[indexPath.row].name {
            cell.textLabel?.text = name
        }

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

//MARK: - TableView Delegate methods
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.interactor?.sendInvitationToUser(inIndexPath: indexPath)
    }
    
//:MARK - Interactor delegate methods
    
    func userAdded(atIndex index: Int) {
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.left)
    }
    
    func userRemoved(atIndex index: Int) {
        
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.middle)
    }
    
    func invitationReceived(fromName name: String, context: Data?, accept: @escaping () -> (), decline: @escaping () -> ()) {
        
        let alert = UIAlertController(title: "Invitation Received", message: "\(name) wants to connect with you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            accept()
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            decline()
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func connectedWithUser(_ user: User?) {
        
        let viewController = ChatViewController()
        if let manager = self.interactor?.mpcManager, let user = self.interactor?.connectedUser  {
            viewController.interactor = ChatInteractor(manager: manager, withUser: user)
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
