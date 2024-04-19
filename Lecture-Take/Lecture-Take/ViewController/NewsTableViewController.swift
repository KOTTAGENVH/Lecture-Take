//
//  NewsTableViewController.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-19.
//

import UIKit
import SafariServices

struct NewsItem: Codable {
    let title: String
    let source: String
}

class NewsTableViewController: UITableViewController {
    
    var newsItems: [NewsItem] = []
    var filteredNewsItems: [NewsItem] = []
    var isLoading = false
    
    @IBOutlet var searchBar: UISearchBar!
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    let noDataLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchData(from: "https://latest-sri-lankan-news.p.rapidapi.com/latest-news/deshaya/1")
        fetchData(from: "https://latest-sri-lankan-news.p.rapidapi.com/latest-news/bbcsinhala")
        
        filteredNewsItems = newsItems
    }
    
    func setupUI() {
        tableView.backgroundView = activityIndicator
        
        noDataLabel.text = "No latest news available"
        noDataLabel.textAlignment = .center
        noDataLabel.isHidden = true
        tableView.addSubview(noDataLabel)
        
        searchBar.delegate = self
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        tableView.separatorStyle = .none
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        tableView.separatorStyle = .singleLine
    }
    
    func showNoDataLabel() {
        noDataLabel.isHidden = false
    }
    
    func hideNoDataLabel() {
        noDataLabel.isHidden = true
    }
    
    func fetchData(from url: String) {
        isLoading = true
        showLoadingIndicator()
        
        guard let apiUrl = URL(string: url) else { return }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.setValue("ca26c6109cmsh798adf6e911e6c8p14fff8jsn64ab23c74ed9", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("latest-sri-lankan-news.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.alert("An error occurred during fetching news")
                }
                print("Error fetching data: \(error)")
                self.isLoading = false
                self.hideLoadingIndicator()
                return
            }
            
            
            guard let data = data else {
                self.isLoading = false
                self.hideLoadingIndicator()
                self.showNoDataLabel()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                struct ResponseData: Decodable {
                    let latestContent: [NewsItem]
                }
                
                let responseData = try decoder.decode(ResponseData.self, from: data)
                self.newsItems.append(contentsOf: responseData.latestContent)
                self.filteredNewsItems.append(contentsOf: responseData.latestContent)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hideLoadingIndicator()
                    self.hideNoDataLabel()
                    self.tableView.reloadData()
                }
            } catch {
                print("Error decoding data: \(error)")
                DispatchQueue.main.async {
                    self.alert("An error occurred during fetching news")
                }
                self.isLoading = false
                self.hideLoadingIndicator()
            }
        }.resume()
    }
    
    func alert(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNewsItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newscellidentifier", for: indexPath) as! NewsTableViewCell
        
        let newsItem = filteredNewsItems[indexPath.row]
        cell.newstitle.text = newsItem.title
        
        // Set source based on the URL
        if let url = URL(string: newsItem.source),
           let host = url.host {
            switch host {
            case "latest-sri-lankan-news.p.rapidapi.com":
                cell.sourcenews.text = "API1"
            case "www.bbc.com":
                cell.sourcenews.text = "BBC"
            case "www.deshaya.lk":
                cell.sourcenews.text = "Deshaya"
            default:
                cell.sourcenews.text = "Unknown"
            }
        } else {
            cell.sourcenews.text = "Unknown"
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsItem = filteredNewsItems[indexPath.row]
        if let url = URL(string: newsItem.source) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
}

extension NewsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterNews(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterNews("")
        searchBar.resignFirstResponder()
    }
    
    func filterNews(_ searchText: String) {
        if searchText.isEmpty {
            filteredNewsItems = newsItems
        } else {
            filteredNewsItems = newsItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.source.localizedCaseInsensitiveContains(searchText) }
        }
        tableView.reloadData()
    }
}
