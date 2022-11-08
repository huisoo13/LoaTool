//
//  CollectionViewLayout.swift
//  SpinningWheelCollectionView
//
//  Created by Trading Taijoo on 2022/11/04.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {
    let itemSize = CGSize(width: 150, height: 150)
    var selectedIndex: Int = 0
    var radius: CGFloat = 500 {
        didSet {
            invalidateLayout()
        }
    }
     
    var anglePerItem: CGFloat {
        return atan(itemSize.height / radius)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGRectGetWidth(collectionView!.bounds),
                      height: CGFloat(collectionView!.numberOfItems(inSection: 0)) * itemSize.height)

    }
    
    var attributesList = [CollectionViewLayoutAttributes]()
    override class var layoutAttributesClass: AnyClass {
        return CollectionViewLayoutAttributes.self
    }
    
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItems(inSection: 0) > 0
        ? -CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem
        : 0
    }
    var angle: CGFloat {
        return angleAtExtreme * collectionView!.contentOffset.y / (collectionViewContentSize.height - CGRectGetHeight(collectionView!.bounds))
    }
    
    override func prepare() {
        super.prepare()

        let centerY = collectionView!.contentOffset.y + (CGRectGetHeight(collectionView!.bounds) / 2.0)
        let anchorPointX = ((itemSize.width / 2.0) + radius) / itemSize.width
        //1
        let theta = atan2(CGRectGetHeight(collectionView!.bounds) / 2.0, radius + (itemSize.width / 2.0) - (CGRectGetWidth(collectionView!.bounds) / 2.0))
        //2
        var startIndex = 0
        var endIndex = collectionView!.numberOfItems(inSection: 0) - 1
        //3
        if (angle < -theta) {
            startIndex = Int(floor((-theta - angle) / anglePerItem))
        }
        //4
        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))
        //5
        if (endIndex < startIndex) {
            endIndex = 0
            startIndex = 0
        }
        
        attributesList = (startIndex...endIndex).map { (i) -> CollectionViewLayoutAttributes in
            let attributes = CollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            attributes.size = self.itemSize
            attributes.center = CGPoint(x: CGRectGetMidX(self.collectionView!.bounds), y: centerY)
            attributes.angle = -(self.angle + (self.anglePerItem * CGFloat(i)))
            attributes.anchorPoint = CGPoint(x: anchorPointX, y: 0.5)

            return attributes
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesList[safe: indexPath.row]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var finalContentOffset = proposedContentOffset
        let factor = -angleAtExtreme / (collectionViewContentSize.height - CGRectGetHeight(collectionView!.bounds))
        let proposedAngle = proposedContentOffset.y * factor
        let ratio = proposedAngle / anglePerItem
        var multiplier: CGFloat
        if (velocity.y > 0) {
            multiplier = ceil(ratio)
        } else if (velocity.y < 0) {
            multiplier = floor(ratio)
        } else {
            multiplier = round(ratio)
        }
        
        finalContentOffset.y = multiplier * anglePerItem / factor
        selectedIndex = Int(multiplier)
        
        return finalContentOffset
    }
    
    
}

