//
//  AlbumGalleryViewController.swift
//  Prodigal
//
//  Created by bob.sun on 28/02/2017.
//  Copyright © 2017 bob.sun. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer
import Haneke

class AlbumGalleryViewController: TickableViewController {

    var stackLayout: AlbumGalleryLayout!
    var collection: UICollectionView!
    var albums: Array<MPMediaItemCollection>! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackLayout = AlbumGalleryLayout()
        stackLayout.scrollDirection = .horizontal
        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: stackLayout)
        collection.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.reuseId)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func attachTo(viewController vc: UIViewController, inView view:UIView) {
        vc.addChildViewController(self)
        view.addSubview(self.view)
        self.view.isHidden = true
        self.view.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(view)
            maker.center.equalTo(view)
        }
        self.view.addSubview(collection)
        collection.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        if albums.count == 0 {
            albums = MediaLibrary.sharedInstance.fetchAllAlbums()
        }
        let size = view.bounds.height / 2
        stackLayout.itemSize = CGSize(width: size, height: size)
        collection.reloadData()
        self.view.backgroundColor = UIColor.lightGray
        current = albums.count / 2
    }


    override func hide(type: AnimType, completion: @escaping AnimationCompletion) {
        self.view.isHidden = true
    }
    
    override func show(type: AnimType) {
        self.view.isHidden = false
        if current > 0 {
            collection.scrollToItem(at: IndexPath.init(row: current, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    override func onNextTick() {
        if current >= albums.count - 1{
            return
        }
        current += 1
        collection.scrollToItem(at: IndexPath(row: current, section:0), at: .centeredHorizontally, animated: true)
    }
    override func onPreviousTick() {
        if current <= 0 {
            return
        }
        current -= 1
        collection.scrollToItem(at: IndexPath(row: current, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension AlbumGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: AlbumCell.reuseId, for: indexPath) as! AlbumCell
        let album = albums[indexPath.row]
        cell.configure(withImage: (album.representativeItem?.artwork?.image(at: CGSize(width: 200, height: 200))) ?? #imageLiteral(resourceName: "ic_album"), cacheId: (album.representativeItem?.albumPersistentID) ?? UInt64(0))
        return cell
    }
    
    
}

class AlbumCell: UICollectionViewCell {
    
    static let reuseId =            "ReuseIdAlbumCollectionCell"
    
    let image = UIImageView(frame:CGRect.zero)
    
    convenience init() {
        self.init()
        initViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        self.contentView.backgroundColor = UIColor.darkGray
        self.contentView.addSubview(image)
        self.image.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        self.image.hnk_cacheFormat = HNKCache.shared().formats["stack"] as! HNKCacheFormat!
        self.image.contentMode = .scaleAspectFit
    }
    
    func configure(withImage img:UIImage, cacheId: UInt64) {
        image.hnk_setImage(img, withKey: String.init(format: "%llu", cacheId))
    }
}
