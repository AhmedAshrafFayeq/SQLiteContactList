//
//  ViewController.swift
//  ContactList
//
//  Created by Ahmed Fayek on 7/7/21.
//

import UIKit
import SQLite3

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let db = openDatabaseConnection()
        createTable(db: db)
        
    }
    
    func openDatabaseConnection() -> OpaquePointer? {
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

}

