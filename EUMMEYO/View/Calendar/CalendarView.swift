//
//  CalendatView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct CalendarView: View {
    // @Binding var isShadowActive: Bool // 그림자 상태 전달
    
    // MARK: - ViewModel을 환경 객체로 주입받아 데이터를 공유
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    // MARK: @Namespace는 Matched Geometry Effect를 구현하기 위한 도구로, 두 뷰 간의 부드러운 전환 애니메이션을 제공
    @Namespace var animation    // (오늘 날짜와 선택된 날짜 간의 부드러운 애니메이션 효과)
    
    // MARK: - 추가 버튼 표시 상태(플러스 버튼 클릭 시 음성 메모 버튼과 텍스트 메모 버튼 표시 여부 제어)
    @State private var showAdditionalButtons = false
    
    // MARK: - 전체 달력 보기 상태
    @State private var isExpanded = false
    
    @State private var showAddMemoView = false
    @State private var isVoiceMemo = false

    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - 사용 근거: ScrollView와 플로팅버튼(떠있는 것처럼 보이는 버튼)이 서로 겹치지 않도록 배치
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        // MARK: - 사용 근거: 스크롤 가능한 리스트 + 성능을 위해 뷰 지연 로드
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            Section {
                                if isExpanded {
                                    FullCalendarView() // 월간 달력 보기
                                } else {
                                    WeekCalendarView() // 주간 달력 보기
                                }
                                MemosListView()
                            } header: {
                                HeaderView()
                            }
                        }
                    }
                    
                    // 버튼 외의 뷰에 그림자 레이어 추가
                    /*
                     if showAdditionalButtons {
                     Color.black.opacity(0.3)
                     .ignoresSafeArea()
                     }
                     */
                    
                    // MARK: - 플로팅 버튼
                    HStack {
                        Spacer()
                        
                        VStack {
                            Spacer()
                            if showAdditionalButtons {
                                VStack(spacing: 30) {
                                    Button {
                                        isVoiceMemo = true
                                        showAddMemoView = true
                                        showAdditionalButtons.toggle()
                                    } label: {
                                        Image(systemName: "mic")
                                            .padding()
                                            .foregroundColor(.black)
                                            .background(
                                                Circle() // 원형 배경
                                                    .fill(.white)
                                                    .frame(width: 60, height: 60)
                                            )
                                            .overlay {
                                                Circle()
                                                    .stroke(lineWidth: 1)
                                                    .frame(width: 60, height: 60)
                                                    .foregroundColor(.black)    // 테두리색
                                            }
                                    }
                                    
                                    
                                    Button {
                                        isVoiceMemo = false
                                        showAddMemoView = true
                                        showAdditionalButtons.toggle()
                                    } label: {
                                        Image(systemName: "doc.text")
                                            .padding()
                                            .foregroundColor(.black)
                                            .background(
                                                Circle() // 원형 배경
                                                    .fill(.white)
                                                    .frame(width: 60, height: 60)
                                            )
                                            .overlay {
                                                Circle()
                                                    .stroke(lineWidth: 1)
                                                    .frame(width: 60, height: 60)
                                                    .foregroundColor(.black)    // 테두리색
                                            }
                                    }
                                }
                                .padding(.bottom, 20)
                            }
                            
                            
                            Button {
                                withAnimation(.spring()) {
                                    showAdditionalButtons.toggle()
                                }
                            } label: {
                                Image(systemName: showAdditionalButtons ? "xmark" : "plus")
                                    .font(.system(size: 25, weight: .bold))
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 60, height: 60)
                                    )
                                    .rotationEffect(.degrees(showAdditionalButtons ? 90 : 0))
                            }
                        }
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 20)
                    .background(.clear) // 배경을 명시적으로 투명하게 설정
                    .sheet(isPresented: $showAddMemoView) {
                        AddMemoView(isVoice: isVoiceMemo)
                            .environmentObject(calendarViewModel)
                    }
                }
            }
            
            // 상단 안전 영역 무시
            // .container: 뷰의 배경과 같은 큰 영역에 영향을 주는 컨테이너를 무시
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    // MARK: - Header View(상단에 12월, 2024 표시)
    private func HeaderView() -> some View {
        HStack(spacing: 10) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(formattedDateKoR())
                
                Text("Today")
                    .font(.largeTitle.bold())
            }
            .hLeading()
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                Text(isExpanded ? "주간" : "월간")
                    .font(.system(size: 14, weight: .bold))
                    .padding(8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.1))
                    )
            }
            
            Button {
                
            } label: {
                Image("DOGE")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
        }
        .padding()
        .padding(.top, getSafeArea().top)
        .background(Color.white) // red
    }
    
    // MARK: - Memos View(메모 리스트)
    private func MemosListView() -> some View {
        LazyVStack(spacing: 10) {
            if let memos = calendarViewModel.filteredMemos {
                if memos.isEmpty {
                    VStack {
                        Text("아직 메모가 없어요.")
                        Text("아래 버튼을 눌러 ")
                        Text("메모를 추가해 보세요!")
                    }
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .fontWeight(.light)
                    .offset(y: 100)
                } else {
                    ForEach(memos) { memo in
                        MemoCardView(memo: memo)
                    }
                }
            } else {
                // MARK: -  Progress View
                ProgressView()
                    .offset(y: 100)
            }
        }
        .padding()
        .padding(.top)
        .onChange(of: calendarViewModel.currentDay) { _, newValue in
            calendarViewModel.filterTodayMemos()
        }
    }

    
    // MARK: - Memo Card View(메모 카드)
    private func MemoCardView(memo: Memo) -> some View {
        HStack(alignment: .top, spacing: 30) {
            VStack(spacing: 10) {
                Circle()
                    .fill(.black)
                    .frame(width: 7, height: 7)
                    .background(
                        Circle()
                            .stroke(.black, lineWidth: 1)
                            .padding(-3)
                    )
                
                Rectangle()
                    .fill(.black)
                    .frame(width: 1.0)
            }
            
            NavigationLink(destination: MemoDetailView(memo: memo)) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .center) {
                        Image(systemName: memo.isVoice ? "mic" : "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 12)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(.black)
                                    .frame(width: 30, height: 30)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(memo.title)
                            .font(.subheadline.bold())
                        
                        Text(memo.content)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .hLeading()
                    VStack {
                        Text(memo.date.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 15))
                        Button {
                            calendarViewModel.toggleBookmark(for: memo)
                        } label: {
                            Image(systemName: memo.isBookmarked ? "star.fill" : "star")
                                .foregroundColor(memo.isBookmarked ? .mainPink : .mainGray)
                                .padding(1)
                        }
                        
                    }
                }
                .foregroundColor(calendarViewModel.isCurrentHour(date: memo.date) ? .white : .black)
                .padding()
                .hLeading()
                .background(
                    (memo.isVoice ? Color.mainGray : Color.mainBlack)
                        .cornerRadius(25)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.mainBlack)
                }
        }
        .hLeading()
    }
        // 기본 버튼 스타일 제거
        //.buttonStyle(PlainButtonStyle())
    }
    

    // MARK: - Custom Date Formatting(상단에 12월, 2024 표시)
    private func formattedDateKoR() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MMM, yyyy" // Custom format for '2024 Dec 2'
        return formatter.string(from: Date())
    }
    
    private func formattedDateMemo() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - 주간 달력 뷰
    private func WeekCalendarView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            // MARK: - 스크롤뷰를 사용하면서 가운데 정렬 방법
            Spacer().containerRelativeFrame([.horizontal])
            
            HStack(spacing: 10) {
                
                ForEach(calendarViewModel.currentWeek, id: \.self) { day in
                    DayView(day: day)
                }
            }
            .padding(.horizontal)
        }
        //.frame(height: 100) // 주간 달력 높이 고정
    }

    // MARK: - 월간 달력 뷰
    private func FullCalendarView() -> some View {
        VStack {
//                HStack(spacing: 0) {
//                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
//                        Text(day)
//                            .font(.system(size: 14))
//                            .fontWeight(.bold)
//                            .frame(maxWidth: .infinity)
//                            .foregroundColor(day == "일" ? .red : (day == "토" ? .blue : .black))
//                    }
//                }
//                .padding(.bottom, 5)

                // 날짜 그리드
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 10) {
                    ForEach(calendarViewModel.currentMonth, id: \.self) { day in
                        DayView(day: day)
                    }
                }
            }
            .padding(.horizontal)
    }
    
    // MARK: - 요일만 출력하는 뷰
    private func dayHeaderView() -> some View {
        HStack(spacing: 10) {
            ForEach(calendarViewModel.currentWeek, id: \.self) { day in
                Text(calendarViewModel.extractDate(date: day, format: "EEE"))
                    .font(.system(size: 14))
                    .frame(width: 45)
                
                    //.frame(maxWidth: .infinity)
                    //.foregroundColor(day == calendarViewModel.currentWeek.last ? .red : day == calendarViewModel.currentWeek.first ? .blue : .primary)
            }
            
        }
        
        .padding(.horizontal)
    }
    
    // MARK: - 개별 날짜 뷰
    private func DayView(day: Date) -> some View {
        VStack(spacing: 10) {
            
            // MON, TUE ...
            Text(calendarViewModel.extractDate(date: day, format: "EEE"))
                .font(.system(size: 14))
             
            
            // 25, 26 ...
            Text(calendarViewModel.extractDate(date: day, format: "dd"))
                .font(.system(size: 15))
                .fontWeight(.semibold)
            
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
            
            // MARK: - 오늘날짜에만 검은동그라미 표시로 강조
                .opacity(calendarViewModel.isToday(date: day) ? 1 : 0)
            
        }
        // MARK: - foregroundstyle
        .foregroundStyle(calendarViewModel.isToday(date: day) ? .primary : .tertiary) // 기본색 : 옅은색
        .foregroundColor(calendarViewModel.isToday(date: day) ? .white : .black)
        
        
        // MARK: - Capsule Shape
        
        .frame(width: 45, height: 90)
        
        .background(
            ZStack {
                // MARK: - Matched Geometry Effect
                // 동일한 id를 가진 View 사이에서 애니메이션 효과를 만든다. 스무스하게 전환효과
                // 선택된 날짜(오늘 날짜)를 강조하고, 다른 날짜를 선택했을 때 강조 표시가 부드럽게 이동하도록 처리
                if calendarViewModel.isToday(date: day) {
                    Capsule()
                        .fill(.black)
                        .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                    
                }
            }
        )
        .contentShape(Circle()) // 클릭하거나 터치할 수 있는 영역
         
        
        // MARK: - 날짜를 클릭하면 현재 날짜를 업데이트
        .onTapGesture {
            // Updating Current Day
            withAnimation {
                calendarViewModel.currentDay = day
            }
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
}

// MARK: - UI Design Heplher functions
extension View {
    // 부모 View의 가로 공간을 최대한 차지하도록 설정. -> 왼쪽, 오른쪽, 가운데 정렬로 배치
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Safe Area
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        
        return safeArea
    }
}

// MARK: - Memo Card View(메모 카드)
struct MemoCardView: View {
    
    // MARK: - ViewModel을 환경 객체로 주입받아 데이터를 공유
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    var memo: Memo
    var body: some View {
        HStack(alignment: .top, spacing: 30) {
            VStack(spacing: 10) {
                Circle()
                    .fill(.black)
                    .frame(width: 7, height: 7)
                    .background(
                        Circle()
                            .stroke(.black, lineWidth: 1)
                            .padding(-3)
                    )
                
                Rectangle()
                    .fill(.black)
                    .frame(width: 1.0)
            }
            
            NavigationLink(destination: MemoDetailView(memo: memo)) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .center) {
                        Image(systemName: memo.isVoice ? "mic" : "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 12)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(.black)
                                    .frame(width: 30, height: 30)
                            )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(memo.title)
                            .font(.subheadline.bold())
                        
                        Text(memo.content)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .hLeading()
                    Text(memo.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 15))
                }
                .foregroundColor(calendarViewModel.isCurrentHour(date: memo.date) ? .white : .black)
                .padding()
                .hLeading()
                .background(
                    Color.mainBlack
                        .cornerRadius(25)
                        .opacity(calendarViewModel.isCurrentHour(date: memo.date) ? 1 : 0)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.mainBlack)
                }
        }
        .hLeading()
    }
    }
}

// MARK: - 메모 상세 뷰
struct MemoDetailView: View {
    var memo: Memo
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(memo.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(memo.date)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Divider()
            
            Spacer()
                .frame(height: 10)
            
            Text(memo.content.replacingOccurrences(of: "\\n", with: "\n"))
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .navigationTitle("메모")
        .navigationBarTitleDisplayMode(.inline)
    }
}
