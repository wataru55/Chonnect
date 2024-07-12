//
//  AddLinkView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/05.
//

import SwiftUI

struct SNSOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct AddLinkView: View {
    @State private var url = ""
    @State private var selectedSNS: String?

    @Binding var isPresented: Bool

    let snsOptions: [SNSOption] = [
        SNSOption(name: "X (Twitter)", icon: "twitter", color: .black),
        SNSOption(name: "Instagram", icon: "instagram", color: .purple),
        SNSOption(name: "Tiktok", icon: "tiktok", color: .indigo),
        SNSOption(name: "BeReal", icon: "bereal", color: .black),
        SNSOption(name: "Facebook", icon: "facebook", color: .blue),
        SNSOption(name: "Youtube", icon: "youtube", color: .red),
        SNSOption(name: "その他", icon: "link", color: .gray)
    ]

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(content: {
                    Picker("SNS", selection: $selectedSNS) {
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

                    TextField("URL", text: $url)
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
                isPresented = false
            })
        }//navigationstack
    }
}

#Preview {
    AddLinkView(isPresented: .constant(true))
}
