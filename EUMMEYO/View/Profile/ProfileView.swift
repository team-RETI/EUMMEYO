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
            VStack(){
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
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.mainBlack)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 0.5)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.mainBlack)
                            }
                    }
                }
                .hTrailing()
                .padding(.trailing, 32)
                .padding(.bottom)
                
//                NavigationLink(destination: SetProfileView(viewModel: profileViewModel,name: profileViewModel.userInfo?.nickname ?? "이름", img2Str: profileViewModel.userInfo?.profile ?? "EUMMEYO_0")){
//                    HStack(alignment: .center, spacing: 10) {
//                        Image(uiImage: profileViewModel.convertStringToUIImage(profileViewModel.userInfo?.profile ?? "EUMMEYO_0") ?? .EUMMEYO_0)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 60, height: 60)
//                            .clipShape(Circle())
//                        
//                        VStack(alignment: .trailing) {
//                            Text(profileViewModel.userInfo?.nickname ?? "이름")
//                                .font(.system(size: 30))
//                                .fontWeight(.bold)
//                                .foregroundColor(Color.mainBlack)
//                            
//                            
//                            if let registerDate = profileViewModel.userInfo?.registerDate {
//                                Text("음메요와 함께한지 \(profileViewModel.calculateDaySince(registerDate))일 째")
//                                    .font(.system(size: 15))
//                                    .foregroundStyle(Color.mainBlack)
//                            }
//                        }
//                        .hTrailing()
//                        
//                    }
                NavigationLink(destination: SetProfileView(calendarViewModel: calendarViewModel,name: calendarViewModel.user?.nickname ?? "이름", img2Str: calendarViewModel.user?.profile ?? "EUMMEYO_0")){
                        HStack(alignment: .center, spacing: 10) {
                            Image(uiImage: calendarViewModel.convertStringToUIImage(calendarViewModel.user?.profile ?? "EUMMEYO_0") ?? .EUMMEYO_0)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            
                            VStack(alignment: .trailing) {
                                Text(calendarViewModel.user?.nickname ?? "이름")
                                    .font(.system(size: 30))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.mainBlack)
                                
                                
                                if let registerDate = calendarViewModel.user?.registerDate {
                                    Text("음메요와 함께한지 \(calendarViewModel.calculateDaySince(registerDate))일 째")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.mainBlack)
                                }
                            }
                            .hTrailing()
                            
                        }
                    .foregroundColor(.black)
                    .padding()
                    .padding(.horizontal)
                    .overlay{
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color(hex: jColor))
                    }
                    .padding(.horizontal)
                }
//                .environmentObject(calendarViewModel)
                
                ShowJandiesView(calendarViewModel: calendarViewModel)
                    .padding()
                
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
                    .frame(width: 20)
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
                        .frame(width: 20)
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
                        .frame(width: 20)
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
                    .frame(width: 20)
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
                    .frame(width: 20)
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
                    .font(.system(size: 16))
                    .fontWeight(.light)
            }
            
            Spacer()
        }
        
    }
}

struct ShowJandiesView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
//    @ObservedObject var profileViewModel: ProfileViewModel
    
    // 요일 이름
    let weekdays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    
    var body: some View {
        HStack {
            VStack(spacing: 3){
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.subheadline.bold())
                        .frame(height: 25)
                }
            }
            ScrollView(.horizontal) {
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(25), spacing: 3), count: 7), spacing: 3) {
                    ForEach(0..<100, id: \.self) { col in
                        ForEach(0..<100, id: \.self) { row in
                            
                           
                            /*
                             MARK: [문제점] Error: Index out of range 에러 발생
                             - calendarViewModel.sortedJandies[row][col] 접근 시 배열 범위를 벗어난 인덱스에 접근하여 에러 발생
                             - 즉 배열이 초기화되기 전인데 접근하려고 함
                             - iphone 15 pro max에서는 괜찮지만 iphone 13 mini처럼 작은 화면에서는 view가 더 빠르게 렌더링되어 배열 초기화보다 먼저 접근하게 됨
                             - 예시로 작은 기기에서는 View가 먼저 렌더링되고 배열이 아직 준비되지 않았을 때, → row = 6인데 sortedJandies.count = 3일 수도 있어서 index out of range 발생!
               
                             */
//                            if row < 7, col < 53 {
//                                let date = calendarViewModel.sortedJandies[row][col]
//                                let userJandies = calendarViewModel.userJandies[date]
//                                let color = calendarViewModel.color(for: userJandies ?? 0)
//                                
//                                Rectangle()
//                                    .fill(color)
//                                    .frame(width: 25, height: 25)
//                                    .cornerRadius(2)
//                                    .onTapGesture {
//                                        print("\(date) : \(userJandies ?? 0)")
//                                    }
//                            }
                            
                            /*
                             [해결 방법]

                             - 기기마다 렌더링 속도가 달라 배열 초기화보다 View가 먼저 그려질 수 있으므로, 배열 접근 전 반드시 index 유효성 체크가 필요하다.
                             */
                            if row < calendarViewModel.sortedJandies.count,
                               col < calendarViewModel.sortedJandies[row].count {
                                
                                let date = calendarViewModel.sortedJandies[row][col]
                                let userJandies = calendarViewModel.userJandies[date]
                                let color = calendarViewModel.color(for: userJandies ?? 0)
                                
                                Rectangle()
                                    .fill(color)
                                    .frame(width: 25, height: 25)
                                    .cornerRadius(2)
                                    .onTapGesture {
                                        print("\(date) : \(userJandies ?? 0)")
                                    }
                            }

                        }
                    }
                }
                .padding()
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
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(lineWidth: 3)
                        .foregroundColor(Color(hex: jColor))
                }
            
            TextField("이름", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .frame(width: 100, height: 50)
                .padding(.bottom, 50)
            
            Divider()
            
            Text("캐릭터")
                .font(.headline)
                .hLeading()
                .padding(10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images, id: \.self) { num in
                        Image(uiImage: num)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100, alignment: .leading)
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
            .padding(.leading, 15)
            
            Text("잔디")
                .font(.headline)
                .hLeading()
                .padding(10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(colors, id: \.self) { num in
                        Circle()
                            .frame(width: 35, height: 35, alignment: .leading)
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
            .padding(.leading, 15)
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    calendarViewModel.updateUserProfile(nick: name, photo: img2Str)
//                    calendarViewModel.getUserMemos()
                    dismiss()
                }
                label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 16))
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
        //.environmentObject(DIContainer(services: Services()))
        .environmentObject(AuthenticationViewModel(container: DIContainer(services: Services())))
        .environmentObject(CalendarViewModel(container: DIContainer(services: Services()), userId: "123"))
}
