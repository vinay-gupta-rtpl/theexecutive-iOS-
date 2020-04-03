//
//  PromotionCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 27/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

let kPromotionCellImageViewTag = 101

protocol PromotionCellTappedDelegate: class {
    func sendPromotionCellDataWithRow(promotionData: PromotionModel, rowNo: Int)
    func openUrlForPromotion()
}

class PromotionCell: UITableViewCell {
    @IBOutlet weak var promotionCollectionView: UICollectionView!
    @IBOutlet weak var promotionTextLabel: UILabel!
    
    var viewModel: HomeDataViewModel?
    weak var promotionDelegate: PromotionCellTappedDelegate?
    
    private var timer = Timer()
    
    /**
     * The time interval between each scroll in collection view. 3 seconds is the default interval.
     */
    var scrollInterval: Int = 3
    
    deinit { stopScrolling() }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        promotionCollectionView.delegate = self
        promotionCollectionView.dataSource = self
        
        // tap on promotion link
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnHomePromotionLink))
        self.promotionTextLabel.addGestureRecognizer(tap)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(viewModel: HomeDataViewModel?) {
        guard let homeDataViewModel = viewModel else {
            return
        }
        
        self.viewModel = homeDataViewModel
        self.promotionCollectionView.reloadData()
        self.startScrolling()
    }
    
    @objc func tapOnHomePromotionLink(_ sender: Any) {
        self.promotionDelegate?.openUrlForPromotion()
    }
}

extension PromotionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: MainScreen.width - 30.0, height: (MainScreen.width - 30.0) * 3/2)
    }
}

extension PromotionCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.promotions.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.CheckoutAndOther.promotionImage, for: indexPath)
        
        if let promotionImageView = cell.viewWithTag(kPromotionCellImageViewTag) as? UIImageView {
            promotionImageView.contentMode = .scaleAspectFit
            promotionImageView.clipsToBounds = true
            if let promotionImage = viewModel?.promotions.value?[indexPath.row].image, !promotionImage.isEmpty {
                if  let url = URL(string: promotionImage) {
                    let request = URLRequest(url: url)
                    
                    DispatchQueue.global(qos: .background).async {
                        promotionImageView.setImageWithUrlRequest(request, placeHolderImage: UIImage(), success: { (_, _, image, _) -> Void in
                            DispatchQueue.main.async(execute: {
                                promotionImageView.alpha = 0.0
                                promotionImageView.image = image
                                promotionImageView.contentMode = .scaleAspectFit
                                UIView.animate(withDuration: 0.5, animations: {promotionImageView.alpha = 1.0})
                            })
                        }, failure: nil)
                    }
                } else {
                    promotionImageView.image = UIImage()
                }
            } else {
                promotionImageView.image = UIImage()
            }
        }
        return cell
    }
}

extension PromotionCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewData = viewModel?.promotions.value![indexPath.row] {
            self.promotionDelegate?.sendPromotionCellDataWithRow(promotionData: viewData, rowNo: indexPath.row)
        }
        
    }
}

extension PromotionCell {
    fileprivate func setTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(scrollInterval), target: self, selector: #selector(self.autoScrollImageSlider), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .commonModes)
    }
    
    /**
     * Starts scrolling the collection view if there is at least one item in the datsource.
     */
    func startScrolling() {
        if !timer.isValid {
            if promotionCollectionView.numberOfItems(inSection: 0) != 0 {
                stopScrolling()
                setTimer()
            }
        }
    }
    
    func stopScrolling() { if timer.isValid { self.timer.invalidate() } }
    
    @objc fileprivate func autoScrollImageSlider() {
        DispatchQueue.main.async {
            let firstIndex = 0
            let lastIndex = self.promotionCollectionView.numberOfItems(inSection: 0) - 1
            let visibleCellsIndexes = self.promotionCollectionView.indexPathsForVisibleItems.sorted()
            
            if !visibleCellsIndexes.isEmpty {
                let nextIndex = visibleCellsIndexes[0].row + 1
                let nextIndexPath: IndexPath = IndexPath.init(item: nextIndex, section: 0)
                let firstIndexPath: IndexPath = IndexPath.init(item: firstIndex, section: 0)
                
                if nextIndex > lastIndex {
                    self.promotionCollectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: false)
                } else {
                    self.promotionCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
}
