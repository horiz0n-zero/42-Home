// home42/Shop.swift
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ *
+
+      :::       ::::::::
+     :+:       :+:    :+:
+    +:+   +:+        +:+
+   +#+   +:+       +#+
+  +#+#+#+#+#+    +#+
+       #+#     #+#
+      ###    ######## H O M E
+
+   Copyright Antoine Feuerstein. All rights reserved.
+
* ++++++++++++++++++++++++++++++++++++++++++++++++++++ */

import Foundation
import UIKit
import WebKit

final class ShopViewController: HomeViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var products: ContiguousArray<IntraProduct>
    private let cache: CachingInterface
    private let tableView: BasicUITableView
    
    required init() {
        let data = try! Data(contentsOf: HomeResources.applicationDirectory.appendingPathComponent("res/json/products.json"))
        
        self.products = try! JSONDecoder.decoder.decode(ContiguousArray<IntraProduct>.self, from: data)
        self.cache = CachingInterface()
        self.tableView = .init()
        self.tableView.register(HomeFramingTableViewCell<ShopViewController.ProductView>.self,
                                forCellReuseIdentifier: "cell")
        self.tableView.contentInsetAdjustTopAndBottom()
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
                                                constant: HomeLayout.safeAeraMain.left).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,
                                                 constant: HomeLayout.safeAeraMain.right).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeFramingTableViewCell<ShopViewController.ProductView>
        
        cell.view.update(with: self.products[indexPath.row], cache: self.cache)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = self.products[indexPath.row]
        
        DynamicAlert(.none, contents: [.title(product.name), .text(product.productDescription)],
                     actions: [.normal(~"general.ok", nil)])
    }
    
    final private class ProductView: BasicUIView, HomeFramingTableViewCellView {
        static var edges: UIEdgeInsets = .init(top: HomeLayout.smargin, left: HomeLayout.margin,
                                               bottom: HomeLayout.smargin, right: HomeLayout.margin)
        
        private let titleLabel: CoalitionBackgroundWithParallaxLabel
        private let imageView: BasicUIImageView
        private let walletLabel: HomeInsetsLabel
        
        override init() {
            self.titleLabel = CoalitionBackgroundWithParallaxLabel(text: "???")
            self.titleLabel.font = HomeLayout.fontSemiBoldTitle
            self.titleLabel.numberOfLines = 0
            self.imageView = BasicUIImageView(image: nil)
            self.imageView.backgroundColor = HomeDesign.lightGray
            self.imageView.layer.masksToBounds = true
            self.walletLabel = .init(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.smargin))
            self.walletLabel.backgroundColor = HomeDesign.gold
            self.walletLabel.textColor = HomeDesign.white
            self.walletLabel.font = HomeLayout.fontBoldMedium
            self.walletLabel.layer.cornerRadius = HomeLayout.scorner
            self.walletLabel.layer.masksToBounds = true
            super.init()
            self.backgroundColor = HomeDesign.white
            self.layer.cornerRadius = HomeLayout.corner
            self.layer.masksToBounds = true
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.addSubview(self.titleLabel)
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
            self.addSubview(self.imageView)
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: HomeLayout.imageViewHeightRatio).isActive = true
            self.imageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor,
                                                constant: HomeLayout.smargin).isActive = true
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.imageView.addSubview(self.walletLabel)
            self.walletLabel.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor,
                                                       constant: -HomeLayout.smargin).isActive = true
            self.walletLabel.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor,
                                                     constant: -HomeLayout.smargin).isActive = true
        }
        
        private var product: IntraProduct!
        func update(with product: IntraProduct, cache: CachingInterface) {
            self.product = product
            self.titleLabel.text = product.name
            self.walletLabel.text = "\(product.price) ₳"
            if product.is_unic != nil && product.is_unic {
                self.layer.borderWidth = HomeLayout.border
                self.layer.borderColor = HomeDesign.gold.cgColor
            }
            else {
                self.layer.borderWidth = 0.0
            }
            cache.getImage(url: product.imageUrl, id: "\(product.id)", block: { id, image in
                DispatchQueue.main.async {
                    if "\(self.product.id)" == id {
                        self.imageView.image = image
                    }
                }
            })
        }
    }
}
