//
//  DQMenuViewController.swift
//  manzhanmiao
//
//  Created by dq on 2018/10/17.
//  Copyright © 2018 dq. All rights reserved.
//

import UIKit

@objc protocol DQMenuViewControllerDelegate: class {
    
    /// 页面切换
    ///
    /// - Parameters:
    ///   - containerView: 页面容器
    ///   - page: 当前显示页面
    ///   - isFirstScrollToIt: 该页面是否是第一次显示（不管有没有数据）
    @objc func scrollContainerView(containerView: DQMenuViewController, scrollAt page: Int, isFirstScrollToIt: Bool)
}

private let defaultSelectedPage = 0

class DQMenuViewController: UIViewController {
    
    // 单独为会话列表的聊天cell设置
    var isScrollViewScrollEnable = true {
        didSet {
            scrollView.isScrollEnabled = isScrollViewScrollEnable
        }
    }
    
    
    weak var delegate: DQMenuViewControllerDelegate?
    
    // MARK: - Designated init
    
    init(frame: CGRect,
         titles: [String],
         viewItems: [UIViewController],
         managerController: UIViewController) {
        
        super.init(nibName: nil, bundle: nil)
        
        if titles.count != viewItems.count {
            fatalError("itles.count != viewItems.count")
        }
        
        
        self.menuTitles = titles
        self.viewItems = viewItems
        self.managerController = managerController
        
        for _ in 0..<viewItems.count {
            hasShowPages.append(false)
        }
    }
        
    /// 配置UI显示（必须调用）
    /// - Parameter isTitleViewStyle: 是否标题模式（在navigationItem上切换）
    /// - Parameter useSeperateLine: 滑动标题和内容之间是否添加分割线
    /// - Parameter useBadge: 是否使用小红点文字显示数目（红点+文字）
    /// - Parameter isRedPoint: 是否使用小红点标示有新内容（红点）
    func configureContainerUI(isTitleViewStyle: Bool = false,
                              useSeperateLine: Bool = false,
                              useBadge: Bool = false,
                              isRedPoint: Bool = false) {
        
        self.useSeperateLine = useSeperateLine
        self.isTitleViewStyle = isTitleViewStyle
        self.useBadge = useBadge
        self.isRedPoint = isRedPoint
        
        addAllSubView()
        setupConstraints()
        resetSubviewsLayoutIfNeeded()
        firstLoadDataNotification()
        configureTitleLabelColor()
        
        useYellowStyle()
        
        useCatTitleMark = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 隐藏在某个位置标题UI
    func updateTitleUIAt(_ index: Int, isHide: Bool) {
        if titleLabels.count > index {
            titleLabels[index].alpha = isHide ? 0 : 1
            titleMarkImageViews[index].alpha = isHide ? 0 : 1
        }
    }
        
    private var isTitleViewStyle = false
    private weak var managerController: UIViewController!
    
    // MARK: - Public properties
    
    /// Default offset page for container ... set after configureContainerUI()
    var defaultOffsetPage = defaultSelectedPage {
        didSet {
            if defaultOffsetPage >= viewItems.count {
                fatalError("The defaultOffsetPage property must be less than viewItems.count")
            } else {
                userDefaultOffsetPage = true
                lastIndex = defaultOffsetPage
            }
            showTitleImageMarkAt(defaultOffsetPage)
        }
        
    }
    
    /// 是否使用标题的小猫头, 主要是为了据点
    var useCatTitleMark = false {
        didSet {
            for imageView in titleMarkImageViews {
                imageView.isHidden = !useCatTitleMark
            }
            showTitleImageMarkAt(defaultOffsetPage)
        }
    }
    
    /// Menu view height
    var menuViewHeight: CGFloat = 44 {
        didSet {
            //            print("set menuViewHeight")
            menuHeight?.isActive = false
            menuHeight = actionMenuView.heightAnchor.constraint(equalToConstant: menuViewHeight)
            menuHeight?.isActive = true
        }
    }
    
    /// Menu view background color
    var menuTitleViewBackgroundColor =  UIColor.hexStringColor(hex: "#F6F7F9") {
        didSet {
            //            print("set menuTitleViewColor")
            menuTitleView?.backgroundColor = menuTitleViewBackgroundColor
        }
    }
    
    /// Unselected button item text color
    var unselectedItemColor = UIColor.hexStringColor(hex: "666666") {
        didSet {
            //            print("set unselectedItemColor")
        }
    }
    
    /// Selected button item text color
    var selectedItemColor = UIColor.black {
        didSet {
            //            print("set selectedItemColor")
            
            // Prevent the order is not right when set public properties value
            lastIndex = defaultOffsetPage
        }
    }
    
    // 测试了不是titleViewStyle的表现形式
    func configureTitleLabelColor() {
        for i in 0..<titleLabels.count {
            titleLabels[i].textColor = (i == defaultOffsetPage) ? selectedItemColor : unselectedItemColor
        }
    }
    
    /// Button item font（统一字体设置）
    var itemFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            //            print("set itemFont")
            for title in titleLabels {
                title.font = itemFont
            }
        }
    }
    
    /// titleView style 选中的字体状态
    var selectedItemFont = UIFont.boldSystemFont(ofSize: 17) {
        didSet {
            //            print("set itemFont")
            for title in titleLabels {
                title.font = itemFont
            }
        }
    }
    
    /// titleView style 的未选中的字体状态
    var unselectedItemFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            //            print("set itemFont")
            for title in titleLabels {
                title.font = itemFont
            }
        }
    }
    
    
    /// Indicator color
    var indicatorColor = UIColor.black {
        didSet {
            //            print("set indicatorColor")
            indicatorView?.backgroundColor = indicatorColor
        }
    }
    
    /// 滚动条是黄色的
    func useYellowStyle() {
        indicatorColor = UIColor.hexStringColor(hex: "#FFE249")
        selectedItemColor = UIColor.hexStringColor(hex: "#202437")
        unselectedItemColor = UIColor.hexStringColor(hex: "#797E8B")
    }
    
    /// Indicator view width, value within (0 , screenWidth/viewItems.count)
    var indicatorWidth: CGFloat = 13 {
        didSet {
            //            print("set indicatorWidth")
            indicatorView?.frame.size.width = indicatorWidth
        }
    }
    
    /// Indicator view height, value within (0 , realTitleBottomMargin]
    var indicatorHeight: CGFloat = 3 {
        didSet {
            //            print("set indicatorHeight")
            indicatorView?.frame.size.height = indicatorHeight
            
            indicatorView?.layer.cornerRadius = indicatorHeight/2
            indicatorView?.layer.masksToBounds = true
        }
    }
    
    
    /// [index: value], 红点显示
    var showRedBadgeValues: [Int: Int] = [:] {
        didSet {
            for (index, value) in showRedBadgeValues {
                if index < redBadgeLabels.count && useBadge { // Not out if bounds
                    redBadgeLabels[index].isHidden = value == 0 // 数目为0不显示，>0显示
                    
                    if !isRedPoint {
                        redBadgeLabels[index].text = "\(value)"
                    }
                }
            }
        }
    }
    
    var shouldHideBadgeIndex: Int = 0 {
        didSet {
            if shouldHideBadgeIndex < redBadgeLabels.count {
                redBadgeLabels[shouldHideBadgeIndex].isHidden = true
            }
        }
    }
    
    
    // MARK: - Private properties
    
    private var titleViews: [UIView] = []
    private var redBadgeLabels: [UILabel] = []  // 是小红点的情况就不显示小红点文字了
    private var titleLabels: [UILabel] = []
    private var titleMarkImageViews: [UIImageView] = []  // 标题猫头

    private var buttonItems: [UIButton] = []
    private var viewItems: [UIViewController] = []
    private var useSeperateLine = false
    private var useBadge = false
    private var isRedPoint = false
    
    private let seperateLineHeight: CGFloat = 0.5
    
    private var actionMenuView: UIView!
    private var scrollView: UIScrollView!
    private var menuTitleView: UIView!
    private var titleStackView: UIStackView!
    private var indicatorView: UIView!
    
    private var menuHeight: NSLayoutConstraint!
    private var menuTitles: [String] = [String]()
    private var indicatorOriginsX: [CGFloat] = [CGFloat]()
    private var itemsViewFrameOriginX: [CGFloat] = [CGFloat]()
    
    private var indicatorViewLastOriginX: CGFloat = 0.0
    private var scale: CGFloat!
    private var userDefaultOffsetPage = false
    
    private let moveDuration: TimeInterval = 0.2
    private let realTitleBottomMargin: CGFloat = 6
    private var badgeWidth: CGFloat = 16
    
    // MARK: - Helper
    
    private func addAllSubView() {
        // Menu container
        actionMenuView = UIView()
        
        
        // Title container
        menuTitleView = UIView()
        titleStackView = UIStackView()
        
        // Indicator
        indicatorView = UIView()
        indicatorView.layer.cornerRadius = indicatorHeight/2
        indicatorView.layer.masksToBounds = true
        indicatorView.backgroundColor = indicatorColor
        
        if isTitleViewStyle {
            actionMenuView.backgroundColor = UIColor.clear
            menuTitleView.backgroundColor = UIColor.clear
        } else {
            actionMenuView.backgroundColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1)
            menuTitleView.backgroundColor = menuTitleViewBackgroundColor
        }
        
        // ScrollView
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        if isRedPoint {
            badgeWidth = 6
        }
        
        for i in 0..<menuTitles.count {
            let view = UIView()
            
            let button = UIButton(type: .custom)
            button.tag = i
            button.addTarget(self,
                             action: #selector(contentOffSetXForButton(sender:)),
                             for: .touchUpInside)
            
            let titleLabel = UILabel()
            titleLabel.text = menuTitles[i]
            if isTitleViewStyle {
                titleLabel.textColor = unselectedItemColor
                titleLabel.font = unselectedItemFont
            } else {
                titleLabel.font = itemFont
            }
            
            let badgeLabel = UILabel()
            badgeLabel.backgroundColor = UIColor(red: 251/255.0, green: 98/255.0, blue: 100/255.0, alpha: 1)
            badgeLabel.textColor = UIColor.white
            badgeLabel.layer.cornerRadius = badgeWidth/2
            badgeLabel.layer.masksToBounds = true
            badgeLabel.textAlignment = .center
            badgeLabel.isHidden = true
            badgeLabel.font = UIFont.systemFont(ofSize: 10)
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: "cat-cat")
            
            view.addSubview(imageView)
            view.addSubview(titleLabel)
            view.addSubview(badgeLabel)
            view.addSubview(button)
            
            redBadgeLabels.append(badgeLabel)
            titleLabels.append(titleLabel)
            buttonItems.append(button)
            titleViews.append(view)
            titleMarkImageViews.append(imageView)
            
            titleStackView.addArrangedSubview(view)
        }
        
        titleStackView.alignment = .fill
        titleStackView.axis = .horizontal
        if isTitleViewStyle {
            titleStackView.distribution = .fill
        } else {
            titleStackView.distribution = .fillEqually
        }
        
        for i in 0 ..< viewItems.count {
            let vc = viewItems[i]
            addChild(vc)
            scrollView.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
        
        menuTitleView.addSubview(titleStackView)
        menuTitleView.addSubview(indicatorView)
        
        actionMenuView.addSubview(menuTitleView)
        
        if isTitleViewStyle {
        } else {
            self.view.addSubview(actionMenuView)
        }
        self.view.addSubview(scrollView)
    }
    
    private func setupConstraints() {
        var all: [NSLayoutConstraint] = []
        
        menuTitleView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // not title view style
        if !isTitleViewStyle {
            actionMenuView.translatesAutoresizingMaskIntoConstraints = false
            
            let menuTop = actionMenuView.topAnchor.constraint(equalTo: self.view.topAnchor)
            let menuLeading = actionMenuView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
            let menuTrailing = actionMenuView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            menuHeight = actionMenuView.heightAnchor.constraint(equalToConstant: menuViewHeight)
            
            
            var menuConstraints: [NSLayoutConstraint] = []
            menuConstraints.append(menuTop)
            menuConstraints.append(menuLeading)
            menuConstraints.append(menuTrailing)
            menuConstraints.append(menuHeight)
            
            all += menuConstraints
        }
        
        // Title view
        let titleViewTop = menuTitleView.topAnchor.constraint(equalTo: actionMenuView.topAnchor)
        let titleViewLeading = menuTitleView.leadingAnchor.constraint(equalTo: actionMenuView.leadingAnchor)
        let titleViewTrailing = menuTitleView.trailingAnchor.constraint(equalTo: actionMenuView.trailingAnchor)
        let titleViewBottom = menuTitleView.bottomAnchor.constraint(equalTo: actionMenuView.bottomAnchor, constant: useSeperateLine ? -0.5 : 0)
        
        var titleViewConstraints: [NSLayoutConstraint] = []
        titleViewConstraints.append(titleViewTop)
        titleViewConstraints.append(titleViewLeading)
        titleViewConstraints.append(titleViewTrailing)
        titleViewConstraints.append(titleViewBottom)
        
        // Title stack view
        let titleStackViewTop = titleStackView.topAnchor.constraint(equalTo: menuTitleView.topAnchor)
        let titleStackViewLeading = titleStackView.leadingAnchor.constraint(equalTo: menuTitleView.leadingAnchor)
        let titleStackViewTrailing = titleStackView.trailingAnchor.constraint(equalTo: menuTitleView.trailingAnchor)
        let titleStatckViewBottom = titleStackView.bottomAnchor.constraint(equalTo: menuTitleView.bottomAnchor, constant: -0.5)
        
        var titleStackViewConstraints: [NSLayoutConstraint] = []
        titleStackViewConstraints.append(titleStackViewTop)
        titleStackViewConstraints.append(titleStackViewLeading)
        titleStackViewConstraints.append(titleStackViewTrailing)
        titleStackViewConstraints.append(titleStatckViewBottom)
        
        // Subview in titleStackView
        var titleLabelConstraints: [NSLayoutConstraint] = []
        var titleButtonConstraints: [NSLayoutConstraint] = []
        var badgeLabelConstraints: [NSLayoutConstraint] = []
        for i in 0..<titleStackView.arrangedSubviews.count {
            
            
            titleLabels[i].translatesAutoresizingMaskIntoConstraints = false
            buttonItems[i].translatesAutoresizingMaskIntoConstraints = false
            redBadgeLabels[i].translatesAutoresizingMaskIntoConstraints = false
            
            
            let titleCenterX = titleLabels[i].centerXAnchor.constraint(equalTo: titleViews[i].centerXAnchor)
            let titleCenterY = titleLabels[i].centerYAnchor.constraint(equalTo: titleViews[i].centerYAnchor)
            
            let titleButtonTop = buttonItems[i].topAnchor.constraint(equalTo: titleViews[i].topAnchor)
            let titleButtonBottom = buttonItems[i].bottomAnchor.constraint(equalTo: titleViews[i].bottomAnchor)
            let titleButtonLeading = buttonItems[i].leadingAnchor.constraint(equalTo: titleViews[i].leadingAnchor)
            let titleButtonTrailing = buttonItems[i].trailingAnchor.constraint(equalTo: titleViews[i].trailingAnchor)
            
            let badgeWidth = redBadgeLabels[i].widthAnchor.constraint(equalToConstant: self.badgeWidth)
            let badgeHeight = redBadgeLabels[i].heightAnchor.constraint(equalToConstant: self.badgeWidth)
            let badgeTop = redBadgeLabels[i].topAnchor.constraint(equalTo: titleLabels[i].topAnchor, constant: -5)
            let badgeLeading = redBadgeLabels[i].leadingAnchor.constraint(equalTo: titleLabels[i].trailingAnchor, constant: 2)
            
            titleLabelConstraints.append(titleCenterX)
            titleLabelConstraints.append(titleCenterY)
            
            titleButtonConstraints.append(titleButtonTop)
            titleButtonConstraints.append(titleButtonBottom)
            titleButtonConstraints.append(titleButtonLeading)
            titleButtonConstraints.append(titleButtonTrailing)
            
            badgeLabelConstraints.append(badgeWidth)
            badgeLabelConstraints.append(badgeHeight)
            badgeLabelConstraints.append(badgeTop)
            badgeLabelConstraints.append(badgeLeading)
        }
        
        // Scroll view
        var scrollViewConstraints: [NSLayoutConstraint] = []
        let scrollViewTop = scrollView.topAnchor.constraint(equalTo: isTitleViewStyle ? self.view.topAnchor : actionMenuView.bottomAnchor)
        let scrollViewLeading = scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let scrollViewTrailing = scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        let scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        scrollViewConstraints.append(scrollViewTop)
        scrollViewConstraints.append(scrollViewLeading)
        scrollViewConstraints.append(scrollViewTrailing)
        scrollViewConstraints.append(scrollViewBottom)
        
        // Activate
        all += titleViewConstraints
        all += titleStackViewConstraints
        all += scrollViewConstraints
        all += titleLabelConstraints
        all += titleButtonConstraints
        all += badgeLabelConstraints
        
        NSLayoutConstraint.activate(all)
        
        // Is title view style
        if isTitleViewStyle {  // 最好是设置为两个字的
            
            var totalMenuWidth: CGFloat = 0

            for i in 0..<titleStackView.arrangedSubviews.count {
                var itemWidth: CGFloat = 0
                let badgeWidth: CGFloat = useBadge ? 20.0 : 0 // 小红点的宽度
                let gap: CGFloat = 20 // item 的前后间隙
                itemWidth = CGFloat(15*max(2, menuTitles[i].count)) + badgeWidth + gap
                
                totalMenuWidth += itemWidth

                let sub = titleStackView.arrangedSubviews[i]
                sub.translatesAutoresizingMaskIntoConstraints = false
                let subHeightCons = sub.heightAnchor.constraint(equalTo: titleStackView.heightAnchor, multiplier: 1)
                let subWidthCons = sub.widthAnchor.constraint(equalToConstant: itemWidth)
                NSLayoutConstraint.activate([subHeightCons, subWidthCons])

            }
            
            actionMenuView.translatesAutoresizingMaskIntoConstraints = false
            // add your views and set up all the constraints
            
            var sumTitleTextCount = 0
            for text in menuTitles {
                sumTitleTextCount += text.count
            }
            
            let width: CGFloat = min(CGFloat(totalMenuWidth), UIScreen.main.bounds.width - 40)
            actionMenuView.widthAnchor.constraint(equalToConstant: width).isActive = true
            actionMenuView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            // This is the magic sauce!
            actionMenuView.layoutIfNeeded()
            actionMenuView.sizeToFit()
            
            // Now the frame is set (you can print it out)
            actionMenuView.translatesAutoresizingMaskIntoConstraints = true // make nav bar happy
            
            // origin
            //            managerController?.navigationItem.titleView = menuView
            
            // new set
            managerController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: actionMenuView)
            self.indicatorView?.isHidden = true
        }
        
        // For title image mark
        if titleMarkImageViews.count == titleStackView.arrangedSubviews.count {
            for imageView in titleMarkImageViews {
                if let sup = imageView.superview {
                    let imgaeTrailing = imageView.trailingAnchor.constraint(equalTo: sup.trailingAnchor)
                    let imgaeCenterY = imageView.centerYAnchor.constraint(equalTo: sup.centerYAnchor)
                    NSLayoutConstraint.activate([imgaeTrailing, imgaeCenterY])
                }
            }
        }
        showTitleImageMarkAt(defaultOffsetPage)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        resetSubviewsLayoutIfNeeded()
    }
    
    private func resetSubviewsLayoutIfNeeded() {
        //        print("resetSubviewsLayoutIfNeeded\n")
        
        var contentSize = scrollView.bounds.size
        contentSize.width = contentSize.width * CGFloat(viewItems.count)
        scrollView.contentSize = contentSize
        
        //        print("----------------------------------")
        //        print("scrollView frame = \(scrollView.frame), bounds: \(scrollView.bounds)")
        
        itemsViewFrameOriginX.removeAll()
        for i in 0 ..< viewItems.count {
            var itemFrame = scrollView.bounds
            let originX = itemFrame.width * CGFloat(i)
            itemFrame.origin.x = originX
            itemFrame.origin.y = 0
            viewItems[i].view.frame = itemFrame
            //            viewItems[i].bounds.origin.y = 0  // 适配 iOS 10 在titleView模式的奇怪上移问题
            
            itemsViewFrameOriginX.append(originX)
            
            //            print("viewItems[i].frame = \(viewItems[i].frame), bounds: \(viewItems[i].bounds)")
        }
        
        // for menuItems originX
        indicatorOriginsX.removeAll()
        
        let itemWidth: CGFloat = actionMenuView.bounds.width/CGFloat(viewItems.count)
        for i in 0..<viewItems.count {
            let tmpFrame = CGRect(x: itemWidth*CGFloat(i), y: 0, width: itemWidth, height: 1)
            let indicatorOriginX = tmpFrame.midX - indicatorWidth/2
            indicatorOriginsX.append(indicatorOriginX)
        }
        
        // for sectionIndicatorView
        var indicatorX: CGFloat = 0
        if userDefaultOffsetPage {  // For Default page
            userDefaultOffsetPage = false
            
            let offset = CGPoint(x: CGFloat(defaultOffsetPage)*scrollView.bounds.width, y: 0)
            scrollView.setContentOffset(offset, animated: false)
            
            indicatorX = indicatorOriginsX[defaultOffsetPage]
        } else { // For rotate
            let offset = CGPoint(x: scrollView.bounds.width * CGFloat(lastIndex), y: 0)
            scrollView.setContentOffset(offset, animated: false)
            
            indicatorX = indicatorOriginsX[lastIndex]
        }
        
        indicatorView.frame = CGRect(x: indicatorX, y: actionMenuView.frame.height - realTitleBottomMargin, width: indicatorWidth, height: indicatorHeight)
        indicatorViewLastOriginX = indicatorView.frame.origin.x
        
        // indicator scroll scale
        if indicatorOriginsX.count == 1 {
            
        } else {
            let indicatorScale = indicatorOriginsX[1] - indicatorOriginsX[0]
            scale = indicatorScale / UIScreen.main.bounds.size.width
        }
    }
    
    private func firstLoadDataNotification() {
        
        if self.hasShowPages.count > defaultOffsetPage {
            // Notification defaultOffsetPage view controller when first load container
            if self.hasShowPages[defaultOffsetPage] == false {
                
                // Set scrollview offset with container first loaded
                if defaultOffsetPage != defaultSelectedPage {
                    let offset = CGPoint(x: UIScreen.main.bounds.width * CGFloat(defaultOffsetPage), y: 0)
                    scrollView.setContentOffset(offset, animated: false)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.setItemsFirstShowData(index: self.defaultOffsetPage, value: true)
                })
            }
        }
    }
    
    private var hasShowPages: [Bool] = []
    private func setItemsFirstShowData(index: Int, value: Bool) {
        hasShowPages[index] = value
        if value == true {
            
            updateButtonItemsFont(index: index)
            delegate?.scrollContainerView(containerView: self, scrollAt: index, isFirstScrollToIt: true)
        }
    }
    
    private func mutipleTimeScrollTo(index: Int) {
        updateButtonItemsFont(index: index)
        
        delegate?.scrollContainerView(containerView: self, scrollAt: index, isFirstScrollToIt: false)
    }
    
    private func updateButtonItemsFont(index: Int) {
        if isTitleViewStyle {
            for i in 0..<titleLabels.count {
                titleLabels[i].font = (i == index) ? selectedItemFont : unselectedItemFont
                titleLabels[i].textColor = (i == index) ? selectedItemColor : unselectedItemColor
            }
        }
    }
    
    private var lastIndex = defaultSelectedPage {
        didSet {
            for i in 0..<viewItems.count {
                let color = i == lastIndex ? selectedItemColor : unselectedItemColor
                if isTitleViewStyle {
                    titleLabels[i].textColor = color
                }  else {
                    titleLabels[i].textColor = color
                }
            }
        }
    }
    
    // MARK: - Menu button tapped
    @objc private func contentOffSetXForButton(sender: UIButton) {
        scrollToPage(sender.tag)
    }
    
    // 滚动到某个页面， 从0开始 [0, 1, 2 ....]
    func scrollToPage(_ page: Int) {
        let index = page
        
        let scrollWithAnimation = canScrollWithAnimation(current: index)
        lastIndex = index
        
        let shouldScrollOffset = CGPoint(x: CGFloat(index)*scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(shouldScrollOffset, animated: scrollWithAnimation)
        UIView.animate(withDuration: moveDuration, animations: {
            self.indicatorView.frame.origin.x = self.indicatorOriginsX[index]
            self.indicatorViewLastOriginX = self.indicatorView.frame.origin.x
            
            self.toIndex(index)
        })
    }
    
    // 滚动到的index
    private func toIndex(_ index: Int) {
        
        if self.hasShowPages[index] == false {
            self.setItemsFirstShowData(index: index, value: true)
        } else {
            self.mutipleTimeScrollTo(index: index)
        }
        
        showTitleImageMarkAt(index)
    }
    
    // 显示的标题图片index
    private func showTitleImageMarkAt(_ index: Int) {
        if useCatTitleMark && isTitleViewStyle {
            for i in 0..<titleMarkImageViews.count {
                titleMarkImageViews[i].isHidden = i != index
            }
        }
    }
    
    private func canScrollWithAnimation(current index: Int) -> Bool {
        var range: [Int] = [index]
        range.append(index+1)
        range.append(index-1)
        
        if range.contains(lastIndex) {
            return true
        } else {
            return false
        }
    }
}


extension DQMenuViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0.0 {
            return
        }
        
        UIView.animate(withDuration: moveDuration, animations: {
            let x = scrollView.contentOffset.x * self.scale + self.indicatorOriginsX[0]
            self.indicatorView.frame.origin.x = x
            self.indicatorViewLastOriginX = x
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if itemsViewFrameOriginX.contains(scrollView.contentOffset.x) {
            let index = itemsViewFrameOriginX.firstIndex(of: scrollView.contentOffset.x)!
            lastIndex = index
           
            toIndex(index)
        }
        
    }
    
}

extension UIColor {

    static func hexStringColor(hex: String) -> UIColor {
        // eg: UIColor.hexStringColor(hex: "333333")
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
