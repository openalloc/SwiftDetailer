//
//  EditDetailerContextMenu.swift
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

public struct EditDetailerContextMenu<Element>: ViewModifier
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

    private var isDeleteAvailable: Bool {
        config.onDelete != nil
    }

    public func body(content: Content) -> some View {
        content
            .contextMenu {
                DetailerEditButton(element: element, canEdit: config.canEdit) { toEdit = $0 }
                
                // NOTE if no delete handler, hide menu item entirely
                if isDeleteAvailable {
                    Divider()
                    DetailerDeleteButton(element: element, canDelete: config.canDelete, onDelete: config.onDelete)
                }
            }
    }
}
