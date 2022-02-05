//
//  NewCategoryButton.swift
//  ToFu (iOS)
//
//  Created by Bri on 2/2/22.
//

import SwiftUI
import RealmSwift
import ErrorHandler

struct NewCategoryButton: View {
    
    @EnvironmentObject fileprivate var content: ContentObserver
    
    let categoryNames = ["Not today, seitan!", "[Tasteless tofu joke here]", "Lookin' soy fine", "Tofu, or not tofu?", "Soy oh soy"]
    
    var body: some View {
        Button {
            Task {
                do {
                    let newCategory = try await content.newCategory(name: categoryNames.randomElement() ?? "New Category")
                    try content.realm.write {
                        content.realm.add(newCategory)
                    }
                } catch {
                    await ErrorObserver.shared.handleError(error, message: "Failed to save new category")
                }
            }
        } label: {
            Label("New Category", systemImage: "plus")
        }
    }
}

//struct NewCategoryButton_Previews: PreviewProvider {
//    static var previews: some View {
//        NewCategoryButton(localCategories: [])
//    }
//}
