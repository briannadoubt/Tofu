//
//  ItemRow.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import SwiftUI
import RealmSwift
import ErrorHandler

struct ItemCompletedButton: View {
    @Binding var completed: Bool
    var update: () async -> ()
    var body: some View {
        Button {
            completed.toggle()
            Task {
                await update()
            }
        } label: {
            Image(systemName: completed ? "cube.fill" : "cube").transition(.scale)
        }
        .buttonStyle(.plain)
    }
}

struct ItemRow: View {
    
    @EnvironmentObject var content: ContentObserver
    @ObservedRealmObject var category: Category
    @ObservedRealmObject var item: Item
    
    @FocusState var focused
    
    #if DEBUG
    let showingId = true
    #endif
    
    @MainActor func update() async {
        do {
            let _ = content.realm.thaw()
            let response = try await content.httpActor.updateItem(item._id, name: item.name, description: item.taskDescription, categoryId: item.categoryId, due: item.due, completed: item.completed)
            let _ = content.realm.freeze()
            debugPrint(response.status, response.content)
            focused = false
        } catch let error as ErrorResponse {
            await ErrorObserver.shared.handle(error)
        } catch {
            await ErrorObserver.shared.handleError(error, message: "Failed to update item")
        }
    }
    
    var body: some View {
        HStack {
            ItemCompletedButton(completed: $item.completed.animation(.spring()), update: update)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    TextField("Item", text: $item.name.animation(.spring()), prompt: Text("Item"))
                        .focused($focused)
                        .foregroundColor(item.completed ? .gray : .primary)
                        .onSubmit {
                            Task {
                                await update()
                            }
                        }
                    if focused {
                        Button("Update") {
                            Task {
                                await update()
                            }
                        }
                        .foregroundColor(.accentColor)
                        .buttonStyle(.plain)
                    } else {
                        #if DEBUG
                        if showingId {
                            Text("\(item._id)").foregroundColor(.secondary)
                        }
                        #endif
                    }
                }
                if focused {
                    ItemDescriptionTextEditor(description: $item.taskDescription)
                        .focused($focused)
                    
                } else if item.taskDescription != "" {
                    Text(item.taskDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                if focused {
                    DatePicker(
                        "Due: ",
                        selection: Binding(
                            get: {
                                item.due ?? Date()
                            }, set: { newDueDate in
                                Task {
                                    do {
                                        guard let item = item.thaw() else {
                                            fatalError()
                                        }
                                        try content.realm.write {
                                            item.due = newDueDate
                                        }
                                
                                        try await content.updateItem(item)
                                    } catch {
                                        await ErrorObserver.shared.handleError(error, message: "Failed to update item with new date")
                                    }
                                }
                            }
                        )
                    )
                } else if let due = item.due {
                    (Text("Due: ") + Text(due.formatted(date: .numeric, time: .shortened)))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focused = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
    }
}

//struct ItemRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemRow()
//    }
//}
