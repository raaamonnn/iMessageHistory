//
//  ViewController.swift
//  iMessageHistory
//
//  Created by Ramon Amini on 3/31/21.
//

import UIKit
import SQLite3

class VCMainScreen: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBox: UITextField!
    @IBOutlet weak var searchText: UISearchBar!
    
    var messages: [DMText] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
       
        searchBox.delegate = self
        searchText.delegate = self
        
        let textFieldCell = UINib(nibName: "TVCText", bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "TVCText")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AllMessages(_ sender: Any) {
        let queryStatementString = """
            SELECT datetime (message.date / 1000000000 + strftime ('%s', '2001-01-01'), 'unixepoch', 'localtime') AS message_date, message.text, message.is_from_me, chat.chat_identifier
            FROM chat JOIN chat_message_join ON chat. 'ROWID' = chat_message_join.chat_id JOIN message ON chat_message_join.message_id = message. 'ROWID'
            ORDER BY message_date ASC;
        """

        messages = queryCall(queryStatementString: queryStatementString)!
        tableView.reloadData()
    }
 
    func queryCall(queryStatementString: String) -> [DMText]? {
        guard let db = openDatabase() else {
            print("Unable to open database.")
            return nil
        }
        print("Opened Database.")

        return query(db: db, queryStatementString: queryStatementString)!
    }
    
    func openDatabase() -> OpaquePointer? {
        do {
            var db: OpaquePointer?
            let fileURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let url = fileURL.appendingPathComponent("Messages", isDirectory: true).appendingPathComponent("chat.db", isDirectory: false)
            print(try url.checkResourceIsReachable() ? "Is Reachable" : "Not Reachable")
            if sqlite3_open(url.absoluteString, &db) == SQLITE_OK {
                print("Successfully opened connection to database at \(url)")
                return db
            } else {
                print("Unable to open database.")
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func query(db: OpaquePointer?, queryStatementString: String) -> [DMText]? {
        var queryStatement: OpaquePointer?
        var messages:[DMText] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
          print("\n")
          while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
            let text = GetText(queryStatement: queryStatement)
            if  text != nil {
                messages.append(text!)
            }
          }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\nQuery is not prepared \(errorMessage)")
        }
        sqlite3_finalize(queryStatement)
        return messages
    }
    
    func GetText(queryStatement: OpaquePointer?) -> DMText? {
        
        guard let messageDateData = sqlite3_column_text(queryStatement, 0) else {
            print("Query messageDateData result is nil.")
            return nil
        }
        
        let messageDate = String(cString: messageDateData)
        
        guard let textData = sqlite3_column_text(queryStatement, 1) else {
            print("Query textData result is nil.")
            return nil
        }
        
        let message = String(cString: textData)
        
        let isFromUser = String(sqlite3_column_int(queryStatement, 2))
        
        guard let chatIdData = sqlite3_column_text(queryStatement, 3) else {
            print("Query chatId result is nil.")
            return nil
        }
        
        let chatId = String(cString: chatIdData)
        
        return DMText(date: messageDate, isUser: isFromUser, phoneNumber: chatId, message: message)
    }
    
    
    @IBAction func PhoneSearch(_ sender: Any) {
        if searchBox.text != "" {
            let queryStatementString = """
                SELECT datetime (message.date / 1000000000 + strftime ('%s', '2001-01-01'), 'unixepoch', 'localtime') AS message_date, message.text, message.is_from_me, chat.chat_identifier
                FROM chat JOIN chat_message_join ON chat. 'ROWID' = chat_message_join.chat_id JOIN message ON chat_message_join.message_id = message. 'ROWID'
                WHERE chat.chat_identifier like '%\(searchBox.text!)%'
                ORDER BY message_date ASC;
            """

            messages = queryCall(queryStatementString: queryStatementString)!
            tableView.reloadData()
        }
    }
    
    @IBAction func SortNewest(_ sender: Any) {
        messages = messages.sorted(by: {$0.date > $1.date})
        tableView.reloadData()
    }
    
    @IBAction func SortOldest(_ sender: Any) {
        messages = messages.sorted(by: {$0.date < $1.date})
        tableView.reloadData()
    }
}

extension VCMainScreen: UITableViewDelegate, UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 200
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TVCText", for: indexPath) as! TVCText
        cell.date?.text = messages[indexPath.row].date
        cell.isUser?.image = messages[indexPath.row].isUser
        cell.phoneNumber?.text = messages[indexPath.row].phoneNumber
        cell.message?.text = messages[indexPath.row].message
        return cell
    }
}

extension VCMainScreen: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "/b" || string == "\n"  { //backspace or enter
            return true
        }
        
        if !(string == string.filter("0123456789".contains)) {
            return false
        }
        
        return true
    }
}

extension VCMainScreen: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            if searchBox.text != "" {
                print("Search ")
                let queryStatementString = """
                    SELECT datetime (message.date / 1000000000 + strftime ('%s', '2001-01-01'), 'unixepoch', 'localtime') AS message_date, message.text, message.is_from_me, chat.chat_identifier
                    FROM chat JOIN chat_message_join ON chat. 'ROWID' = chat_message_join.chat_id JOIN message ON chat_message_join.message_id = message. 'ROWID'
                    WHERE message.text like '%\(searchBox.text!)%' AND message.text like '%\(searchText)%'
                    ORDER BY message_date ASC;
                """

                messages = queryCall(queryStatementString: queryStatementString)!
                tableView.reloadData()
            }
        }
        else {
            let queryStatementString = """
                SELECT datetime (message.date / 1000000000 + strftime ('%s', '2001-01-01'), 'unixepoch', 'localtime') AS message_date, message.text, message.is_from_me, chat.chat_identifier
                FROM chat JOIN chat_message_join ON chat. 'ROWID' = chat_message_join.chat_id JOIN message ON chat_message_join.message_id = message. 'ROWID'
                WHERE message.text like '%\(searchText)%'
                ORDER BY message_date ASC;
            """

            messages = queryCall(queryStatementString: queryStatementString)!
            tableView.reloadData()
        }
    }
}

