//
//  ContentView.swift
//  Grocery List
//
//  Created by Furkan İSLAM on 13.04.2025.
//

import SwiftUI
import SwiftData
import TipKit

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item] // veritabanında güncelleme olduğun da anasayfa da güncellenmesi için yazılan bir kod.
    
    @State private var item: String = ""
    
    @FocusState private var isFocued: Bool
    
    let buttonTip = ButtonTip()
    
    func setupTips() {
        do {
            try Tips.resetDatastore()
            Tips.showAllTipsForTesting()
            try Tips.configure([
                .displayFrequency(.immediate)
            ])
        } catch {
            print("Error initializing TipKit \(error.localizedDescription)")
        }
    }
    
    init() {
        setupTips()
    }
    
    func addEssentialFoods() {
        modelContext.insert(Item(title: "Bakery & Bread", isCompletion: false))
        modelContext.insert(Item(title: "Meat & Seafood", isCompletion: true))
        modelContext.insert(Item(title: "Creals", isCompletion: .random()))
        modelContext.insert(Item(title: "Pasta & Rice", isCompletion: .random()))
        modelContext.insert(Item(title: "Cheese & Eggs", isCompletion: .random()))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Text(item.title)
                        .font(.title.weight(.light))
                        .padding(.vertical, 2)
                        .foregroundStyle(item.isCompletion == false ? Color.primary : Color.accentColor)
                        .strikethrough(item.isCompletion)
                        .italic(item.isCompletion)
                        .swipeActions {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(item)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button("Done", systemImage: item.isCompletion == false ? "checkmark.circle" : "x.circle") {
                                item.isCompletion.toggle()
                            }
                            .tint(item.isCompletion == false ? .green : .accentColor)
                        }
                }
            }
            .navigationTitle("Grocery List")
            .toolbar{
                if items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            addEssentialFoods()
                        } label: {
                            Image(systemName: "carrot")
                        }
                        .popoverTip(buttonTip)
                    }
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("Empty Cart", systemImage: "cart.circle", description: Text("Add some items to the shopping list."))
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    TextField("", text: $item)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(.tertiary)
                        .cornerRadius(12)
                        .font(.title.weight(.light))
                        .focused($isFocued)
                    
                    Button {
                        guard !item.isEmpty else {
                            return
                        }
                        let newItem = Item(title: item, isCompletion: false)
                        modelContext.insert(newItem)
                        item = ""
                        isFocued = false
                    } label: {
                        Text("Save")
                            .font(.title2.weight(.medium))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.extraLarge)
                }
                .padding()
                .background(.bar)
            }
        }
    }
}

#Preview("Sample Data") {
    let sampleData: [Item] = [
        Item(title: "Bakery & Bread", isCompletion: false),
        Item(title: "Meat & Seafood", isCompletion: true),
        Item(title: "Creals", isCompletion: .random()),
        Item(title: "Pasta & Rice", isCompletion: .random()),
        Item(title: "Cheese & Eggs", isCompletion: .random())
    ]
    
    let container = try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    for item in sampleData {
        container.mainContext.insert(item)
    }
    return ContentView()
        .modelContainer(container)
}

#Preview("Empty List") {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
