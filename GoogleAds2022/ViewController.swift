//
//  ViewController.swift
//  GoogleAds2022
//
//  Created by Anas Almomany on 12/01/2022.
//

import UIKit

// Should be implemented
protocol Presentation {

}

class Cell: UITableViewCell {

}

struct McokCellData: Presentation {
    var title: String

    static var generate: McokCellData {
        return McokCellData(title: randomString(length: 10))
    }

    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

class ViewController: UIViewController {
    private var tableView = UITableView()
    private var items: [Presentation] = []

    var adsProvider: ADSProvider?

    override func viewDidLoad() {
        super.viewDidLoad()

        generateFakeDate()
        drawTable()
        configTable()
        applyAdsIfPossible()
    }

    func generateFakeDate() {
        items = (0...20).map({ number -> McokCellData in
            return McokCellData.generate
        })
    }

    func drawTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }

    func configTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
    }

    func applyAdsIfPossible() {
        adsProvider = ADSProvider(rootViewController: self, tableView: tableView, adInsertionEvery: 3)
        adsProvider?.insertionOperation = { [weak self] ad, i in
            // You should only request ads number that can fit in your array
            // Like loading 4 ads in 3 rows array will fail and its not recommended to try to handle it manualy
            self?.items.insert(ad, at: i)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let nativeAd = adsProvider?.adForRowAr(indexPath: indexPath) {
            return nativeAd
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let item = items[indexPath.row] as? McokCellData {
            cell.textLabel?.text = item.title
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items[indexPath.row] as? McokCellData {
            print("ITEM TAPPED", item.title)
        }
    }
}

