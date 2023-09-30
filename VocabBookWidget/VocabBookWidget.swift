//
//  VocabBookWidget.swift
//  VocabBookWidget
//
//  Created by Oliver Brehm on 30.09.23.
//  Copyright © 2023 Oliver Brehm. All rights reserved.
//

import WidgetKit
import SwiftUI
import SwiftData

struct VocabBookState {
    let nDue: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> VocabBookStateEntry {
        .init(date: Date(), state: .init(nDue: 0))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (VocabBookStateEntry) -> Void) {
        completion(placeholder(in: context))
    }
    
    /*func placeholder(in context: Context) -> VocabBookStateEntry {
        VocabBookStateEntry(date: Date(), state: VocabBookState(nDue: 0))
    }

    func snapshot(for configuration: VocabBookState, in context: Context) async -> VocabBookStateEntry {
        VocabBookStateEntry(date: Date(), state: configuration)
    }*/

    /*
    func timeline(for configuration: VocabBookState, in context: Context) async -> Timeline<VocabBookStateEntry> {
        var entries: [VocabBookStateEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = VocabBookStateEntry(date: entryDate, state: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }*/

    func getTimeline(in context: Context, completion: @escaping (Timeline<VocabBookStateEntry>) -> Void) {
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate

        let entry = VocabBookStateEntry(date: currentDate, state: VocabBookState(nDue: 0))

        let timeline = Timeline(entries: [entry], policy: .after(nextDate))

        completion(timeline)
    }
}

struct VocabBookStateEntry: TimelineEntry {
    let date: Date
    let state: VocabBookState
}

struct VocabBookWidgetEntryView : View {
    var entry: VocabBookStateEntry

    var body: some View {
        VStack {
            Text("VocabBook")
            Text("Due cards: \(entry.state.nDue)")
        }
    }
}

struct VocabBookWidget: Widget {
    let kind: String = "VocabBookWidget"

    var body: some WidgetConfiguration {
        /*
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            VocabBookWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }*/
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VocabBookWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

/*
extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}*/

#Preview(as: .systemSmall) {
    VocabBookWidget()
} timeline: {
    VocabBookStateEntry(date: .now, state: .init(nDue: 0))
    //VocabBookStateEntry(date: .now, configuration: .starEyes)
}
