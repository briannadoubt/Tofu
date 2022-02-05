//
//  CategoryCard.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import SwiftUI
import RealmSwift
import ErrorHandler

struct CategoryCard: View {
    
    @EnvironmentObject var content: ContentObserver
    @ObservedRealmObject var category: Category
    
    var items: [Item] {
        if !category.isInvalidated {
            return category.items.sorted(by: \.due, ascending: true).sorted(by: { $0.completed == false || $1.completed == true })
        } else {
            return []
        }
    }
    
    @State var newItemName = ""
    @State var newItemDescription = ""
    
    @FocusState var focused: Item?
    
    func save() {
        guard newItemName != "" else {
            return
        }
        Task {
            do {
                let newItem = try await content.newItem(name: newItemName, description: newItemDescription, categoryId: category._id)
                withAnimation {
                    $category.items.append(newItem)
                    newItemName = ""
                    newItemDescription = ""
                }
            } catch {
                await ErrorObserver.shared.handleError(error, message: "Failed to save new item")
            }
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        Task {
            do {
                for offset in offsets {
                    let item = category.items[offset]
                    try await content.deleteItem(item)
                }
            } catch {
                assertionFailure("Failed to delete item")
                await ErrorObserver.shared.handleError(error, message: "Failed to delete item")
            }
        }
    }
    
    func updateCategory() {
        Task {
            do {
                try await content.updateCategory(category._id, name: category.name)
            } catch {
                await ErrorObserver.shared.handleError(error, message: "Failed to update category")
            }
        }
    }
    
    func deleteCategory(_ category: Category) {
        Task {
            for item in category.items {
            
                do {
                    try await content.deleteItem(item)
                } catch {
                    await ErrorObserver.shared.handleError(error, message: "Failed to delete item in category")
                }
            }
            $category.delete()
            do {
                try await content.deleteCategory(category._id)
            } catch {
                await ErrorObserver.shared.handleError(error, message: "Failed to delete category")
            }
        }
    }
    
    var body: some View {
        Section {
            HStack {
                TextField("Category Name", text: $category.name, prompt: Text("Category"))
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .tint(.white)
                    .colorMultiply(.white)
                    .onSubmit(updateCategory)
                Menu {
                    if !category.isInvalidated {
                        Button(role: .destructive) {
                            deleteCategory(category)
                        } label: {
                            Label("Delete \"\(category.name)\"", systemImage: "trash.fill")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
            }
            .listRowBackground(Color.accentColor)
            
            ForEach(items) { item in
                ItemRow(category: category, item: item)
                    .environment(\.realm, content.realm)
            }
            .onMove(perform: $category.items.move)
            .onDelete(perform: deleteItems)
            
            HStack {
                TextField("New Item", text: $newItemName, prompt: Text("New Item"))
                    .onSubmit(save)
                
                if newItemName != "" {
                    Button("Save", action: save)
                        .foregroundColor(.accentColor)
                        .buttonStyle(.plain)
                }
            }
            if newItemName != "" {
                ItemDescriptionTextEditor(description: $newItemDescription)
            }
        }
        .animation(.spring(), value: category.items)
//        .onAppear(perform: observeItemChanges)
    }
}

//struct CategoryCard_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryCard()
//    }
//}
