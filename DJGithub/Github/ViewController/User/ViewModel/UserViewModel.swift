//
//  UserViewModel.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/11/22.
//

import UIKit

@MainActor
struct UserViewModel {

    var userObserver: DJObserverable<UserViewer> = DJObserverable()
    
    var userViewer: UserViewer? {
        return userObserver.value
    }
    
    func fetchUser(with name: String) async {
        if name.isEmpty || ConfigManager.checkOwner(by: name),
           let userViewer = ConfigManager.viewer {
            userObserver.value = userViewer
        }
        
        Task.detached {
            if let viewer = await UserManager.fetchUserInfo(by: name) {
                await MainActor.run {
                    userObserver.value = viewer
                    if ConfigManager.checkOwner(by: viewer.login) {
                        LocalUserManager.saveUser(viewer)
                    }
                }
            }
        }
    }
    
    mutating func update(_ userViewer: UserViewer?) {
        userObserver.value = userViewer
    }
}
