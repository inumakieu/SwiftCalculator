//
//  ContentView.swift
//  Calculator
//
//  Created by Inumaki on 01.01.23.
//

import SwiftUI

struct TextButton: View {
    let text: String
    var body: some View {
        ZStack {
            Color(hex: "#ff23283c")
            Text(text)
                .font(.system(size: 22, weight: .medium))
        }
        .frame(width: 78,height: 78)
        .cornerRadius(35)
    }
}

struct Button: View {
    let text: String
    @Binding var equation: String
    
    var body: some View {
        ZStack {
            Color(hex: "#ff23283c")
            Text(text)
                .font(.system(size: 22, weight: .medium))
        }
        .frame(width: 78,height: 78)
        .cornerRadius(35)
        .onTapGesture {
            if(text == "=") {
                let expression = NSExpression(format: equation.replacingOccurrences(of: "x", with: "*").replacingOccurrences(of: "÷", with: "/"))
                let value = expression.expressionValue(with: nil, context: nil) as? Int
                equation = value != nil ? String(value!) : "ERROR"
            } else {
                equation = equation + text
            }
        }
    }
}

struct ContentView: View {
    @State var equation = ""
    var body: some View {
        ZStack {
            Color(hex: "#ff1e2336")
            
            VStack {
                // display
                ZStack {
                    Color(hex: "#ff23283c")
                    Text(equation)
                            .padding(40)
                            .font(.system(size: 60))
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                    
                         
                }
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                .padding(.bottom, 10)
                
                HStack {
                    Text("√")
                        .bold()
                    
                    Spacer()
                    
                    Text("π")
                        .bold()
                    
                    Spacer()
                    
                    Text("^")
                        .bold()
                    
                    Spacer()
                    
                    Text("!")
                        .bold()
                    
                    Spacer()
                    
                    ZStack {
                        Color(hex: "#ff8bbf44")
                        Image(systemName: "chevron.down")
                            .bold()
                    }
                    .frame(width: 38, height: 38)
                    .cornerRadius(19)
                }
                .padding(.horizontal, 34)
                
                // buttons
                HStack(alignment: .center, spacing: 12) {
                    TextButton(text: "AC")
                        .onTapGesture {
                            equation = ""
                        }
                    TextButton(text: "( )")
                    Button(text: "%", equation: $equation)
                    Button(text: "÷", equation: $equation)
                }
                HStack(alignment: .center, spacing: 12) {
                    Button(text: "7", equation: $equation)
                    Button(text: "8", equation: $equation)
                    Button(text: "9", equation: $equation)
                    Button(text: "x", equation: $equation)
                }
                HStack(alignment: .center, spacing: 12) {
                    Button(text: "4", equation: $equation)
                    Button(text: "5", equation: $equation)
                    Button(text: "6", equation: $equation)
                    Button(text: "-", equation: $equation)
                }
                HStack(alignment: .center, spacing: 12) {
                    Button(text: "1", equation: $equation)
                    Button(text: "2", equation: $equation)
                    Button(text: "3", equation: $equation)
                    Button(text: "+", equation: $equation)
                }
                HStack(alignment: .center, spacing: 12) {
                    Button(text: "0", equation: $equation)
                    Button(text: "•", equation: $equation)
                    ZStack {
                        Color(hex: "#ff23283c")
                        Image(systemName: "delete.left")
                    }
                    .frame(width: 78,height: 78)
                    .cornerRadius(35)
                    Button(text: "=", equation: $equation)
                }
            }
            .padding(.bottom, 20)
        }
        .ignoresSafeArea()
        .foregroundColor(.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
