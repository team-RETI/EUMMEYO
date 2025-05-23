//
//  MemoDetailView.swift
//  EUMMEYO
//
//  Created by eunchanKim on 4/10/25.
//

import SwiftUI
import GoogleMobileAds

struct MemoDetailView: View {
    @StateObject var viewModel: MemoDetailViewModel
    
    var memo: Memo
    @State var editTitle = ""
    @State var editContent = ""
    
    @Environment(\.dismiss) private var dismiss /// 뒤로가기
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(memo.date.formattedKoreanDateTime)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            if viewModel.isEditing == true {
                TextField(memo.title, text: $editTitle, axis: .vertical)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
            } else {
                Text(memo.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
            }
            
            Text("요약 키워드")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.mainBlack)
            
            Text(memo.gptContent ?? "요약 없음")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button {
                        withAnimation {
                            viewModel.isVoiceView = true
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text("음성기록")
                                .foregroundStyle(viewModel.isVoiceView ? .black : .mainGray)
                                .frame(maxWidth: .infinity)
                            
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(viewModel.isVoiceView ? .mainBlack : .clear) // ⭐️ 선택된 쪽만 표시
                        }
                    }
                    .disabled(!memo.isVoice)
                    
                    Button {
                        withAnimation {
                            viewModel.isVoiceView = false
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text("메모 • 요약")
                                .foregroundStyle(!viewModel.isVoiceView ? .black : .mainGray)
                                .frame(maxWidth: .infinity)
                            
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(!viewModel.isVoiceView ? .mainBlack : .clear) // ⭐️ 선택된 쪽만 표시
                        }
                    }
                    .disabled(!memo.isVoice)
                }
                .padding(.top)
                
                Divider() // 전체 아래 Divider로 경계선
            }
            
            if viewModel.isVoiceView {
                voiceView()
            } else {
                textView()
            }
            
            Spacer()
            
            AdBannerView()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 0)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if viewModel.isEditing == true { viewModel.showUpdateMemoAlarm.toggle() }
                    else { dismiss() }
                } label: {
                    Image(systemName: viewModel.isEditing ? "checkmark" : "arrow.backward")
                        .foregroundColor(Color.mainBlack)
                }
                .alert(isPresented: $viewModel.showUpdateMemoAlarm) {
                    Alert(
                        title: Text("메모 수정"),
                        message: Text("정말로 메모를 수정하시겠습니까?"),
                        primaryButton: .destructive(Text("수정")) {
                            viewModel.updateMemo(memoId: memo.id, title: editTitle, content: editContent)
                            viewModel.isEditing = false
                            dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }

            if !viewModel.isEditing {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        viewModel.isBookmark = memo.isBookmarked
                        viewModel.isBookmark.toggle()
                        viewModel.toggleBookmark(memoId: memo.id, isBookmark: viewModel.isBookmark)
                    } label: {
                        Image(systemName: memo.isBookmarked ? "star.fill" : "star")
                            .foregroundColor(memo.isBookmarked ? .mainPink : .mainBlack)
                    }
                    Button {
                        viewModel.isEditing.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.mainBlack)
                    }
                    Button {
                        viewModel.shareText(title: memo.title, content: memo.content)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.mainBlack)
                    }
                    Button {
                        viewModel.memoStore.deleteTarget = memo
                        viewModel.showDeleteMemoAlarm.toggle()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.mainBlack)
                    }
                }
            }
        }
        .onAppear {
            if memo.isVoice {
                viewModel.isVoiceView = true
            } else {
                viewModel.isVoiceView = false
            }
        }
        .alert(isPresented: $viewModel.showDeleteMemoAlarm) {
            Alert(
                title: Text("메모 삭제"),
                message: Text("정말로 메모를 삭제하시겠습니까?2222"),
                primaryButton: .destructive(Text("삭제")) {
                    viewModel.memoStore.deleteMemo()
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func voiceView() -> some View {
        
        VStack(spacing: 20) {
            HStack {
                Text(viewModel.currentTime)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.totalTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Slider(value: $viewModel.progress, in: 0...1, onEditingChanged: { editing in
                if !editing {
                    viewModel.seek(to: viewModel.progress)
                }
            })
            .accentColor(.mainBlack)
            .padding(.horizontal)
            
            Button {
                guard let audioURL = memo.voiceMemoURL else { return }
                
                if viewModel.isPlaying {
                    viewModel.audioPause()
                }
                else {
                    viewModel.audioPlay(url: audioURL)
                }
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.mainBlack)
            }
            
            Button {
                viewModel.audioStop()
            } label: {
                Text("다시듣기")
            }
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
        .padding()
    }
    
    private func textView() -> some View {
        VStack {
            if viewModel.isEditing == true {
                TextField(memo.content, text: $editContent, axis: .vertical)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    Text(memo.content)
                        .font(.body)
                }
            }
        }
    }
}

struct AdBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView()
        banner.adSize = AdSizeBanner // ✅ 여기서 사이즈 지정
        banner.adUnitID = "ca-app-pub-8085540941363843/5757542334" // 테스트 ID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.load(Request())
        print("📢 광고 호출됨")
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
