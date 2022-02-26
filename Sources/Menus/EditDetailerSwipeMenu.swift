//
//  EditDetailerSwipeMenu.swift
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct EditDetailerSwipeMenu<Element>: ViewModifier
    where Element: Identifiable
{
    private var config: DetailerConfig<Element>
    @Binding private var toEdit: Element?
    private var element: Element

    public init(_ config: DetailerConfig<Element>,
                _ toEdit: Binding<Element?>,
                _ element: Element)
    {
        self.config = config
        _toEdit = toEdit
        self.element = element
    }

    // convenience to unwrap bound element
    public init(_ config: DetailerConfig<Element>,
                _ toEdit: Binding<Element?>,
                _ element: Binding<Element>)
    {
        self.init(config,
                  toEdit,
                  element.wrappedValue)
    }

    public func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                DetailerEditButton(element: element, canEdit: config.canEdit) { toEdit = $0 }
                    .tint(.accentColor)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                DetailerDeleteButton(element: element, canDelete: config.canDelete, onDelete: config.onDelete)
                    .tint(.red)
            }
    }
}
