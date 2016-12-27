//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by Tom Ranalli on 12/25/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

// MARK: - Protocols
protocol PinterestLayoutDelegate {
  
  // Request height of photo
  func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
                      withWidth:CGFloat) -> CGFloat
  
  // Request annotation for photo
  func collectionView(_ collectionView: UICollectionView,
                      heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
  
  // This declares the photoHeight property that the cell will use to resize its image view
  var photoHeight: CGFloat = 0.0
  
  /* This overrides copy(_with:)
   
     Subclasses of UICollectionViewLayoutAttributes need to conform to the NSCopying protocol 
     because the attribute’s objects can be copied internally. You override this method to 
     guarantee that the photoHeight property is set when the object is copied.
  */
  
  override func copy(with zone: NSZone? = nil) -> Any {
    let copy = super.copy(with: zone) as! PinterestLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  /* This overrides isEqual(_:), and it’s mandatory as well.
 
     The collection view determines whether the attributes have changed by comparing the old 
     and new attribute objects using isEqual(_:). You must implement it to compare the custom
     properties of your subclass. The code compares the photoHeight of both instances, and
     if they are equal, calls super to determine if the inherited attributes are the same;
     if the photo heights are different, it returns false
  */

  override func isEqual(_ object: Any?) -> Bool {
    if let attributes = object as? PinterestLayoutAttributes {
      if( attributes.photoHeight == photoHeight  ) {
        return super.isEqual(object)
      }
    }
    return false
  }
}

// MARK: - Class definition
class PinterestLayout: UICollectionViewLayout {
  
  // MARK: - Properties
  
  // Keep reference to the delegate
  var delegate: PinterestLayoutDelegate!
  
  // Configure number of columns and cell padding
  var numberOfColumns = 2
  var cellPadding: CGFloat = 6.0
  
  // This is an array to cache the calculated attributes. 
  
  /* When you call prepareLayout(), you’ll calculate the attributes for all items and add them to the cache. When the collection view later requests the layout attributes, you can be efficient and query the cache instead of recalculating them every time
  */
  
  private var cache = [PinterestLayoutAttributes]()
  
  // This declares two properties to store the content size.
  // contentHeight is incremented as photos are added
  private var contentHeight: CGFloat  = 0.0
  
  // contentWidth is calculated based on the collection view width and its content inset.
  private var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return collectionView!.bounds.width - (insets.left + insets.right)
  }
  
  // Variable overrides
  
  /* This overrides collectionViewContentSize variable of the abstract parent class, and returns the size of the collection view’s contents. To do this, you use both contentWidth and contentHeight calculated in the previous steps.
  */
 
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  /* This overrides layoutAttributesClass variable to tell the collection view to use PinterestLayoutAttributes whenever it creates layout attributes objects.
  */
  
  override class var layoutAttributesClass: AnyClass {
    return PinterestLayoutAttributes.self
  }
  
  // MARK: - Overrides
  
  override func prepare() {
    
    // Only calculate if cache is empty
    if cache.isEmpty {
      
      /*  This declares and fills the xOffset array with the x-coordinate for every column based on the column widths.
      */
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      
      var xOffset = [CGFloat]()
      
      for column in 0 ..< numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth )
      }
      
      /*  The yOffset array tracks the y-position for every column. You initialize each value in yOffset to 0, since this is the offset of the first item in each column.
      */
      var column = 0
      var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
      
      // This loops through all the items in the first section, as this particular 
      // layout has only one section
      for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
        
        let indexPath = NSIndexPath(item: item, section: 0)
        
        // This is where you perform the frame calculation
        // Width is the previously calculated cellWidth, with the padding between cells removed
        let width = columnWidth - cellPadding * 2
        
        // You ask the delegate for the height of the image
        let photoHeight = delegate.collectionView(collectionView!,
                                                  heightForPhotoAtIndexPath: indexPath,
                                                  withWidth:width)

        // You ask the delegate for the height of the annotation
        let annotationHeight = delegate.collectionView(collectionView!,
                                    heightForAnnotationAtIndexPath: indexPath,
                                    withWidth: width)
        
        // Calculate the frame height based on those heights and the predefined cellPadding 
        // for the top and bottom
        let height = cellPadding +  photoHeight + annotationHeight + cellPadding
        
        // Combine this with the x and y offsets of the current column to create the
        // insetFrame used by the attribute
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
        
        // This creates an instance of PinterestLayoutAttributes
        let attributes = PinterestLayoutAttributes(forCellWith: indexPath as IndexPath)
        attributes.photoHeight = photoHeight
        
        // Sets its frame using insetFrame
        attributes.frame = insetFrame
        
        // Append the attributes to cache
        cache.append(attributes)
        
        // This expands contentHeight to account for the frame of the newly calculated item
        contentHeight = max(contentHeight, frame.maxY)
        
        // It then advances the yOffset for the current column based on the frame
        yOffset[column] = yOffset[column] + height
        
        // Finally, it advances the column so that the next item will be placed in the next column.
        if column >= numberOfColumns - 1 {
          column = 0
        } else {
          column = column + 1
        }
        
      }
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    //  Iterate through the attributes in cache and check if their frames intersect with rect
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        layoutAttributes.append(attributes) // Add in any attributes for display
      }
    }
    return layoutAttributes
  }

}
