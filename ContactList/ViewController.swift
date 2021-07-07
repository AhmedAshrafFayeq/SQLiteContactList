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
        openDatabaseConnection()
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

}

