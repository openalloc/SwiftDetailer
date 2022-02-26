//
//  Validate.swift
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

/// For use with LIGHTWEIGHT field-level validation.
struct Validate<Element, T>: View
    where Element: Identifiable,
    T: Equatable
{
    typealias Test = (T) -> Bool

    var ctx: DetailerContext<Element>
    var anyKeyPath: AnyKeyPath
    var value: T
    var test: Test

    var body: some View {
        ctx.config.validateFail()
            .backport.symbolRenderingMode() // .symbolRenderingMode(.hierarchical)
            .font(.title2)
            .foregroundColor(.secondary)
            .opacity(test(value) ? 0 : 1)
            .onAppear {
                updateSet(value)
            }
            .onChange(of: value) { nuValue in
                updateSet(nuValue)
            }
    }

    // using async to avoid updating the state during state render
    private func updateSet(_ nuValue: T) {
        DispatchQueue.main.async {
            ctx.onValidate(anyKeyPath, test(nuValue))
        }
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
                .symbolRenderingMode(.hierarchical).foregroundColor(.orange)
        } else {
            content
        }
    }
}
