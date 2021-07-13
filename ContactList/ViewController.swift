//
//  ViewController.swift
//  ContactList
//
//  Created by Ahmed Fayek on 7/7/21.
//

import UIKit
import SQLite3

class ViewController: UITableViewController {
    var db: OpaquePointer?
    var contactLis = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = openDatabaseConnection()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAlertController))
        query(db: db)
//        createTable(db: db)
       // insert(id: 2, name: "Ali", db: db)
//        delete(db: db)
//        query(db: db)
        
    }
    
    
    @objc func showAlertController(){
        let alertController = UIAlertController(title: "Add contact", message: nil, preferredStyle: .alert)
        alertController.addTextField{ (tf) in
            tf.placeholder  = "Enter Id"
            tf.keyboardType = .asciiCapableNumberPad
        }
        alertController.addTextField { (tf) in
            tf.placeholder = "Enter Name"
        }
        let submitButton = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] (action) in
            guard let id = alertController?.textFields?[0].text else {return}
            guard let name = alertController?.textFields?[1].text else {return}
            print("\(id)  ||  \(name)")
            
            guard let idAsInt = Int32(id) else {return}
            
            self?.insert(id: idAsInt, name: name as NSString, db: self?.db)
            self?.query(db: self?.db)
        }
        alertController.addAction(submitButton)
        present(alertController, animated: true)
        
    }
    
    
    // connect to database
    func openDatabaseConnection() -> OpaquePointer?{
        var db: OpaquePointer?
        let fileUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Contacts.sqlite")
        if sqlite3_open(fileUrl?.path, &db) == SQLITE_OK {
            print("Successfully opened connection to database")
            return db
        }else{
            print("unable to open database")
            return nil
        }
    }
    
    //create table in database
    func createTable(db: OpaquePointer?){
        let createTableString = """
        CREATE TABLE Contact(Id INT PRIMARY KEY NOT NULL,
        Name CHAR(255));
        """
        
        //1
        var createTableStatement: OpaquePointer?
        
        //2
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK{
            //3
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Contact table created")
            }else {
                print("Contact table is not created")
            }
        }else {
            print("create table statement is not prepared")
        }
        //4
        sqlite3_finalize(createTableStatement)
    }
    
    //insert to table contact
    func insert(id: Int32, name: NSString, db: OpaquePointer?){
        let insertStatementString = "INSERT INTO Contact (Id,Name) VALUES (?, ?);"
        var insertStatement: OpaquePointer?
        //1
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK{
            
            //2
            sqlite3_bind_int(insertStatement, 1, id)
            sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
            
            //3
            if sqlite3_step(insertStatement) == SQLITE_DONE{
                print("row inserted successfully")
            }else{
                print("failed to insert data")
            }
        }else{
            print("insert statement not prepared")
        }
        
        //4
        sqlite3_finalize(insertStatement)
        
    }

    //retrieve from table Contact
    func query(db: OpaquePointer?){
        let queryStatementString = "SELECT * FROM Contact;"
        var queryStatement: OpaquePointer?
        //1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            contactLis.removeAll()
            //2
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                //3
                let id = sqlite3_column_int(queryStatement, 0)
                //4
                guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                    print("query result is nil")
                    return
                }
                let name = String(cString: queryResultCol1)
                //5
                contactLis.append("\(id) | \(name)")
            }
            self.tableView.reloadData()
        }else {
            //6
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("Query is not prepared \(errorMsg)")
        }
        sqlite3_finalize(queryStatement)
    }
    
    //delete from table Content
    func delete(db: OpaquePointer?){
        let deleteStatementString = "DELETE FROM Contact WHERE Id = 2;"
        var deleteOpauePointer: OpaquePointer?
        
        //1
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteOpauePointer, nil) == SQLITE_OK {
            if sqlite3_step(deleteOpauePointer) == SQLITE_DONE {
                print("row deleted successfully")
            }else {
                print("couldn't deleted the row")
            }
        }else{
            print("couldn't prepare")
        }
        sqlite3_finalize(deleteOpauePointer)
    }
}

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactLis.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        cell?.textLabel?.text = contactLis[indexPath.row]
        return cell!
    }
}
