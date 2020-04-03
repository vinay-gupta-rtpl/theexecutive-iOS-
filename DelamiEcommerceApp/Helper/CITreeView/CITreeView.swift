//
//  CITreeView.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

protocol CITreeViewDataSource {
    func treeView(_ treeView: CITreeView, atIndexPath indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode?) -> UITableViewCell
    func treeViewSelectedNodeChildren(for treeViewNodeItem: Any) -> [Any]
    func treeViewDataArray(section: Int) -> [Any]
    func treeViewSectionCount() -> Int
}

protocol CITreeViewDelegate: class {
    func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode?) -> CGFloat
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode: CITreeViewNode)
    func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath)
    func didExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath)
    func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath)
    func didCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath)
    
    // header view and height delegate methods
    func treeViewHeaderHeight(_ treeView: CITreeView, section: Int) -> CGFloat
    func treeViewHeader(_ treeView: CITreeView, section: Int) -> UIView?
}

class CITreeView: UITableView {
    var treeViewDataSource: CITreeViewDataSource?
    weak var treeViewDelegate: CITreeViewDelegate?
    var treeViewController = CITreeViewController(treeViewNodes: [])
    var selectedTreeViewNode: CITreeViewNode?
    var collapseNoneSelectedRows = false
    fileprivate var mainDataArray: [CITreeViewNode] = []
    
    var selectedSection: Int?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        super.delegate = self
        super.dataSource = self
        treeViewController.treeViewControllerDelegate = self as CITreeViewControllerDelegate
        self.backgroundColor = .clear
    }
    
    override func reloadData() {
        treeViewController.treeViewNodes = [CITreeViewNode]()
        super.reloadData()
    }
    
    fileprivate func deleteRows() {
        self.beginUpdates()
        self.deleteRows(at: treeViewController.indexPathsArray, with: .automatic)
        self.endUpdates()
    }
    
    fileprivate func insertRows() {
        self.beginUpdates()
        self.insertRows(at: treeViewController.indexPathsArray, with: .automatic)
        self.endUpdates()
    }
    
    fileprivate func collapseRows(for treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath, completion: @escaping () -> Void) {
        if #available(iOS 11.0, *) {
            self.performBatchUpdates({
                deleteRows()
            }, completion: { (_) in
                self.treeViewDelegate?.didCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
                completion()
            })
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.treeViewDelegate?.didCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
                completion()
            })
            deleteRows()
            CATransaction.commit()
        }
    }
    
    fileprivate func expandRows(for treeViewNode: CITreeViewNode, withSelected indexPath: IndexPath) {
        if #available(iOS 11.0, *) {
            self.performBatchUpdates({
                insertRows()
            }, completion: { (_) in
                self.treeViewDelegate?.didExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
            })
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.treeViewDelegate?.didExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
            })
            insertRows()
            CATransaction.commit()
        }
    }
    
    func getAllCells() -> [UITableViewCell] {
        var cells = [UITableViewCell]()
        for section in 0 ..< self.numberOfSections {
            for row in 0 ..< self.numberOfRows(inSection: section) {
                cells.append(self.cellForRow(at: IndexPath(row: row, section: section))!)
            }
        }
        return cells
    }
}

extension CITreeView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.treeViewDelegate?.treeViewHeaderHeight((tableView as? CITreeView)!, section: section))!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.treeViewDelegate?.treeViewHeader((tableView as? CITreeView)!, section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return (self.treeViewDelegate?.treeView((tableView as? CITreeView)!, heightForRowAt: indexPath, withTreeViewNode: nil))!
        } else {
            let treeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
            return (self.treeViewDelegate?.treeView((tableView as? CITreeView)!, heightForRowAt: indexPath, withTreeViewNode: treeViewNode))!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as? CategoryCell
        
        selectedTreeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        self.treeViewDelegate?.treeView((tableView as? CITreeView)!, didSelectRowAt: selectedTreeViewNode!)
        var willExpandIndexPath = indexPath
        if (selectedTreeViewNode?.expand)! {
            cell?.arrowButton.isSelected = false
            treeViewController.collapseRows(for: selectedTreeViewNode!, atIndexPath: indexPath)
            collapseRows(for: self.selectedTreeViewNode!, atIndexPath: indexPath) {}
        } else {
            cell?.arrowButton.isSelected = true
            if collapseNoneSelectedRows, selectedTreeViewNode?.level == 0, let collapsedTreeViewNode = treeViewController.collapseAllRows(section: indexPath.section) {
                if treeViewController.indexPathsArray.count > 0 {
                    collapseRows(for: collapsedTreeViewNode, atIndexPath: indexPath) {
                        for (index, treeViewNode) in self.mainDataArray.enumerated() where treeViewNode == self.selectedTreeViewNode {
                            willExpandIndexPath.row = index
                        }
                        self.treeViewController.expandRows(atIndexPath: willExpandIndexPath, with: self.selectedTreeViewNode!)
                        self.expandRows(for: self.selectedTreeViewNode!, withSelected: indexPath)
                    }
                } else {
                    treeViewController.expandRows(atIndexPath: willExpandIndexPath, with: selectedTreeViewNode!)
                    expandRows(for: self.selectedTreeViewNode!, withSelected: indexPath)
                }
            } else {
                treeViewController.expandRows(atIndexPath: willExpandIndexPath, with: selectedTreeViewNode!)
                expandRows(for: self.selectedTreeViewNode!, withSelected: indexPath)
            }
        }
    }
}

extension CITreeView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.treeViewDataSource?.treeViewSectionCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let sectionObj = self.treeViewDataSource?.treeViewDataArray(section: section)[section - 1] as? CategoryModel, let collapsed = sectionObj.collapsed, collapsed {
                if sectionObj.children.count > treeViewController.treeViewNodes.count {
                    mainDataArray = [CITreeViewNode]()
                    for item in sectionObj.children {
                        treeViewController.addTreeViewNode(with: item)
                    }
                    mainDataArray = treeViewController.treeViewNodes
                }
                return treeViewController.treeViewNodes.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return (self.treeViewDataSource?.treeView((tableView as? CITreeView)!, atIndexPath: indexPath, withTreeViewNode: nil))!
        } else {
            let treeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
            return (self.treeViewDataSource?.treeView((tableView as? CITreeView)!, atIndexPath: indexPath, withTreeViewNode: treeViewNode))!
        }
    }
}

extension CITreeView: CITreeViewControllerDelegate {
    func getChildren(forTreeViewNodeItem item: Any, with indexPath: IndexPath) -> [Any] {
        return (self.treeViewDataSource?.treeViewSelectedNodeChildren(for: item))!
    }
    
    func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        self.treeViewDelegate?.willCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: atIndexPath)
    }
    
    func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        self.treeViewDelegate?.willExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: atIndexPath)
    }
}
