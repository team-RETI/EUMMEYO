//
//  MemoDetailView 2.swift
//  EUMMEYO
//
//  Created by eunchanKim on 2/8/25.
//

import SwiftUI

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
