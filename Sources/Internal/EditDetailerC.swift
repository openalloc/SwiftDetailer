//
//  EditDetailerC.swift
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
import CoreData

struct EditDetailerC<Element, Detail, Container>: View
    where Element: Identifiable & ObservableObject,
    Detail: View,
    Container: View
{
    typealias ProjectedValue = ObservedObject<Element>.Wrapper
    typealias DetailContent = (DetailerContext<Element>, ProjectedValue) -> Detail
    typealias ContainerContent = () -> Container

    // MARK: - Parameters

    var config: DetailerConfig<Element>
    @Binding var toEdit: Element?
    @Binding var isAdd: Bool
    //var childContext: NSManagedObjectContext
    var detailContent: DetailContent
    var containerContent: ContainerContent

    // MARK: - Views

    var body: some View {
        containerContent()
            .sheet(item: $toEdit) { element in
                #if os(macOS)
                    detailView(element)
                #elseif os(iOS)
                    NavigationView {
                        detailView(element)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                #endif
            }
    }

    private func detailView(_ element: Element) -> some View {
        EditDetailC(config: config,
                    element: element,
                    isAdd: $isAdd,
                    detailContent: detailContent)
//            .environment(\.managedObjectContext, childContext)
        // .animation(.default)
    }
}
