import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: Date())
        // Timeline estática, pois o botão é apenas um atalho de emergência
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct EmergencyWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            // Botão Circular para a Tela de Bloqueio (iOS 16+)
            Link(destination: URL(string: "basta://home")!) {
                ZStack {
                    AccessoryWidgetBackground()
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.title2)
                }
            }
        case .accessoryRectangular:
            // Botão Retangular com Texto para a Tela de Bloqueio
            Link(destination: URL(string: "basta://home")!) {
                HStack {
                    Image(systemName: "exclamationmark.shield.fill")
                    VStack(alignment: .leading) {
                        Text("EMERGÊNCIA")
                            .font(.headline)
                        Text("Abrir Alerta")
                            .font(.caption)
                    }
                }
            }
        default:
            Text("Apenas Lock Screen")
        }
    }
}

struct EmergencyWidget: Widget {
    let kind: String = "EmergencyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EmergencyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Acesso Rápido de Emergência")
        .description("Toque para disparar o pedido de ajuda imediatamente.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}
