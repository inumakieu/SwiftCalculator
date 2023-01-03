//
//  ContentView.swift
//  Calculator
//
//  Created by Inumaki on 01.01.23.
//

import SwiftUI
import Expression
import Numerics

extension RangeReplaceableCollection {
    mutating func splice<R: RangeExpression>(range: R) -> SubSequence
    where R.Bound == Index {
        let result = self[range]
        self.removeSubrange(range)
        return result
    }
}

struct MyButtonStyle: ButtonStyle {
    @Binding var extraOptions: Bool
    let color: String?

  func makeBody(configuration: Self.Configuration) -> some View {
      configuration.label
          .frame(width: 78,height: extraOptions ? 64 : 78)
          .foregroundColor(.white)
          .background(configuration.isPressed ? Color(hex: "#ff363D58") : Color(hex: "ff23283c"))
          .animation(.spring(response: 0.3), value: extraOptions)
      
    }
}

struct TextButton: View {
    let text: String
    @Binding var equation: String
    @Binding var result: String
    @Binding var extraOptions: Bool
    @Binding var errored: Bool
    let color: String?
    
    var body: some View {
        ZStack {
            Color(hex: (color ?? "ff23283c"))
            Text(text)
                .font(.system(size: 22, weight: .medium))
        }
        .frame(width: 78,height: extraOptions ? 64 : 78)
        .cornerRadius(39)
        .animation(.spring(response: 0.3), value: extraOptions)
        .onTapGesture {
            if(text == "( )") {
                if(equation.count == 0 || equation.last! == "(") {
                    equation = equation + "("
                } else if(!equation.contains("(")) {
                    equation = equation + "("
                    
                } else {
                    equation = equation + ")"
                }
                
            } else if(text == "AC") {
                equation = ""
                result = ""
                errored = false
            }
        }
    }
}

struct CustomButton: View {
    let text: String
    @Binding var equation: String
    @Binding var result: String
    @Binding var extraOptions: Bool
    @Binding var errored: Bool
    let color: String?
    
    var body: some View {
        Button(action: {
            if(text == "=") {
                do {
                    let value = try ExpressionsLib().evaluateExpression(expo: equation.replacingOccurrences(of: "x", with: "*").replacingOccurrences(of: "÷", with: "/"))
                    result = String(value)
                } catch {
                    print(error)
                    result = "\(error)"
                    errored = true
                }
                
            } else if(text == "•") {
                equation = equation + "."
            } else {
                equation = equation + text
                
            }
        }) {
            //Color(hex: color ?? "#ff23283c")
            Text(text)
                .font(.system(size: text == "×" || text == "+" || text == "-" || text == "÷" || text == "=" ? 34 : 26, weight: .medium))
        }
        .buttonStyle(MyButtonStyle(extraOptions: $extraOptions, color: color))
        .cornerRadius(39)
    }
}

struct ContentView: View {
    @State var equation = ""
    @State var result = ""
    @State var extraOptions: Bool = false
    @State var halfExtended: Bool = false
    @State var errored: Bool = false
    
    var body: some View {
        let textField = TextField("textField", text: $equation)
        
        ZStack {
            Color(hex: "#ff1e2336")
            
            VStack {
                // display
                ZStack {
                    Color(hex: "#ff23283c")
                    VStack {
                        Spacer()
                        TextField("", text: $equation)
                            .padding(.horizontal, 40)
                            .foregroundColor(errored ? Color(hex: "#ffE53C3C") : .white)
                            .font(.system(size: 80))
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                        
                        Text(result)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                            .foregroundColor(errored ? Color(hex: "#ffE53C3C") : .white)
                            .opacity(0.7)
                            .font(.system(size: 40, weight: .medium))
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(maxWidth: 30, maxHeight: 4)
                            .padding(.bottom, 12)
                    }
                    .frame(height: halfExtended ? 500 : 320, alignment: .bottom)
                    .animation(.spring(response: 0.3), value: halfExtended)
                }
                .frame(height: halfExtended ? 500 : 320)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                .padding(.bottom, 10)
                .animation(.spring(response: 0.3), value: halfExtended)
                .gesture(
                    DragGesture(minimumDistance: 100)
                        .onEnded { endedGesture in
                            if (endedGesture.location.y - endedGesture.startLocation.y) > 0 {
                                // run code to increase display size
                                halfExtended = true
                            } else {
                                print("Up")
                                halfExtended = false
                            }
                        }
                )
                
                VStack {
                    HStack {
                        Text("√")
                            .bold()
                            .onTapGesture {
                                equation = equation + "√"
                            }
                        
                        Spacer()
                        
                        Text("π")
                            .bold()
                            .font(.system(size: 22))
                            .onTapGesture {
                                equation = equation + "π"
                            }
                        
                        Spacer()
                        
                        Text("^")
                            .bold()
                            .onTapGesture {
                                equation = equation + "^"
                            }
                        
                        Spacer()
                        
                        Text("!")
                            .bold()
                            .onTapGesture {
                                equation = equation + "!"
                            }
                        
                        Spacer()
                        
                        ZStack {
                            Color(hex: "#ff8bbf44")
                            Image(systemName: extraOptions ? "chevron.up" : "chevron.down")
                                .bold()
                        }
                        .frame(width: 38, height: 38)
                        .cornerRadius(19)
                        .animation(.spring(response: 0.3), value: extraOptions)
                        .onTapGesture {
                            extraOptions = !extraOptions
                        }
                    }
                    .padding(.horizontal, 34)
                    if(extraOptions) {
                        VStack {
                            HStack{
                                Text("RAD")
                                    .font(.system(size: 22))
                                    .padding(.trailing, 28)
                                Text("sin")
                                    .font(.system(size: 22))
                                    .padding(.trailing, 36)
                                    .onTapGesture {
                                        equation = equation + "sin("
                                    }
                                Text("cos")
                                    .font(.system(size: 22))
                                    .padding(.trailing, 30)
                                    .onTapGesture {
                                        equation = equation + "cos("
                                    }
                                Text("tan")
                                    .font(.system(size: 22))
                                    .onTapGesture {
                                        equation = equation + "tan("
                                    }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            Spacer()
                                .frame(maxHeight: 12)
                            HStack {
                                Text("INV")
                                    .font(.system(size: 22))
                                    .onTapGesture {
                                        equation = equation + "INV("
                                    }
                                
                                Spacer()
                                Text("e")
                                    .font(.system(size: 22))
                                    .padding(.trailing, 10)
                                    .onTapGesture {
                                        equation = equation + "e"
                                    }
                                
                                Spacer()
                                Text("ln")
                                    .font(.system(size: 22))
                                    .onTapGesture {
                                        equation = equation + "ln("
                                    }
                                
                                Spacer()
                                Text("log")
                                    .font(.system(size: 22))
                                    .onTapGesture {
                                        equation = equation + "log("
                                    }
                                
                                Spacer()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 22)
                        }
                    }
                }
                .padding(.bottom, 20)
                .animation(.spring(response: 0.3), value: extraOptions)
                
                // buttons
                HStack(alignment: .center, spacing: 20) {
                    TextButton(text: "AC", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: "#ff613b57")
                    TextButton(text: "( )", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: "#ff41465b")
                    CustomButton(text: "%", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: "#ff41465b")
                    CustomButton(text: "÷", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: "#ff41465b")
                }
                HStack(alignment: .center, spacing: 20) {
                    CustomButton(text: "7", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "8", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "9", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "×", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: "#ff41465b")
                }
                HStack(alignment: .center, spacing: 20) {
                    CustomButton(text: "4", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "5", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "6", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "-", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: "#ff41465b")
                }
                HStack(alignment: .center, spacing: 20) {
                    CustomButton(text: "1", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "2", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "3", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "+", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: "#ff41465b")
                }
                HStack(alignment: .center, spacing: 20) {
                    CustomButton(text: "0", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    CustomButton(text: "•", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: nil)
                    ZStack {
                        Color(hex: "#ff23283c")
                        Image(systemName: "delete.left")
                    }
                    .frame(width: 78,height: extraOptions ? 64 : 78)
                    .cornerRadius(35)
                    .animation(.spring(response: 0.3), value: extraOptions)
                    .onTapGesture {
                        equation = String(equation.dropLast())
                    }
                    CustomButton(text: "=", equation: $equation, result: $result, extraOptions: $extraOptions, errored: $errored, color: "#ff41465b")
                }
            }
            .padding(.bottom, 32)
            .animation(.spring(response: 0.3), value: halfExtended)
            
            ZStack {
                Menu(content: {
                    Button("History", action: placeOrder)
                    Menu("Theme") {
                        Button("Dark", action: rename)
                        Button("Light", action: delay)
                    }
                    Button("Send Feedback", action: cancelOrder)
                    Button("Help", action: adjustOrder)
                }, label: {
                    ZStack {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .font(.system(size: 22))
                    }
                    .frame(maxWidth: 40, maxHeight: 40)
                    
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.trailing, 20)
            .padding(.top, 40)
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
        .foregroundColor(Color(hex: "#ffb2beeb"))
    }
    
    func placeOrder() { }
    func adjustOrder() { }
    func rename() { }
    func delay() { }
    func cancelOrder() { }
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
