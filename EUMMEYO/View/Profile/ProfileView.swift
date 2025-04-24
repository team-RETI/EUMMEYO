//
//  ProfileView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI
import WebKit

struct ProfileView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false    // 다크모드 상태 가져오기
    @AppStorage("jColor") private var jColor: Int = 0           // 잔디 색상 가져오기
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    // 회원 탈퇴 재확인 알람
    @State private var showDeleteUserAlarm: Bool = false
    
    var body: some View {
        VStack {
            HeaderView()
        }
    }
    
    func HeaderView() -> some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        withAnimation(.spring(duration: 1)) {
                            isDarkMode.toggle()
                        }
                        // 진동 발생
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20.scaled, height: 20.scaled)
                            .foregroundColor(Color.mainBlack)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 0.5)
                                    .frame(width: 30.scaled, height: 30.scaled)
                                    .foregroundColor(.mainBlack)
                            }
                    }
                    .hTrailing()
                    .padding(.trailing, 32.scaled)
                    .padding(.bottom)
                }

                
                NavigationLink(destination: SetProfileView(calendarViewModel: calendarViewModel,name: calendarViewModel.user?.nickname ?? "이름", img2Str: calendarViewModel.user?.profile ?? "EUMMEYO_0")){
                    HStack(alignment: .center, spacing: 10.scaled) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: calendarViewModel.convertStringToUIImage(calendarViewModel.user?.profile ?? "EUMMEYO_0") ?? .EUMMEYO_0)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60.scaled, height: 60.scaled)
                                .clipShape(Circle())
                            
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .frame(width: 18.scaled, height: 18.scaled)
                                .foregroundColor(.black)
                                .offset(x: 4.scaled, y: 4.scaled)
                        }
                        
                        
                        VStack(alignment: .trailing) {
                            Text(calendarViewModel.user?.nickname ?? "이름")
                                .font(.system(size: 30.scaled))
                                .fontWeight(.bold)
                                .foregroundColor(Color.mainBlack)
                            
                            if let registerDate = calendarViewModel.user?.registerDate {
                                Text("음메요와 함께한지 \(calendarViewModel.calculateDaySince(registerDate))일 째")
                                    .font(.system(size: 15.scaled))
                                    .foregroundStyle(Color.mainBlack)
                            }
                        }
                        .hTrailing()
                        
                    }
                    .foregroundColor(.black)
                    .padding()
                    .padding(.horizontal)
                    .overlay{
                        RoundedRectangle(cornerRadius: 25.scaled)
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color(hex: jColor))
                    }
                    .padding(.horizontal)
                }
                
                ShowJandiesView(calendarViewModel: calendarViewModel)
                    .padding(.horizontal)
                Spacer()
                
                FooterView()
                Spacer()
            }
        }
        .alert(isPresented: $showDeleteUserAlarm) {
            Alert(
                title: Text("계정 삭제"),
                message: Text("정말로 계정을 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    authViewModel.send(action: .deleteUser)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func FooterView() -> some View {
        VStack {
            Divider()
            HStack {
                Image(systemName: "iphone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.scaled)
                    .foregroundColor(Color.mainBlack)
                
                Text("앱버전")
                    .foregroundColor(Color.mainBlack)
                    .font(.subheadline.bold())
                
                Spacer()
                
                Text(appVersion)
            }
            .hLeading()
            .profileButtonStyle()
            
            Divider()
            NavigationLink(destination: OnboardingView(onboardingViewModel: .init())) {
                HStack {
                    Image(systemName: "info.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.scaled)
                        .foregroundColor(Color.mainBlack)
                    Text("앱설명")
                        .foregroundColor(Color.mainBlack)
                        .font(.subheadline.bold())
                }
                .hLeading()
                .profileButtonStyle()
            }
            Divider()
            NavigationLink(destination: webView(url: calendarViewModel.infoUrl)){
                HStack {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.scaled)
                        .foregroundColor(Color.mainBlack)
                    
                    Text("공지사항")
                        .foregroundColor(Color.mainBlack)
                        .font(.subheadline.bold())
                }
                .hLeading()
                .profileButtonStyle()
            }
            Divider()
            Button {
                authViewModel.send(action: .logout)
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.scaled)
                    .foregroundColor(Color.mainBlack)
                
                
                Text("로그아웃")
                    .foregroundColor(Color.mainBlack)
                    .font(.subheadline.bold())
            }
            .hLeading()
            .profileButtonStyle()
            
            Divider()
            Button {
                showDeleteUserAlarm.toggle()
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.scaled)
                    .foregroundColor(Color.mainBlack)
                
                
                Text("회원탈퇴")
                    .foregroundColor(Color.mainBlack)
                    .font(.subheadline.bold())
            }
            .hLeading()
            .profileButtonStyle()
            
            Divider()
            Spacer()
            
            NavigationLink(destination: webView(url: calendarViewModel.policyUrl)){
                Text("개인정보처리방침")
                    .foregroundColor(Color.mainBlack)
                    .underline()
                    .font(.system(size: 16.scaled))
                    .fontWeight(.light)
            }
            
            Spacer()
        }
        
    }
}

struct ShowJandiesView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    var body: some View {
        // 요일 이름
        let weekdays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        let today = calendarViewModel.formatString(calendarViewModel.formatDate(Date()))
        HStack {
            VStack(spacing: 3){
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.subheadline.bold())
                        .frame(height: 25.scaled)
                }
            }
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHGrid(rows: Array(repeating: GridItem(.fixed(25.scaled), spacing: 3.scaled), count: 7), spacing: 3.scaled) {
                        ForEach(0..<100, id: \.self) { col in
                            ForEach(0..<100, id: \.self) { row in
                                if row < calendarViewModel.sortedJandies.count,
                                   col < calendarViewModel.sortedJandies[row].count {
                                    
                                    let date = calendarViewModel.sortedJandies[row][col]
                                    let userJandies = calendarViewModel.userJandies[date]
                                    let color = calendarViewModel.color(for: userJandies ?? 0)
                                    
                                    RoundedRectangle(cornerRadius: 5.scaled)
                                        .fill(color)
                                        .frame(width: 25.scaled, height: 25.scaled)
                                        .cornerRadius(2)
                                        .onTapGesture {
                                            print("\(date) : \(userJandies ?? 0)")
                                        }
                                        .id(date) // 👈 오늘 셀에 ID 지정
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(today, anchor: .center) // 👈 오늘 위치로 스크롤 이동
                    }
                }
            }
        }
    }
}

struct webView: UIViewRepresentable {
    
    var url: String
    
    func makeUIView(context: Context) -> WKWebView {
        // unwrapping
        guard let url = URL(string:  self.url) else {
            return WKWebView()
        }
        
        // webview instance
        let webview = WKWebView()
        // webview load
        webview.load(URLRequest(url: url))
        return webview
    }
    
    // update UIView
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}


// dimiss 하기위해서는 struct형태의 뷰가 필요
struct SetProfileView: View {
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


// MARK: - Index
extension View {
    func profileButtonStyle() -> some View {
        self
            .frame(height: 5)
            .padding()
            .padding(.horizontal)
        
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel(container: DIContainer(services: Services())))
        .environmentObject(CalendarViewModel(container: DIContainer(services: Services()), userId: "123"))
}
