//
//  EditImageView.swift
//  NearU
//
//  Created by 高橋和 on 2025/06/09.
//

import SwiftUI
import PhotosUI

struct EditImageView: View {
    @StateObject var viewModel = EditImageViewModel()
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
                .frame(width: UIScreen.main.bounds.width, alignment: .trailing)
                .padding(.vertical, 10)
                .padding(.trailing, 20)
                .alert("Error", isPresented: Binding<Bool> (
                    get: { viewModel.alertType != nil },
                    set: { if !$0 { viewModel.alertType = nil } }
                ), presenting: viewModel.alertType) { alert in
                    switch alert {
                    case .okOnly:
                        Button("OK", role: .cancel) { }
                        
                    case .retryURLFetch:
                        Button("キャンセル") { }
                        Button("再試行") {
                            Task {
                                await viewModel.retrySaveProcess()
                            }
                        }
                        
                    case .retrySaveToFireStore:
                        Button("キャンセル") { }
                        Button("再試行") {
                            Task {
                                await viewModel.retrySaveProcess()
                            }
                        }
                    }
                } message: { alert in
                    Text(alert.message)
                }
                
                
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
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                Color.black.opacity(0.8)
                                    .clipShape(Circle())
                            )
                    }
                }
            }
            
            ViewStateOverlayView(state: $viewModel.state)
        }
        .navigationBarBackButtonHidden()
        .modifier(EdgeSwipe())
        .onDisappear() {
            viewModel.resetSelectedImage()
        }
    }
}

//#Preview {
//    EditImageView()
//}
