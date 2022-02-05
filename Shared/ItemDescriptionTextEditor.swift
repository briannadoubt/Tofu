//
//  ItemDescriptionTextEditor.swift
//  ToFu
//
//  Created by Bri on 2/3/22.
//

import SwiftUI

struct ItemDescriptionTextEditor: View {
    
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $description)
                .frame(maxWidth: .infinity, minHeight: 34, maxHeight: .infinity)
                .fixedSize(horizontal: false, vertical: true)
            Text("Optional description")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

struct ItemDescriptionTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        ItemDescriptionTextEditor(description: .constant("Rawr"))
    }
}
