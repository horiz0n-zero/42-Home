
/* > DynamicAlert */
/*
 
    case sync(() -> ())
    case .sync(let completion):
     let syncView = SyncApiResourcesView(completion: completion, alert: self)
     
     contentView.addSubview(syncView)
     syncView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HomeLayout.margins).isActive = true
     syncView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HomeLayout.margins).isActive = true
     syncView.topAnchor.constraint(equalTo: topAnchor, constant: HomeLayout.margins).isActive = true
     topAnchor = syncView.bottomAnchor
 
  @Sendable static func sync() async throws {
      if let lastUpdate: Date = HomeDefaults.read(.syncLastUpdate), lastUpdate > Date() {
          return
      }
      return try await withUnsafeThrowingContinuation { continuation in
          DispatchQueue.main.async {
              let completion: () -> () = {
                  HomeDefaults.save(Date().dateByAdding(7, .day).date, forKey: .syncLastUpdate)
                  continuation.resume()
              }
              
              DynamicAlert(.primary(~"UPDATING"), contents: [.sync(completion)], actions: [])
          }
      }
  }
  
     final class SyncApiResourcesView: BasicUIView {
         
         private let completion: () -> ()
         private let views: [SyncApiResourcesView.SingleView]
         private let dynamicAlert: DynamicAlert
         
         init(completion: @escaping () -> (), alert: DynamicAlert) {
             self.completion = completion
             self.views = Query.texts.map({ SingleView(text: $0) })
             self.dynamicAlert = alert
             super.init()
         }
         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
                 
         @frozen private enum Query: Int, CaseIterable {
             case blocs = 0
             case campus
             case skills
             
             static var texts: [String] = Query.allCases.map({ "/" + ($0.route.path as NSString).lastPathComponent })
             
             var route: HomeApi.Routes {
                 switch self {
                 case .blocs:
                     return HomeApi.Routes.blocs
                 case .campus:
                     return HomeApi.Routes.campus
                 case .skills:
                     return HomeApi.Routes.skills
                 }
             }
         }
         private var currentQuery: Query! = .blocs
         
         private func nextQuery() async {
             guard let query = self.currentQuery else {
                 self.completion()
                 self.dynamicAlert.remove()
                 return
             }
             switch query {
             case .blocs:
                 HomeApiResources.blocs = await self.views[query.rawValue].startReceive(query: query)
             case .campus:
                 HomeApiResources.campus = await self.views[query.rawValue].startReceive(query: query)
             case .skills:
                 HomeApiResources.skills = await self.views[query.rawValue].startReceive(query: query)
             }
             self.currentQuery = Query(rawValue: query.rawValue &+ 1)
         }
         
         private final class SingleView: BasicUIView {
             
             private let indicator: ActionWebDataActivityIndicatorButtonView
             private let label: BasicUILabel
             
             init(text: String) {
                 self.indicator = ActionWebDataActivityIndicatorButtonView()
                 self.label = BasicUILabel(text: text)
                 self.label.textColor = HomeDesign.black
                 self.label.font = HomeLayout.fontThinTitle
                 super.init()
                 self.layer.cornerRadius = HomeLayout.corner
                 self.backgroundColor = HomeDesign.grayLayer
                 self.indicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(indicatorTapped(sender:))))
             }
             required init?(coder: NSCoder) {
                 fatalError("init(coder:) has not been implemented")
             }
             
             override func willMove(toSuperview newSuperview: UIView?) {
               
                 self.addSubview(self.indicator)
                 self.indicator.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.smargin).isActive = true
                 self.indicator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.margin).isActive = true
                 self.indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.smargin).isActive = true
                 self.addSubview(self.label)
                 self.label.leadingAnchor.constraint(equalTo: self.indicator.trailingAnchor, constant: HomeLayout.margin).isActive = true
                 self.label.centerYAnchor.constraint(equalTo: self.indicator.centerYAnchor).isActive = true
                 self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.margin).isActive = true
             }
             
             @objc private func indicatorTapped(sender: UITapGestureRecognizer) {
                 let parent: SyncApiResourcesView = self.parent()!
                 
                 if self.indicator.state == .errorOccurred {
                     if parent.currentQuery == nil {
                         parent.currentQuery = Query.allCases.last
                     }
                     else {
                         parent.currentQuery = Query(rawValue: parent.currentQuery.rawValue &- 1) ?? parent.currentQuery
                     }
                     Task.init(priority: .userInitiated, operation: {
                         await parent.nextQuery()
                     })
                 }
             }
             
             @MainActor func startReceive<G: IntraObject>(query: Query) async -> ContiguousArray<G>? {
                 let route = query.route
                 var array: ContiguousArray<G> = []
                 unowned(unsafe) let parent: SyncApiResourcesView = self.parent()!
                 
                 self.indicator.state = .inProgress
                 do {
                     for try await elements in HomeApi.RequestSequence<G>.init(route: route, parameters: nil) {
                         array.append(contentsOf: elements)
                     }
                     self.indicator.state = .done
                     HomeAnimations.animateQuick({
                         self.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
                     }, completion: nil)
                     Task.init(priority: .userInitiated, operation: {
                         await parent.nextQuery()
                     })
                     return array
                 }
                 catch {
                     self.indicator.state = .errorOccurred
                     DynamicAlert.presentWith(error: error as! HomeApi.RequestError)
                     return nil
                 }
             }
         }
         
         override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
         
             var top = self.topAnchor
             
             for singleView in self.views {
                 self.addSubview(singleView)
                 singleView.topAnchor.constraint(equalTo: top, constant: HomeLayout.smargin).isActive = true
                 singleView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                 singleView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                 top = singleView.bottomAnchor
             }
             self.bottomAnchor.constraint(equalTo: top, constant: HomeLayout.margind).isActive = true
             Task.init(priority: .userInitiated, operation: {
                 await self.nextQuery()
             })
         }
     }
 
    settings scroll bar
 final private class ScrollBar: BasicUIView {
     
     unowned(unsafe) var settingsViewController: SettingsViewController!
     private let stackView: BasicUIStackView
     private let offsetView: BasicUIView
     private var offsetViewTop: NSLayoutConstraint!
     private var offsetViewHeight: NSLayoutConstraint!
     
     override init() {
         self.stackView = BasicUIStackView()
         self.stackView.axis = .vertical
         self.stackView.distribution = .equalSpacing
         self.stackView.alignment = .center
         self.offsetView = BasicUIView()
         self.offsetView.backgroundColor = HomeDesign.primary.withAlphaComponent(HomeDesign.alphaLowLayer)
         self.offsetView.layer.cornerRadius = HomeLayout.scorner
         super.init()
     }
     required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
     
     final private class SelectionView: BasicUIImageView {
         
         let section: SettingsViewController.Section
         
         init(_ section: SettingsViewController.Section) {
             self.section = section
             super.init(asset: section.icon)
             self.layer.cornerRadius = HomeLayout.scorner
             self.contentMode = .scaleAspectFit
         }
         required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
         
         override func willMove(toSuperview newSuperview: UIView?) {
             guard newSuperview != nil else { return }
             
             self.heightAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
             self.widthAnchor.constraint(equalToConstant: HomeLayout.smallActionButtonSize).isActive = true
         }
         
         func selectedStyle() {
             self.backgroundColor = HomeDesign.primary
             self.tintColor = HomeDesign.white
         }
         func unselectedStyle() {
             self.backgroundColor = HomeDesign.lightGray
             self.tintColor = HomeDesign.primary
         }
     }
     
     override func willMove(toSuperview newSuperview: UIView?) {
         guard newSuperview != nil else { return }
         
         self.addSubview(self.offsetView)
         self.offsetViewTop = self.offsetView.topAnchor.constraint(equalTo: self.topAnchor)
         self.offsetViewTop.isActive = true
         self.offsetViewHeight = self.offsetView.heightAnchor.constraint(equalToConstant: 42.0)
         self.offsetViewHeight.isActive = true
         self.offsetView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: HomeLayout.dmargin).isActive = true
         self.offsetView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -HomeLayout.dmargin).isActive = true
         self.addSubview(self.stackView)
         self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: HomeLayout.margin).isActive = true
         self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
         self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
         self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -HomeLayout.margin).isActive = true
         for selectionView in SettingsViewController.sections.map({ SelectionView($0) }) {
             selectionView.isUserInteractionEnabled = true
             selectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScrollBar.selectionViewTapped(sender:))))
             selectionView.unselectedStyle()
             self.stackView.addArrangedSubview(selectionView)
         }
         self.widthAnchor.constraint(equalToConstant: HomeLayout.leftCurvedTitleViewHeigth).isActive = true
     }
     
     @objc private func selectionViewTapped(sender: UITapGestureRecognizer) {
         let selectionView = (sender.view as! SelectionView)
         let index = SettingsViewController.sections.firstIndex(where: { $0.titleKey == selectionView.section.titleKey }) ?? 0
         
         selectionView.selectedStyle()
         self.settingsViewController.tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
     }
     
     func update(with scrollView: UIScrollView) {
         /*self.offsetViewHeight.constant = scrollView.contentSize.height / scrollView.frame.height
         self.offsetViewTop.constant = scrollView.contentSize.height / scrollView.contentOffset.y
         self.layoutIfNeeded()
         print(self.offsetViewHeight.constant, self.offsetViewTop.constant)
         print(scrollView.contentSize.height / scrollView.frame.height)
         print(scrollView.contentSize.height / scrollView.contentOffset.y)*/
     }
 }
 
 final class DonationsViewController: HomeViewController, UITableViewDelegate, UITableViewDataSource {
     
     private struct SubscriptionData {
         let asset: UIImage.Assets
         let title: String
         let id: String
     }
     static private let subscriptionData: [SubscriptionData] = [
         .init(asset: .controllerTracker, title: "title.tracker", id: "com.horiz0n-zero.home42.subscriptions.tracker"),
         .init(asset: .controllerCorrections, title: "title.corrections", id: "com.horiz0n-zero.home42.subscriptions.corrections")
     ]
     
     private let header: DarkBlurHeaderWithActionsView
     private let tableView: BasicUITableView
     
     required init() {
         let infoView = ActionButtonView(asset: .actionInfo, color: HomeDesign.primary)
         
         self.header = DarkBlurHeaderWithActionsView(title: ~"settings.extra.subscriptions", actions: [infoView])
         self.tableView = BasicUITableView()
         super.init()
         self.view.backgroundColor = HomeDesign.black
         self.view.addSubview(self.tableView)
         self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
         self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
         self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
         self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
         self.tableView.register(SubscriptionCell.self, forCellReuseIdentifier: "cell")
         self.tableView.delegate = self
         self.tableView.dataSource = self
         self.tableView.backgroundColor = .clear
         self.tableView.contentInsetAdjustTopConstant(HomeLayout.headerWithActionViewHeigth + HomeLayout.safeAera.top + HomeLayout.margin, bottom: HomeLayout.safeAera.bottom)
         self.view.addSubview(self.header)
         self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
         self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
         self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
         infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DonationsViewController.infoTapped(sender:))))
         Task.init(priority: .userInitiated, operation: {
             do {
                 try await self.getProducts()
             }
             catch {
                 print(error.localizedDescription)
                 dump(error)
             }
         })
     }
     required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
     
     @MainActor private func getProducts() async throws {
         let productsId: [String] = DonationsViewController.subscriptionData.map(\.id)
         let products = try await Product.products(for: productsId)
         
         for product in products {
             dump(product)
         }
         print(#function, "ended")
     }
     
     final private class SubscriptionCell: BasicUITableViewCell {
         
         private let container: BasicUIView
         private let header: LeftCurvedTitleView
         private let icon: BasicUIImageView
         private let title: BasicUILabel
         
         override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
             self.container = BasicUIView()
             self.container.layer.cornerRadius = HomeLayout.corner
             self.container.backgroundColor = HomeDesign.blackGray
             self.container.layer.borderWidth = HomeLayout.border
             self.container.layer.borderColor = HomeDesign.gold.cgColor
             self.header = LeftCurvedTitleView(text: "???", primaryColor: HomeDesign.gold, addTopCorner: true)
             self.icon = BasicUIImageView(asset: .controllerMystere)
             self.icon.tintColor = HomeDesign.gold
             self.icon.backgroundColor = UIColor.black
             self.icon.layer.cornerRadius = HomeLayout.scorner
             self.icon.layer.shadowColor = HomeDesign.gold.cgColor
             self.icon.layer.shadowOpacity = Float(HomeDesign.alphaLow)
             self.icon.layer.shadowRadius = HomeLayout.dcorner
             self.icon.layer.shadowOffset = .zero
             self.title = BasicUILabel(text: "???")
             self.title.textColor = HomeDesign.white
             self.title.textAlignment = .left
             self.title.font = HomeLayout.fontSemiBoldMedium
             super.init(style: style, reuseIdentifier: reuseIdentifier)
             self.contentView.backgroundColor = .clear
         }
         required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
         
         override func willMove(toSuperview newSuperview: UIView?) {
             guard newSuperview != nil else { return }
             
             self.contentView.addSubview(self.container)
             self.container.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: HomeLayout.margin).isActive = true
             self.container.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -HomeLayout.margin).isActive = true
             self.container.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
             self.container.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -HomeLayout.margind).isActive = true
             
             self.container.addSubview(self.header)
             self.header.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
             self.header.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
             self.header.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
             
             self.container.addSubview(self.icon)
             self.icon.heightAnchor.constraint(equalToConstant: HomeLayout.mainSelectionSize).isActive = true
             self.icon.widthAnchor.constraint(equalToConstant: HomeLayout.mainSelectionSize).isActive = true
             self.icon.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: HomeLayout.margin).isActive = true
             self.icon.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: HomeLayout.margin).isActive = true
             
             self.container.addSubview(self.title)
             self.title.leadingAnchor.constraint(equalTo: self.icon.trailingAnchor, constant: HomeLayout.margin).isActive = true
             self.title.topAnchor.constraint(equalTo: self.icon.topAnchor).isActive = true
             self.title.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -HomeLayout.margin).isActive = true
             
             self.icon.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: -HomeLayout.margin).isActive = true
         }
         
         func update(with subscription: SubscriptionData) {
             self.header.update(with: ~subscription.title, primaryColor: HomeDesign.gold)
             self.icon.image = subscription.asset.image
             self.title.text = ~subscription.title
         }
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return DonationsViewController.subscriptionData.count
     }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SubscriptionCell
         
         cell.update(with: DonationsViewController.subscriptionData[indexPath.row])
         return cell
     }
     
     @objc private func infoTapped(sender: UITapGestureRecognizer) {
         
     }
 }
 @available(*, deprecated)
 @propertyWrapper struct LazySVGKImageGetter {
     
     private let url: URL
     
     lazy var wrappedValue: SVGKImage = {
         return SVGKImage(contentsOf: self.url)!
     }()
     
     init(location: String) {
         self.url = HomeResources.applicationDirectory.appendingPathComponent(location)
     }
 }
 */
