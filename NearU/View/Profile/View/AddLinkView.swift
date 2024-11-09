//
//  AddLinkView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/05.
//

import SwiftUI

struct AddLinkView: View {
    @State private var url = ""
    @State private var selectedSNS: String?
    
    @Binding var isPresented: Bool

    @StateObject var viewModel: AddLinkViewModel

    @Environment(\.colorScheme) private var colorScheme

    // 計算プロパティとしてsnsOptionsを定義
    var snsOptions: [SNSOption] {
        [
            SNSOption(
                name: "GitHub",
                icon: colorScheme == .dark ? "GitHub-white" : "GitHub",
                color: colorScheme == .dark ? .white : .black
            ),
            SNSOption(name: "X (Twitter)", icon: "X (Twitter)", color: .black),
            SNSOption(name: "Instagram", icon: "Instagram", color: .purple),
            SNSOption(name: "Facebook", icon: "Facebook", color: .blue),
            SNSOption(name: "Youtube", icon: "Youtube", color: .red),
            SNSOption(name: "Other", icon: "link", color: .gray)
        ]
    }

    init(isPresented: Binding<Bool>, user: User) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: AddLinkViewModel(user: user))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(content: {
                    Picker("SNS", selection: $viewModel.selectedSNS) {
                        ForEach(snsOptions) { option in
                            HStack {
                                if let uiImage = UIImage(named: option.icon) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image(systemName: option.icon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }

                                Text(option.name)
                                    .foregroundStyle(option.color)

                            }
                            .tag(option.name)
                        }
                    } //picker
                    .pickerStyle(WheelPickerStyle())

                    TextField("URLを入力", text: $viewModel.sns_url)
                        .modifier(URLFieldModifier())
                }, header: {
                    HStack{
                        Text("SNS")
                            .font(Font.subheadline)
                    }
                })
                
                Section(content: {
                    ForEach(viewModel.urls.indices, id: \.self) { index in
                        TextField("URLを入力", text: $viewModel.urls[index])
                            .modifier(URLFieldModifier())
                    }
                    
                    Button(action: {
                        viewModel.urls.append("") // ViewModelのurlsに追加
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("URLを追加")
                                .font(.system(size: 10))
                        }
                    }
                    .padding(.top, 10)
                }, header: {
                    HStack {
                        Text("その他")
                            .font(Font.subheadline)
                    }
                })
                
            } //form
            .navigationTitle("Add Link")
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
        }//navigationstack
    }
}

struct SNSOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}


#Preview {
    AddLinkView(isPresented: .constant(true), user: User.MOCK_USERS[0])
}
