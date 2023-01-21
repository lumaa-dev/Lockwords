//Made by Lumaa

import SwiftUI
import AlertToast
import UniformTypeIdentifiers

struct PasswordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var passwords: [Password]
    @State var password: Password = Password.init(source: "lumination.brebond.com", username: "Lumaa", password: "BackroomsMod <3")
    @State var ii: Int = -1
    
    @State private var succeedBanner: Bool = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Source")
                    Text(password.source)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack {
                    Text("Nom d'utilisateur")
                    Text(password.username)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .contextMenu {
                            Button() {
                                UIPasteboard.general.setValue(password.username, forPasteboardType: UTType.plainText.identifier)
                                succeedBanner = true
                            } label: {
                                Label("Copier", systemImage: "doc.on.clipboard")
                            }
                        }
                }
                HStack {
                    Text("Mot de passe")
                    Text(password.password)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.monospaced(.body)())
                        .contextMenu {
                            Button() {
                                UIPasteboard.general.setValue(password.password, forPasteboardType: UTType.plainText.identifier)
                                succeedBanner = true
                            } label: {
                                Label("Copier", systemImage: "doc.on.clipboard")
                            }
                        }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    let i = passwords.firstIndex(of: password) ?? passwords.count - 1
                    
                    passwords.remove(at: i)
                } label: {
                    Label("Supprimer", systemImage: "trash")
                        .foregroundColor(.red)
                }
                
                NavigationLink {
                    CreatePassword(passwords: $passwords, source: password.source, username: password.username, password: password.password, passwordVisible: true, index: ii, modelPassword: password)
                } label: {
                    Label("Modifier", systemImage: "pencil")
                        .foregroundColor(.blue)
                }
                .disabled(true)
            }
        }
        .navigationTitle(password.source)
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $succeedBanner, offsetY: 40) {
            AlertToast(displayMode: .hud, type: .complete(.green), title: "Copié !")
        }
        .onAppear {
            if (ii == -1) {
                ii = passwords.firstIndex(of: password)!
                password = passwords[ii]
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct CreatePassword: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var passwords: [Password]
    
    // generic vars
    @State var source: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var passwordVisible: Bool = false
    
    // edit vars
    @State var index: Int = -1
    @State var modelPassword: Password = Password.init(source: "lumination.brebond.com", username: "Lumaa", password: "BackroomsMod <3")
    
    var body: some View {
        Form {
            Section {
                TextField("Source", text: $source)
                TextField("Nom d'utilisateur", text: $username)
                HStack {
                    if passwordVisible == false { SecureField("Mot de passe", text: $password) } else { TextField("Mot de passe", text: $password) }
                    
                    Button() {
                        passwordVisible.toggle()
                    } label: {
                        if passwordVisible { Image(systemName: "eye.slash") } else { Image(systemName: "eye") }
                    }
                    .frame(width: 20, height: 20)
                }
            }
            
            Section {
                Button() {
                    if (index == -1) {
                        create()
                    } else {
                        edit()
                    }
                } label: {
                    Label(index == -1 ? "Créer ce mot de passe" : "Modifier ce mot de passe", systemImage: "checkmark.shield")
                }
                .disabled(source.isEmpty || username.isEmpty || password.isEmpty)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func create() {
        if (index == -1) {
            let new: Password = Password.init(source: source, username: username, password: password)
            
            passwords.append(new)
            Password.save(passwords)
            
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func edit() {
        if (index != -1) {
            passwords[index] = Password.init(source: source, username: username, password: password)
            Password.save(passwords)
            
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}
