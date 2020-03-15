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
    let price : Int
    let updated : String
    let smallImageURL : String
    let currency : String
    let slots : Int
    
    
    enum CodingKeys : String, CodingKey {
        case name = "shortName"
        case uid
        case price
        case updated
        case smallImageURL = "icon"
        case currency = "traderPriceCur"
        case slots
        
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    
    
    var itemArray = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        tableView.tableFooterView = UIView()
        
        
        
        
        //        let dateString = "2020-03-15T01:38:01.380Z"
        
        
        //        getAllItems()
        //        let items = "Ammo, AK, btc"
        //        let favourites = items.wordList
        
        //        for favourite in favourites {
        //            getPrice(of: favourite)
        //        }
        //        getPrice(of: items)
        //        getPrice(of: "btc")
        
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
    
    func getPrice(of item: String) {
        
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tarkov-market.com"
        components.path = "/api/v1/item"
        let queryItemKey = URLQueryItem(name: "q", value: item)
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
                    
                    self.itemArray.insert(item, at: 0)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("ERROR")
            }
        }.resume()
        
    }
    
    func calculateUpdated(last updated: Date) -> String {
        let timeUpdatedInHours = (updated.distance(to: Date()) / 3600)
        var measureOfTime = 0
        
        if timeUpdatedInHours / 24.0 > 1 {
            measureOfTime = Int((timeUpdatedInHours / 24.0).rounded())
            
            if measureOfTime == 1 {
                return "Updated 1 day ago"
            } else {
                return "Updated \(measureOfTime) days ago"
            }
            
            
        }
            
        else if timeUpdatedInHours > 1 {
            measureOfTime = Int(timeUpdatedInHours.rounded())
            
            if measureOfTime == 1 {
                return "Updated 1 hour ago"
            } else {
                return "Updated \(measureOfTime) hours ago"
            }
        }
            
        else if timeUpdatedInHours > 0 {
            measureOfTime = Int((timeUpdatedInHours * 60.0).rounded())
            
            if measureOfTime == 1 {
                return "Updated 1 minute ago"
            } else {
                return "Updated \(measureOfTime) minutes ago"
            }
        }
        else {
            return "Over a week ago"
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        guard let item = searchTextField.text else { return }
        getPrice(of: item)
        tableView.reloadData()
        self.view.endEditing(true)
    }
    
}

// #PRAGMA MARK: TableView functions

extension ViewController : UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        
        
        
        cell.nameLabel.text = itemArray[indexPath.row].name
        
        
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let priceAsInt = Int(itemArray[indexPath.row].price)
        guard let formattedPrice = numberFormatter.string(from: NSNumber(value: priceAsInt)) else { return cell }
        let currency = itemArray[indexPath.row].currency
        cell.priceLabel.text = "Price: \(formattedPrice)" + currency
        
        let date = itemArray[indexPath.row].updated
        
        
        //        let dateString = date.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
        let dateStringWithoutT = date.replacingOccurrences(of: "T", with: " ")
        let date2 = dateStringWithoutT.prefix(upTo: dateStringWithoutT.firstIndex(of: ".")!)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        var showDate = inputFormatter.date(from: String(date2))
        
        showDate?.addTimeInterval(-14400) // Time according to API is +4hrs from EST
        
        print(calculateUpdated(last: showDate!))
        
        
//
//        inputFormatter.dateFormat = "MMM d, h:mm a"
//        let displayDate = inputFormatter.string(from: showDate!)
//
//
        
        cell.updatedLabel.text = calculateUpdated(last: showDate!)
        
        
        
        
        
        guard let url = URL(string: itemArray[indexPath.row].smallImageURL) else { return cell }
        cell.itemImageView?.load(url: url) {
            tableView.reloadData()
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.bounds.size.height / 6
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchButtonPressed(self)
        return true
    }
    
    
    
    
}

extension String {
    var wordList: [String] {
        return components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty
        }
    }
}

extension UIImageView {
    func load(url: URL, completion: @escaping() -> Void) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

