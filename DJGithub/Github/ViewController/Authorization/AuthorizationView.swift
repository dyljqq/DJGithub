//
//  AuthorizationView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/28.
//

import SwiftUI

struct AuthorizationView: View {
    
    var completionHandler: ((Bool) -> ())? = nil
    
    @State private var showingPopover = false
    @State private var showPersonalPopover = false
    
    @ViewBuilder private var personalAccessView: some View {
        PersonalAccessView { isSuccess in
            if isSuccess {
                completionHandler?(isSuccess)
            } else {
                showingPopover = false
                showPersonalPopover = false
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showingPopover.toggle()
                }) {
                    Text("Access Token")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
                .popover(isPresented: $showingPopover) {
                    PersonalAccessView { isSuccess in
                        completionHandler?(isSuccess)
                    }
                }
            }
            .padding()
            Spacer()
            VStack(spacing: 15) {
                Image(uiImage: UIImage(named: "AppIcon")!)
                    .resizable()
                    .frame(width: 100, height: 100)
                Text("DJGithub For Github")
                    .font(.system(size: 16))
                    .foregroundColor(Color(uiColor: UIColor.textColor))
            }

            Spacer()

            VStack {
                Button(action: {
                    showPersonalPopover.toggle()
                }) {
                    Text("Github Authorization")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 44)
                .background(Color(with: 68, green: 73, blue: 82))
                .cornerRadius(6)
                .padding(EdgeInsets(top: 0, leading: 40, bottom: 40, trailing: 40))
            }
            .popover(isPresented: $showPersonalPopover) {
                PersonalAccessView { isSuccess in
                    completionHandler?(isSuccess)
                }
            }
        }
    }
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView()
    }
}
