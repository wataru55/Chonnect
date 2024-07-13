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

    let snsOptions: [SNSOption] = [
        SNSOption(name: "X (Twitter)", icon: "twitter", color: .primary),
        SNSOption(name: "Instagram", icon: "instagram", color: .purple),
        SNSOption(name: "Tiktok", icon: "tiktok", color: .indigo),
        SNSOption(name: "BeReal", icon: "bereal", color: .primary),
        SNSOption(name: "Facebook", icon: "facebook", color: .blue),
        SNSOption(name: "Youtube", icon: "youtube", color: .red),
        SNSOption(name: "その他", icon: "link", color: .gray)
    ]

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
                                Image(option.icon)
                                Text(option.name)
                                    .foregroundStyle(option.color)

                            }
                            .tag(option.name)
                        }
                    } //picker
                    .pickerStyle(WheelPickerStyle())

                    TextField("URL", text: $viewModel.sns_url)
                        .foregroundColor(Color(.systemMint))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding(10)
                        .cornerRadius(10)
                }, header: {
                    HStack{
                        Text("Major SNS")
                            .font(Font.subheadline)
                    }
                })
            } //form
            .navigationTitle("Add Link")
            .navigationBarItems(leading: Button("キャンセル") {
                isPresented = false
            }, trailing: Button("追加") {
                Task {
                    try await viewModel.updateSNSLink()
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
