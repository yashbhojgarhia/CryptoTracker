//
//  CryptoTableViewController.swift
//  Crypto Tracker
//
//  Created by Yash Bhojgarhia on 30/05/21.
//

import UIKit
import LocalAuthentication

private let headerHeight: CGFloat = 100.0
private let netWorthHeight: CGFloat = 45.0

class CryptoTableViewController: UITableViewController, CoinDataDelegate {
    
    var amountLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        CoinData.shared.getPrices()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(reportTapped))
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            updateSecureButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoinData.shared.delegate = self
        tableView.reloadData()
        displayNetWorth()
    }
    
    @objc func reportTapped() {
        let formatter = UIMarkupTextPrintFormatter(markupText: CoinData.shared.html())
        let render  = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        let shareVC  = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(shareVC, animated: true, completion: nil)
    }
    
    func updateSecureButton() {
        if UserDefaults.standard.bool(forKey: "secure") {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unsecure App", style: .plain, target: self, action: #selector(secureTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Secure App", style: .plain, target: self, action: #selector(secureTapped))
        }
    }
    
    @objc func secureTapped() {
        if UserDefaults.standard.bool(forKey: "secure") {
            UserDefaults.standard.setValue(false, forKey: "secure")
        } else {
            UserDefaults.standard.setValue(true, forKey: "secure")
        }
        updateSecureButton()
    }
    
    func newPrices() {
        displayNetWorth()
        tableView.reloadData()
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight))
        headerView.backgroundColor = .white
        let netWorthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: netWorthHeight))
        netWorthLabel.text = "My Crypto Net Worth"
        netWorthLabel.textAlignment = .center
        headerView.addSubview(netWorthLabel)
        
        amountLabel.frame = CGRect(x: 0, y: netWorthHeight, width: view.frame.size.width, height: headerHeight - netWorthHeight)
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.boldSystemFont(ofSize: 60.0)
        headerView.addSubview(amountLabel)
        
        displayNetWorth()
        
        return headerView
    }
    
    func displayNetWorth() {
        amountLabel.text = CoinData.shared.netWorthAsString()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinData.shared.coins.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let coin = CoinData.shared.coins[indexPath.row]
        if coin.amount != 0.0 {
            cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString()) - \(coin.amount)"
        }
        else {
            cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString())"
        }
        cell.imageView?.image = coin.image
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinVC = CoinViewController()
        coinVC.coin = CoinData.shared.coins[indexPath.row]
        navigationController?.pushViewController(coinVC, animated: true)
    }

}
