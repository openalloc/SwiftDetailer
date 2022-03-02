//
//  DetailerConfig.swift
//
// Copyright 2022 FlowAllocator LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

public enum DetailerConfigDefaults {
    
    #if os(macOS)
    public static let minWidth: CGFloat = 300
    #elseif os(iOS)
    public static let minWidth: CGFloat = 0
    #endif
    
    public static let validateIndicator: (Bool) -> AnyView = { AnyView(
        Image(systemName: "exclamationmark.triangle")
            .font(.title2)
            .backport.symbolRenderingMode()
            .foregroundColor(.orange)
            .opacity($0 ? 0 : 1)
    )}
}

public struct DetailerConfig<Element>
    where Element: Identifiable
{
    public typealias Context = DetailerContext<Element>

    public typealias CanDelete = (Element) -> Bool
    public typealias CanEdit = (Element) -> Bool
    public typealias OnDelete = (Element.ID) -> Void
    public typealias OnValidate = (Context, Element) -> [String]
    public typealias OnCancel = (Context, Element) -> Void
    public typealias OnSave = (Context, Element) -> Void
    public typealias Titler = (Element) -> String
    public typealias ValidateIndicator = (Bool) -> AnyView

    // MARK: Parameters

    public let minWidth: CGFloat
    public let canEdit: CanEdit?
    public let canDelete: CanDelete
    public let onDelete: OnDelete?
    public let onValidate: OnValidate
    public let onSave: OnSave?
    public let onCancel: OnCancel
    public let titler: Titler
    public let validateIndicator: ValidateIndicator

    public init(minWidth: CGFloat = DetailerConfigDefaults.minWidth,
                canEdit: CanEdit? = nil,
                canDelete: @escaping CanDelete = { _ in true },
                onDelete: OnDelete? = nil,
                onValidate: @escaping OnValidate = { _, _ in [] },
                onSave: OnSave? = nil,
                onCancel: @escaping OnCancel = { _, _ in },
                titler: @escaping Titler,
                validateIndicator: @escaping ValidateIndicator = DetailerConfigDefaults.validateIndicator)
    {
        self.minWidth = minWidth
        self.canEdit = canEdit
        self.canDelete = canDelete
        self.onDelete = onDelete
        self.onValidate = onValidate
        self.onSave = onSave
        self.onCancel = onCancel
        self.titler = titler
        self.validateIndicator = validateIndicator
    }
}


// Backport for .symbolRenderingMode which isn't supported in earlier versions
struct Backport<Content: View> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

extension Backport {
    @ViewBuilder func symbolRenderingMode() -> some View {
        if #available(macOS 12.0, iOS 15.0, *) {
            self.content
                .symbolRenderingMode(.hierarchical)
        } else {
            content
        }
    }
}
