//
//  ProfileView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct ProfileView: View {

    @State private var darkMode = false
    @State private var engMode = false
    
    
    // 예제 데이터: 날짜별 활동량 (0~5)
    let activityData: [Date: Int] = {
        var data = [Date: Int]()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -364, to: Date())! // 1년 전부터 시작
        for i in 0..<365 {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            data[date] = Int.random(in: 0...5)
        }
        return data
    }()
    
    // 색상 팔레트: 활동량에 따라 다르게 설정
    func color(for level: Int) -> Color {
        switch level {
        case 0: return Color.gray.opacity(0.2)
        case 1: return Color.green.opacity(0.4)
        case 2: return Color.green.opacity(0.6)
        case 3: return Color.green.opacity(0.8)
        case 4: return Color.green.opacity(0.9)
        default: return Color.green
        }
    }
    
    // 요일 이름 (월, 화, ...)
    let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    
    // 날짜 정렬 함수: 일요일부터 시작
    func sortedDates() -> [Date] {
        let calendar = Calendar.current
        return activityData.keys.sorted { $0 < $1 }.filter { calendar.component(.weekday, from: $0) == 1 || true }
    }

    
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
                            darkMode.toggle()
                        }
                    } label: {
                        Image(systemName: darkMode ? "sun.max.fill" : "moon")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.black)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 0.5)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.black)
                            }
                    }
                    
                    
                    Button {
                        withAnimation(.spring(duration: 1)) {
                            engMode.toggle()
                        }
                    } label: {
                        Image(systemName: engMode ? "a.circle.fill" : "swedishkronasign.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.black)
                    }
                    .padding(.leading,10)
                }
                .hTrailing()
                .padding(.trailing, 32)
                .padding(.top, 10)
                
                NavigationLink(destination: SetProfileView()) {
                    HStack(alignment: .center, spacing: 10) {
                        
                        Image("DOGE")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        
                        VStack(alignment: .trailing) {
                            Text("이름")
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                            Text("음메요와 함께한지 2500일 째")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.black)
                        }
                        .hTrailing()
                        
                    }
                    .foregroundColor(.black)
                    .padding()
                    .padding(.horizontal)
                }

                
                ShowJandiesView()
                    .padding()
                
                FooterView()
                
                Spacer()
            }
        }
    }
    
    
    func ShowJandiesView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack {
                VStack(alignment: .leading) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 25))
                            .fontWeight(.ultraLight)
                    }
                }
                
                // 잔디 그리드
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(25), spacing: 4), count: 7), spacing: 4) {
                    ForEach(sortedDates(), id: \.self) { date in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color(for: activityData[date] ?? 0))
                            .frame(width: 25, height: 25)
                            .onTapGesture {
                                print("Date: \(date), Activity: \(activityData[date] ?? 0)")
                            }
                    }
                }
            }
            
        }
    }
    
    func NotiListView() -> some View {
        Text("Notiview")
    }
    func FooterView() -> some View {
        VStack {
            HStack(spacing: 20) {
                NavigationLink(destination: OnboardingView(onboardingViewModel: .init())) {
                    HStack {
                        Image(systemName: "info.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color.mainBlack)
                        Text("앱설명")
                            .foregroundColor(Color.mainBlack)
                            .fontWeight(.light)
                    }
                    .frame(width: 90)
                    .padding(.vertical, 5)
                    .padding(.horizontal,10)
                    .overlay{
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(lineWidth: 0.5)
                            .foregroundColor(Color.mainBlack)
                    }
                }
                
                NavigationLink(destination: NotiListView()){
                    HStack {
                        Image(systemName: "bell.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color.mainBlack)
                        
                        Text("공지사항")
                            .foregroundColor(Color.mainBlack)
                            .fontWeight(.light)
                    }
                    .frame(width: 90)
                    .padding(.vertical, 5)
                    .padding(.horizontal,10)
                    .overlay{
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(lineWidth: 0.5)
                            .foregroundColor(Color.mainBlack)
                    }
                }
                
                Button {
                    //authViewModel.send(action: .logout)
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(Color.mainBlack)
                    
                    Text("로그아웃")
                        .foregroundColor(Color.mainBlack)
                        .fontWeight(.light)
                }
                .frame(width: 90)
                .padding(.vertical, 5)
                .padding(.horizontal,10)
                .overlay{
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 0.5)
                }
            }
            Spacer()
            
            Text("음메요 v1.0.0")
                .foregroundColor(Color.mainBlack)
                .font(.system(size: 16))
                .fontWeight(.light)
            
            Button {
                
            } label: {
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

// dimiss 하기위해서는 struct형태의 뷰가 필요
struct SetProfileView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    @State var name = ""
    @State var image: UIImage = .DOGE
    @State var color: Color = .black
    var images: [UIImage] = [.DOGE, .COW, .user1, .user2]
    var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink, .brown, .cyan]
    
    var body: some View {
        VStack() {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(lineWidth: 1.5)
                        .foregroundColor(color)
                }

            TextField("DOGE", text: $name)
                .frame(width: 50,height: 50,alignment: .center)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.1)
                        .foregroundColor(Color.mainBlack)
                }
                .padding(.bottom, 50)
            
            Rectangle()
                .stroke(lineWidth: 0.2)
                .frame(height: 1)
                .foregroundColor(Color.mainBlack)
                

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
                            }
                    }
                    .overlay{
                        Circle()
                            .stroke(lineWidth: 0.1)
                    }

                }
            }
            .padding(.leading, 15)
            
            Text("테두리")
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("완료")
                        .font(.system(size: 16))
                        .foregroundColor(Color.mainBlack)

                }
            }
        }
        
    }
}

#Preview {
    ProfileView()
    
}

