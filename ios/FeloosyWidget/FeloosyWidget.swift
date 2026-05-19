import SwiftUI
import WidgetKit

// MARK: - App Group

private let kAppGroup = "group.com.feloosy.feloosy"

// MARK: - Data model

struct FWCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct FWData {
    let accountName: String
    let currencyCode: String
    let available: Double
    let isOverBudget: Bool
    let todayEmpty: Bool
    let todayTotal: Double
    let categories: [FWCategory]

    static var placeholder: FWData {
        FWData(
            accountName: "Wallet",
            currencyCode: "AED",
            available: 3200,
            isOverBudget: false,
            todayEmpty: false,
            todayTotal: 595,
            categories: [
                FWCategory(name: "Coffee",    amount: 200, color: Color(argb: "#FF8A6F5C")),
                FWCategory(name: "Transport", amount: 295, color: Color(argb: "#FF5F7F8A")),
                FWCategory(name: "Dining",    amount: 100, color: Color(argb: "#FF8F7A4F")),
            ]
        )
    }

    static func load() -> FWData {
        let d = UserDefaults(suiteName: kAppGroup)
        let available   = Double(d?.string(forKey: "fw_available")   ?? "0") ?? 0
        let isOver      = d?.bool(forKey: "fw_is_over_budget") ?? false
        let todayEmpty  = d?.bool(forKey: "fw_today_empty")    ?? true
        let todayTotal  = Double(d?.string(forKey: "fw_today_total") ?? "0") ?? 0
        let name        = d?.string(forKey: "fw_account_name")  ?? "Wallet"
        let currency    = d?.string(forKey: "fw_currency_code") ?? "AED"

        var cats: [FWCategory] = []
        if let json = d?.string(forKey: "fw_categories_json"),
           let data = json.data(using: .utf8),
           let arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            for obj in arr {
                let catName   = obj["name"]   as? String ?? "Other"
                let catAmount = obj["amount"] as? Double ?? 0
                let catColor  = obj["color"]  as? String ?? "#FF6E8790"
                cats.append(FWCategory(name: catName, amount: catAmount,
                                       color: Color(argb: catColor)))
            }
        }
        return FWData(accountName: name, currencyCode: currency,
                      available: available, isOverBudget: isOver,
                      todayEmpty: todayEmpty, todayTotal: todayTotal,
                      categories: cats)
    }
}

// MARK: - Color helper (Flutter ARGB #AARRGGBB)

extension Color {
    init(argb hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var val: UInt64 = 0
        Scanner(string: h).scanHexInt64(&val)
        let a: Double
        let r: Double
        let g: Double
        let b: Double
        if h.count == 8 {
            a = Double((val & 0xFF000000) >> 24) / 255
            r = Double((val & 0x00FF0000) >> 16) / 255
            g = Double((val & 0x0000FF00) >>  8) / 255
            b = Double( val & 0x000000FF        ) / 255
        } else {
            a = 1
            r = Double((val & 0xFF0000) >> 16) / 255
            g = Double((val & 0x00FF00) >>  8) / 255
            b = Double( val & 0x0000FF        ) / 255
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Timeline

struct FWEntry: TimelineEntry {
    let date: Date
    let data: FWData
}

struct FWProvider: TimelineProvider {
    func placeholder(in context: Context) -> FWEntry {
        FWEntry(date: .now, data: .placeholder)
    }
    func getSnapshot(in context: Context, completion: @escaping (FWEntry) -> Void) {
        completion(FWEntry(date: .now, data: context.isPreview ? .placeholder : .load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<FWEntry>) -> Void) {
        let entry    = FWEntry(date: .now, data: .load())
        let nextFire = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextFire)))
    }
}

// MARK: - Widget view

struct FeloosyWidgetEntryView: View {
    let entry: FWEntry
    @Environment(\.colorScheme) var colorScheme

    private var isDark: Bool {
        let stored = UserDefaults(suiteName: kAppGroup)?
            .string(forKey: "fw_theme_mode") ?? "system"
        switch stored {
        case "dark":  return true
        case "light": return false
        default:      return colorScheme == .dark
        }
    }

    // Adaptive palette — mirrors AppTheme dark/light palettes
    private var bg:          Color { isDark ? Color(argb: "#FF1E2E3D") : Color(argb: "#FFF4F7F1") }
    private var textColor:   Color { isDark ? Color(argb: "#FFC4D0DC") : Color(argb: "#FF2C2C2C") }
    private var mutedColor:  Color { isDark ? Color(argb: "#FF9AB0C4") : Color(argb: "#FF4A5E40") }
    private var accentColor: Color { isDark ? Color(argb: "#FF7AAECF") : Color(argb: "#FF3F6329") }
    private var overColor:   Color { isDark ? Color(argb: "#FFF07171") : Color(argb: "#FFB23636") }
    private var primaryFill: Color { isDark ? Color(argb: "#FF4D7FA8") : Color(argb: "#FF639922") }
    private var onPrimary:   Color { isDark ? Color(argb: "#FF060C11") : Color(argb: "#FF162008") }
    // Button text is dark in both modes so the primary circle stays readable.

    // Static category palettes (applied by index, ignoring per-category DB colors)
    private let catColorsLight: [Color] = [
        Color(argb: "#FF6E8F68"), // Soft Sage
        Color(argb: "#FF8F7A4F"), // Ledger Ochre
        Color(argb: "#FF7C7796"), // Dust Violet
        Color(argb: "#FF67849A"), // Steel Water
    ]
    private let catColorsDark: [Color] = [
        Color(argb: "#FF9BB09B"), // Pale Sage
        Color(argb: "#FFC0A86A"), // Muted Ochre
        Color(argb: "#FFA99FC8"), // Pale Violet
        Color(argb: "#FF8FB2C8"), // Steel Water
    ]
    private var catPalette: [Color] { isDark ? catColorsDark : catColorsLight }

    var data: FWData { entry.data }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                headerRow.padding(.bottom, data.todayEmpty || data.categories.isEmpty ? 0 : 10)
                if !data.todayEmpty && !data.categories.isEmpty {
                    barView.padding(.bottom, 8)
                    legendRow
                }
            }
            .padding(14)
        }
        .widgetURL(URL(string: "feloosy:///"))
        .accessibilityElement(children: .contain)
    }

    // ── Header ──────────────────────────────────────────────────────────
    private var headerRow: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(data.isOverBudget ? "OVER BUDGET" : "AVAILABLE TO SPEND")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.1)
                    .foregroundColor(data.isOverBudget ? overColor : mutedColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .accessibilityHidden(true)

                HStack(alignment: .bottom, spacing: 0) {
                    Text(formattedAvailable)
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(data.isOverBudget ? overColor : textColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(" \(data.currencyCode)")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(accentColor)
                        .offset(y: -3)
                }
            }
            .accessibilityLabel(
                "\(formattedAvailable) \(data.currencyCode) available to spend this month"
            )

            Spacer(minLength: 8)

            Link(destination: URL(string: "feloosy:///transactions/add?type=expense")!) {
                ZStack {
                    Circle().fill(primaryFill).frame(width: 42, height: 42)
                    Text("−")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(onPrimary)
                }
            }
            .accessibilityLabel("Add expense")
        }
    }

    private var formattedAvailable: String {
        let abs = Swift.abs(data.available)
        let prefix = data.available < 0 ? "−" : ""
        return prefix + fmtDouble(abs)
    }

    // ── Progress bar ─────────────────────────────────────────────────────
    private var barView: some View {
        GeometryReader { geo in
            if data.todayEmpty || data.categories.isEmpty {
                Rectangle()
                    .fill(textColor.opacity(0.1))
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                let total = data.categories.map(\.amount).reduce(0, +)
                HStack(spacing: 0) {
                    ForEach(Array(data.categories.enumerated()), id: \.offset) { i, cat in
                        Rectangle()
                            .fill(catPalette[i % catPalette.count])
                            .frame(
                                width: total > 0
                                    ? CGFloat(cat.amount / total) * geo.size.width
                                    : 0
                            )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }
        }
        .frame(height: 8)
        .accessibilityLabel(
            "This month's spending: \(fmtDouble(data.todayTotal)) \(data.currencyCode)" +
            " across \(data.categories.count) categories"
        )
    }

    // ── Legend ───────────────────────────────────────────────────────────
    private var legendRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(data.categories.enumerated()), id: \.offset) { i, cat in
                HStack(spacing: 3) {
                    Circle().fill(catPalette[i % catPalette.count]).frame(width: 7, height: 7)
                    Text(cat.name)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            // Fill remaining slots so items are evenly spaced
            let remaining = max(0, 4 - data.categories.count)
            ForEach(0..<remaining, id: \.self) { _ in
                Spacer().frame(maxWidth: .infinity)
            }
        }
    }

    private func fmtDouble(_ v: Double) -> String {
        v == Double(Int(v)) ? "\(Int(v))" : String(format: "%.2f", v)
    }
}

// MARK: - Widget declaration

struct FeloosyWidget: Widget {
    let kind = "FeloosyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FWProvider()) { entry in
            FeloosyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Feloosy")
        .description("Available budget and top spending categories this month.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Preview

struct FeloosyWidget_Previews: PreviewProvider {
    static var previews: some View {
        FeloosyWidgetEntryView(entry: FWEntry(date: .now, data: .placeholder))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
