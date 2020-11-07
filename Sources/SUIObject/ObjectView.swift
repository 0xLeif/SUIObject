//
//  ObjectView.swift
//  SUIObject
//
//  Created by Zach Eriksen on 11/7/20.
//

import SwiftUI

public struct ObjectView<Content>: View where Content: View {
    @ObservedObject private var object: Object
    
    public var content: (Object) -> Content
    
    public init(
        object: Object,
        content: @escaping (Object) -> Content
    ) {
        self.object = object
        self.content = content
    }
    
    public var body: some View {
        content(object)
    }
}

public extension Object {
    func view<Content>(content: @escaping (Object) -> Content) -> ObjectView<Content> where Content: View {
        ObjectView(object: self, content: content)
    }
}

struct ObjectView_Previews: PreviewProvider {
    static private var previewObject: Object {
        Object { $0.add(value: "SUIObject") }
    }
    
    static private var previewObjectView: some View {
        previewObject.view { obj in
            Text(obj.stringValue() ?? "-1")
        }
    }
    
    static var previews: some View {
        ObjectView(object: previewObject) { obj in
            Text(obj.stringValue() ?? "-1")
        }
    }
}
