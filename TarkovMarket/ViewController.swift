//
//  ViewController.swift
//  TarkovMarket
//
//  Created by Will Chew on 2020-03-08.
//  Copyright © 2020 Will Chew. All rights reserved.
//

import UIKit

struct Item : Codable {
    let name : String
    let uid : String
    let price : Int?
    let updated : String?
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var itemArray = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        getAllItems()
        getItem()
        
        // Do any additional setup after loading the view.
    }


    
    
    func getAllItems() {
        
        guard let url = URL(string: "https://tarkov-market.com/api/v1/items/all") else { return }
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.addValue("", forHTTPHeaderField: "x-api-key")
//        request.addValue("btc", forHTTPHeaderField: "q")
        
        session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else { return }
            
            do {
                let item = try JSONDecoder().decode([Item].self, from: data)
                
                for item in item {
                    self.itemArray.append(item)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("ERROR")
            }
        }.resume()
   
    }
    
    func getItem() {

        
            

            
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tarkov-market.com"
        components.path = "/api/v1/item"
        let queryItemKey = URLQueryItem(name: "q", value: "btc")
        components.queryItems = [queryItemKey]
        
        
            let session = URLSession.shared
        guard let url = components.url else { return }
        var request = URLRequest(url: url)
        request.addValue("", forHTTPHeaderField: "x-api-key")
    //        request.addValue("btc", forHTTPHeaderField: "q")
            
            session.dataTask(with: request) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else { return }
                
                do {
                    let item = try JSONDecoder().decode([Item].self, from: data)
                    
                    for item in item {
                        self.itemArray.append(item)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("ERROR")
                }
            }.resume()
       
        }
    
    
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].name
        
        return cell
    }
    
    
}



