//
//  Donations.swift
//  home42
//
//  Created by Antoine Feuerstein on 02/05/2021.
//

import Foundation
import UIKit

final class DonationsViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource {
    
    private struct DonationData {
        let price: CGFloat
        let priceText: String
        let isHigh: Bool
    }
    static private let donationsData: [DonationData] = [
        .init(price: 0.99, priceText: "0.99", isHigh: false),
        .init(price: 1.99, priceText: "1.99", isHigh: false),
        .init(price: 4.99, priceText: "4.99", isHigh: false),
        .init(price: 9.99, priceText: "9.99", isHigh: false),
        .init(price: 19.99, priceText: "19.99", isHigh: false),
        .init(price: 49.99, priceText: "49.99", isHigh: true),
        .init(price: 99.99, priceText: "99.99", isHigh: true)
    ]
    
    private let header: DarkBlurHeaderWithActionsView
    private let tableView: BasicUITableView
    
    required init() {
        let infoView = ActionButtonView(asset: .actionInfo, color: HomeDesign.primary)
        
        self.header = DarkBlurHeaderWithActionsView(title: ~"SETTINGS_EXTRA_DONATIONS", actions: [infoView])
        self.tableView = BasicUITableView()
        super.init()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(self.tableView)
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.register(DonationCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.contentInsetAdjustTopConstant(HomeLayout.headerWithActionViewHeigth + App.safeAera.top + HomeLayout.margin, bottom: App.safeAera.bottom)
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DonationsViewController.infoTapped(sender:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    final private class DonationCell: BasicUITableViewCell {
        
        private let container: BasicUIView
        private let priceLabel: BasicUILabel
        private let particles: ParticlesEmitterView
        private let particlesGold: ParticlesEmitterView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.container = BasicUIView()
            self.container.layer.cornerRadius = HomeLayout.corner
            self.container.backgroundColor = HomeDesign.black
            self.container.layer.shadowColor = HomeDesign.gold.cgColor
            self.container.layer.shadowOpacity = Float(HomeDesign.alphaMiddle)
            self.container.layer.shadowRadius = HomeLayout.scorner
            self.container.layer.shadowOffset = .zero
            self.priceLabel = BasicUILabel()
            self.priceLabel.textColor = HomeDesign.white
            self.priceLabel.textAlignment = .center
            self.priceLabel.font = HomeLayout.fontSemiBoldTitle
            self.particles = .init(.stars)
            self.particlesGold = .init(.donationGoldStars)
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.contentView.backgroundColor = .clear
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            
            self.contentView.addSubview(self.particles)
            self.contentView.addSubview(self.particlesGold)
            self.contentView.addSubview(self.container)
            self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margins).isActive = true
            self.container.heightAnchor.constraint(equalToConstant: HomeLayout.donationCellHeight).isActive = true
            
            self.particles.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
            self.particles.bottomAnchor.constraint(equalTo: self.container.bottomAnchor).isActive = true
            self.particles.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
            self.particles.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
            self.particles.heightAnchor.constraint(equalTo: self.container.heightAnchor).isActive = true
            self.particles.widthAnchor.constraint(equalTo: self.container.widthAnchor).isActive = true
            self.particlesGold.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
            self.particlesGold.bottomAnchor.constraint(equalTo: self.container.bottomAnchor).isActive = true
            self.particlesGold.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
            self.particlesGold.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
            self.particlesGold.heightAnchor.constraint(equalTo: self.container.heightAnchor).isActive = true
            self.particlesGold.widthAnchor.constraint(equalTo: self.container.widthAnchor).isActive = true
            
            self.container.addSubview(self.priceLabel)
            self.priceLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.priceLabel.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.priceLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.priceLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        func update(with donation: DonationData) {
            self.priceLabel.text = donation.priceText
            if donation.isHigh {
                self.priceLabel.textColor = HomeDesign.gold
                self.particlesGold.particleLayer.play()
            }
            else {
                self.priceLabel.textColor = HomeDesign.white
                self.particlesGold.particleLayer.pause()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DonationsViewController.donationsData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DonationCell
        
        cell.update(with: DonationsViewController.donationsData[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let donation = DonationsViewController.donationsData[indexPath.row]
        
        DynamicAlert(.withPrimary(~"SETTINGS_EXTRA_DONATIONS", HomeDesign.gold),
                     contents: [.title(donation.priceText)], actions: [.normal(~"CANCEL", nil), .highligth(~"BUY", nil)]).setParticles(.alertStars)
    }
    
    @objc private func infoTapped(sender: UITapGestureRecognizer) {
        
    }
}
