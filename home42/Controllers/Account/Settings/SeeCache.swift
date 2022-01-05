//
//  SeeCache.swift
//  home42
//
//  Created by Antoine Feuerstein on 29/10/2021.
//

import Foundation
import UIKit
import SVGKit
import SwiftUI

typealias SeeCacheImagesViewController = SeeCacheViewController<UIImage, UIImageView>
typealias SeeCacheSVGsViewController = SeeCacheViewController<SVGKImage, SVGKFastImageView>

final class SeeCacheViewController<G, V: UIView>: HomeViewController, UICollectionViewDataSource, UICollectionViewDelegate where G: AnyObject {
    
    private let header: HeaderWithActionsView
    private let stateLabel: BasicUILabel
    private let separator: BasicUIView
    private let collectionView: BasicUICollectionView
    
    private let interface: StorageCachingInterface<G>
    private var info: StorageCachingInterface<G>.Info!
    private var files: [URL]!
    
    @frozen enum Style {
        case profil
        case landscapeCinema
        case square(count: CGFloat)
    }
    
    init(directory: HomeResources.DocumentDirectory, style: SeeCacheViewController.Style = .profil) {
        self.header = HeaderWithActionsView(title: directory.rawValue)
        self.stateLabel = BasicUILabel(text: ~"LOADING")
        self.stateLabel.textColor = HomeDesign.black
        self.stateLabel.textAlignment = .left
        self.stateLabel.adjustsFontSizeToFitWidth = true
        self.separator = BasicUIView()
        self.separator.backgroundColor = HomeDesign.primary
        self.collectionView = BasicUICollectionView(CollectionViewLayout(style: style))
        self.collectionView.backgroundColor = HomeDesign.white
        self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.contentInset = .init(top: 0.0, left: 0.0, bottom: App.safeAera.bottom + HomeLayout.smargin, right: 0.0)
        self.interface = StorageCachingInterface<G>.init(directory: directory)
        if directory.isSVG {
            Self.CollectionViewCell.swizzleImplementation(method: #selector(Self.CollectionViewCell.updateWith(_:)), with: #selector(Self.CollectionViewCell.updateWithSVGKImage(_:)))
        }
        else {
            Self.CollectionViewCell.swizzleImplementation(method: #selector(Self.CollectionViewCell.updateWith(_:)), with: #selector(Self.CollectionViewCell.updateWithUIImage(_:)))
        }
        super.init()
        self.view.backgroundColor = HomeDesign.white
        self.view.addSubview(self.header)
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.view.addSubview(self.stateLabel)
        self.stateLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: HomeLayout.margin).isActive = true
        self.stateLabel.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.smargin).isActive = true
        self.stateLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -HomeLayout.margin).isActive = true
        self.view.addSubview(self.separator)
        self.separator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.separator.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.separator.topAnchor.constraint(equalTo: self.stateLabel.bottomAnchor, constant: HomeLayout.smargin).isActive = true
        self.separator.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        self.view.addSubview(self.collectionView)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.topAnchor.constraint(equalTo: self.separator.bottomAnchor).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: self.separator.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.separator.trailingAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        Task.init(priority: .userInitiated, operation: {
            
            @MainActor func errorOccured(_ error: Error) {
                DynamicAlert(contents: [.text(~"SEE_CACHE_ERROR"), .text(error.localizedDescription)], actions: [.normal(~"OK", nil)])
                self.dismiss(animated: true, completion: nil)
            }
            @MainActor func update() {
                self.stateLabel.text = String(format: ~"SEE_CACHE_INFO", self.files.count, self.info.memoryFootprint)
                self.collectionView.reloadData()
            }
            
            do {
                self.info = try self.interface.allFilesInfo()
                self.files = try self.interface.allFilesName()
                HomeResources.seeCacheFilesCount = self.files.count
                HomeResources.seeCacheDirectory = directory
                update()
            }
            catch {
                errorOccured(error)
            }
        })
    }
    required init() { fatalError("init() has not been implemented") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit {
        self.interface.clearCache()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.files?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.updateWith(self.files[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let value = (collectionView.cellForItem(at: indexPath) as! CollectionViewCell).value {
            ContentPreview(value: value)
        }
    }
    
    final class CollectionViewCell: BasicUICollectionViewCell {
        
        private let view: V
        var value: G? {
            switch self.view {
            case let imageView as UIImageView where imageView.image != nil:
                return unsafeDowncast(imageView.image!, to: G.self)
            case let svgImageView as SVGKFastImageView where svgImageView.image != nil:
                return unsafeDowncast(svgImageView.image, to: G.self)
            default:
                return nil
            }
        }
        
        override init(frame: CGRect) {
            self.view = V(frame: frame)
            super.init(frame: frame)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            guard newSuperview != nil else {
                return
            }
            
            self.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.contentMode = .scaleAspectFill
            self.contentView.addSubview(self.view)
            self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.contentView.layer.cornerRadius = HomeLayout.scorner
            self.contentView.layer.masksToBounds = true
        }
        @objc dynamic func updateWith(_ url: URL) {
            self.contentView.backgroundColor = HomeDesign.gold
        }
        
        @objc dynamic func updateWithUIImage(_ url: URL) {
            self.contentView.backgroundColor = HomeDesign.lightGray
            (self.view as! UIImageView).image = nil
            Task.detached(priority: .userInitiated, operation: {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    @MainActor func setImage(_ image: UIImage) {
                        HomeAnimations.transitionQuick(withView: self.view, {
                            (self.view as! UIImageView).image = image
                        }, completion: nil)
                    }
                    await setImage(image)
                }
                else {
                    @MainActor func errorOccured() {
                        self.contentView.backgroundColor = HomeDesign.redError
                        #if DEBUG
                        print(#function, url.lastPathComponent)
                        #endif
                    }
                    await errorOccured()
                }
            })
        }
        
        @objc dynamic func updateWithSVGKImage(_ url: URL) {
            self.contentView.backgroundColor = HomeDesign.lightGray
            (self.view as! SVGKFastImageView).image = nil
            Task.detached(priority: .userInitiated, operation: {
                if let data = try? Data(contentsOf: url), let image = SVGKImage(data: data) {
                    @MainActor func setImage(_ image: SVGKImage) {
                        //HomeAnimations.transitionQuick(withView: self.view, {
                            (self.view as! SVGKFastImageView).image = image
                        //}, completion: nil)
                    }
                    await setImage(image)
                }
                else {
                    @MainActor func errorOccured() {
                        self.contentView.backgroundColor = HomeDesign.redError
                        #if DEBUG
                        print(#function, url.lastPathComponent)
                        #endif
                    }
                    await errorOccured()
                }
            })
        }
    }
}

private extension SeeCacheViewController {
    
    final class CollectionViewLayout: UICollectionViewFlowLayout {
        
        private let style: SeeCacheViewController.Style
        
        init(style: SeeCacheViewController.Style) {
            self.style = style
            super.init()
        }
        required init?(coder: NSCoder) { fatalError("nirvana - smell like teen spirits") }
        
        override func prepare() {
            super.prepare()
            
            func configRects(count: CGFloat, ratio: CGFloat) {
                let margin = HomeLayout.margin
                let width = (UIScreen.main.bounds.width - margin * (2 + count - 1)) / count
                let height = width * ratio
                
                self.itemSize = CGSize(width: width, height: height)
                self.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
                self.sectionInsetReference = .fromContentInset
                self.minimumLineSpacing = margin
                self.minimumInteritemSpacing = margin
            }
            
            switch self.style {
            case .profil:
                configRects(count: 5.0, ratio: 1.33)
            case .landscapeCinema:
                let margin = HomeLayout.margin
                let width = UIScreen.main.bounds.width - margin * 2.0
                let height = width * HomeLayout.imageViewHeightRatio
                
                self.itemSize = CGSize(width: width, height: height)
                self.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
                self.sectionInsetReference = .fromContentInset
                self.minimumLineSpacing = margin
                self.minimumInteritemSpacing = margin
            case .square(let count):
                configRects(count: count, ratio: 1.0)
            }
        }
    }
}

private extension SeeCacheViewController {
    
    final class ContentPreview: DynamicController, UIScrollViewDelegate {
        
        private let scrollView: BasicUIScrollView
        private let scrollViewContent: V
        
        @discardableResult init(value: G) {
            let valueSize: CGSize
            
            self.scrollView = BasicUIScrollView()
            self.scrollViewContent = V.init(frame: .zero)
            self.scrollViewContent.translatesAutoresizingMaskIntoConstraints = false
            self.scrollViewContent.contentMode = .scaleAspectFill
            self.scrollViewContent.layer.cornerRadius = HomeLayout.corner
            self.scrollViewContent.layer.masksToBounds = true
            switch value.self {
            case is UIImage:
                (self.scrollViewContent as! UIImageView).image = unsafeDowncast(value, to: UIImage.self)
                valueSize = (self.scrollViewContent as! UIImageView).image!.size
            case is SVGKImage:
                (self.scrollViewContent as! SVGKFastImageView).image = unsafeDowncast(value, to: SVGKImage.self)
                valueSize = (self.scrollViewContent as! SVGKFastImageView).image.size
            default:
                fatalError()
            }
            super.init()
            self.scrollView.minimumZoomScale = 1.0
            self.scrollView.maximumZoomScale = 15.0
            self.scrollView.zoomScale = 1.0
            self.scrollView.isScrollEnabled = true
            self.scrollView.delegate = self
            self.scrollView.contentInset = .init(top: App.safeAera.top + HomeLayout.margin, left: 0.0, bottom: HomeLayout.margin + App.safeAera.bottom, right: 0.0)
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(ContentPreview.tapGesture(sender:))))
            self.view.addSubview(self.scrollView)
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.scrollView.addSubview(self.scrollViewContent)
            self.scrollViewContent.topAnchor.constraint(greaterThanOrEqualTo: self.scrollView.topAnchor).isActive = true
            self.scrollViewContent.bottomAnchor.constraint(greaterThanOrEqualTo: self.scrollView.bottomAnchor).isActive = true
            self.scrollViewContent.leadingAnchor.constraint(greaterThanOrEqualTo: self.scrollView.leadingAnchor).isActive = true
            self.scrollViewContent.trailingAnchor.constraint(greaterThanOrEqualTo: self.scrollView.trailingAnchor).isActive = true
            self.scrollViewContent.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
            self.scrollViewContent.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor).isActive = true
            self.scrollViewContent.heightAnchor.constraint(equalToConstant: valueSize.height).isActive = true
            self.scrollViewContent.widthAnchor.constraint(equalToConstant: valueSize.width).isActive = true
            self.present()
        }
        required init() { fatalError("init() has not been implemented") }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return self.scrollViewContent
        }
        
        @objc private func tapGesture(sender: UITapGestureRecognizer) {
            self.remove()
        }
        override func present() {
            self.scrollView.alpha = 0.0
            if let backgroundPrimary = self.backgroundPrimary {
                backgroundPrimary.alpha = 0.0
                backgroundPrimary.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLow)
            }
            super.present()
            HomeAnimations.animateShort({
                self.scrollView.alpha = 1.0
                self.background.effect = HomeDesign.blur
                if let backgroundPrimary = self.backgroundPrimary {
                    backgroundPrimary.alpha = 1.0
                }
            })
        }
        override func remove(isFinish: Bool = true) {
            HomeAnimations.animateShort({
                self.scrollView.alpha = 0.0
                self.background.effect = nil
                if let backgroundPrimary = self.backgroundPrimary {
                    backgroundPrimary.alpha = 0.0
                }
            }, completion: super.remove(isFinish:))
        }
    }
}
