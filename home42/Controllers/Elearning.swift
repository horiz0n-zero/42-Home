// home42/Elearning.swift
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
import AVKit

final class ElearningViewController: HomeViewController, SearchFieldViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    private let scrollView: BasicUIScrollView
    private let pageControl: BasicUIPageControl
    
    private let notionView: BasicUIView
    private let searchField: SearchFieldViewWithTimer
    private let notionTableView: GenericSingleInfiniteRequestTableView<NotionTableViewCell, IntraNotion>
    
    private let subnotionView: BasicUIView
    private let subnotionTableView: BasicUITableView
    private var subnotions: ContiguousArray<IntraSubnotion>! = nil
    private var subnotionsParentNotion: IntraNotion! = nil
    private var attachments: Array<IntraAttachment>! = nil
    
    private let cache: CachingInterface
    
    required init() {
        self.scrollView = BasicUIScrollView()
        self.scrollView.isPagingEnabled = true
        self.pageControl = BasicUIPageControl()
        self.pageControl.pageIndicatorTintColor = HomeDesign.lightGray
        self.pageControl.currentPageIndicatorTintColor = HomeDesign.primary
        self.pageControl.backgroundStyle = .prominent
        self.pageControl.numberOfPages = 2
        self.pageControl.currentPage = 0
        self.pageControl.isUserInteractionEnabled = false
        self.notionView = BasicUIView()
        self.searchField = SearchFieldViewWithTimer()
        if App.userCursus != nil {
            self.notionTableView = .init(.cursusWithCursusIdNotions(App.userCursus.cursus_id), parameters: ["sort": "updated_at"])
        }
        else {
            self.notionTableView = .init(.notions, parameters: ["sort": "updated_at"])
        }
        self.subnotionView = BasicUIView()
        self.subnotionTableView = .init()
        self.subnotionTableView.backgroundColor = .clear
        self.subnotionTableView.register(NotionTableViewCell.self, forCellReuseIdentifier: "notion")
        self.subnotionTableView.register(SubnotionVideoCell.self, forCellReuseIdentifier: IntraAttachment.AttachmentType.video.rawValue)
        self.subnotionTableView.register(SubnotionPDFCell.self, forCellReuseIdentifier: IntraAttachment.AttachmentType.pdf.rawValue)
        self.subnotionTableView.register(SubnotionLinkCell.self, forCellReuseIdentifier: IntraAttachment.AttachmentType.link.rawValue)
        self.subnotionTableView.contentInsetAdjustTopConstant(HomeLayout.safeAeraMain.top + HomeLayout.smargin, bottom: HomeLayout.safeAera.bottom + 40.0)
        self.cache = CachingInterface()
        super.init()
        
        self.view.addSubview(self.scrollView)
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.scrollView.delegate = self
        self.view.addSubview(self.pageControl)
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.pageControl.trySettingCustomBlur(HomeDesign.blur)
        
        self.scrollView.addSubview(self.notionView)
        self.notionView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.notionView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.notionView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.notionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        self.notionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        self.notionView.addSubview(self.notionTableView)
        self.notionView.addSubview(self.searchField)
        self.searchField.delegate = self
        self.searchField.topAnchor.constraint(equalTo: self.notionView.topAnchor, constant: HomeLayout.safeAeraMain.top + HomeLayout.margin).isActive = true
        self.searchField.leadingAnchor.constraint(equalTo: self.notionView.leadingAnchor, constant: HomeLayout.safeAeraMain.left + HomeLayout.margin).isActive = true
        self.searchField.trailingAnchor.constraint(equalTo: self.notionView.trailingAnchor, constant: -(HomeLayout.safeAeraMain.left + HomeLayout.margin)).isActive = true
        self.notionTableView.leadingAnchor.constraint(equalTo: self.searchField.leadingAnchor).isActive = true
        self.notionTableView.trailingAnchor.constraint(equalTo: self.searchField.trailingAnchor).isActive = true
        self.notionTableView.topAnchor.constraint(equalTo: self.searchField.centerYAnchor).isActive = true
        self.notionTableView.bottomAnchor.constraint(equalTo: self.notionView.bottomAnchor).isActive = true
        self.notionTableView.contentInsetAdjustTopConstant(HomeLayout.roundedGenericActionsViewRadius + HomeLayout.smargin, bottom: HomeLayout.safeAera.bottom + 40.0)
        self.notionTableView.block = self.notionSelected(_:)
        self.notionTableView.backgroundColor = .clear
        Task(priority: .userInitiated, operation: {
            await self.notionTableView.nextPage()
        })
        
        self.scrollView.addSubview(self.subnotionView)
        self.subnotionView.leadingAnchor.constraint(equalTo: self.notionView.trailingAnchor).isActive = true
        self.subnotionView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.subnotionView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.subnotionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        self.subnotionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        self.subnotionView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        
        self.subnotionTableView.delegate = self
        self.subnotionTableView.dataSource = self
        self.subnotionView.addSubview(self.subnotionTableView)
        self.subnotionTableView.leadingAnchor.constraint(equalTo: self.subnotionView.leadingAnchor, constant: HomeLayout.safeAeraMain.left + HomeLayout.margin).isActive = true
        self.subnotionTableView.trailingAnchor.constraint(equalTo: self.subnotionView.trailingAnchor, constant: -(HomeLayout.safeAeraMain.left + HomeLayout.margin)).isActive = true
        self.subnotionTableView.topAnchor.constraint(equalTo: self.subnotionView.topAnchor).isActive = true
        self.subnotionTableView.bottomAnchor.constraint(equalTo: self.subnotionView.bottomAnchor).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newValue = self.pageControl.currentPage
        
        if scrollView.contentOffset.x < scrollView.bounds.width {
            self.pageControl.currentPage = 0
        }
        else {
            self.pageControl.currentPage = 1
        }
        if newValue != self.pageControl.currentPage && self.searchField.view.isFirstResponder {
            self.searchField.resignFirstResponder()
        }
    }
    
    private func scrollViewMove(at index: Int, animated: Bool) {
        let offset = UIScreen.main.bounds.width * CGFloat(index)
        
        self.scrollView.setContentOffset(.init(x: offset, y: 0.0), animated: animated)
        self.pageControl.currentPage = index
    }
    
    func searchFieldTextUpdated(_ searchField: SearchFieldView) {
        if searchField.text.count > 0 {
            self.notionTableView.restart(with: ["search[name]": searchField.text, "sort": "updated_at"])
        }
        else {
            self.notionTableView.restart(with: ["sort": "updated_at"])
        }
        print(#function, searchField.text)
    }
    func searchFieldBeginEditing(_ searchField: SearchFieldView) { }
    func searchFieldEndEditing(_ searchField: SearchFieldView) { }
    
    // MARK: -
    final private class NotionTableViewCell: BasicUITableViewCell, GenericSingleInfiniteRequestCell {
        
        private let container: BasicUIView
        private let titleLabel: BasicUILabel
        private let subnotionPreview: BasicUIView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.container = BasicUIView()
            self.container.backgroundColor = HomeDesign.white
            self.container.layer.cornerRadius = HomeLayout.corner
            self.titleLabel = BasicUILabel(text: "???")
            self.titleLabel.font = HomeLayout.fontSemiBoldTitle
            self.titleLabel.textColor = HomeDesign.black
            self.titleLabel.textAlignment = .left
            self.titleLabel.numberOfLines = 0
            self.subnotionPreview = BasicUIView()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else { return }
            self.contentView.addSubview(self.container)
            self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margin).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.container.addSubview(self.titleLabel)
            self.titleLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.smargin).isActive = true
            self.titleLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.container.addSubview(self.subnotionPreview)
            self.subnotionPreview.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.subnotionPreview.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.subnotionPreview.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: HomeLayout.margin).isActive = true
            self.subnotionPreview.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        final private class SubnotionLabel: BasicUILabel {
            
            override var intrinsicContentSize: CGSize {
                let originalSize = super.intrinsicContentSize
                
                return .init(width: originalSize.width + HomeLayout.margin, height: originalSize.height + HomeLayout.margin)
            }
            
            override init(text: String) {
                super.init(text: text)
                self.backgroundColor = HomeDesign.lightGray
                self.layer.cornerRadius = HomeLayout.scorner
                self.layer.masksToBounds = true
                self.font = HomeLayout.fontRegularMedium
                self.textColor = HomeDesign.primary
                self.textAlignment = .center
                self.numberOfLines = 0
            }
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            func emptyStyle() {
                self.textColor = HomeDesign.black
            }
        }
        
        func fill(with element: IntraNotion) {
            let stackView = BasicUIView()
            var top = stackView.topAnchor
            
            self.titleLabel.text = element.name
            for view in element.subnotions.count == 0 ? [SubnotionLabel(text: element.name)] : element.subnotions.map({ SubnotionLabel.init(text: $0.name) }) {
                stackView.addSubview(view)
                view.topAnchor.constraint(equalTo: top, constant: HomeLayout.smargin).isActive = true
                view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
                top = view.bottomAnchor
            }
            top.constraint(equalTo: stackView.bottomAnchor).isActive = true
            
            self.subnotionPreview.subviews.first?.removeFromSuperview()
            self.subnotionPreview.addSubview(stackView)
            stackView.topAnchor.constraint(equalTo: self.subnotionPreview.topAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: self.subnotionPreview.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.subnotionPreview.trailingAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.subnotionPreview.bottomAnchor).isActive = true
            self.contentView.layoutIfNeeded()
        }
        
        func update(with notion: IntraNotion, subnotions: ContiguousArray<IntraSubnotion>) {
            let stackView = BasicUIView()
            var top = stackView.topAnchor
            
            self.titleLabel.text = notion.name
            for (index, view) in notion.subnotions.map({ SubnotionLabel.init(text: $0.name) }).enumerated() {
                if index < subnotions.count && subnotions[index].attachments.count == 0 {
                    view.emptyStyle()
                }
                stackView.addSubview(view)
                view.topAnchor.constraint(equalTo: top, constant: HomeLayout.smargin).isActive = true
                view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
                top = view.bottomAnchor
            }
            top.constraint(equalTo: stackView.bottomAnchor).isActive = true
            
            self.subnotionPreview.subviews.first?.removeFromSuperview()
            self.subnotionPreview.addSubview(stackView)
            stackView.topAnchor.constraint(equalTo: self.subnotionPreview.topAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: self.subnotionPreview.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.subnotionPreview.trailingAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.subnotionPreview.bottomAnchor).isActive = true
            self.contentView.layoutIfNeeded()
        }
    }
    
    func notionSelected(_ notion: IntraNotion) {
        if self.searchField.view.isFirstResponder {
            self.searchField.resignFirstResponder()
        }
        if notion.subnotions.count == 0 {
            DynamicAlert.init(contents: [.title(notion.name), .text(~"elearning.empty-notion")], actions: [.normal(~"general.ok", nil)])
            return
        }
        Task.init(priority: .userInitiated, operation: {
            do {
                let subnotions: ContiguousArray<IntraSubnotion> = try await HomeApi.get(.notionsWithNotionIdSubnotions(notion.id))
                
                self.subnotions = subnotions
                self.subnotionsParentNotion = notion
                self.attachments = subnotions.map({ $0.attachments }).flatMap({ $0 })
                self.scrollViewMove(at: 1, animated: true)
                self.subnotionTableView.reloadData()
                self.subnotionTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            }
            catch {
                DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
            }
        })
    }
    
    private class SubnotionCell: BasicUITableViewCell {
        
        fileprivate let container: BasicUIView
        fileprivate let titleLabel: BasicUILabel
        private let typeLabel: HomeInsetsLabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.container = BasicUIView()
            self.container.backgroundColor = HomeDesign.white
            self.container.layer.cornerRadius = HomeLayout.corner
            self.titleLabel = BasicUILabel(text: "???")
            self.titleLabel.font = HomeLayout.fontSemiBoldMedium
            self.titleLabel.textColor = HomeDesign.black
            self.titleLabel.textAlignment = .left
            self.titleLabel.numberOfLines = 0
            self.typeLabel = .init(text: "???", inset: .init(width: HomeLayout.margin, height: HomeLayout.smargin))
            self.typeLabel.textColor = HomeDesign.white
            self.typeLabel.font = HomeLayout.fontSemiBoldMedium
            self.typeLabel.textAlignment = .center
            self.typeLabel.layer.cornerRadius = HomeLayout.scorner
            self.typeLabel.layer.masksToBounds = true
            self.typeLabel.backgroundColor = HomeDesign.primary
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            self.contentView.addSubview(self.container)
            self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: HomeLayout.margins).isActive = true
            self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.container.addSubview(self.titleLabel)
            self.titleLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.margin).isActive = true
            self.titleLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margin).isActive = true
            self.container.addSubview(self.typeLabel)
            self.typeLabel.centerYAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
            self.typeLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        }
        
        func update(with attachment: IntraAttachment) {
            self.titleLabel.text = attachment.name
            self.typeLabel.text = ~attachment.type.key
        }
    }
    private final class SubnotionVideoCell: SubnotionCell {
        
        private let videoImageView: BasicUIImageView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.videoImageView = BasicUIImageView(image: nil)
            self.videoImageView.backgroundColor = HomeDesign.gray
            self.videoImageView.layer.cornerRadius = HomeLayout.scorner
            self.videoImageView.layer.masksToBounds = true
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            super.willMove(toSuperview: newSuperview)
            self.container.addSubview(self.videoImageView)
            self.videoImageView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.videoImageView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.videoImageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.videoImageView.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.videoImageView.heightAnchor.constraint(equalTo: self.videoImageView.widthAnchor, multiplier: HomeLayout.imageViewHeightRatio).isActive = true
        }
        
        private unowned(unsafe) var attachment: IntraVideoAttachment!
        func update(with attachment: IntraVideoAttachment, cache: CachingInterface) {
            super.update(with: attachment)
            self.attachment = attachment
            self.videoImageView.image = nil
            if let thumb = attachment.videoUrls.thumbs.last {
                cache.getImage(url: thumb, id: "\(attachment.id)", block: { id, image in
                    if id == "\(self.attachment.id)" {
                        self.videoImageView.image = image
                    }
                })
            }
        }
    }
    private final class SubnotionPDFCell: SubnotionCell {
        
        private let pdfLinkLabel: BasicUILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.pdfLinkLabel = BasicUILabel(text: ~"general.open")
            self.pdfLinkLabel.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
            self.pdfLinkLabel.layer.cornerRadius = HomeLayout.scorner
            self.pdfLinkLabel.layer.masksToBounds = true
            self.pdfLinkLabel.textAlignment = .center
            self.pdfLinkLabel.textColor = HomeDesign.primary
            self.pdfLinkLabel.font = HomeLayout.fontBoldMedium
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.pdfLinkLabel.isUserInteractionEnabled = true
            self.pdfLinkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubnotionPDFCell.tapGesture)))
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            super.willMove(toSuperview: newSuperview)
            self.container.addSubview(self.pdfLinkLabel)
            self.pdfLinkLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.pdfLinkLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.pdfLinkLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.pdfLinkLabel.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
            self.pdfLinkLabel.heightAnchor.constraint(equalToConstant: HomeLayout.elearningSubnotionActionHeight).isActive = true
        }
        
        private unowned(unsafe) var pdfAttachment: IntraPDFAttachment! = nil
        func update(with attachment: IntraPDFAttachment) {
            self.pdfAttachment = attachment
            super.update(with: attachment)
        }
        
        @objc private func tapGesture() {
            guard let url = self.pdfAttachment.pdfUrl else {
                DynamicAlert(contents: [.title(~"elearning.incorrect-link"), .text(self.pdfAttachment.url)], actions: [.normal(~"general.ok", nil)])
                return
            }
            
            self.parentViewController?.present(SafariWebView(url), animated: true, completion: nil)
        }
    }
    private final class SubnotionLinkCell: SubnotionCell {
        
        private let openWebLink: BasicUILabel
        private let openWebLinkSafari: BasicUILabel
        private let copy: BasicUILabel

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.openWebLink = BasicUILabel(text: ~"openweb-link")
            self.openWebLink.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
            self.openWebLink.layer.cornerRadius = HomeLayout.scorner
            self.openWebLink.layer.masksToBounds = true
            self.openWebLink.textAlignment = .center
            self.openWebLink.textColor = HomeDesign.primary
            self.openWebLink.font = HomeLayout.fontBoldMedium
            self.openWebLinkSafari = BasicUILabel(text: ~"openweb-link-safari")
            self.openWebLinkSafari.backgroundColor = self.openWebLink.backgroundColor
            self.openWebLinkSafari.layer.cornerRadius = self.openWebLink.layer.cornerRadius
            self.openWebLinkSafari.layer.masksToBounds = self.openWebLink.layer.masksToBounds
            self.openWebLinkSafari.textAlignment = self.openWebLink.textAlignment
            self.openWebLinkSafari.textColor = self.openWebLink.textColor
            self.openWebLinkSafari.font = self.openWebLink.font
            self.copy = BasicUILabel(text: ~"general.copy")
            self.copy.backgroundColor = self.openWebLink.backgroundColor
            self.copy.layer.cornerRadius = self.openWebLink.layer.cornerRadius
            self.copy.layer.masksToBounds = self.openWebLink.layer.masksToBounds
            self.copy.textAlignment = self.openWebLink.textAlignment
            self.copy.textColor = self.openWebLink.textColor
            self.copy.font = self.openWebLink.font
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.openWebLink.isUserInteractionEnabled = true
            self.openWebLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubnotionLinkCell.tapGestureWebLink)))
            self.openWebLinkSafari.isUserInteractionEnabled = true
            self.openWebLinkSafari.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubnotionLinkCell.tapGestureWebLinkSafari)))
            self.copy.isUserInteractionEnabled = true
            self.copy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubnotionLinkCell.tapGestureCopy)))
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            super.willMove(toSuperview: newSuperview)
            self.container.addSubview(self.openWebLink)
            self.openWebLink.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.smargin).isActive = true
            self.openWebLink.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.smargin).isActive = true
            self.openWebLink.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.openWebLink.heightAnchor.constraint(equalToConstant: HomeLayout.elearningSubnotionActionHeight).isActive = true
            self.container.addSubview(self.openWebLinkSafari)
            self.openWebLinkSafari.leadingAnchor.constraint(equalTo: self.openWebLink.leadingAnchor).isActive = true
            self.openWebLinkSafari.trailingAnchor.constraint(equalTo: self.openWebLink.trailingAnchor).isActive = true
            self.openWebLinkSafari.topAnchor.constraint(equalTo: self.openWebLink.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.openWebLinkSafari.heightAnchor.constraint(equalToConstant: HomeLayout.elearningSubnotionActionHeight).isActive = true
            self.container.addSubview(self.copy)
            self.copy.leadingAnchor.constraint(equalTo: self.openWebLink.leadingAnchor).isActive = true
            self.copy.trailingAnchor.constraint(equalTo: self.openWebLink.trailingAnchor).isActive = true
            self.copy.topAnchor.constraint(equalTo: self.openWebLinkSafari.bottomAnchor, constant: HomeLayout.smargin).isActive = true
            self.copy.heightAnchor.constraint(equalToConstant: HomeLayout.elearningSubnotionActionHeight).isActive = true
            self.copy.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
        }
        
        private unowned(unsafe) var linkAttachment: IntraLinkAttachment!
        func update(with attachment: IntraLinkAttachment) {
            self.linkAttachment = attachment
            super.update(with: attachment)
        }
        
        @objc private func tapGestureWebLink() {
            self.parentViewController?.present(SafariWebView(self.linkAttachment.url.url), animated: true, completion: nil)
        }
        @objc private func tapGestureWebLinkSafari() {
            App.open(self.linkAttachment.url.url, options: [:], completionHandler: nil)
        }
        @objc private func tapGestureCopy() {
            UIPasteboard.general.string = self.linkAttachment.url
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.subnotionsParentNotion == nil ? 0 : 1
        default:
            return self.attachments?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "notion", for: indexPath) as! NotionTableViewCell
            
            cell.update(with: self.subnotionsParentNotion, subnotions: self.subnotions)
            return cell
        default:
            let attachment = self.attachments[indexPath.row]
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: attachment.type.rawValue, for: indexPath)
            
            switch attachment.type {
            case .video:
                unsafeDowncast(cell, to: SubnotionVideoCell.self).update(with: unsafeDowncast(attachment, to: IntraVideoAttachment.self), cache: self.cache)
            case .pdf:
                unsafeDowncast(cell, to: SubnotionPDFCell.self).update(with: unsafeDowncast(attachment, to: IntraPDFAttachment.self))
            case .link:
                unsafeDowncast(cell, to: SubnotionLinkCell.self).update(with: unsafeDowncast(attachment, to: IntraLinkAttachment.self))
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        func playVideo() {
            let video = self.attachments[indexPath.row] as! IntraVideoAttachment
            let source = video.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            guard let url = URL(string: source) else {
                DynamicAlert(contents: [.title(~"elearning.incorrect-link"), .text(source)],
                             actions: [.normal(~"general.ok", nil)])
                return
            }
            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            
            playerViewController.player = player
            playerViewController.allowsPictureInPicturePlayback = true
            self.present(playerViewController, animated: true) {
                player.play()
            }
        }
        
        if indexPath.section != 0 && self.attachments[indexPath.row].type == .video {
            playVideo()
        }
    }
}
