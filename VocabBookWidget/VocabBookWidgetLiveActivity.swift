//
//  VocabBookWidgetLiveActivity.swift
//  VocabBookWidget
//
//  Created by Oliver Brehm on 30.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI

/*
struct VocabBookWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct VocabBookWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VocabBookWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension VocabBookWidgetAttributes {
    fileprivate static var preview: VocabBookWidgetAttributes {
        VocabBookWidgetAttributes(name: "World")
    }
}

extension VocabBookWidgetAttributes.ContentState {
    fileprivate static var smiley: VocabBookWidgetAttributes.ContentState {
        VocabBookWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: VocabBookWidgetAttributes.ContentState {
         VocabBookWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: VocabBookWidgetAttributes.preview) {
   VocabBookWidgetLiveActivity()
} contentStates: {
    VocabBookWidgetAttributes.ContentState.smiley
    VocabBookWidgetAttributes.ContentState.starEyes
}
*/
