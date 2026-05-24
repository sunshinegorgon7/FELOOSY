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
                FWCategory(name: "Coffee",    amount: 200, color: Color(argb: "#FF0E3B2E")),
                FWCategory(name: "Transport", amount: 295, color: Color(argb: "#FF1E4FA3")),
                FWCategory(name: "Dining",    amount: 100, color: Color(argb: "#FFA6192E")),
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
                let catColor  = obj["color"]  as? String ?? "#FF0E3B2E"
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
    private var bg:          Color { isDark ? Color(argb: "#FF0D1513") : Color(argb: "#FFF3F6EF") }
    private var textColor:   Color { isDark ? Color(argb: "#FFE3ECE8") : Color(argb: "#FF202823") }
    private var mutedColor:  Color { isDark ? Color(argb: "#FFAAB7B1") : Color(argb: "#FF566156") }
    private var accentColor: Color { isDark ? Color(argb: "#FF8FD5E6") : Color(argb: "#FF1E4FA3") }
    private var overColor:   Color { isDark ? Color(argb: "#FFFF7885") : Color(argb: "#FFA6192E") }
    private var primaryFill: Color { isDark ? Color(argb: "#FF8FD5E6") : Color(argb: "#FF0E3B2E") }
    private var onPrimary:   Color { isDark ? Color(argb: "#FF0E3B2E") : Color(argb: "#FFF3F6EF") }
    // Button text follows the active fill so the primary circle stays readable.

    // Static category palettes (applied by index, ignoring per-category DB colors)
    private let catColorsLight: [Color] = [
        Color(argb: "#FF0E3B2E"), // Forest green
        Color(argb: "#FF1E4FA3"), // Royal blue
        Color(argb: "#FFA6192E"), // Ghazel blood
        Color(argb: "#FF647A43"), // Moss green
    ]
    private let catColorsDark: [Color] = [
        Color(argb: "#FF8FD5E6"), // Ice performance blue
        Color(argb: "#FF6F8FEA"), // Lifted royal blue
        Color(argb: "#FFFF7885"), // Ghazel blood
        Color(argb: "#FFA8BE72"), // Moss green
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
