import SwiftUI
import PhotosUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: Store

    @State private var name = ""
    @State private var expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var category: FoodCategory = .other
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        NavigationView {
            Form {
                Section("البيانات") {
                    TextField("اسم الطعام", text: $name)
                    DatePicker("تاريخ الانتهاء", selection: $expiryDate, displayedComponents: .date)
                    Picker("التصنيف", selection: $category) {
                        ForEach(FoodCategory.allCases) { cat in
                            Label(cat.title, systemImage: cat.symbol).tag(cat)
                        }
                    }
                }
                Section("الصورة") {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: category.color).opacity(0.15))
                                .frame(width: 72, height: 72)
                            if let data = imageData, let ui = UIImage(data: data) {
                                Image(uiImage: ui).resizable().scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Label("اختيار صورة", systemImage: "photo.on.rectangle")
                        }
                        .onChange(of: pickerItem) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    imageData = data
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("إضافة طعام")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") {
                        let item = FoodItem(name: name.isEmpty ? "منتج" : name,
                                            expiryDate: expiryDate,
                                            category: category,
                                            imageData: imageData)
                        store.add(item)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

