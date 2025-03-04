# EUM-MEYO (음메요)

<p align="center">
  <img src="https://github.com/user-attachments/assets/1d462bc3-608f-49a0-8baf-fba856306827" width="200">
</p>

## 📱 프로젝트 소개

EUMMEYO는 일상의 순간들을 쉽고 간편하게 기록할 수 있는 iOS 다이어리 앱입니다. 
텍스트 메모와 함께 음성 녹음 기능을 제공하여 사용자의 감정과 생각을 더욱 풍부하게 담아낼 수 있습니다.

<br/>

## 🍎 Developers

<img width="160px" src=""/> | <img width="160px" src=""/> | <img width="160px" src=""/> | <img width="160px" src="h"/> |
|:-----:|:-----:|:-----:|:-----:|
| [김은찬](https://github.com/evanKim1999) | [김동현](https://github.com/indextrown) | [장주진](https://github.com/TripleJ709) | [홍예희](https://github.com/HongYehee) |
|팀장 👑|팀원 👨🏻‍💻|팀원 👨🏻‍💻|팀원 👨🏻‍💻|
|`캘린더`, `프로필`|`로그인`, `즐겨찾기`| `캘린더`, `GPT 음메요약` |`기획`, `캐릭터 디자인`|
</div>
<br/>

## ✨ 주요 기능

- **간편한 메모 작성**: 텍스트와 음성으로 일상을 기록
- **캘린더 뷰**: 날짜별 메모 조회 및 관리
- **북마크**: 중요한 메모를 즐겨찾기
- **GPT 요약**: 긴 메모를 자동으로 요약
- **프로필 관리**: 개인화된 사용자 경험

## 🛠 기술 스택

- **Framework**: SwiftUI
- **Architecture**: MVVM + Clean Architecture
- **Database**: Firebase Realtime Database, Firebase Storage
- **Authentication**: Firebase Auth
- **Dependencies**:
  - Firebase
  - OpenAI
  - Combine

## 📦 프로젝트 구조
```bash
EUMMEYO/
├── Model/ # 데이터 모델
├── View/ # UI 컴포넌트
├── Service/ # 비즈니스 로직
├── Repository/ # 데이터 접근 계층
├── General/ # 유틸리티
└── Extension/ # Swift 확장
```

## MVVM + CleanArchitecture
```mermaid
%%{init: {'themeVariables': { 'fontSize': '14px', 'lineHeight': '18px'}}}%%
graph TD
    %% Subgraph: App
    subgraph App
        A["EUMMEYOApp&nbsp;&nbsp;&nbsp;"] --> B["AuthenticationView&nbsp;&nbsp;&nbsp;"]
    end

    %% Subgraph: Views
    subgraph Views
        B --> C["LoginView&nbsp;&nbsp;&nbsp;"]
        B --> D["MaintabView&nbsp;&nbsp;&nbsp;"]
        B --> E["NicknameSettingView&nbsp;&nbsp;&nbsp;"]
        
        D --> F["CalendarView&nbsp;&nbsp;&nbsp;"]
        D --> G["BookmarkView&nbsp;&nbsp;&nbsp;"]
        D --> H["ProfileView&nbsp;&nbsp;&nbsp;"]
        
        F --> I["AddMemoView&nbsp;&nbsp;&nbsp;"]
    end

    %% Subgraph: ViewModels
    subgraph ViewModels
        J["AuthenticationViewModel&nbsp;&nbsp;&nbsp;"]
        K["CalendarViewModel&nbsp;&nbsp;&nbsp;"]
        L["BookmarkViewModel&nbsp;&nbsp;&nbsp;"]
        M["ProfileViewModel&nbsp;&nbsp;&nbsp;"]
        N["AddMemoViewModel&nbsp;&nbsp;&nbsp;"]
        
        B --- J
        F --- K
        G --- L
        H --- M
        I --- N
    end

    %% Subgraph: Services
    subgraph Services
        O["Services&nbsp;&nbsp;&nbsp;"]
        P["UserService&nbsp;&nbsp;&nbsp;"]
        Q["MemoService&nbsp;&nbsp;&nbsp;"]
        R["GPTAPIService&nbsp;&nbsp;&nbsp;"]
        S["AuthenticationService&nbsp;&nbsp;&nbsp;"]
        
        O --> P
        O --> Q
        O --> R
        O --> S
    end

    %% Subgraph: Repositories
    subgraph Repositories
        T["UserDBRepository&nbsp;&nbsp;&nbsp;"]
        U["MemoDBRepository&nbsp;&nbsp;&nbsp;"]
        V["PromptDBRepository&nbsp;&nbsp;&nbsp;"]
        
        P --> T
        Q --> U
        R --> V
    end

    %% Subgraph: DI
    subgraph DI
        W["DIContainer&nbsp;&nbsp;&nbsp;"] --> O
    end

    %% Subgraph: Models
    subgraph Models
        X["User&nbsp;&nbsp;&nbsp;"]
        Y["Memo&nbsp;&nbsp;&nbsp;"]
    end

    %% 연결선 정의
    A --> W
    J --> S
    K --> Q
    M --> P
    M --> Q

    %% 모든 노드에 패딩 스타일 적용 (브라우저나 렌더러에 따라 일부 속성이 반영되지 않을 수 있음)
    classDef wide fill:#fff,stroke:#333,stroke-width:1px, padding:10px;
    class A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y wide;

```

