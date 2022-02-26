//
//  DetailerConfig.swift
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

/// Convenience alias which hides the "Image"-bound type ugliness.
/// Can't figure out how to avoid it yet. Curiously this isn't
/// needed for Views.
public typealias DetailerConfig<E> = DetailerConfigBase<E, Text, Image> where E: Identifiable

private let defaultTitler = ""
private let defaultValidateFail = "exclamationmark.triangle"
// TODO: defaults for all the non-nil parameters

public struct DetailerConfigBase<Element, TitleContent, ValidateImage>
    where Element: Identifiable,
    TitleContent: View,
    ValidateImage: View
{
    public typealias Context = DetailerContext<Element>

    public typealias CanDelete = (Element) -> Bool
    public typealias CanEdit = (Element) -> Bool
    public typealias OnDelete = (Element.ID) -> Void
    public typealias OnValidate = (Context, Element) -> [String]
    public typealias OnCancel = (Context, Element) -> Void
    public typealias OnSave = (Context, Element) -> Void

    // MARK: Parameters

    public let canEdit: CanEdit?
    public let canDelete: CanDelete
    public let onDelete: OnDelete?
    public let onValidate: OnValidate
    public let onSave: OnSave?
    public let onCancel: OnCancel
    public let titler: (Element) -> TitleContent
    public let validateFail: () -> ValidateImage

    public init(canEdit: CanEdit? = nil,
                canDelete: @escaping CanDelete = { _ in true },
                onDelete: OnDelete? = nil,
                onValidate: @escaping OnValidate = { _, _ in [] },
                onSave: OnSave? = nil,
                onCancel: @escaping OnCancel = { _, _ in },
                @ViewBuilder titler: @escaping (Element) -> TitleContent,
                @ViewBuilder validateFail: @escaping () -> ValidateImage)
    {
        self.canEdit = canEdit
        self.canDelete = canDelete
        self.onDelete = onDelete
        self.onValidate = onValidate
        self.onSave = onSave
        self.onCancel = onCancel
        self.titler = titler
        self.validateFail = validateFail
    }

    // omitting: titler
    public init(canEdit: CanEdit? = nil,
                canDelete: @escaping CanDelete = { _ in true },
                onDelete: OnDelete? = nil,
                onValidate: @escaping OnValidate = { _, _ in [] },
                onSave: OnSave? = nil,
                onCancel: @escaping OnCancel = { _, _ in },
                @ViewBuilder validateFail: @escaping () -> ValidateImage)
        where TitleContent == Text
    {
        self.init(canEdit: canEdit,
                  canDelete: canDelete,
                  onDelete: onDelete,
                  onValidate: onValidate,
                  onSave: onSave,
                  onCancel: onCancel,
                  titler: { _ in Text(defaultTitler) },
                  validateFail: validateFail)
    }

    // omitting: validateFail
    public init(canEdit: CanEdit? = nil,
                canDelete: @escaping CanDelete = { _ in true },
                onDelete: OnDelete? = nil,
                onValidate: @escaping OnValidate = { _, _ in [] },
                onSave: OnSave? = nil,
                onCancel: @escaping OnCancel = { _, _ in },
                @ViewBuilder titler: @escaping (Element) -> TitleContent)
        where ValidateImage == Image
    {
        self.init(canEdit: canEdit,
                  canDelete: canDelete,
                  onDelete: onDelete,
                  onValidate: onValidate,
                  onSave: onSave,
                  onCancel: onCancel,
                  titler: titler,
                  validateFail: { Image(systemName: defaultValidateFail) })
    }

    // omitting: validateFail, titler
    public init(canEdit: CanEdit? = nil,
                canDelete: @escaping CanDelete = { _ in true },
                onDelete: OnDelete? = nil,
                onValidate: @escaping OnValidate = { _, _ in [] },
                onSave: OnSave? = nil,
                onCancel: @escaping OnCancel = { _, _ in })
        where ValidateImage == Image, TitleContent == Text
    {
        self.init(canEdit: canEdit,
                  canDelete: canDelete,
                  onDelete: onDelete,
                  onValidate: onValidate,
                  onSave: onSave,
                  onCancel: onCancel,
                  titler: { _ in Text(defaultTitler) },
                  validateFail: { Image(systemName: defaultValidateFail) })
    }
}
