//
//  ContentView.swift
//  SwiftUI_Chat
//
//  Created by tw on 2022/04/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

class FirebaseManager: NSObject {
	
	let auth: Auth
	
	static let shared = FirebaseManager()
	
	override init() {
		FirebaseApp.configure()
		
		self.auth = Auth.auth()
	
		super.init()
	}
}

struct LoginView: View {
	
	@State var isLoginMode = false
	@State var email = ""
	@State var password = ""
	@State var loginStatusMessage = ""
	
	@State var shouldShowImagePicker = false
	
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
							Image(systemName: "person.fill")
								.font(.system(size: 64))
								.padding()
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
	}
	
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
		FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
			if let error = error {
				self.loginStatusMessage = "failed \(error)"
				return
			}
			
			self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
		}
	}
	
	private func loginUser() {
		FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
			if let error = error {
				self.loginStatusMessage = "failed \(error)"
				return
			}
			
			self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
		}
	}
	
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
	}
}
