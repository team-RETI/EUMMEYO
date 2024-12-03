//
//  CalendatView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct CalendarView: View {
    // @Binding var isShadowActive: Bool // 그림자 상태 전달
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    // @Namespace는 Matched Geometry Effect를 구현하기 위한 도구로, 두 뷰 간의 부드러운 전환 애니메이션을 제공
    @Namespace var animation
    
    // 추가 버튼 표시 상태
    @State private var showAdditionalButtons = false
    
    var body: some View {
        VStack {
            ZStack {
                
                ScrollView(.vertical, showsIndicators: false) {
                    // MARK: -  Lazy Stack With Pinned Header
                    LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                        Section {
                            // MARK: - Current Week View
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(taskViewModel.currentWeek, id: \.self) { day in
                                        VStack(spacing: 10) {
                                            // 25, 26 ...
                                            Text(taskViewModel.extractDate(date: day, format: "dd"))
                                                .font(.system(size: 15))
                                                .fontWeight(.semibold)
                                            
                                            // MON, TUE ...
                                            Text(taskViewModel.extractDate(date: day, format: "EEE"))
                                                .font(.system(size: 14))
                                            
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 8, height: 8)
                                            // MARK: - 오늘날짜에만 동그라미 표시
                                                .opacity(taskViewModel.isToday(date: day) ? 1 : 0)
                                            
                                        }
                                        // MARK: - foregroundstyle
                                        .foregroundStyle(taskViewModel.isToday(date: day) ? .primary : .tertiary) // 기본색 : 옅은색
                                        .foregroundColor(taskViewModel.isToday(date: day) ? .white : .black)
                                        // MARK: - Capsule Shape
                                        .frame(width: 45, height: 90)
                                        .background(
                                            ZStack {
                                                // MARK: - Matched Geometry Effect
                                                // 동일한 id를 가진 View 사이에서 애니메이션 효과를 만든다. 스무스하게 전환효과
                                                // 선택된 날짜(오늘 날짜)를 강조하고, 다른 날짜를 선택했을 때 강조 표시가 부드럽게 이동하도록 처리
                                                if taskViewModel.isToday(date: day) {
                                                    Capsule()
                                                        .fill(.black)
                                                        .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                                    
                                                }
                                                
                                            }
                                        )
                                        .contentShape(Circle()) // 클릭하거나 터치할 수 있는 영역
                                        .onTapGesture {
                                            // Updating Current Day
                                            withAnimation {
                                                taskViewModel.currentDay = day
                                            }
                                        }
                                        
                                    }
                                }
                                .padding(.horizontal)
                            }
                            MemossView()
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
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        
                        if showAdditionalButtons {
                            VStack(spacing: 30) {
                                Button {
                                    
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
                            Image(systemName: "plus")
                                .font(.system(size: 25, weight: .bold))
                                .padding()
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(.black)
                                        .frame(width: 60, height: 60)
                                )
                        }
                        
                    }
                }
                .padding(.trailing, 30)
                .padding(.bottom, 20)
                .background(.clear) // 배경을 명시적으로 투명하게 설정
            }
        }
        // 상단 안전 영역 무시
        // .container: 뷰의 배경과 같은 큰 영역에 영향을 주는 컨테이너를 무시
        .ignoresSafeArea(.container, edges: .top)
    }
    
    // MARK: - Memos View
    func MemossView() -> some View {
        LazyVStack(spacing: 10) {
            if let memos = taskViewModel.filteredTasks {
                if memos.isEmpty {
                    Text("No tasks found!")
                        .font(.system(size: 16))
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
        .onChange(of: taskViewModel.currentDay) { _, newValue in
            taskViewModel.filterTodayMemos()
        }
    }
    
    // MARK: - Memo Card View
    func MemoCardView_save(memo: Memo) -> some View {
        HStack(alignment: .top, spacing: 30) {
            
            
            VStack(spacing: 10) {
                Circle()
                    .fill(.black)
                    .frame(width: 10, height: 10)
                    .background(
                        Circle()
                            .stroke(.black, lineWidth: 1)
                            .padding(-3)
                    )
                
                // MARK: - 세로선
                Rectangle()
                    .fill(.black)
                    .frame(width: 1.5)
            }
             
            
            VStack {
                HStack(alignment: .top, spacing: 10) {
                    
                    VStack(alignment: .center) {
                        
                        Image(systemName: memo.isVoice ? "mic" : "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 12)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                Circle() // 원형 배경
                                    .fill(.black)
                                    .frame(width: 30, height: 30)
                            )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(memo.title)
                            .font(.subheadline.bold())
                        
                        Text(memo.content)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary) // 보조 색상(회색톤)
                    }
                    .hLeading()
                    Text(memo.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 15))
                }
                

            }
            //.foregroundColor(.white)
            // 현재시간이면 흰색 아니면 검은색
            .foregroundColor(taskViewModel.isCurrentHour(date: memo.date) ? .white : .black)
            .padding()
            .hLeading()
            .background(
                Color(hex: "#38383A")
                    .cornerRadius(25)
                    .opacity(taskViewModel.isCurrentHour(date: memo.date) ? 1 : 0)
            )
            // 테두리 추가
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(lineWidth: 1)
            }
            
        }
        
        .hLeading()
    }
    
    func MemoCardView(memo: Memo) -> some View {
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
                
                // MARK: - 세로선
                Rectangle()
                    .fill(.black)
                    .frame(width: 1.0)
            }
            
            Button {
                
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    
                    VStack(alignment: .center) {
                        
                        Image(systemName: memo.isVoice ? "mic" : "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12, height: 12)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                Circle() // 원형 배경
                                    // .fill(memo.isVoice ? .green : Color(hex: "#38383A"))
                                    .fill(.black)
                                    .frame(width: 30, height: 30)
                            )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(memo.title)
                            .font(.subheadline.bold())
                        
                        Text(memo.content)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary) // 보조 색상(회색톤)
                    }
                    .hLeading()
                    Text(memo.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 15))
                }
            }
            // 현재시간이면 흰색 아니면 검은색
            .foregroundColor(taskViewModel.isCurrentHour(date: memo.date) ? .white : .black)
            .padding()
            .hLeading()
            .background(
                Color(hex: "#38383A")
                    .cornerRadius(25)
                    .opacity(taskViewModel.isCurrentHour(date: memo.date) ? 1 : 0)
            )
            // 테두리 추가
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(lineWidth: 1)
            }
        }
        .hLeading()
    }
    
    // MARK: - Header
    func HeaderView() -> some View {
        HStack(spacing: 10) {
            
            VStack(alignment: .leading, spacing: 10) {
                // Text(Date().formatted(date: .abbreviated, time: .omitted))
                Text(formattedDateKoR())
                
                Text("Today")
                    .font(.largeTitle.bold())
            }
            .hLeading()
            
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
    
    // MARK: - Custom Date Formatting
    func formattedDateKoR() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MMM, yyyy" // Custom format for '2024 Dec 2'
        return formatter.string(from: Date())
    }
}

#Preview {
    CalendarView()
        .environmentObject(TaskViewModel())
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

private struct MemoDetailView: View {
    fileprivate var body: some View {
        VStack {
            
        }
    }
}
