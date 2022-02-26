//
//  DetailerEditButton.swift
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

/// Regarding enabling/disabling the Edit menu:
///  * Assumes the user will be allowed to edit (canEdit==true) even if no canEdit provided (canEdit==nil).
///
public struct DetailerEditButton<Element, Content>: View
    where Element: Identifiable, Content: View
{
    public typealias CanEdit = (Element) -> Bool
    public typealias OnEdit = (Element) -> Void

    // MARK: Parameters

    private let element: Element
    private let canEdit: CanEdit?
    private let onEdit: OnEdit
    private let label: () -> Content

    public init(element: Element,
                canEdit: CanEdit? = nil,
                onEdit: @escaping OnEdit,
                @ViewBuilder label: @escaping () -> Content)
    {
        self.element = element
        self.canEdit = canEdit
        self.onEdit = onEdit
        self.label = label
    }

    // omitting explicit Label
    public init(element: Element,
                canEdit: CanEdit? = nil,
                onEdit: @escaping OnEdit)
        where Content == Text // Label<Text, Image>
    {
        self.init(element: element,
                  canEdit: canEdit,
                  onEdit: onEdit)
        {
            Text("Edit")
            // Label("Edit", systemImage: "square.and.pencil")
        }
    }

    // MARK: Views

    public var body: some View {
        Button(action: { onEdit(element) }) {
            label()
        }
        .disabled(!(canEdit?(element) ?? true))
    }
}
