//Made by Lumaa

import SwiftUI
import AlertToast
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage("bookmarkData") var downloadsBookmark: Data?
    
    @Binding var passwords: [Password]
    
    @State private var importFile: InputDoument = InputDoument(input: "")
    @State private var isImporting: Bool = false
    @State private var warnImporting: Bool = false
    @State private var isExporting: Bool = false
    
    @State private var importSuccessToast: Bool = false
    @State private var importFailToast: Bool = false
    @State private var exportSuccessToast: Bool = false
    @State private var exportFailToast: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    Section(header: Text("Importations et exportations"), footer: Text("L'utilisation de ses boutons son utiles lorsque vous changez d'appareil Apple pour transférer vos mot de passes d'un appareil à l'autre")) {
                        Button {
                            if passwords.count > 0 {
                                warnImporting.toggle()
                            }
                        } label: {
                            Text("Importer")
                        }
                        .confirmationDialog("Cette action remplacera vos mots de passes actuels, voulez-vous continuer ?", isPresented: $warnImporting, titleVisibility: .visible, actions: {
                            Button(role: .destructive) {
                                isImporting.toggle()
                            } label: {
                                Text("Continuer")
                            }
                            
                            Button("Annuler", role: .cancel) {
                                print("Canceled import")
                            }
                        })
                        
                        Button {
                            isExporting = true
                        } label: {
                            Text("Exporter")
                        }
                    }
                }
                .navigationTitle("Paramètres")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
        // MARK: - Toasts
        .toast(isPresenting: $importSuccessToast) {
            // success import
            AlertToast(displayMode: .alert, type: .complete(.green), title: "Vos mots de passes ont été importés !")
        }
        .toast(isPresenting: $importFailToast) {
            // fail import
            AlertToast(displayMode: .alert, type: .error(.red), title: "Erreur", subTitle: "Vos mot de passes n'ont pas pu être importés.")
        }
        .toast(isPresenting: $exportSuccessToast) {
            // success export
            AlertToast(displayMode: .alert, type: .complete(.green), title: "Vos mots de passes ont été exportés !")
        }
        .toast(isPresenting: $exportFailToast) {
            // fail export
            AlertToast(displayMode: .alert, type: .error(.red), title: "Erreur", subTitle: "Vos mot de passes n'ont pas pu être exportés.")
        }
        
        // MARK: - File Imports/Exports
        .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.json],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(_):
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            if selectedFile.startAccessingSecurityScopedResource() {
                                guard let fileContent = try Data(contentsOf: selectedFile) as Data? else { return }
                                do { selectedFile.stopAccessingSecurityScopedResource() }
                                
                                var newArray = [Password]()
                                let decoder = JSONDecoder()
                                
                                do {
                                    let passwordss = try decoder.decode([Password].self, from: fileContent)

                                    for password in passwordss {
                                        newArray.append(password)
                                    }
                                    
                                    passwords = newArray
                                    Password.save(passwords)
                                    
                                    importSuccessToast = true
                                } catch {
                                    print(error)
                                    importFailToast = true
                                }
                            } else {
                                // Handle denied access
                                importFailToast = true
                            }
                        } catch {
                            // Handle failure.
                            print("Unable to read file contents")
                            print(error.localizedDescription)
                            importFailToast = true
                        }
                    case .failure(let error):
                        print(error)
                        importFailToast = true
                    }
                }
        .fileExporter(isPresented: $isExporting, document: JSONFile(initialText: UserDefaults.standard.data(forKey: "passwords")!), contentType: .json, defaultFilename: "lockwords_\(Date.now.description.trimmingCharacters(in: .whitespacesAndNewlines)).json", onCompletion: { result in
            exportSuccessToast = true
        })
            
    }
}
