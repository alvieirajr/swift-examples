//
//  ContentView.swift
//  AnimationTimingCurve
//
//  Created by Chris Eidhof on 25.09.19.
//  Copyright © 2019 Chris Eidhof. All rights reserved.
//
import SwiftUI
import Combine

let animations: [(String, Animation)] = [
    ("default", .default),
    ("linear(duration: 1)", .linear(duration: 1)),
    ("interpolatingSpring(stiffnes: 5, damping: 3)", .interpolatingSpring(stiffness: 5, damping: 3)),
  
    ("teste", Animation .interpolatingSpring(mass: 1, stiffness: 1, damping: 1, initialVelocity: 0).speed(10)),
  

    ("teste2", Animation .interpolatingSpring(mass: 0.5, stiffness: 1, damping: 1, initialVelocity: 0).speed(10)),
    
    (".easeInOut(duration: 1)", .easeInOut(duration: 1)),
    (".easeIn(duration: 1)", .easeIn(duration: 1)),
    (".easeOut(duration: 1)", .easeOut(duration: 1)),
    (".interactiveSpring(response: 3, dampingFraction: 2, blendDuration: 1)", .interactiveSpring(response:3, dampingFraction: 2, blendDuration: 1)),
    (".spring", .spring()),
    (".default.repeatCount(3)", Animation.default.repeatCount(3))
   
]

struct ContentView: View {

    @State var animating: Bool = false
    @State var selectedAnimationIndex: Int = 0
    @State var slowAnimations: Bool = false
    var selectedAnimation: (String, Animation) {
        return animations[selectedAnimationIndex]
    }
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .fill(Color.pink)
                    .frame(width: 60, height: 60)
                    .offset(x: animating ? -80 : 100)
                    .animation(Animation.interpolatingSpring(mass: 1, stiffness: 1, damping: 1, initialVelocity: 0).speed(5))
                Rectangle()
                    .fill(Color.green)
                        .frame(width:60, height: 60)
                        .offset(x: animating ? -80 : 100)
                    .animation(Animation.interpolatingSpring(mass: 1, stiffness: 1, damping: 1, initialVelocity: 0).speed(7).delay(0.15))
                Rectangle()
                   .fill(Color.blue)
                       .frame(width:60, height: 60)
                       .offset(x: animating ? -80 : 100)
                    .animation(Animation.interpolatingSpring(mass: 1 , stiffness: 1, damping: 1, initialVelocity: 0).speed(7).delay(0.20))
                Rectangle()
                   .fill(Color.gray)
                       .frame(width:60, height: 60)
                       .offset(x: animating ? -80 : 100)
                    .animation(Animation.interpolatingSpring(mass: 1 , stiffness: 1, damping: 1, initialVelocity: 0).speed(7).delay(0.25))
            }
            
            Spacer()
            Picker(selection: $selectedAnimationIndex, label: EmptyView(), content: {
                ForEach(0..<animations.count) {
                    Text(animations[$0].0)
                }
            })
            
            Button(action: {
                self.animating = false
                withAnimation(self.selectedAnimation.1.speed(self.slowAnimations ? 0.25 : 1), {
                    self.animating = true
                })
                
            }, label: { Text("Animate") })
            Toggle(isOn: $slowAnimations, label: { Text("Slow Animations") })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
