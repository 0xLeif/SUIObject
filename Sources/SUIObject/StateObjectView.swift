//
//  StateObjectView.swift
//  SUIObject
//
//  Created by Zach Eriksen on 12/3/20.
//

import SwiftUI

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
public struct StateObjectView<Content>: View where Content: View {
    @StateObject private var object: Object
    
    public var content: (Object) -> Content
    
    public init(
        object: Object,
        content: @escaping (Object) -> Content
    ) {
        self._object = StateObject(wrappedValue: object)
        self.content = content
    }
    
    public var body: some View {
        content(object)
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
public extension Object {
    func stateView<Content>(content: @escaping (Object) -> Content) -> StateObjectView<Content> where Content: View {
        StateObjectView(object: self, content: content)
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
struct StateObjectView_Previews: PreviewProvider {
    static private var previewObject: Object {
        Object { $0.add(value: "SUIObject") }
    }
    
    static private var previewObjectView: some View {
        previewObject.stateView { obj in
            Text(obj.stringValue() ?? "-1")
        }
    }
    
    static var previews: some View {
        StateObjectView(object: previewObject) { obj in
            Text(obj.stringValue() ?? "-1")
        }
    }
}
