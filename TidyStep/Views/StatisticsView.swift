//
//  StatisticsView.swift
//  TidyStep
//

import SwiftUI

private struct DayDetailItem: Identifiable {
    let id = UUID()
    let dayStart: Date
}

/// 柱状图点击详情：按天 / 按周 / 按月
private struct PeriodDetailItem: Identifiable {
    enum Kind { case day, week, month }
    let kind: Kind
    let periodStart: Date
    var id: String { "\(kind)-\(periodStart.timeIntervalSince1970)" }
}

private struct PeriodDetailSheetView: View {
    @Binding var detailItem: PeriodDetailItem?
    let title: String
    let summary: StatsSummary
    let formatMin: (Int) -> String
    @EnvironmentObject var appLanguage: AppLanguage

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(hex: 0x9CA3AF))
                VStack(spacing: 12) {
                    row(appLanguage.string("stats_sessions"), "\(summary.count)")
                    row(appLanguage.string("session_duration"), formatMin(Int(summary.totalDurationSeconds / 60)))
                    row(appLanguage.string("session_steps"), "\(summary.totalSteps)")
                    row(appLanguage.string("end_calories"), String(format: "%.0f", summary.totalCalories))
                }
                .padding(20)
                .background(Color(hex: 0x1A1A1E))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: 0x0D0D0F))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(appLanguage.string("end_done")) {
                        detailItem = nil
                    }
                    .foregroundStyle(Color(hex: 0x5EEAD4))
                }
            }
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}

private struct DayDetailSheetView: View {
    @Binding var detailItem: DayDetailItem?
    let dayStart: Date
    let summary: StatsSummary
    let dayLabel: String
    let formatMin: (Int) -> String
    @EnvironmentObject var appLanguage: AppLanguage

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(dayLabel)
                    .font(.headline)
                    .foregroundStyle(Color(hex: 0x9CA3AF))
                VStack(spacing: 12) {
                    row(appLanguage.string("stats_sessions"), "\(summary.count)")
                    row(appLanguage.string("session_duration"), formatMin(Int(summary.totalDurationSeconds / 60)))
                    row(appLanguage.string("session_steps"), "\(summary.totalSteps)")
                    row(appLanguage.string("end_calories"), String(format: "%.0f", summary.totalCalories))
                }
                .padding(20)
                .background(Color(hex: 0x1A1A1E))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: 0x0D0D0F))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(appLanguage.string("end_done")) {
                        detailItem = nil
                    }
                    .foregroundStyle(Color(hex: 0x5EEAD4))
                }
            }
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}

/// 自定义日历：有记录的日期标蓝圈（统一小圆不重叠），仅可选有数据日
private struct SessionCalendarView: View {
    @Binding var selectedDate: Date
    let daysWithData: Set<Date>
    /// 点击有数据的日期时调用，用于直接弹出该日统计详情
    var onDayTapped: ((Date) -> Void)?
    private let cal = Calendar.current
    /// 数字背后的圆形背景直径，统一缩小避免相邻重叠
    private let circleBackgroundSize: CGFloat = 24
    @State private var displayedMonthStart: Date

    init(selectedDate: Binding<Date>, daysWithData: Set<Date>, onDayTapped: ((Date) -> Void)? = nil) {
        _selectedDate = selectedDate
        self.daysWithData = daysWithData
        self.onDayTapped = onDayTapped
        let start = Calendar.current.startOfDay(for: selectedDate.wrappedValue)
        _displayedMonthStart = State(initialValue: Calendar.current.dateInterval(of: .month, for: start)?.start ?? start)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    if let prev = cal.date(byAdding: .month, value: -1, to: displayedMonthStart) {
                        displayedMonthStart = prev
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                }
                Spacer()
                Text(monthYearString(displayedMonthStart))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    if let next = cal.date(byAdding: .month, value: 1, to: displayedMonthStart) {
                        displayedMonthStart = next
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(hex: 0x6B7280))
                }
                ForEach(Array(daysInGrid().enumerated()), id: \.offset) { _, cell in
                    dayCell(cell)
                }
            }
        }
        .padding(12)
        .background(Color(hex: 0x1A1A1E))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func weekdaySymbols() -> [String] {
        let first = cal.firstWeekday
        let symbols = cal.veryShortWeekdaySymbols
        return (0..<7).map { symbols[(first - 1 + $0) % 7] }
    }

    private struct DayCell: Hashable {
        let day: Int?
        let date: Date?
    }

    private func daysInGrid() -> [DayCell] {
        guard let interval = cal.dateInterval(of: .month, for: displayedMonthStart),
              let count = cal.range(of: .day, in: .month, for: displayedMonthStart)?.count else { return [] }
        let firstWeekday = cal.component(.weekday, from: interval.start)
        let offset = firstWeekday - cal.firstWeekday
        let startOffset = offset < 0 ? offset + 7 : offset
        var cells: [DayCell] = []
        for _ in 0..<startOffset {
            cells.append(DayCell(day: nil, date: nil))
        }
        for day in 1...count {
            if let date = cal.date(bySetting: .day, value: day, of: interval.start) {
                cells.append(DayCell(day: day, date: cal.startOfDay(for: date)))
            }
        }
        while cells.count < 42 {
            cells.append(DayCell(day: nil, date: nil))
        }
        return cells
    }

    @ViewBuilder
    private func dayCell(_ cell: DayCell) -> some View {
        let hasData = cell.date.map { daysWithData.contains($0) } ?? false
        let isToday = cell.date.map { cal.isDateInToday($0) } ?? false
        let showCircle = hasData || isToday
        let circleColor: Color = isToday ? Color(hex: 0x38BDF8) : Color(hex: 0x5EEAD4)
        let content = ZStack {
            if let day = cell.day {
                if showCircle {
                    Circle()
                        .fill(circleColor)
                        .frame(width: circleBackgroundSize, height: circleBackgroundSize)
                }
                Text("\(day)")
                    .font(.system(size: 13, weight: showCircle ? .semibold : .regular))
                    .foregroundStyle(showCircle ? .white : Color(hex: 0x6B7280))
            }
        }
        .frame(height: 36)
        .contentShape(Rectangle())

        if hasData, let date = cell.date {
            Button {
                selectedDate = date
                onDayTapped?(date)
            } label: {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
                .allowsHitTesting(false)
        }
    }

    private func monthYearString(_ monthStart: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = cal.locale
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")
        return formatter.string(from: monthStart)
    }
}

/// 汇总周期：近 7 / 14 / 30 / 60 / 90 / 120 / 150 / 180 / 210 / 240 / 270 / 300 / 330 / 360 天
private enum SummaryPeriod: String, CaseIterable {
    case last7Days
    case last14Days
    case last30Days
    case last60Days
    case last90Days
    case last120Days
    case last150Days
    case last180Days
    case last210Days
    case last240Days
    case last270Days
    case last300Days
    case last330Days
    case last360Days
    var days: Int {
        switch self {
        case .last7Days: return 7
        case .last14Days: return 14
        case .last30Days: return 30
        case .last60Days: return 60
        case .last90Days: return 90
        case .last120Days: return 120
        case .last150Days: return 150
        case .last180Days: return 180
        case .last210Days: return 210
        case .last240Days: return 240
        case .last270Days: return 270
        case .last300Days: return 300
        case .last330Days: return 330
        case .last360Days: return 360
        }
    }
}

/// 图表纵轴指标：次数 / 时长 / 步数 / 卡路里
private enum ChartMetric: String, CaseIterable {
    case sessions
    case duration
    case steps
    case calories
}

/// 图表周期：同上（柱状图对应同样天数的柱子）
private enum ChartPeriod: String, CaseIterable {
    case last7Days
    case last14Days
    case last30Days
    case last60Days
    case last90Days
    case last120Days
    case last150Days
    case last180Days
    case last210Days
    case last240Days
    case last270Days
    case last300Days
    case last330Days
    case last360Days
    var days: Int {
        switch self {
        case .last7Days: return 7
        case .last14Days: return 14
        case .last30Days: return 30
        case .last60Days: return 60
        case .last90Days: return 90
        case .last120Days: return 120
        case .last150Days: return 150
        case .last180Days: return 180
        case .last210Days: return 210
        case .last240Days: return 240
        case .last270Days: return 270
        case .last300Days: return 300
        case .last330Days: return 330
        case .last360Days: return 360
        }
    }
}

struct StatisticsView: View {
    @EnvironmentObject var storage: StorageManager
    @EnvironmentObject var appLanguage: AppLanguage
    @EnvironmentObject var subscription: SubscriptionManager
    @State private var showPaywall = false
    @State private var shareItem: ShareItem?
    @State private var selectedDayForDetail: DayDetailItem?
    private static let summaryPeriodKey = "stats_summary_period"
    private static let chartPeriodKey = "stats_chart_period"
    private static let chartMetricKey = "stats_chart_metric"
    @State private var summaryPeriod: SummaryPeriod = .last7Days
    @State private var chartPeriod: ChartPeriod = .last7Days
    @State private var chartMetric: ChartMetric = .sessions
    @State private var selectedPeriodDetail: PeriodDetailItem?
    /// 当图表 >14 天时，用日期选择器查询某日数据
    @State private var queryDate: Date = Date()

    private var selectedSummary: StatsSummary {
        storage.statsLast(days: summaryPeriod.days)
    }

    /// 按当前选择的指标取该日的数值（用于柱高/折线纵轴）
    private func chartValue(for item: DayChartItem, metric: ChartMetric) -> Double {
        switch metric {
        case .sessions: return Double(item.sessionCount)
        case .duration: return item.totalDurationSeconds
        case .steps: return Double(item.totalSteps)
        case .calories: return item.totalCalories
        }
    }

    private func chartMetricTitle(_ m: ChartMetric) -> String {
        switch m {
        case .sessions: return appLanguage.string("stats_sessions")
        case .duration: return appLanguage.string("session_duration")
        case .steps: return appLanguage.string("session_steps")
        case .calories: return appLanguage.string("end_calories")
        }
    }

    private func summaryPeriodTitle(_ p: SummaryPeriod) -> String {
        switch p {
        case .last7Days: return appLanguage.string("stats_last_7_days")
        case .last14Days: return appLanguage.string("stats_last_14_days")
        case .last30Days: return appLanguage.string("stats_last_30_days")
        case .last60Days: return appLanguage.string("stats_last_60_days")
        case .last90Days: return appLanguage.string("stats_last_90_days")
        case .last120Days: return appLanguage.string("stats_last_120_days")
        case .last150Days: return appLanguage.string("stats_last_150_days")
        case .last180Days: return appLanguage.string("stats_last_180_days")
        case .last210Days: return appLanguage.string("stats_last_210_days")
        case .last240Days: return appLanguage.string("stats_last_240_days")
        case .last270Days: return appLanguage.string("stats_last_270_days")
        case .last300Days: return appLanguage.string("stats_last_300_days")
        case .last330Days: return appLanguage.string("stats_last_330_days")
        case .last360Days: return appLanguage.string("stats_last_360_days")
        }
    }

    private func chartPeriodTitle(_ p: ChartPeriod) -> String {
        switch p {
        case .last7Days: return appLanguage.string("stats_last_7_days")
        case .last14Days: return appLanguage.string("stats_last_14_days")
        case .last30Days: return appLanguage.string("stats_last_30_days")
        case .last60Days: return appLanguage.string("stats_last_60_days")
        case .last90Days: return appLanguage.string("stats_last_90_days")
        case .last120Days: return appLanguage.string("stats_last_120_days")
        case .last150Days: return appLanguage.string("stats_last_150_days")
        case .last180Days: return appLanguage.string("stats_last_180_days")
        case .last210Days: return appLanguage.string("stats_last_210_days")
        case .last240Days: return appLanguage.string("stats_last_240_days")
        case .last270Days: return appLanguage.string("stats_last_270_days")
        case .last300Days: return appLanguage.string("stats_last_300_days")
        case .last330Days: return appLanguage.string("stats_last_330_days")
        case .last360Days: return appLanguage.string("stats_last_360_days")
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x0D0D0F)
                    .ignoresSafeArea()

                if subscription.hasAccess {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            summarySection
                            chartSection
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 0) {
                        premiumLockView
                        preview2DaySection
                    }
                }
            }
            .navigationTitle(appLanguage.string("tab_statistics"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        let sessions = storage.sessionsThisWeek.isEmpty ? storage.sessionsLast2Days : storage.sessionsThisWeek
                        shareItem = ShareItem(text: buildWeeklyShareText(sessions: sessions, appLanguage: appLanguage))
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .regular))
                            .frame(width: 44, height: 44, alignment: .center)
                            .contentShape(Rectangle())
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appLanguage.toggleLanguage()
                    } label: {
                        Image(systemName: "globe")
                            .font(.system(size: 17, weight: .regular))
                            .frame(width: 44, height: 44, alignment: .center)
                            .contentShape(Rectangle())
                            .foregroundStyle(Color(hex: 0x9CA3AF))
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(onDismiss: { showPaywall = false })
                    .environmentObject(subscription)
                    .environmentObject(appLanguage)
            }
            .sheet(item: $shareItem) { item in
                ShareSheet(items: [item.text.isEmpty ? (appLanguage.string("share_stats_week_header") + " " + appLanguage.string("share_stats_empty")) : item.text])
            }
            .sheet(item: $selectedDayForDetail) { item in
                DayDetailSheetView(
                    detailItem: $selectedDayForDetail,
                    dayStart: item.dayStart,
                    summary: storage.statsForDay(dayStart: item.dayStart),
                    dayLabel: shortDayLabel(item.dayStart),
                    formatMin: formatMin
                )
                .environmentObject(appLanguage)
            }
            .sheet(item: $selectedPeriodDetail) { detail in
                PeriodDetailSheetView(
                    detailItem: $selectedPeriodDetail,
                    title: periodDetailTitle(detail),
                    summary: periodDetailSummary(detail),
                    formatMin: formatMin
                )
                .environmentObject(appLanguage)
            }
            .onAppear {
                if let raw = UserDefaults.standard.string(forKey: Self.summaryPeriodKey), let p = SummaryPeriod(rawValue: raw) {
                    summaryPeriod = p
                }
                if let raw = UserDefaults.standard.string(forKey: Self.chartPeriodKey), let p = ChartPeriod(rawValue: raw) {
                    chartPeriod = p
                }
                if let raw = UserDefaults.standard.string(forKey: Self.chartMetricKey), let m = ChartMetric(rawValue: raw) {
                    chartMetric = m
                }
            }
            .onChange(of: summaryPeriod) { new in
                UserDefaults.standard.set(new.rawValue, forKey: Self.summaryPeriodKey)
            }
            .onChange(of: chartPeriod) { new in
                UserDefaults.standard.set(new.rawValue, forKey: Self.chartPeriodKey)
            }
            .onChange(of: chartMetric) { new in
                UserDefaults.standard.set(new.rawValue, forKey: Self.chartMetricKey)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(appLanguage.string("stats_summary_period"))
                .font(.headline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            Menu {
                ForEach(SummaryPeriod.allCases, id: \.self) { p in
                    Button(summaryPeriodTitle(p)) { summaryPeriod = p }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(summaryPeriodTitle(summaryPeriod))
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                }
                .contentShape(Rectangle())
            }
            .tint(.white)
            statsCard(summary: selectedSummary)
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(appLanguage.string("stats_chart_period"))
                .font(.headline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            Menu {
                ForEach(ChartPeriod.allCases, id: \.self) { p in
                    Button(chartPeriodTitle(p)) { chartPeriod = p }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(chartPeriodTitle(chartPeriod))
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                }
                .contentShape(Rectangle())
            }
            .tint(.white)
            Text(appLanguage.string("stats_chart_metric"))
                .font(.headline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            Menu {
                ForEach(ChartMetric.allCases, id: \.self) { m in
                    Button(chartMetricTitle(m)) { chartMetric = m }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(chartMetricTitle(chartMetric))
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                }
                .contentShape(Rectangle())
            }
            .tint(.white)
            barChartContent
        }
    }

    /// 图表：≤60 天柱状图一屏展示；≥90 天折线图一屏展示；仅 7 天可点柱，≥14 天用日期选择器。纵轴按 chartMetric 显示。
    private var barChartContent: some View {
        let days = chartPeriod.days
        let items = storage.lastDaysChartItems(days: days)
        let maxValue = max(1, items.map { chartValue(for: $0, metric: chartMetric) }.max() ?? 1)
        let canTapBar = (days == 7)
        let useLineChart = (days >= 90)
        return barChartContainer(showTitle: false) {
            VStack(alignment: .leading, spacing: 12) {
                if days >= 14 {
                    datePickerRow
                }
                if useLineChart {
                    lineChartView(items: items, metric: chartMetric, maxValue: maxValue)
                        .frame(height: 100)
                } else {
                    barChartView(items: items, days: days, metric: chartMetric, maxValue: maxValue, canTapBar: canTapBar)
                        .frame(height: 100)
                }
            }
        }
    }

    private func barChartView(items: [DayChartItem], days: Int, metric: ChartMetric, maxValue: Double, canTapBar: Bool) -> some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 8
            let availableWidth = geometry.size.width - horizontalPadding * 2
            let spacing: CGFloat = 2
            let totalSpacing = CGFloat(max(0, days - 1)) * spacing
            let computedBarWidth = max(2, (availableWidth - totalSpacing) / CGFloat(days))
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(items) { item in
                    let value = chartValue(for: item, metric: metric)
                    Group {
                        if canTapBar {
                            Button {
                                selectedDayForDetail = DayDetailItem(dayStart: item.dayStart)
                            } label: {
                                barColumn(item: item, barWidth: computedBarWidth, days: days, value: value, maxValue: maxValue)
                            }
                            .buttonStyle(.plain)
                        } else {
                            barColumn(item: item, barWidth: computedBarWidth, days: days, value: value, maxValue: maxValue)
                        }
                    }
                    .frame(width: computedBarWidth)
                }
            }
            .frame(width: availableWidth)
            .padding(.horizontal, horizontalPadding)
        }
    }

    /// 折线图：≥90 天时使用，一屏内显示全部数据点；纵轴按 metric 取值
    private func lineChartView(items: [DayChartItem], metric: ChartMetric, maxValue: Double) -> some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let count = items.count
            if count <= 1 {
                if let first = items.first {
                    Text(shortDayLabel(first.dayStart))
                        .font(.caption2)
                        .foregroundStyle(Color(hex: 0x6B7280))
                }
            } else {
                let stepX = (w - 16) / CGFloat(count - 1)
                let maxVal = CGFloat(max(1, maxValue))
                let points: [(CGFloat, CGFloat)] = items.enumerated().map { i, item in
                    let x = 8 + CGFloat(i) * stepX
                    let val = chartValue(for: item, metric: metric)
                    let y = h - 20 - (CGFloat(val) / maxVal) * (h - 24)
                    return (x, max(4, y))
                }
                ZStack(alignment: .bottomLeading) {
                    Path { path in
                        path.move(to: CGPoint(x: points[0].0, y: points[0].1))
                        for i in 1..<points.count {
                            path.addLine(to: CGPoint(x: points[i].0, y: points[i].1))
                        }
                    }
                    .stroke(Color(hex: 0x5EEAD4), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    ForEach(Array(items.enumerated()), id: \.element.id) { i, _ in
                        Circle()
                            .fill(Color(hex: 0x5EEAD4))
                            .frame(width: 4, height: 4)
                            .position(x: points[i].0, y: points[i].1)
                    }
                    if let first = items.first {
                        Text(shortDayLabel(first.dayStart))
                            .font(.system(size: 6, weight: .medium))
                            .foregroundStyle(Color(hex: 0x6B7280))
                            .position(x: 8, y: h - 4)
                    }
                    if let last = items.last {
                        Text(shortDayLabel(last.dayStart))
                            .font(.system(size: 6, weight: .medium))
                            .foregroundStyle(Color(hex: 0x6B7280))
                            .position(x: w - 8, y: h - 4)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    /// 单根柱子：无数据时贴底显示（固定高度区域，柱从底部向上生长）
    private func barColumn(item: DayChartItem, barWidth: CGFloat, days: Int, value: Double, maxValue: Double) -> some View {
        let barMaxHeight: CGFloat = 80
        let h = value <= 0 ? 4 : max(4, CGFloat(value) / CGFloat(max(1, maxValue)) * barMaxHeight)
        return VStack(spacing: 2) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: 0x5EEAD4))
                    .frame(width: max(2, barWidth - 2), height: h)
            }
            .frame(height: barMaxHeight)
            Text(shortDayLabel(item.dayStart))
                .font(.system(size: dayLabelFontSize(for: days), weight: .medium))
                .foregroundStyle(Color(hex: 0x6B7280))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    /// ≥14 天时显示：自定义日历（有记录日标蓝圈、仅可选有数据日）+ 查看按钮
    private var datePickerRow: some View {
        let cal = Calendar.current
        let daysWithData = storage.dayStartsWithSessions
        return VStack(alignment: .leading, spacing: 12) {
            SessionCalendarView(selectedDate: $queryDate, daysWithData: daysWithData) { dayStart in
                selectedDayForDetail = DayDetailItem(dayStart: dayStart)
            }
            Button {
                let dayStart = cal.startOfDay(for: queryDate)
                selectedDayForDetail = DayDetailItem(dayStart: dayStart)
            } label: {
                Text(appLanguage.string("stats_view_day"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(hex: 0x0D0D0F))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: 0x5EEAD4))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
    }

    private func dayLabelFontSize(for days: Int) -> CGFloat {
        switch days {
        case 7: return 10
        case 14: return 9
        case 30: return 8
        case 60: return 7
        case 90: return 7
        case 120: return 6
        case 150...360: return 5
        default: return 8
        }
    }

    private func barChartContainer<Content: View>(showTitle: Bool = false, title: String = "", @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if showTitle && !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: 0x6B7280))
            }
            content()
                .padding(.vertical, 12)
                .padding(20)
                .background(Color(hex: 0x1A1A1E))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func periodDetailTitle(_ detail: PeriodDetailItem) -> String {
        switch detail.kind {
        case .day: return shortDayLabel(detail.periodStart)
        case .week: return shortWeekRangeLabel(detail.periodStart)
        case .month: return shortMonthRangeLabel(detail.periodStart)
        }
    }

    private func periodDetailSummary(_ detail: PeriodDetailItem) -> StatsSummary {
        switch detail.kind {
        case .day: return storage.statsForDay(dayStart: detail.periodStart)
        case .week: return storage.statsForWeek(weekStart: detail.periodStart)
        case .month: return storage.statsForMonth(monthStart: detail.periodStart)
        }
    }

    private var premiumLockView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color(hex: 0x5EEAD4))
            Text(appLanguage.string("paywall_stats_locked"))
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(appLanguage.string("paywall_stats_locked_subtitle"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
                .multilineTextAlignment(.center)
            Button {
                showPaywall = true
            } label: {
                Text(appLanguage.string("paywall_unlock"))
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: 0x5EEAD4))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    /// Free users: 2-day stats (次数, duration, steps, calories) + bar chart preview.
    private var preview2DaySection: some View {
        let summary = storage.statsLast2Days
        let items = storage.last2DaysChartItems
        let maxCount = max(1, items.map(\.sessionCount).max() ?? 1)
        return VStack(alignment: .leading, spacing: 12) {
            Text(appLanguage.string("stats_chart_preview"))
                .font(.headline)
                .foregroundStyle(Color(hex: 0x9CA3AF))
            HStack(spacing: 16) {
                miniStat(value: "\(summary.count)", label: appLanguage.string("stats_sessions"))
                miniStat(value: formatMin(Int(summary.totalDurationSeconds / 60)), label: appLanguage.string("session_duration"))
                miniStat(value: "\(summary.totalSteps)", label: appLanguage.string("session_steps"))
                miniStat(value: String(format: "%.0f", summary.totalCalories), label: appLanguage.string("end_calories"))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            HStack(alignment: .bottom, spacing: 20) {
                ForEach(items) { item in
                    Button {
                        selectedDayForDetail = DayDetailItem(dayStart: item.dayStart)
                    } label: {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: 0x5EEAD4))
                                .frame(width: 14, height: max(4, CGFloat(item.sessionCount) / CGFloat(maxCount) * 60))
                            Text(shortDayLabel(item.dayStart))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color(hex: 0x6B7280))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 12)
            .padding(20)
            .background(Color(hex: 0x1A1A1E))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }

    private func statsCard(summary: StatsSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                miniStat(value: "\(summary.count)", label: appLanguage.string("stats_sessions"))
                miniStat(value: formatMin(Int(summary.totalDurationSeconds / 60)), label: appLanguage.string("session_duration"))
                miniStat(value: "\(summary.totalSteps)", label: appLanguage.string("session_steps"))
                miniStat(value: String(format: "%.0f", summary.totalCalories), label: appLanguage.string("end_calories"))
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0x1A1A1E))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color(hex: 0x6B7280))
        }
        .frame(maxWidth: .infinity)
    }

    private func formatMin(_ min: Int) -> String {
        if min < 60 { return "\(min)m" }
        let h = min / 60
        let m = min % 60
        return m > 0 ? "\(h)h\(m)m" : "\(h)h"
    }

    private func shortWeekLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        f.locale = Locale.current
        return f.string(from: date)
    }

    private func shortWeekRangeLabel(_ weekStart: Date) -> String {
        let cal = Calendar.current
        guard let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart) else { return shortWeekLabel(weekStart) }
        let f = DateFormatter()
        f.dateFormat = "M/d"
        f.locale = Locale.current
        return "\(f.string(from: weekStart)) – \(f.string(from: weekEnd))"
    }

    private func shortMonthLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M"
        f.locale = Locale.current
        return f.string(from: date)
    }

    private func shortMonthRangeLabel(_ monthStart: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy M"
        f.locale = Locale.current
        return f.string(from: monthStart)
    }

    private func shortDayLabel(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return appLanguage.string("stats_today") }
        if cal.isDateInYesterday(date) { return appLanguage.string("stats_yesterday") }
        let f = DateFormatter()
        f.dateFormat = "M/d"
        f.locale = Locale.current
        return f.string(from: date)
    }
}
