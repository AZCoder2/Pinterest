//
//  PhotoStreamViewController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoStreamViewController: UICollectionViewController {
  
  var photos = Photo.allPhotos()
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set controller as delegate for layout
    if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
      layout.delegate = self
    }
    
    if let patternImage = UIImage(named: "Pattern") {
      view.backgroundColor = UIColor(patternImage: patternImage)
    }
    
    collectionView!.backgroundColor = UIColor.clear
    collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
  }
  
}

extension PhotoStreamViewController {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! AnnotatedPhotoCell
    cell.photo = photos[indexPath.item]
    return cell
  }
  
}

extension PhotoStreamViewController : PinterestLayoutDelegate {
  
  // This provides the height of the photos
  
  /* It uses AVMakeRectWithAspectRatioInsideRect() from AVFoundation to calculate a height that retains the photo’s aspect ratio, restricted to the cell’s width.
   */
  
  func collectionView(_ collectionView:UICollectionView,
                      heightForPhotoAtIndexPath indexPath: NSIndexPath,
                      withWidth width: CGFloat) -> CGFloat {
    
    let photo = photos[indexPath.item]
    let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
    let rect  = AVMakeRect(aspectRatio: photo.image.size, insideRect: boundingRect)
    
    return rect.size.height
  }
  
  // This calculates the height of the photo’s comment based on the given font and the cell’s width
  func collectionView(_ collectionView: UICollectionView,
                      heightForAnnotationAtIndexPath indexPath: NSIndexPath,
                      withWidth width: CGFloat) -> CGFloat {
    
    let annotationPadding = CGFloat(4)
    let annotationHeaderHeight = CGFloat(17)
    let photo = photos[indexPath.item]
    let font = UIFont(name: "AvenirNext-Regular", size: 10)!
    let commentHeight = photo.heightForComment(font, width: width)
    
    /* You then add that height to a hard-coded annotationPadding value for the top and bottom, as well as a hard-coded annotationHeaderHeight that accounts for the size of the annotation title.
     */
    let height = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding
    
    return height
  }
}


