//
//  PersonalAccessView.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/28.
//

import SwiftUI

struct PersonalAccessView: View {
    
    @State var accessToken: String = ""
    @State var showErrorMessage = false
    @State var isLoading = false

    @Environment(\.dismiss) var dismiss

    var completionHandler: ((Bool) -> ())? = nil
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Image(uiImage: UIImage(named: "close")!)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        dismiss()
                    }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            Text("Privacy Licence: We will not collect your github personal key, even more, wo dont have own server.")
                .padding(.horizontal)
                .foregroundColor(Color(uiColor: .textGrayColor))
            
            VStack {
                HStack {
                    TextField("Personal Access Token", text: $accessToken)
                        .textFieldStyle(.plain)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 1)
                )
                
                if showErrorMessage {
                    HStack {
                        Text("Invalid Personal Access Token!!!")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .padding()
            
            Button(action: {
                guard !isLoading else { return }
                guard !accessToken.isEmpty else {
                    showErrorMessage = true
                    return
                }
                isLoading = true
                
                Task {
                    defer {
                        isLoading = false
                    }

                    accessToken = "token \(accessToken)"
                    DJUserDefaults.setAccessToken(accessToken)
                    guard let _ = await LocalUserManager.loadViewer() else {
                        isLoading = false
                        showErrorMessage = true
                        return
                    }
                    completionHandler?(true)
                    dismiss()
                }
                
            }) {
                HStack(spacing: 15) {
                    Text("Login")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 44)
            .background(Color(with: 68, green: 73, blue: 82))
            .cornerRadius(6)
            .padding(EdgeInsets(top: 0, leading: 40, bottom: 40, trailing: 40))
            
            Spacer()
        }
        .padding(.top, 20)
    }
}

struct PersonalAccessView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalAccessView(accessToken: "")
    }
}
