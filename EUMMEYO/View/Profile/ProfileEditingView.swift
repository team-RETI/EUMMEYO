//
//  ProfileEditingView.swift
//  EUMMEYO
//
//  Created by eunchanKim on 4/26/25.
//

import SwiftUI

// dimiss 하기위해서는 struct형태의 뷰가 필요
struct ProfileEditingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var calendarViewModel: CalendarViewModel
    @AppStorage("jColor") private var jColor: Int = 0           // 잔디 색상 가져오기
    @State var name: String
    @State var img2Str: String = ""
    @State var restored: UIImage? = nil
    @State var image: UIImage = .EUMMEYO_0
    @State var color: Color = .black
    
    var images: [UIImage] = [.EUMMEYO_0, .EUMMEYO_1, .EUMMEYO_2, .EUMMEYO_3, .EUMMEYO_4]
    var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .brown, .cyan, .mainBlack, .mainPink, .mainGray]
    
    func convertUIImageToString(_ image: UIImage) -> String? {
        // Convert UIImage to JPEG data with compression quality
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        // Encode Data to Base64 string
        let base64String = imageData.base64EncodedString()
        return base64String
    }
    func convertStringToUIImage(_ base64String: String) -> UIImage? {
        // Decode Base64 string to Data
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        // Create UIImage from Data
        return UIImage(data: imageData)
    }
    
    var body: some View {
        VStack() {
            
            Image(uiImage: convertStringToUIImage(img2Str) ?? .EUMMEYO_0)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200.scaled, height: 200.scaled)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(lineWidth: 3)
                        .foregroundColor(Color(hex: jColor))
                }
            
            TextField("이름", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .frame(width: 100.scaled, height: 50.scaled)
                .padding(.bottom, 50.scaled)
            
            Divider()
            
            Text("캐릭터")
                .font(.headline)
                .hLeading()
                .padding(10.scaled)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images, id: \.self) { num in
                        Image(uiImage: num)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100.scaled, height: 100.scaled, alignment: .leading)
                            .clipShape(Circle())
                            .onTapGesture {
                                image = num
                                img2Str = convertUIImageToString(image) ?? ""
                                
                            }
                    }
                    .overlay{
                        Circle()
                            .stroke(lineWidth: 0.1)
                    }
                    
                }
            }
            .padding(.leading, 15.scaled)
            
            Text("잔디")
                .font(.headline)
                .hLeading()
                .padding(10.scaled)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(colors, id: \.self) { num in
                        Circle()
                            .frame(width: 35.scaled, height: 35.scaled, alignment: .leading)
                            .foregroundColor(num)
                            .onTapGesture {
                                color = num
                                jColor = color.toInt() ?? 0
                            }
                    }
                    .overlay{
                        Circle()
                            .stroke(lineWidth: 0.1)
                    }
                }
            }
            .padding(.leading, 15.scaled)
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    calendarViewModel.updateUserProfile(nick: name, photo: img2Str)
                    dismiss()
                }
                label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 16.scaled))
                        .foregroundColor(Color.mainBlack)
                    
                }
            }
        }
    }
}
