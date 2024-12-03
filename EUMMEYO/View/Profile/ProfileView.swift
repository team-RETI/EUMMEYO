//
//  ProfileView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack {
                Image("DOGE")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 530, height: 150)
                    .clipShape(Circle())
                    .padding(.top, 50)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 33))
                    .foregroundColor(.blue)
                    .offset(x: 65, y: -50)
                
                VStack(alignment: .leading) {
                    Text("\("Doge")님")
                    // .font(.title)
                        .font(.system(size: 35))
                        .fontWeight(.bold)
                    Text("음메요를 입양한지 000일째")
                        .font(.system(size: 25))
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                }
                
                /*
                 HeatMapView(date: Date(), heatMapItems: heatMapItems)
                 .padding(.top, 30)
                 */
                
                Spacer()
                
                HStack(spacing: 30) {
                    Button {
                        
                    } label: {
                        Image(systemName: "moon.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.black)
                        
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "info.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.black)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "bell.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.black)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.black)
                    }
                    
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ProfileView()
}
