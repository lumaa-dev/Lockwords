//Made by Lumaa

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State var editMode: EditMode = .inactive
    @Environment(\.scenePhase) var scenePhase
    
    @State private var settingsOn: Bool = false
    @State private var isUnlocked: Bool = false
    @State private var isAuthenticating: Bool = false
    
    @State var search: String = ""
    @State var passwords: [Password] = []
    
    var body: some View {
        NavigationView {
            List {
                if isUnlocked {
                    if passwords.count > 0 {
                        ForEach(searchResults, id: \.self) { password in
                            NavigationLink(destination: PasswordView(passwords: $passwords, password: password)) {
                                HStack {
                                    Text(password.source)
                                    /*if editMode == .inactive {
                                        Spacer()
                                        xText(password.username)
                                            .foregroundColor(.gray)
                                            .opacity(0.5)
                                    }*/
                                }
                            }
                        }
                        .onDelete { passwords.remove(atOffsets: $0); Password.save(passwords) }
                        .onMove { passwords.move(fromOffsets: $0, toOffset: $1); Password.save(passwords) }
                    } else {
                        Text("Vous ne possédez pas de mot de passes")
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    }
                } else {
                    Label("Vous ne pouvez pas accéder aux mot de passes", systemImage: "xmark.shield.fill")
                        .foregroundColor(.red)
                        .ignoresSafeArea()
                }
            }
            .searchable(text: $search, prompt: "Recherchez des sources")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isUnlocked {
                        Button {
                            settingsOn.toggle()
                        } label: {
                            Image(systemName: "gear")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isUnlocked {
                        NavigationLink(destination: CreatePassword(passwords: $passwords)) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if isUnlocked {
                        EditButton()
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Mots de passes")
        }
        .sheet(isPresented: $settingsOn) {
            if isUnlocked {
                SettingsView(passwords: $passwords)
            }
        }
        .onAppear() {
            passwords = Password.load()
            
            if isUnlocked == false && isAuthenticating == false {
                authenticate()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                if isUnlocked == false && isAuthenticating == false {
                    authenticate()
                }
            }
            if newPhase == .background {
                isUnlocked = false
            }
        }
    }
    
    var searchResults: [Password] {
            if search.isEmpty {
                return passwords
            } else {
                return passwords.filter { $0.source.lowercased().contains(search.lowercased()) }
            }
        }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Déverouillez vos mots de passes"
            isAuthenticating = true
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    // authenticated
                    print("Authenticated")
                    isUnlocked = true
                } else {
                    // not authenticated
                }
            }
            
            isAuthenticating = false
        } else {
            // no biometrics
            isUnlocked = true
            isAuthenticating = false
        }
    }
}
