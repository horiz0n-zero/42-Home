//
//  Unused.swift
//  home42
//
//  Created by Antoine Feuerstein on 29/11/2021.
//

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
 */
