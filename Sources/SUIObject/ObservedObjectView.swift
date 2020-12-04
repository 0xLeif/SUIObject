//
//  ObservedObjectView.swift
//  SUIObject
//
//  Created by Zach Eriksen on 11/7/20.
//

import SwiftUI

public struct ObservedObjectView<Content>: View where Content: View {
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
    func observedView<Content>(content: @escaping (Object) -> Content) -> ObservedObjectView<Content> where Content: View {
        ObservedObjectView(object: self, content: content)
    }
}

struct ObjectView_Previews: PreviewProvider {
    static private var previewObject: Object {
        Object { $0.add(value: "SUIObject") }
    }
    
    static private var previewObjectView: some View {
        previewObject.observedView { obj in
            Text(obj.stringValue() ?? "-1")
        }
    }
    
    static var previews: some View {
        ObservedObjectView(object: previewObject) { obj in
            Text(obj.stringValue() ?? "-1")
        }
    }
}
