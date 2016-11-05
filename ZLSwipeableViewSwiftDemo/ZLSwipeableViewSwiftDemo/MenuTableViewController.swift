//
//  MenuTableViewController.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/25/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    let demoViewControllers = [("Default", ZLSwipeableViewController.self),
                                ("Custom Animation", CustomAnimationDemoViewController.self),
                                ("Custom Swipe", CustomSwipeDemoViewController.self),
                                ("Allowed Direction", CustomDirectionDemoViewController.self),
                                ("History", HistoryDemoViewController.self),
                                ("Previous View", PreviousViewDemoViewController.self),
                                ("Should Swipe", ShouldSwipeDemoViewController.self),
                                ("Always Swipe", AlwaysSwipeDemoViewController.self)]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ZLSwipeableView"
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoViewControllers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = String(format: "s%li-r%li", indexPath.section, indexPath.row)
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }

        cell.textLabel?.text = titleForRowAtIndexPath(indexPath)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titleForRowAtIndexPath(indexPath)
        let vc = viewControllerForRowAtIndexPath(indexPath)
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func titleForRowAtIndexPath(_ indexPath: IndexPath) -> String {
        let (title, _) = demoViewControllers[indexPath.row]
        return title
    }
    
    func viewControllerForRowAtIndexPath(_ indexPath: IndexPath) -> ZLSwipeableViewController {
        let (_, vc) = demoViewControllers[indexPath.row]
        return vc.init()
    }

}
