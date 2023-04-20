//
//  View+Validate.swift
//
// Copyright 2021, 2022 OpenAlloc LLC
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

public extension View {
    /// LIGHTWEIGHT field validation. For heavyweight validation see the element validation that runs on save.
    /// Automatically wrap the View with an indicator in an HStack {}.
    func validate<Element, T>(_ ctx: DetailerContext<Element>,
                              _ element: Binding<Element>,
                              _ keyPath: KeyPath<Element, T>,
                              _ test: @escaping (T) -> Bool) -> some View
        where Element: Identifiable, T: Equatable
    {
        validate(ctx, element.wrappedValue, keyPath, test)
    }

    /// Automatically wrap the View with an indicator in an HStack {}.
    func validate<Element, T>(_ ctx: DetailerContext<Element>,
                              _ element: Element,
                              _ keyPath: KeyPath<Element, T>,
                              _ test: @escaping (T) -> Bool) -> some View
        where Element: Identifiable, T: Equatable
    {
        let value: T = element[keyPath: keyPath]
        return validate(ctx, value, keyPath, test)
    }

    func validate<Element, T>(_ ctx: DetailerContext<Element>,
                              _ value: T,
                              _ keyPath: KeyPath<Element, T>,
                              _ test: @escaping (T) -> Bool) -> some View
        where Element: Identifiable, T: Equatable
    {
        // NOTE type-erase to collectively track validation failures
        let anyKeyPath: AnyKeyPath = keyPath

        return wrap {
            Validate(ctx: ctx,
                     anyKeyPath: anyKeyPath,
                     value: value,
                     test: test)
        }
    }

    /// A simple display of indicator, without any context.
    func validate<Element>(_ config: DetailerConfig<Element>, _ testResult: Bool) -> some View {
        wrap {
            config.validateIndicator(testResult)
        }
    }

    // MARK: Helpers

    private func wrap<Content: View>(_ content: () -> Content) -> some View {
        HStack {
            self
            content()
        }
    }
}
