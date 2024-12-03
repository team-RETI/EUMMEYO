//
//  ㅗㄷㅁ스메.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/3/24.
//

import SwiftUI

struct HeatMapItem: Identifiable {
  let id: UUID = UUID()
  let date: Date
  let weight: Double
}

struct HeatMapItemView: View {
  var heatMapItem: HeatMapItem
  var color: Color = .gray
  var active: Bool {
    heatMapItem.weight > 0.25 ? true : false
  }
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 5)
        .fill(active ? color.opacity(heatMapItem.weight) : .secondary.opacity(0.5))
        .frame(width: 33, height: 23)
    }
  }
}

struct HeatMapView: View {
  let columns = [GridItem(.adaptive(minimum: 28))]
  var color: Color = Color(red: 60 / 255, green: 238 / 255, blue: 73 / 255)
  var date = Date()
  var heatMapItems: [HeatMapItem]
  
  var title: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: date)
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
      LazyVGrid(columns: columns, spacing: 5) {
        ForEach(heatMapItems) { item in
          HeatMapItemView(heatMapItem: item, color: color)
        }
      }
    }
  }
}

// 샘플 데이터를 생성
let heatMapItems: [HeatMapItem] = {
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .day, value: -30, to: Date())!
    return (0..<30).map { index in
        let date = calendar.date(byAdding: .day, value: index, to: startDate)!
        return HeatMapItem(date: date, weight: Double.random(in: 0...1))
    }
}()

#Preview {
    HeatMapView(date: Date(), heatMapItems: heatMapItems)
}


