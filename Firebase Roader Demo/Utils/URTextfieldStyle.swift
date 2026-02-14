//
//  URTextfieldStyle.swift
//  Firebase Roader Demo
//
//  Created by Harshit on 2/13/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import SwiftUI

struct URTextfieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration.body
            .padding()
            .background(.white)
            .foregroundStyle(.primary)
            .clipShape(.capsule)
    }
}

extension TextFieldStyle where Self == URTextfieldStyle {
    static var URStyle: URTextfieldStyle { URTextfieldStyle() }
}

#Preview {
    @Previewable @State var text = "Some text"
    
    VStack {
        TextField("Something", text: $text)
            .textFieldStyle(URTextfieldStyle())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}
