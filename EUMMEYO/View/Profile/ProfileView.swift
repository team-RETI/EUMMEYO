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
    
    @StateObject var viewModel: ProfileViewModel
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    // 회원 탈퇴 재확인 알람
    @State private var showDeleteUserAlarm: Bool = false
    @State private var selectedDate: (date: Date?, memoCount: Int?) = (nil, nil)
    
    // 잔디뷰 용도
    var today: Date {
        (Date().formattedStringYYYY_MM_dd).formattedDateYYYY_MM_dd
    }
    let weekdays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    // 중간 바인딩
    private var selectedDateBinding: Binding<Date?> {
        Binding {
            selectedDate.date
        } set: { newValue in
            selectedDate.date = newValue
        }
    }
    
    private var memoCountBinding: Binding<Int?> {
        Binding {
            selectedDate.memoCount
        } set: { newValue in
            selectedDate.memoCount = newValue
        }
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 클릭하면 selectedDate 초기화
                Color.mainWhite // 투명하지만 터치 감지됨
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            selectedDate = (nil, nil)
                        }
                    }
                
                VStack {
                    HStack(spacing: 20.scaled) {
                        Button {
                            exportToCSV(memos: viewModel.memoStore.memoList)
                        } label: {
                            Image(systemName: "arrow.down.to.line")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20.scaled, height: 20.scaled)
                                .foregroundColor(Color.mainBlack)
                                .overlay {
                                    Circle()
                                        .stroke(lineWidth: 0.5)
                                        .frame(width: 30.scaled, height: 30.scaled)
                                        .foregroundColor(.mainBlack)
                                }
                        }
                        
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
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20.scaled, height: 20.scaled)
                                .foregroundColor(Color.mainBlack)
                                .overlay {
                                    Circle()
                                        .stroke(lineWidth: 0.5)
                                        .frame(width: 30.scaled, height: 30.scaled)
                                        .foregroundColor(.mainBlack)
                                }
                        }
                    }
                    .hTrailing()
                    .padding(.trailing, 32.scaled)
                    .padding(.bottom)
                    
                    NavigationLink(destination: ProfileEditingView(viewModel: viewModel,name: viewModel.userInfo?.nickname ?? "이름", img2Str: viewModel.userInfo?.profile ?? "EUMMEYO_0")){
                        HStack(alignment: .center, spacing: 10.scaled) {
                            ZStack(alignment: .bottomTrailing) {
                                Image(uiImage: viewModel.convertStringToUIImage(viewModel.userInfo?.profile ?? "EUMMEYO_0") ?? .EUMMEYO_0)
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
                                Text(viewModel.userInfo?.nickname ?? "이름")
                                    .font(.system(size: 30.scaled))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.mainBlack)
                                
                                if let registerDate = viewModel.userInfo?.registerDate {
                                    Text("음메요와 함께한지 \(viewModel.calculateDaySince(registerDate))일 째")
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
                    
                    
                    HStack {
                        VStack(spacing: 3){
                            ForEach(weekdays, id: \.self) { day in
                                Text(day)
                                    .font(.subheadline.bold())
                                    .frame(height: 25.scaled)
                            }
                        }
                        ZStack {
                            ScrollViewReader { proxy in
                                ScrollView(.horizontal) {
                                    LazyHGrid(
                                        rows: Array(repeating: GridItem(.fixed(25.scaled), spacing: 3.scaled), count: 7),
                                        spacing: 3.scaled
                                    ) {
                                        let rowCount = viewModel.sortedJandies.count
                                        let colCount = viewModel.sortedJandies.first?.count ?? 0
                                        
                                        ForEach(0..<colCount, id: \.self) { col in
                                            ForEach(0..<rowCount, id: \.self) { row in
                                                cellView(row: row, col: col)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                                .task {
                                    // 약간의 지연을 줘서 LazyHGrid가 완전히 렌더링된 이후에 scrollTo 실행
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            proxy.scrollTo(today, anchor: .center)
                                        }
                                    }
                                }
                            }
                            
                            // 날짜 오버레이
                            if let date = selectedDate.date {
                                VStack(spacing: 4) {
                                    Text(date.formattedStringYYYY_MM_dd)
                                        .font(.headline)
                                    
                                    if let count = selectedDate.memoCount {
                                        Text("메모 \(count)개")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                                .transition(.scale)
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
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
                    NavigationLink(destination: webView(url: viewModel.infoUrl)){
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
                    
                    NavigationLink(destination: webView(url: viewModel.policyUrl)){
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
    
    @ViewBuilder
    private func cellView(row: Int, col: Int) -> some View {
        if row < viewModel.sortedJandies.count,
           col < viewModel.sortedJandies[row].count {
            
            let date = viewModel.sortedJandies[row][col]
            let userJandies = viewModel.userJandies[date]
            let color = viewModel.color(for: userJandies ?? 0)
            
            Group {
                if date == today {
                    Image(uiImage: .EUMMEYO_0)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25.scaled, height: 25.scaled)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.scaled)
                                .stroke(lineWidth: 0.5)
                                .frame(width: 25.scaled, height: 25.scaled)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 5.scaled)
                        .fill(color)
                        .frame(width: 25.scaled, height: 25.scaled)
                        .cornerRadius(2)
                }
            }
            .id(date)
            .onTapGesture {
                print("\(date.formattedStringYYYY_MM_dd) : \(userJandies ?? 0)")
                selectedDate = (date, userJandies)
            }
        }
    }
    
    func exportToCSV(memos: [Memo]) {
        // 1. CSV 문자열 구성
        var csvString = "제목,내용,날짜\n"
        for memo in memos {
            let row = "\"\(memo.title)\",\"\(memo.content)\",\"\(memo.date)\"\n"
            csvString.append(row)
        }
        
        // 2. 파일 경로 생성
        let fileName = "EUMMEYO_\(viewModel.userInfo?.nickname ?? "").csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // 3. 문자열을 파일로 저장
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            
            // 4. 공유 시트 열기
            let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            
        } catch {
            print("CSV 저장 실패: \(error)")
        }
    }
}



// 공지사항,개인정보처리방침 용 웹뷰
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

// MARK: - Index
extension View {
    func profileButtonStyle() -> some View {
        self
            .frame(height: 5)
            .padding()
            .padding(.horizontal)
        
    }
}
