import Foundation
import UserNotifications
import UIKit

// MARK: - Categories
enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case dairy, meat, produce, snacks, drinks, frozen, bakery, other
    var id: String { rawValue }

    var title: String {
        switch self {
        case .dairy: return "ألبان"
        case .meat: return "لحوم"
        case .produce: return "خضار/فاكهة"
        case .snacks: return "سناكات"
        case .drinks: return "مشروبات"
        case .frozen: return "مجمدات"
        case .bakery: return "مخبوزات"
        case .other: return "أخرى"
        }
    }

    var symbol: String {
        switch self {
        case .dairy: return "carton"
        case .meat: return "fork.knife"
        case .produce: return "leaf"
        case .snacks: return "takeoutbag.and.cup.and.straw"
        case .drinks: return "cup.and.saucer.fill"
        case .frozen: return "snowflake"
        case .bakery: return "birthday.cake"
        case .other: return "shippingbox"
        }
    }

    var color: UIColor {
        switch self {
        case .dairy: return .systemTeal
        case .meat: return .systemRed
        case .produce: return .systemGreen
        case .snacks: return .systemOrange
        case .drinks: return .systemBlue
        case .frozen: return .systemMint
        case .bakery: return .systemBrown
        case .other: return .systemGray
        }
    }
}

// MARK: - Model
struct FoodItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var expiryDate: Date
    var category: FoodCategory = .other
    var imageData: Data? = nil

    var daysLeft: Int {
        let start = Calendar.current.startOfDay(for: Date())
        let end   = Calendar.current.startOfDay(for: expiryDate)
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
}

// MARK: - Data Store
final class Store: ObservableObject {
    @Published var items: [FoodItem] = [] { didSet { save() } }
    private let saveKey = "SavedItemsV3" 
    init() { load() }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([FoodItem].self, from: data) {
            items = decoded
        }
    }
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func add(_ item: FoodItem) {
        items.append(item)
        scheduleNotification(for: item)
    }
    func delete(at offsets: IndexSet) { items.remove(atOffsets: offsets) }

    // MARK: - Notification (قبل 3 أيام)
    private func scheduleNotification(for item: FoodItem) {
        let content = UNMutableNotificationContent()
        content.title = "تنبيه انتهاء صلاحية"
        content.body  = "\(item.name) سينتهي خلال 3 أيام!"
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .day, value: -3, to: item.expiryDate) ?? Date()
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        comps.hour = 9; comps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}

