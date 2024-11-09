import SwiftUI

struct EditAbstractView: View {
    @State private var url = ""
    @State private var selectedSNS: String?
    
    @Binding var isPresented: Bool

    @StateObject var viewModel: AddLinkViewModel
    @ObservedObject private var abstractModel = CurrentUserProfileViewModel()

    init(isPresented: Binding<Bool>, user: User) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: AddLinkViewModel(user: user))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98) // シート全体の背景色
                    .ignoresSafeArea()

                Form {
                    Section(content: {
                        ForEach(viewModel.urls.indices, id: \.self) { index in
                            TextField("URLを入力", text: $viewModel.urls[index])
                                .foregroundColor(Color(.systemMint))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .padding(10)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            viewModel.urls.append("") // ViewModelのurlsに追加
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("URLを追加")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                        }
                        .padding(.top, 10)
                    }, header: {
                        HStack {
                            Text("記事等のURLを追加する")
                                .font(Font.subheadline)
                        }
                    })
                    
                    Section {
                        VStack(alignment: .trailing, spacing: 20) {
                            if abstractModel.abstractUrls.isEmpty {
                                Text("リンクがありません")
                                    .foregroundColor(.orange)
                                    .padding()
                            } else {
                                ForEach(abstractModel.abstractUrls, id: \.self) { url in
                                    SiteLinkButtonView(
                                        abstract_url: url,
                                        showDeleteButton: true
                                    ) {
                                        deleteAbstract(url: url)
                                    }
                                }
                            }
                        }
                        .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                    }
                } // Form
                .background(Color.clear)
            } // ZStack
            .navigationTitle("Edit abstract")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Done") {
                Task {
                    try await viewModel.updateSNSLink()
                    try await AuthService.shared.loadUserData()
                    await MainActor.run {
                        isPresented = false
                    }
                }
            })
            .onAppear {
                Task {
                    await abstractModel.loadAbstractLinks()
                }
            }
        } // NavigationStack
    }
    private func deleteAbstract(url: String) {
       Task {
           await abstractModel.deleteAbstractLink(url: url)
           await abstractModel.loadAbstractLinks()
       }
   }
}

