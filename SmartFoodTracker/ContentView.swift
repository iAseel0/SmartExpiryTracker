import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @State private var showingAdd = false
    @State private var selected: FoodCategory? = nil
    @State private var query = ""

    var filtered: [FoodItem] {
        var arr = store.items
        if let sel = selected { arr = arr.filter { $0.category == sel } }
        if !query.trimmingCharacters(in: .whitespaces).isEmpty {
            arr = arr.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
        return arr.sorted { $0.daysLeft < $1.daysLeft }
    }

    let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            LinearGradient(colors: [.mint.opacity(0.35), .blue.opacity(0.25)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                header
                searchField
                categoryChips

                ScrollView {
                    LazyVGrid(columns: cols, spacing: 12) {
                        ForEach(filtered) { item in
                            Card(item: item)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let i = store.items.firstIndex(where: {$0.id == item.id}) {
                                            store.items.remove(at: i)
                                        }
                                    } label: {
                                        Label("حذف", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 8)

                    VStack(spacing: 4) {
                        Text("Made with ❤️ by ASO")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .sheet(isPresented: $showingAdd) { AddItemView() }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Smart Food")
                    .font(.largeTitle.bold())
                Text("تتبّع صلاحية الأطعمة حسب التصنيف")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { showingAdd = true } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
            }
            .tint(.blue)
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    // MARK: - Search
    private var searchField: some View {
        TextField("ابحث باسم المنتج…", text: $query)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
    }

    // MARK: - Category Chips
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Chip(title: "الكل", symbol: "square.grid.2x2.fill",
                     selected: selected == nil, color: .gray) {
                    selected = nil
                }
                ForEach(FoodCategory.allCases) { cat in
                    Chip(title: cat.title, symbol: cat.symbol,
                         selected: selected == cat,
                         color: Color(uiColor: cat.color)) {
                        selected = (selected == cat) ? nil : cat
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
}

// MARK: - Card View
private struct Card: View {
    let item: FoodItem

    var statusColor: Color {
        item.daysLeft <= 0 ? .red : (item.daysLeft <= 3 ? .orange : .green)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: item.category.color).opacity(0.18))

                if let data = item.imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: item.category.symbol)
                            .font(.system(size: 26))
                        Text(item.category.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                }
            }
            .frame(height: 110)

            Text(item.name)
                .font(.headline)
            Text("ينتهي: \(item.expiryDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                ProgressView(value: progressValue)
                    .tint(statusColor)
                Spacer(minLength: 6)
                Text(item.daysLeft <= 0 ? "منتهي" : "\(item.daysLeft) يوم")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundStyle(statusColor)
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 6)
    }

    private var progressValue: Double {
        let totalWindow = 14.0
        return min(max(Double(item.daysLeft) / totalWindow, 0), 1)
    }
}

// MARK: - Chip Component
private struct Chip: View {
    let title: String
    let symbol: String
    let selected: Bool
    let color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                Text(title)
            }
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selected ? color.opacity(0.22) : Color.secondary.opacity(0.12))
            .foregroundStyle(selected ? color : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(selected ? color : .clear, lineWidth: 1)
            )
        }
    }
}

