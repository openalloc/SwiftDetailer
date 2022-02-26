//
//  DetailerDeleteButton.swift
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

public struct DetailerDeleteButton<Element, Content>: View
    where Element: Identifiable, Content: View
{
    public typealias CanDelete = (Element) -> Bool
    public typealias OnDelete = (Element.ID) -> Void

    // MARK: Parameters

    private let element: Element
    private let canDelete: CanDelete
    private let onDelete: OnDelete?
    private let label: () -> Content

    public init(element: Element,
                canDelete: @escaping CanDelete,
                onDelete: OnDelete? = nil,
                @ViewBuilder label: @escaping () -> Content)
    {
        self.element = element
        self.canDelete = canDelete
        self.onDelete = onDelete
        self.label = label
    }

    // omitting explicit Label
    public init(element: Element,
                canDelete: @escaping CanDelete,
                onDelete: OnDelete? = nil)
        where Content == Label<Text, Image>
    {
        self.init(element: element, canDelete: canDelete, onDelete: onDelete) {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: Locals

    private var netCanDelete: Bool {
        onDelete != nil && canDelete(element)
    }

    // MARK: Views

    public var body: some View {
        Button(action: { onDelete?(element.id) }) {
            label()
        }
        .keyboardShortcut(.delete, modifiers: [])
        .disabled(!netCanDelete)
    }
}
