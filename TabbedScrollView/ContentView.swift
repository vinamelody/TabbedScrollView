//
//  ContentView.swift
//  TabbedScrollView
//
//  Created by Vina Rianti on 7/6/23.
//

import SwiftUI

class Model: ObservableObject {
    @Published var tabBarYOffset: CGFloat = .zero
}

struct ContentView: View {
    @StateObject private var model = Model()
    @State private var selection: Int = 0
    @State private var scrollContentOffset: CGPoint = .zero
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            
            HStack {
                Button("Home") {
                    selection = 0
                }
                
                Button("Detail") {
                    selection = 1
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal)
            .background(.thinMaterial)
            .offset(y: max(250 - model.tabBarYOffset, .zero))
            .zIndex(1)
            
            // Tab content
            TabView(selection: $selection) {
                TabContentScrollView(backgroundColor: Color.orange) {
                    ForEach(0..<100) { idx in
                        Text("Home \(selection + 1) - \(idx)")
                            .frame(maxWidth: .infinity)
                    }
                }
                .tag(0)
                
                TabContentScrollView {
                    ForEach(0..<100) { idx in
                        Text("Detail \(selection + 1) - \(idx)")
                            .frame(maxWidth: .infinity)
                    }
                }
                .tag(1)
            }
            .environmentObject(model)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// Native SwiftUI Scroll View
struct TabContentScrollView<Content: View>: View {
    
    @EnvironmentObject var model: Model
    var backgroundColor: Color = Color.yellow
    @ViewBuilder let content: Content
    @State private var offset: CGPoint = .zero
    
    var body: some View {
        OffsetObservingScrollView(offset: $offset) {
            VStack(spacing: .zero) {
                // Transparency
                Color.clear
                    .frame(height: 300)
                // Main content
                content
                .background(backgroundColor)
            }
        }
        .onChange(of: offset.y) { newValue in
            model.tabBarYOffset = newValue
        }
        .onAppear {
            offset.y = model.tabBarYOffset
            print("--> onAppear \(offset.y)")
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/// View that observes its position within a given coordinate space,
/// and assigns that position to the specified Binding.
struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    @Binding var position: CGPoint
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        content()
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: PreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(PreferenceKey.self) { position in
                self.position = position
            }
    }
}

private extension PositionObservingView {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }
        
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            // No-op
        }
    }
}

/// Specialized scroll view that observes its content offset (scroll position)
/// and assigns it to the specified Binding.

struct OffsetObservingScrollView<Content: View>: View {
    var axes: Axis.Set = [.vertical]
    var showsIndicators = true
    @Binding var offset: CGPoint
    @ViewBuilder var content: () -> Content
    
    // The name of our coordinate space doesn't have to be
    // stable between view updates (it just needs to be
    // consistent within this view), so we'll simply use a
    // plain UUID for it:
    private let coordinateSpaceName = UUID()
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                position: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(
                            x: -newOffset.x,
                            y: -newOffset.y
                        )
                    }
                ),
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}
