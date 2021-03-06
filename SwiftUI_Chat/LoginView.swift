//
//  ContentView.swift
//  SwiftUI_Chat
//
//  Created by tw on 2022/04/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    let didCompletedLoginProccess: () -> ()
	
	@State private var isLoginMode = false
	@State private var email = ""
	@State private var password = ""
	@State private var loginStatusMessage = ""
	
	@State private var shouldShowImagePicker = false
	
	var body: some View {
		NavigationView {
			ScrollView {
				
				VStack(spacing: 16) {
					Picker(selection: $isLoginMode, label: Text("Picker here")) {
						Text("Login")
							.tag(true)
						Text("Create Account")
							.tag(false)
					}.pickerStyle(.segmented)
						.padding()
					
					if !isLoginMode {
						Button {
							shouldShowImagePicker
								.toggle()
						} label: {
							
							VStack {
								
								if let image = self.image {
									Image(uiImage: image)
										.resizable()
										.frame(width: 128, height: 128)
										.scaledToFill()
										.cornerRadius(64)
								} else {
									Image(systemName: "person.fill")
										.font(.system(size: 64))
										.padding()
										.foregroundColor(Color(.label))
								}
							}
							.overlay(RoundedRectangle(cornerRadius: 64)
												.stroke(Color.black, lineWidth: 3)
							)
						}
					}
					
					Group {
						TextField("Email", text: $email)
							.keyboardType(.emailAddress)
							.autocapitalization(.none)
						SecureField("password", text: $password)
					}
					.padding(12)
					.background(Color.white)
					
					
					Button {
						handleAction()
					} label: {
						HStack {
							Spacer()
							Text(isLoginMode ? "Log in" : "Create Account")
								.foregroundColor(.white)
								.padding(.vertical, 10)
								.font(.system(size: 14, weight: .semibold))
							Spacer()
						}.background(Color.blue)
					}
				}
				Text(self.loginStatusMessage)
					.foregroundColor(.red)
				
			}
			.navigationTitle(isLoginMode ? "Log in" : "Create Account")
			.background(Color(.init(white: 0, alpha: 0.05))
										.ignoresSafeArea())
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
			ImagePicker(image: $image)
		}
	}
	
	@State var image: UIImage?
	
	private func handleAction() {
		if isLoginMode {
			print("isLogin True")
			loginUser()
		} else {
			createNewAccount()
			print("isLogin false")
		}
	}
	
	private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avator image"
            return
        }
        
		FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
			if let error = error {
				self.loginStatusMessage = "failed \(error)"
				return
			}
			
			self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
			
			self.persistImageToStorage()
		}
	}
	
	private func persistImageToStorage() {
		
//		let fileName = UUID().uuidString
		guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
		let ref = FirebaseManager.shared.storage.reference(withPath: uid)
		guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
		ref.putData(imageData, metadata: nil) { metadata , error in
			if let err = error {
				self.loginStatusMessage = "Failed to push \(err)"
				return 
			}
			
			ref.downloadURL { url, err in
				if let err = err {
					self.loginStatusMessage = "Failed to retrieve \(err)"
					return
				}
				
				self.loginStatusMessage = "Successfully stored url: \(url?.absoluteString ?? "")"
				print(url?.absoluteString)
				
				guard let url = url else { return }
				self.storeUserInformation(imageProfileUrl: url)
			}
		}
	}
	
	private func storeUserInformation(imageProfileUrl: URL) {
			guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
			let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
			FirebaseManager.shared.firestore.collection("users")
					.document(uid).setData(userData) { err in
							if let err = err {
									print(err)
									self.loginStatusMessage = "\(err)"
									return
							}

							print("Success")
                        
                        self.didCompletedLoginProccess()
					}
	}
	
	private func loginUser() {
		FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
			if let error = error {
				self.loginStatusMessage = "failed \(error)"
				return
			}
			
			self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompletedLoginProccess()
		}
	}
	
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
        LoginView(didCompletedLoginProccess: {
            
        })
	}
}
