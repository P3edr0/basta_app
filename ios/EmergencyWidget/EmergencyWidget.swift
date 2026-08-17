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
        Group {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    // Substituímos o ícone pelo logo
                    Image("WidgetLogo")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .padding(8) // Dá um respiro para o logo não colar na borda
                }
            case .accessoryRectangular:
                HStack {
                    // Substituímos o ícone pelo logo
                    Image("WidgetLogo")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 42, height: 42) // Define um tamanho fixo para o logo aqui
                    
                    VStack(alignment: .leading) {
                        Text("BASTA")
                            .font(.headline)
                        Text("Abrir para emergência")
                            .font(.caption)
                    }
                }
            default:
                Text("Lock Screen")
            }
        }
        .widgetURL(URL(string: "basta://home"))
        .applyWidgetBackground()
    }
}
// Extensão segura para adicionar o fundo no iOS 17 e não quebrar em versões antigas
extension View {
    @ViewBuilder
    func applyWidgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(.clear, for: .widget)
        } else {
            self.background(Color.clear)
        }
    }
}

struct EmergencyWidget: Widget {
    let kind: String = "EmergencyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EmergencyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Acesso Rápido")
        .description("Toque para disparar o pedido de ajuda.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}
