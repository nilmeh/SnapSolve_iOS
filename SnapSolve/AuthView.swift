import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var error: String?
    @State private var loading = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var sessionManager: SessionManager
    @Namespace private var animation

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                
                VStack(spacing: 12) {
                    Image(systemName: "camera.aperture")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.blue)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 80, height: 80)
                        )
                    Text("SnapSolve")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                .padding(.bottom, 32)
                
                HStack(spacing: 32) {
                    TabButton(title: "Log In", isSelected: isLogin, namespace: animation) {
                        withAnimation { isLogin = true }
                    }
                    TabButton(title: "Sign Up", isSelected: !isLogin, namespace: animation) {
                        withAnimation { isLogin = false }
                    }
                }
                .padding(.bottom, 24)
                
                VStack(spacing: 16) {
                    if !isLogin {
                        TextField("Full Name", text: $name)
                            .textFieldStyle(MinimalTextFieldStyle())
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(MinimalTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(MinimalTextFieldStyle())
                    
                    if let error = error {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                    }
                    
                    Button(action: submit) {
                        ZStack {
                            Text(isLogin ? "Log In" : "Sign Up")
                                .font(.headline)
                                .opacity(loading ? 0 : 1)
                            
                            if loading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(loading)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                VStack(spacing: 16) {
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(.gray)
                        Text("or continue with").font(.subheadline).foregroundColor(.secondary)
                        Rectangle().frame(height: 1).foregroundColor(.gray)
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: loginWithGoogle) {
                        Label("Continue with Google", image: "googleIcon")
                            .labelStyle(TitleAndIconLabelStyle())
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 24 : 40)
            }
            .background(Color(.systemBackground))
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func submit() {
        hideKeyboard()
        error = nil
        loading = true
        
        if isLogin {
            AuthService.login(email: email, password: password) { result in
                loading = false
                switch result {
                case .success: sessionManager.listen()
                case .failure(let err): error = err.localizedDescription
                }
            }
        } else {
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                error = "Please enter your name."
                loading = false
                return
            }
            guard password.count >= 8 else {
                error = "Password must be at least 8 characters."
                loading = false
                return
            }
            AuthService.signup(name: name, email: email, password: password) { result in
                loading = false
                switch result {
                case .success: sessionManager.listen()
                case .failure(let err): error = err.localizedDescription
                }
            }
        }
    }
    
    private func loginWithGoogle() {
        hideKeyboard()
        loading = true
        AuthService.signInWithGoogle { result in
            loading = false
            switch result {
            case .success: sessionManager.listen()
            case .failure(let err): error = err.localizedDescription
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                ZStack {
                    if isSelected {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "tab_indicator", in: namespace)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 2)
                    }
                }
            }
            .frame(width: 100)
        }
    }
}

struct MinimalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}
