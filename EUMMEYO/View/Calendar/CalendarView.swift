//
//  CalendatView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI
import AVFoundation

struct CalendarView: View {
    // MARK: - ViewModel을 환경 객체로 주입받아 데이터를 공유
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var container: DIContainer
    
    @AppStorage("jColor") private var jColor: Int = 0           // 커스텀 색상 가져오기
    
    // MARK: @Namespace는 Matched Geometry Effect를 구현하기 위한 도구로, 두 뷰 간의 부드러운 전환 애니메이션을 제공
    @Namespace var animation    // (오늘 날짜와 선택된 날짜 간의 부드러운 애니메이션 효과)
    
    // MARK: - 추가 버튼 표시 상태(플러스 버튼 클릭 시 음성 메모 버튼과 텍스트 메모 버튼 표시 여부 제어)
    @State private var showAdditionalButtons = false
    
    // MARK: - 사용 횟수 추가 알림 표시
    @State private var showLimitAlert = false
    
    // MARK: - 전체 달력 보기 상태
    @State private var isExpanded = false
    @State private var showAddMemoView = false
    @State private var isVoiceMemo = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                if isExpanded {
                    FullCalendarView() // 월간 달력 보기
                } else {
                    WeekCalendarView() // 주간 달력 보기
                }
                // MARK: - 사용 근거: ScrollView와 플로팅버튼(떠있는 것처럼 보이는 버튼)이 서로 겹치지 않도록 배치
                ZStack {
                    // MARK: - 사용 근거: 스크롤 가능한 리스트 + 성능을 위해 뷰 지연 로드
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            MemosListView()
                        }
                    }

                    // MARK: - 플로팅 버튼
                    HStack {
                        Spacer()
                        
                        VStack {
                            Spacer()
                            if showAdditionalButtons {
                                VStack(spacing: 30.scaled) {
                                    Button {
                                        if calendarViewModel.user?.currentUsage ?? 0 >= calendarViewModel.user?.maxUsage ?? 0 {
                                            showLimitAlert = true
                                        } else {
                                            isVoiceMemo = true
                                            showAddMemoView = true
                                            showAdditionalButtons.toggle()
                                        }
                                    } label: {
                                        Image(systemName: "mic")
                                            .padding()
                                            .foregroundColor(.black)
                                            .background(
                                                Circle() // 원형 배경
                                                    .fill(.white)
                                                    .frame(width: 60.scaled, height: 60.scaled)
                                            )
                                            .overlay {
                                                Circle()
                                                    .stroke(lineWidth: 0.5)
                                                    .frame(width: 60.scaled, height: 60.scaled)
                                                    .foregroundColor(.black)    // 테두리색
                                            }
                                    }
                                    
                                    Button {
                                        if calendarViewModel.user?.currentUsage ?? 0 >= calendarViewModel.user?.maxUsage ?? 0 {
                                            showLimitAlert = true
                                        } else {
                                            isVoiceMemo = false
                                            showAddMemoView = true
                                            showAdditionalButtons.toggle()
                                        }
                                    } label: {
                                        Image(systemName: "doc.text")
                                            .padding()
                                            .foregroundColor(.black)
                                            .background(
                                                Circle() // 원형 배경
                                                    .fill(.white)
                                                    .frame(width: 60.scaled, height: 60.scaled)
                                            )
                                            .overlay {
                                                Circle()
                                                    .stroke(lineWidth: 0.5)
                                                    .frame(width: 60.scaled, height: 60.scaled)
                                                    .foregroundColor(.black)    // 테두리색
                                            }
                                    }
                                }
                                .padding(.bottom, 20.scaled)
                            }
                            
                            Button {
                                withAnimation(.spring()) {
                                    showAdditionalButtons.toggle()
                                }
                            } label: {
                                Image(systemName: showAdditionalButtons ? "xmark" : "plus")
                                    .font(.system(size: 25.scaled, weight: .bold))
                                    .padding()
                                    .foregroundColor(.mainWhite)
                                    .background(
                                        Circle()
                                            .fill(.mainBlack)
                                            .frame(width: 60.scaled, height: 60.scaled)
                                    )
                                    .overlay {
                                        Circle()
                                            .stroke(lineWidth: 0.5)
                                            .frame(width: 60.scaled, height: 60.scaled)
                                            .foregroundColor(.mainWhite)    // 테두리색
                                    }
                                    .rotationEffect(.degrees(showAdditionalButtons ? 90 : 0))
                            }
                        }
                    }
                    .padding(.trailing, 30.scaled)
                    .padding(.bottom, 20.scaled)
                    .background(.clear) // 배경을 명시적으로 투명하게 설정
                    .sheet(isPresented: $showAddMemoView) {
                        AddMemoView(isVoice: isVoiceMemo)
                            .environmentObject(calendarViewModel)
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.fraction(0.9)])
                    }
                }
                // 사용 횟수 초과 알림 표시
                .alert(isPresented: $showLimitAlert) {
                    Alert(
                        title: Text("사용 횟수 초과"),
                        message: Text("오늘의 메모 작성 횟수를 모두 사용하셨습니다."),
                        dismissButton: .default(Text("확인"))
                    )
                }
            }
        }
        .alert(isPresented: $calendarViewModel.showDeleteMemoAlarm) {
            Alert(
                title: Text("메모 삭제"),
                message: Text("정말로 메모를 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    print("진행")
                    calendarViewModel.deleteMemo()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Header View(상단에 12월, 2024 표시)
    private func HeaderView() -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10.scaled) {
                Text(formattedYear())
                    .font(.subheadline.bold())
                Text(calendarViewModel.formatDateForTitle(calendarViewModel.currentDay))
                    .font(.largeTitle.bold())
            }
            .hLeading()

            Button {
                calendarViewModel.currentDay = Date()
                calendarViewModel.fetchCurrentWeek(for: Date())
                isExpanded = false
                
            } label: {
                VStack{
                    Image(uiImage: calendarViewModel.convertStringToUIImage(calendarViewModel.user?.profile ?? ".EUMMEYO_0") ?? .EUMMEYO_0)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50.scaled, height: 50.scaled)
                        .clipShape(Circle())
                    
                    Text("home")
                        .font(.system(size: 11))
                        .foregroundColor(.mainBlack)
                }
            }
        }
        .padding()
//        .padding(.top, getSafeArea().top)
    }
    
    // MARK: - Memos View(메모 리스트)
    private func MemosListView() -> some View {
        VStack(spacing: 15.scaled) {
            if let memos = calendarViewModel.filteredMemos {
                if memos.isEmpty {
                    VStack {
                        Text("아직 메모가 없어요.")
                        Text("아래 버튼을 눌러 ")
                        Text("메모를 추가해 보세요!")
                    }
                    .font(.system(size: 24.scaled))
                    .fontWeight(.bold)
                    .fontWeight(.light)
                    .offset(y: 100.scaled)
                } else {
                    ForEach(memos){ memo in
                        NavigationLink {
                            MemoDetailView(memo: memo, editMemo: memo.content, editTitle: memo.title)
                        } label: {
                            MemoCardView(memo: memo)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            calendarViewModel.selectedMemo = memo
                        })
                    }
                }
            } else {
                // MARK: -  Progress View
                ProgressView()
                    .offset(y: 100.scaled)
            }
        }
        .padding()
        .padding(.top)
        .onChange(of: calendarViewModel.currentDay) { _, newValue in
            calendarViewModel.filterTodayMemos()
        }
    }
    
    // MARK: - Custom Date Formatting(상단에 12월, 2024 표시)
    private func formattedYear() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy" // 🔹 3월, 2025 형식
        return formatter.string(from: calendarViewModel.currentDay)
    }
    // MARK: - Custom Date Formatting(12월 표시)
    private func formattedMonth() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월" // 🔹 3월 형식
        return formatter.string(from: calendarViewModel.currentDay)
    }
    // MARK: - Custom Date Formatting(영문 표시)
    private func formattedMonthEng() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM" // 🔹 3월, 2025 형식
        return formatter.string(from: calendarViewModel.currentDay)
    }
    private func formattedDateMemo() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - 주간 달력 뷰
    private func WeekCalendarView() -> some View {
        VStack {
            // 🔹 이전/다음 주 이동 버튼 추가
            HStack {
                Button(action: {
                    withAnimation {
                        let previousWeek = Calendar.current.date(byAdding: .day, value: -7, to: calendarViewModel.currentWeek.first!)!
                        calendarViewModel.fetchCurrentWeek(for: previousWeek)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding()
                }
                Spacer()
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Text("\(formattedMonthEng())")  // 🔹 현재 월 표시 (3월, 2025)
                        .font(.headline)
                    Text(" \(formattedMonth())")  // 🔹 현재 월 표시 (3월, 2025)
                        .font(.subheadline)
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: calendarViewModel.currentWeek.first!)!
                        calendarViewModel.fetchCurrentWeek(for: nextWeek)
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding()
                }
            }
            .padding(.horizontal)
            
            // 🔹 요일 헤더 (일 ~ 토)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 10.scaled) {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 10)
            // 🔹 기존 날짜 뷰
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 10.scaled) {
                ForEach(calendarViewModel.currentWeek, id: \.self) { day in
                    DayView(day: day)
                    
                }
            }
            .offset(x: calendarViewModel.offsetX.isFinite ? calendarViewModel.offsetX : 0) // NaN 방지
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // 왼쪽 스와이프: 음수 / 오른쪽 스와이프: 양수
                        calendarViewModel.offsetX = gesture.translation.width.clamped(to: -50...50)
                    }
                    .onEnded { _ in
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if calendarViewModel.offsetX <= -30 {
                                    // 👉 왼쪽 스와이프 (다음 주로 이동)
                                    calendarViewModel.offsetX = 0
                                    let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: calendarViewModel.currentWeek.first!)!
                                    calendarViewModel.fetchCurrentWeek(for: nextWeek)
                                    
                                } else if calendarViewModel.offsetX >= 30 {
                                    // 👈 오른쪽 스와이프 (이전 주로 이동)
                                    calendarViewModel.offsetX = 0
                                    let previousWeek = Calendar.current.date(byAdding: .day, value: -7, to: calendarViewModel.currentWeek.first!)!
                                    calendarViewModel.fetchCurrentWeek(for: previousWeek)
                                } else {
                                    // 기준치 미만일 땐 원위치
                                    calendarViewModel.offsetX = 0
                                }
                            }
                        }
                    }
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - 월간 달력 뷰
    private func FullCalendarView() -> some View {
        VStack {
            // 🔹 이전/다음 달 이동 버튼 + 현재 월 표시
            HStack {
                Button(action: {
                    withAnimation {
                        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendarViewModel.currentDay)!
                        calendarViewModel.fetchMonthData(for: previousMonth)
                        calendarViewModel.fetchCurrentWeek(for: previousMonth)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding()
                }
                Spacer()
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Text("\(formattedMonthEng())")  // 🔹 현재 월 표시 (3월, 2025)
                        .font(.headline)
                    Text(" \(formattedMonth())")  // 🔹 현재 월 표시 (3월, 2025)
                        .font(.subheadline)
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendarViewModel.currentDay)!
                        calendarViewModel.fetchMonthData(for: nextMonth)
                        calendarViewModel.fetchCurrentWeek(for: nextMonth)
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding()
                }
            }
            .padding(.horizontal)
            // 🔹 요일 헤더 (일 ~ 토)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 10) {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 10)
            // 🔹 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 10) {
                // 🔹 빈 칸 추가 (월 첫날 요일에 맞춰 정렬)
                ForEach(0..<calendarViewModel.leadingEmptyDays, id: \.self) { _ in
                    Color.clear.frame(height: 40)
                }
                
                // 🔹 실제 날짜 표시
                ForEach(calendarViewModel.currentMonth, id: \.self) { day in
                    DayView(day: day)
                        .frame(maxWidth: .infinity) // 각 요일의 너비를 균일하게
                }
            }
            .offset(x: calendarViewModel.offsetX.isFinite ? calendarViewModel.offsetX : 0) // NaN 방지
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // 왼쪽 스와이프: 음수 / 오른쪽 스와이프: 양수
                        calendarViewModel.offsetX = gesture.translation.width.clamped(to: -50...50)
                    }
                    .onEnded { _ in
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if calendarViewModel.offsetX <= -30 {
                                    // 👉 왼쪽 스와이프 (다음 주로 이동)
                                    calendarViewModel.offsetX = 0
                                    let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendarViewModel.currentDay)!
                                    calendarViewModel.fetchMonthData(for: nextMonth)
                                    calendarViewModel.fetchCurrentWeek(for: nextMonth)
                                    
                                } else if calendarViewModel.offsetX >= 30 {
                                    // 👈 오른쪽 스와이프 (이전 주로 이동)
                                    calendarViewModel.offsetX = 0
                                    let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendarViewModel.currentDay)!
                                    calendarViewModel.fetchMonthData(for: previousMonth)
                                    calendarViewModel.fetchCurrentWeek(for: previousMonth)
                                } else {
                                    // 기준치 미만일 땐 원위치
                                    calendarViewModel.offsetX = 0
                                }
                            }
                        }
                    }
            )
            
        }
        .padding(.horizontal)
    }
    
    // MARK: - 요일만 출력하는 뷰
    private func dayHeaderView() -> some View {
        HStack(spacing: 10.scaled) {
            ForEach(calendarViewModel.currentWeek, id: \.self) { day in
                Text(calendarViewModel.extractDate(date: day, format: "EEE"))
                    .font(.system(size: 14.scaled))
                    .frame(width: 45.scaled)
            }
            
        }
        
        .padding(.horizontal)
    }
    
    // MARK: - 개별 날짜 뷰
    private func DayView(day: Date) -> some View {
        VStack(spacing: 10.scaled) {
            // 25, 26 ...
            Text(calendarViewModel.extractDate(date: day, format: "dd"))
                .font(.system(size: 12.scaled))
                .fontWeight(.semibold)
                .foregroundColor(.mainGray)
            
            Circle()
                .fill(.mainWhite)
                .frame(width: 6.scaled, height: 6.scaled)
            
            // MARK: - 해당 날짜에만 검은동그라미 표시로 강조
                .opacity(calendarViewModel.isToday(date: day) ? 1 : 0)
            
            // MARK: - 메모 있는거 표시
            HStack(spacing: 2.scaled) {
                ForEach(0..<calendarViewModel.hasMemos(date: day), id: \.self) { array in
                    Circle()
                        .fill(Color(hex: jColor))
                        .frame(width: 3.scaled, height: 3.scaled)
                        .opacity(calendarViewModel.hasMemo(date: day) ? 1 : 0)
                }
            }
        }
        // MARK: - foregroundstyle
        .foregroundStyle(calendarViewModel.isToday(date: day) ? .primary : .tertiary) // 기본색 : 옅은색
        .foregroundColor(calendarViewModel.isToday(date: day) ? .white : .black)
        // MARK: - Capsule Shape
        //        .frame(width: 45, height: 90)
        .frame(width: 45.scaled, height: 70.scaled)
        .background(
            ZStack {
                // MARK: - Matched Geometry Effect
                // 동일한 id를 가진 View 사이에서 애니메이션 효과를 만든다. 스무스하게 전환효과
                // 선택된 날짜(오늘 날짜)를 강조하고, 다른 날짜를 선택했을 때 강조 표시가 부드럽게 이동하도록 처리
                if calendarViewModel.isToday(date: day) {
                    Capsule()
                        .fill(.mainBlack)
                        .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                }
            }
        )
        .contentShape(Rectangle()) // 클릭하거나 터치할 수 있는 영역
        // MARK: - 날짜를 클릭하면 현재 날짜를 업데이트
        .onTapGesture {
            // Updating Current Day
            withAnimation(.easeInOut(duration: 0.5)) {
                calendarViewModel.updateCalendar(to: day)
            }
        }
    }
}

struct MemoCardView: View {
    var memo: Memo
    @EnvironmentObject var viewModel: CalendarViewModel
    @State var offsetX: CGFloat = 0 // 드래그 거리
    @State var showDelete: Bool = false // 삭제 버튼 표시 여부
    //@StateObject private var audioRecorderManager = AudioRecorderManager()
    
    var body: some View {
        ZStack{  // 삭제 버튼용
            HStack {
                Button {
                    viewModel.deleteTarget = memo.id
                    viewModel.showDeleteMemoAlarm.toggle()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(
                            Color.white
                                .opacity(showDelete ? 1 : 0)
                        )
                        .padding()
                        .background(
                            Color.red
                                .opacity(showDelete ? 1 : 0)
                        )
                        .cornerRadius(10.scaled)
                }
                .padding(.trailing, 10)
            }
            .hTrailing()
            
            HStack(alignment: .top, spacing: 30.scaled) {
                VStack(spacing: 10.scaled) {
                    Circle()
                        .fill(.mainBlack)
                        .frame(width: 7.scaled, height: 7.scaled)
                        .background(
                            Circle()
                                .stroke(.mainBlack, lineWidth: 1)
                                .padding(-3)
                        )
                    Rectangle()
                        .fill(.mainBlack)
                        .frame(width: 1.0.scaled)
                }
                
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .center) {
                        Image(systemName: memo.isVoice ? "mic" : "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12.scaled, height: 12.scaled)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(.black)
                                    .frame(width: 30.scaled, height: 30.scaled)
                            )
                    }
                    VStack(alignment: .leading, spacing: 12.scaled) {
                        Text(memo.title)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        Text(memo.gptContent ?? "요약 없음")
                            .font(.system(size: 10.scaled))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .hLeading()
                    
                    VStack {
                        Text(memo.date.formatted(date: .numeric, time: .omitted))
                            .font(.system(size: 15.scaled))
                        Button {
                            viewModel.isBookmark.toggle()
                            viewModel.toggleBookmark(memoId: memo.id, isBookmark: viewModel.isBookmark)
                        } label: {
                            Image(systemName: memo.isBookmarked ? "star.fill" : "star")
                                .foregroundColor(memo.isBookmarked ? .mainPink : .mainGray)
                                .padding(1)
                        }
                    }
                }
                .padding()
                .foregroundColor(viewModel.isCurrentHour(date: memo.date) && viewModel.isToday(date: memo.date) ? .mainWhite : .mainBlack)
                .background(viewModel.isCurrentHour(date: memo.date) && viewModel.isToday(date: memo.date) ? .mainBlack : .mainWhite)
                .cornerRadius(25.scaled)
                .overlay {
                    RoundedRectangle(cornerRadius: 25.scaled)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.mainBlack)
                }
            }

            .offset(x: offsetX.isFinite ? offsetX : 0) // NaN 방지
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        offsetX = gesture.translation.width.clamped(to: -100...10) // 최대 이동 거리 제한
                    }
                    .onEnded { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                if offsetX <= -75 {
                                    offsetX = -70
                                    showDelete = true
                                } else {
                                    offsetX = 0
                                    showDelete = false
                                }
                            }
                        }
                    }
            )
        }
    }
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
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
    
}
