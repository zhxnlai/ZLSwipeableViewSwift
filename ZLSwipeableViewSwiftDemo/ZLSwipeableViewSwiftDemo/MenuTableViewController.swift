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
                                ("Custom Direction", CustomDirectionDemoViewController.self),
                                ("Undo", UndoDemoViewController.self),
                                ("Should Swipe", ShouldSwipeDemoViewController.self)]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ZLSwipeableView"
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoViewControllers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = String(format: "s%li-r%li", indexPath.section, indexPath.row)
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }

        cell.textLabel?.text = titleForRowAtIndexPath(indexPath)
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let title = titleForRowAtIndexPath(indexPath)
        let vc = viewControllerForRowAtIndexPath(indexPath)
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        let (title, _) = demoViewControllers[indexPath.row]
        return title
    }
    
    func viewControllerForRowAtIndexPath(indexPath: NSIndexPath) -> ZLSwipeableViewController {
        let (_, vc) = demoViewControllers[indexPath.row]
        return vc.init()
    }

}
