//
//  View+Detailer.swift
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

public extension View {
    typealias ProjectedValue<E> = ObservedObject<E>.Wrapper where E: ObservableObject
    typealias EditDetailContentC<E, D> = (DetailerContext<E>, ProjectedValue<E>) -> D where E: Identifiable & ObservableObject
    typealias EditDetailContent<E, D> = (DetailerContext<E>, Binding<E>) -> D where E: Identifiable
    typealias ViewDetailContent<E, D> = (E) -> D where E: Identifiable
    
    func editDetailer<Element, Detail>(_ config: DetailerConfig<Element>,
                                       toEdit: Binding<Element?>,
                                       isAdd: Binding<Bool>,
                                       @ViewBuilder detailContent: @escaping EditDetailContent<Element, Detail>) -> some View
    where Element: Identifiable,
          Detail: View
    {
        EditDetailer(config: config,
                     toEdit: toEdit,
                     isAdd: isAdd,
                     detailContent: detailContent,
                     containerContent: { self })
    }
    
    func editDetailerC<Element, Detail>(_ config: DetailerConfig<Element>,
                                        toEdit: Binding<Element?>,
                                        isAdd: Binding<Bool>,
                                        //childContext: NSManagedObjectContext,
                                        @ViewBuilder detailContent: @escaping EditDetailContentC<Element, Detail>) -> some View
    where Element: Identifiable & ObservableObject,
          Detail: View
    {
        EditDetailerC(config: config,
                      toEdit: toEdit,
                      isAdd: isAdd,
                      //childContext: childContext,
                      detailContent: detailContent,
                      containerContent: { self })
    }
    
    func viewDetailer<Element, Detail>(_ config: DetailerConfig<Element>,
                                       toView: Binding<Element?>,
                                       @ViewBuilder viewContent: @escaping ViewDetailContent<Element, Detail>) -> some View
    where Element: Identifiable,
          Detail: View
    {
        ViewDetailer(config: config,
                     toView: toView,
                     viewContent: viewContent,
                     containerContent: { self })
    }
}
