//
//  ChatViewController.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, ChatInteractorDelegate, UITableViewDataSource {
    
    let inputTextView = InputTextView(frame: CGRect.zero)
    let messagesTableView = UITableView()
    
    var interactor: ChatInteractor?
    
    var verticalConstraints = [NSLayoutConstraint]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.interactor?.user.name
        self.interactor?.delegate = self
        
        self.inputTextView.translatesAutoresizingMaskIntoConstraints = false
        self.messagesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCellIdentifier")
        self.messagesTableView.translatesAutoresizingMaskIntoConstraints = false
        self.messagesTableView.separatorStyle = .none
        self.messagesTableView.dataSource = self
        
        self.view.addSubview(self.messagesTableView)
        self.view.addSubview(self.inputTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(notification:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(notification:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
        
        let tapToDismissGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.userTapInView))
        tapToDismissGestureRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapToDismissGestureRecognizer)
        
        self.inputTextView.buttonPressed = { [unowned self] message in //without the [unowned self] we obtain retain cycle, and deinit do not be called
            
            do {
                try self.interactor?.sendMessage(message)
                
            } catch {
                //TODO: show error
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.interactor?.stopSession()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateConstraintsForHeight(0.0)
        let views = ["inputTextView" : inputTextView, "messagesTableView" : messagesTableView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[inputTextView]|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[messagesTableView]|",
                                                                options: [],
                                                                metrics: nil,
                                                                views: views))
    }
    
//MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.interactor?.messages.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCellIdentifier", for: indexPath)
        
        if let message = self.interactor?.messages[indexPath.row] {
            cell.textLabel?.text = message.message
            
            if message.isMine {
                cell.textLabel?.textAlignment = NSTextAlignment.right
                
            } else {
                cell.textLabel?.textAlignment = NSTextAlignment.left
            }
        }
        
        return cell
    }
    
//MARK: - AutoLayout
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if let info = notification.userInfo {
            let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double
            if keyboardFrame != nil && animationDuration != nil {
                self.shouldAnimateWithDuration(animationDuration!, height: Double(keyboardFrame!.height))
            }
        }
        
    }
    @objc func keyboardWillHide(notification: Notification) {
        
        if let info = notification.userInfo {
            if let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                self.shouldAnimateWithDuration(animationDuration, height: 0)
            }
        }
    }
    
    func shouldAnimateWithDuration(_ duration: TimeInterval, height: Double) {
        
        self.updateConstraintsForHeight(height)
        
        UIView.animate(withDuration: duration) { 
            self.view.layoutIfNeeded()
        }
        
        if height > 0 {
            if var index = self.interactor?.messages.count {
                index = index-1
                if index > 0 {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    func updateConstraintsForHeight(_ height: Double) {
        
        self.view.removeConstraints(self.verticalConstraints)
        self.verticalConstraints = []
        
        
        let views = ["inputTextView" : inputTextView, "messagesTableView" : messagesTableView]
        let metrics = ["bottomMargin" : height]
        self.verticalConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat:"V:|[messagesTableView][inputTextView(==45)]-bottomMargin-|",
                                                                                   options: [],
                                                                                   metrics: metrics,
                                                                                   views: views))
        self.view.addConstraints(self.verticalConstraints)
    }
    
//MARK: - Utils
    
    @objc func userTapInView() {
        self.view.findFirstResponder()?.resignFirstResponder()
    }
    
//MARK: - Interactor delegate
    
    func messageAdded(atIndex index: Int, isMine: Bool) {
        
        let indexPath = IndexPath(row: index, section: 0)
        let animation = isMine ? UITableViewRowAnimation.right : UITableViewRowAnimation.left
        self.messagesTableView.insertRows(at: [indexPath], with: animation)
        
        if index > 0 {
            let indexPath = IndexPath(row: index, section: 0)
            self.messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func connectionError() {
        
        let alert = UIAlertController(title: "Connection", message: "The connection is lost", preferredStyle: UIAlertControllerStyle.alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { [weak self] (alertAction) -> Void in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(acceptAction)
        self.present(alert, animated: true, completion: nil)
    }
}
