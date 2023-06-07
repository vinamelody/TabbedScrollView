//
//  SundelView.swift
//  TabbedScrollView
//
//  Created by Vina Rianti on 7/6/23.
//

import SwiftUI

/// View that renders scrollable content beneath a header that
/// automatically collapses when the user scrolls down.
struct SundelView<Content: View>: View {
    var title: String
    var headerGradient: Gradient
    @ViewBuilder var content: () -> Content

    private let headerHeight = (collapsed: 50.0, expanded: 150.0)
    @State private var scrollOffset = CGPoint()

    var body: some View {
        GeometryReader { geometry in
            OffsetObservingScrollView(offset: $scrollOffset) {
                VStack(spacing: 0) {
                    makeHeaderText(collapsed: false)
                    content()
                }
            }
            .overlay(alignment: .top) {
                makeHeaderText(collapsed: true)
                    .background(alignment: .top) {
                        headerLinearGradient.ignoresSafeArea()
                    }
                    .opacity(collapsedHeaderOpacity)
            }
            .background(alignment: .top) {
                // We attach the expanded header's background to the scroll
                // view itself, so that we can make it expand into both the
                // safe area, as well as any negative scroll offset area:
                headerLinearGradient
                    .frame(height: max(0, headerHeight.expanded - scrollOffset.y) + geometry.safeAreaInsets.top)
                    .ignoresSafeArea()
            }
        }
    }
}

private extension SundelView {
    var collapsedHeaderOpacity: CGFloat {
        let minOpacityOffset = headerHeight.expanded / 2
        let maxOpacityOffset = headerHeight.expanded - headerHeight.collapsed

        guard scrollOffset.y > minOpacityOffset else { return 0 }
        guard scrollOffset.y < maxOpacityOffset else { return 1 }

        let opacityOffsetRange = maxOpacityOffset - minOpacityOffset
        return (scrollOffset.y - minOpacityOffset) / opacityOffsetRange
    }

    var headerLinearGradient: LinearGradient {
        LinearGradient(
            gradient: headerGradient,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    func makeHeaderText(collapsed: Bool) -> some View {
        Text(title)
            .font(collapsed ? .body : .title)
            .lineLimit(1)
            .padding()
            .frame(height: collapsed ? headerHeight.collapsed : headerHeight.expanded)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .accessibilityHeading(.h1)
            .accessibilityHidden(collapsed)
    }
}

struct SundelView_Previews: PreviewProvider {
    static var previews: some View {
        SundelView(title: "Hiiiii", headerGradient: Gradient(colors: [Color.orange, Color.red])) {
            ForEach(0..<100) { idx in
                Text("Line at \(idx)")
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
