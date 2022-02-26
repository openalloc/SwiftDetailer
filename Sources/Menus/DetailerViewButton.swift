//
//  DetailerViewButton.swift
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

public struct DetailerViewButton<Element, Content>: View
    where Element: Identifiable, Content: View
{
    public typealias OnView = (Element) -> Void

    // MARK: Parameters

    private let element: Element
    private let onView: OnView
    private let label: () -> Content

    public init(element: Element,
                onView: @escaping OnView,
                @ViewBuilder label: @escaping () -> Content)
    {
        self.element = element
        self.onView = onView
        self.label = label
    }

    // omitting explicit Label
    public init(element: Element,
                onView: @escaping OnView)
        where Content == Text // Label<Text, Image>
    {
        self.init(element: element,
                  onView: onView)
        {
            Text("View")
            // Label("View", systemImage: "eye")
        }
    }

    // MARK: Views

    public var body: some View {
        Button(action: { onView(element) }) {
            label()
        }
    }
}
