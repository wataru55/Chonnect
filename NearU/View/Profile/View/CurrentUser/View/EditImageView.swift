//
//  EditImageView.swift
//  NearU
//
//  Created by 高橋和 on 2025/06/09.
//

import SwiftUI
import PhotosUI

struct EditImageView: View {
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if let image = viewModel.backgroundImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.white)
                        .frame(width: UIScreen.main.bounds.width, height: 500)
                        .clipped()
                } else {
                    BackgroundImageView(user: viewModel.user, height: 500, isGradient: false)
                }
                
                HStack {
                    Button {
                        
                    } label: {
                        Text("削除")
                            .fontWeight(.bold)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    
                    Spacer()

                    Button {
                        Task {
                            await viewModel.updateProfileImage()
                        }
                    } label: {
                        Text("保存")
                            .fontWeight(.bold)
                            .font(.subheadline)
                            .foregroundStyle((viewModel.selectedBackgroundImage != nil) ? Color.mint : Color.gray)
                    }
                    .disabled(viewModel.selectedBackgroundImage == nil)
                    .padding(.horizontal)
                    .alert("Error", isPresented: $viewModel.isShowAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                        }
                    }
                    
                }
                .padding(.vertical, 10)
                
                PhotosPicker(
                    selection: $viewModel.selectedBackgroundImage,
                    matching: .images,
                    preferredItemEncoding: .current,
                    photoLibrary: .shared()
                ) {
                    Text("画像を選択してください")
                }
                .photosPickerStyle(.inline)
                .photosPickerDisabledCapabilities(.selectionActions)
                .photosPickerAccessoryVisibility(.hidden, edges: .all)

            }//vstack
            .ignoresSafeArea(edges: .top)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.resetSelectedImage()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.black)
                    }
                }
            }
            
            ViewStateOverlayView(state: $viewModel.state)
        }
        .modifier(EdgeSwipe())
        .onDisappear() {
            viewModel.resetSelectedImage()
        }
    }
}

//#Preview {
//    EditImageView()
//}
