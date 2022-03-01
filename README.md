# SwiftDetailer

A multi-platform SwiftUI component for editing fielded data.

Available as an open source library to be incorporated in SwiftUI apps.

_SwiftDetailer_ is part of the [OpenAlloc](https://github.com/openalloc) family of open source Swift software tools.

macOS | iOS
:---:|:---:
![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/macOSb.png)  |  ![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/iOSc.png)

## Features

* Convenient editing (and viewing) of fielded data in your app
* Can be used with various collection container types, such as `List`, `Table`, `LazyVStack`, etc.\*
* Presently targeting macOS v11+ and iOS v14+\*\*
* Both bound (`editDetailer`) and unbound (`viewDetailer`) views available
* Optional support for operations to add new records and delete them
* Optional support for field-level validation, with indicators
* Optional support for record-level validation, with alert view
* Minimal use of View type erasure (i.e., use of `AnyView`)
* No external dependencies!

\* And also the `Tabler` table component (by the same author; see link below)

\*\* Other platforms like macCatalyst, iPad on Mac, watchOS, tvOS, etc. are poorly supported, if at all. Please contribute to improve support!

## Detailer Example

An example, showing the basic use of _Detailer_. As a baseline, start with the display of rows of data in a `List`:

```swift
import SwiftUI

struct Fruit: Identifiable {
    var id: String
    var name: String
    var weight: Double
    var color: Color
}

struct ContentView: View {

    @State private var fruits: [Fruit] = [
        Fruit(id: "🍌", name: "Banana", weight: 118, color: .brown),
        Fruit(id: "🍓", name: "Strawberry", weight: 12, color: .red),
        Fruit(id: "🍊", name: "Orange", weight: 190, color: .orange),
        Fruit(id: "🥝", name: "Kiwi", weight: 75, color: .green),
        Fruit(id: "🍇", name: "Grape", weight: 7, color: .purple),
        Fruit(id: "🫐", name: "Blueberry", weight: 2, color: .blue),
    ]

    var body: some View {
        List(fruits) { fruit in
            HStack {
                Text(fruit.id)
                Text(fruit.name).foregroundColor(fruit.color)
                Spacer()
                Text(String(format: "%.0f g", fruit.weight))
            }
        }
    }
}
```

To add basic support for a detail page, targeting both macOS and iOS, you'll need to:

* A. Import the `SwiftDetailer` package.
* B. Add state properties.
* C. Give each row a menu (context for macOS; swipe for iOS).
* D. Add a call to `editDetailer`, available as a modifier.
* E. Include a `Form` containing the fields to edit, and...
* F. Add an action handler to save a modified `Fruit` element, along with a few support methods.

These are shown (and annotated) in the modified code below:

```swift
import SwiftUI
import Detailer // A

struct Fruit: Identifiable {
    var id: String
    var name: String
    var weight: Double
    var color: Color
}

struct ContentView: View {

    @State private var fruits: [Fruit] = [
        Fruit(id: "🍌", name: "Banana", weight: 118, color: .brown),
        Fruit(id: "🍓", name: "Strawberry", weight: 12, color: .red),
        Fruit(id: "🍊", name: "Orange", weight: 190, color: .orange),
        Fruit(id: "🥝", name: "Kiwi", weight: 75, color: .green),
        Fruit(id: "🍇", name: "Grape", weight: 7, color: .purple),
        Fruit(id: "🫐", name: "Blueberry", weight: 2, color: .blue),
    ]
    
    @State private var toEdit: Fruit? = nil // B
    @State private var isAdd: Bool = false

    var body: some View {
        List(fruits) { fruit in
            HStack {
                Text(fruit.id)
                Text(fruit.name).foregroundColor(fruit.color)
                Spacer()
                Text(String(format: "%.0f g", fruit.weight))
            }
            .modifier(menu(fruit)) // C
        }
        .editDetailer(config,
                      toEdit: $toEdit,
                      isAdd: $isAdd,
                      detailContent: editDetail) // D
    }
    
    // E
    private func editDetail(ctx: DetailerContext<Fruit>, element: Binding<Fruit>) -> some View {
        Form {
            TextField("ID", text: element.id)
            TextField("Name", text: element.name)
            TextField("Weight", value: element.weight, formatter: NumberFormatter())
            ColorPicker("Color", selection: element.color)
        }
    }
    
    // F
    private func saveAction(_ context: DetailerContext<Fruit>, _ element: Fruit) {
        if let n = fruits.firstIndex(where: { $0.id == element.id }) {
            fruits[n] = element
        }
    }
    
    private var config: DetailerConfig<Fruit> {
        DetailerConfig<Fruit>(onSave: saveAction)
    }
    
#if os(macOS)
    private func menu(_ fruit: Fruit) -> EditDetailerContextMenu<Fruit> {
        EditDetailerContextMenu(config, $toEdit, fruit)
    }
#elseif os(iOS)
    private func menu(_ fruit: Fruit) -> EditDetailerSwipeMenu<Fruit> {
        EditDetailerSwipeMenu(config, $toEdit, fruit)
    }
#endif
}
```

On macOS, ctrl-click (or right-click) on a row to invoke the context menu. On iOS, swipe the row to invoke the menu.

For a full implementation, see the _DetailerDemo_ project (link below). It extends the example with operations to add new records, delete records, and validate input. 

It shows _Detailer_ used with `LazyVGrid` and `Table` containers.

## Menuing

The use of context menus for macOS and iOS:

macOS | iOS
:---:|:---:
![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/macOSa.png)  |  ![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/iOSb.png)

And swipe menu for iOS:

iOS
:---:
![](https://github.com/openalloc/SwiftDetailer/blob/main/Images/iOSa.png)

## Validation

You can optionally validate data both at the field and record level.

### Field-level validation

This is a *lightweight* form of validation where individual fields get a closure to test their validity. As they are executed with each change, they should NOT run expensive operations, like hitting a remote server.

Field-level validation is implemented as modifiers in the detail form, as in this example of three(3) validators used in the demo app:

```swift
private func editDetail(ctx: DetailerContext<Fruit>, element: Binding<Fruit>) -> some View {
    Form {
        TextField("ID", text: element.id)
            .validate(ctx, element, \.id) { $0.count > 0 }
        TextField("Name", text: element.name)
            .validate(ctx, element, \.name) { $0.count > 0 }
        TextField("Weight", value: element.weight, formatter: NumberFormatter())
            .validate(ctx, element, \.weight) { $0 > 0 }
        ColorPicker("Color", selection: element.color)
    }
}
```

The first two are testing string length. The third is testing the numerical value.

By default, invalid fields will be suffixed with a warning icon, currently an "exclamationmark.triangle", as displayed in the images above. This image is configurable.

All field-level validations must return `true` for the `Save` button to be enabled.

TIP: for consistent margin spacing in layout, you can create a validation that always succeeds: `.validate(...) { _ in true }`.

### Record-level validation

This can be a *heavyweight* form of validation executed when the user presses the `Save` button.

It's a parameter of the `DetailerConfig` initialization, specifically `onValidate: (Context, Element) -> [String]`.

In your action handler, test the record and, if okay, return `[]`, an empty string array. Populate the array with messages if invalid. They will be presented to the user in an alert.

If this validation is used, the user will not be able to save changes until it returns `[]`.

## See Also

* [DetailerDemo](https://github.com/openalloc/DetailerDemo) - the demonstration app for this library

Swift open-source libraries (by the same author):

* [SwiftTabler](https://github.com/openalloc/SwiftTabler) - multi-platform SwiftUI component for displaying (and interacting with) tabular data
* [AllocData](https://github.com/openalloc/AllocData) - standardized data formats for investing-focused apps and tools
* [FINporter](https://github.com/openalloc/FINporter) - library and command-line tool to transform various specialized finance-related formats to the standardized schema of AllocData
* [SwiftCompactor](https://github.com/openalloc/SwiftCompactor) - formatters for the concise display of Numbers, Currency, and Time Intervals
* [SwiftModifiedDietz](https://github.com/openalloc/SwiftModifiedDietz) - A tool for calculating portfolio performance using the Modified Dietz method
* [SwiftNiceScale](https://github.com/openalloc/SwiftNiceScale) - generate 'nice' numbers for label ticks over a range, such as for y-axis on a chart
* [SwiftRegressor](https://github.com/openalloc/SwiftRegressor) - a linear regression tool that’s flexible and easy to use
* [SwiftSeriesResampler](https://github.com/openalloc/SwiftSeriesResampler) - transform a series of coordinate values into a new series with uniform intervals
* [SwiftSimpleTree](https://github.com/openalloc/SwiftSimpleTree) - a nested data structure that’s flexible and easy to use

And commercial apps using this library (by the same author):

* [FlowAllocator](https://flowallocator.app/FlowAllocator/index.html) - portfolio rebalancing tool for macOS
* [FlowWorth](https://flowallocator.app/FlowWorth/index.html) - a new portfolio performance and valuation tracking tool for macOS

## License

Copyright 2022 FlowAllocator LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Contributing

Contributions are welcome. You are encouraged to submit pull requests to fix bugs, improve documentation, or offer new features. 

The pull request need not be a production-ready feature or fix. It can be a draft of proposed changes, or simply a test to show that expected behavior is buggy. Discussion on the pull request can proceed from there.
