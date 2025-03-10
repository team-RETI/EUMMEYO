//
//  TestView.swift
//  EUMMEYO
//
//  Created by 김동현 on 3/10/25.
//

import SwiftUI

struct TestView: View {
    // 실제로는 [memo] 구조체 배열
    @State private var memos = [0, 1, 2]
    
    var body: some View {
        VStack {
            List {
                ForEach(memos, id: \.self) { memo in
                    Text("\(memo)")
                }
                .onDelete(perform: delete)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        memos.remove(atOffsets: offsets)
    }
}

#Preview {
    TestView()
}
