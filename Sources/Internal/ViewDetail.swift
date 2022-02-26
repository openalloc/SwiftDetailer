//
//  ViewDetail.swift
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

struct ViewDetail<Element, Detail>: View
    where Element: Identifiable,
    Detail: View
{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    typealias ViewContent = (Element) -> Detail

    // MARK: Parameters

    var config: DetailerConfig<Element>
    @State var element: Element
    var viewContent: ViewContent

    // MARK: Views

    var body: some View {
        VStack(alignment: .leading) { // .leading needed to keep title from centering
            #if os(macOS)
                Text(config.titler(element)).font(.largeTitle)
            #endif
            // this is where the user will typically declare a VStack or Form
            viewContent(element)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            // .animation(.default)
        }
        #if os(macOS)
        .padding()
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: dismissAction) {
                    Text("Close")
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        #if os(macOS)
        // NOTE on macOS, this seems to be needed to avoid excessive height
        .frame(minWidth: 500, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        #endif

        #if os(iOS) || targetEnvironment(macCatalyst)
        .navigationTitle(config.titler(element))
        #endif
    }

    // MARK: Action Handlers

    private func dismissAction() {
        presentationMode.wrappedValue.dismiss()
    }
}
