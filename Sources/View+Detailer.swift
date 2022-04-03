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
    typealias EditContentC<E, D> = (DetailerContext<E>, ProjectedValue<E>) -> D where E: Identifiable & ObservableObject
    typealias EditContentR<E, D> = (DetailerContext<E>, Binding<E>) -> D where E: Identifiable
    
    /// For Value data source
    func editDetailer<E, D>(_ config: DetailerConfig<E> = .init(),
                            toEdit: Binding<E?>,
                            originalID: E.ID? = nil,
                            @ViewBuilder detailContent: @escaping EditContentR<E, D>) -> some View
    where E: Identifiable,
          D: View
    {
        self.sheet(item: toEdit) { element in
#if os(macOS)
            EditDetailR(config: config,
                        element: element,
                        originalID: originalID,
                        detailContent: detailContent)
#elseif os(iOS)
            NavigationView {
                EditDetailR(config: config,
                            element: element,
                            originalID: originalID,
                            detailContent: detailContent)
            }
            .navigationViewStyle(StackNavigationViewStyle())
#endif
        }
    }
    
    /// For Reference data source, including Core Data
    func editDetailer<E, D>(_ config: DetailerConfig<E> = .init(),
                            toEdit: Binding<E?>,
                            originalID: E.ID? = nil,
                            @ViewBuilder detailContent: @escaping EditContentC<E, D>) -> some View
    where E: Identifiable & ObservableObject,
          D: View
    {
        self.sheet(item: toEdit) { element in
#if os(macOS)
            EditDetailC(config: config,
                        element: element,
                        originalID: originalID,
                        detailContent: detailContent)
#elseif os(iOS)
            NavigationView {
                EditDetailC(config: config,
                            element: element,
                            originalID: originalID,
                            detailContent: detailContent)
            }
            .navigationViewStyle(StackNavigationViewStyle())
#endif
        }
    }
}

public extension View {
    
    typealias ViewContent<E, D> = (E) -> D where E: Identifiable
    
    func viewDetailer<E, D>(_ config: DetailerConfig<E> = .init(),
                            toView: Binding<E?>,
                            @ViewBuilder viewContent: @escaping ViewContent<E, D>) -> some View
    where E: Identifiable,
          D: View
    {
        self.sheet(item: toView) { element in
#if os(macOS)
            ViewDetail(config: config,
                       element: element,
                       viewContent: viewContent)
#elseif os(iOS)
            NavigationView {
                ViewDetail(config: config,
                           element: element,
                           viewContent: viewContent)
            }
            .navigationViewStyle(StackNavigationViewStyle())
#endif
        }
    }
}
