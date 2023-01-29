//
//  RssFeedsViewController.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/11.
//

import UIKit

class RssFeedsViewController: UIViewController {
    
    let rssFeedAtom: RssFeedAtom
    
    let manager: RssFeedsViewManager = RssFeedsViewManager()
    
    init(with rssFeedAtom: RssFeedAtom) {
        self.rssFeedAtom = rssFeedAtom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    private func setUp() {
        view.backgroundColor = .backgroundColor
        navigationItem.title = rssFeedAtom.title
        
        let vc = manager.addRssFeedsView(with: rssFeedAtom) { [weak self] feed in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushToRssFeedDetial(with: feed)
            
            Task {
                await feed.updateReadStatus()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: RssFeedManager.RssFeedAtomReadFeedNotificationKey, object: ["atomId": strongSelf.rssFeedAtom.id])
                }
            }
        }
        
        view.addSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAtomAction))
    }
    
    @objc func editAtomAction() {
        let vc = TitleAndDescViewController(with: .editRssFeedAtom(title: rssFeedAtom.title, description: rssFeedAtom.des, feedLink: rssFeedAtom.feedLink))
        vc.completionHandler = { [weak self] in
            guard let strongSelf = self else { return }
            if let atom = RssFeedAtom.getByFeedLink(strongSelf.rssFeedAtom.feedLink) {
                strongSelf.navigationItem.title = atom.title
            }
        }
        self.present(vc, animated: true)
    }
}
