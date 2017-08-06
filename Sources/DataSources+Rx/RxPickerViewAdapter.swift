//
//  RxPickerViewAdapter.swift
//  RxDataSources
//
//  Created by Sergey Shulga on 04/07/2017.
//  Copyright © 2017 kzaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

/// A reactive UIPickerView adapter which uses `func pickerView(UIPickerView, titleForRow: Int, forComponent: Int)` to desplay content
/**
 Example:
 
let stringPickerAdapter = RxPickerViewStringAdapter<[T]>(...)
 
items
 .bind(to: firstPickerView.rx.items(adapter: stringPickerAdapter))
 .disposed(by: disposeBag)
 
 */
open class RxPickerViewStringAdapter<T>: RxPickerViewDataSource<T>, UIPickerViewDelegate {
    public typealias TitleForRow = (RxPickerViewStringAdapter<T>, UIPickerView, T,Int, Int) -> String?
    
    private let titleForRow: TitleForRow
    
    public init(components: T,
                numberOfComponents: @escaping NumberOfComponents,
                numberOfRowsInComponent: @escaping NumberOfRowsInComponent,
                titleForRow: @escaping TitleForRow) {
        self.titleForRow = titleForRow
        super.init(components: components,
                   numberOfComponents: numberOfComponents,
                   numberOfRowsInComponent: numberOfRowsInComponent)
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleForRow(self, pickerView, components, row, component)
    }
}

/// A reactive UIPickerView adapter which uses `func pickerView(UIPickerView, viewForRow: Int, forComponent: Int, reusing: UIView?)` to desplay content
/**
 Example:
 
 let stringPickerAdapter = RxPickerViewAttributedStringAdapter<[T]>(...)
 
 items
 .bind(to: firstPickerView.rx.items(adapter: stringPickerAdapter))
 .disposed(by: disposeBag)
 
 */
open class RxPickerViewAttributedStringAdapter<T>: RxPickerViewDataSource<T>, UIPickerViewDelegate {
    public typealias AttributedTitleForRow = (RxPickerViewAttributedStringAdapter<T>, UIPickerView, T, Int, Int) -> NSAttributedString?
    
    private let attributedTitleForRow: AttributedTitleForRow
    
    public init(components: T,
                numberOfComponents: @escaping NumberOfComponents,
                numberOfRowsInComponent: @escaping NumberOfRowsInComponent,
                attributedTitleForRow: @escaping AttributedTitleForRow) {
        self.attributedTitleForRow = attributedTitleForRow
        super.init(components: components,
                   numberOfComponents: numberOfComponents,
                   numberOfRowsInComponent: numberOfRowsInComponent)
    }
    
    open func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return attributedTitleForRow(self, pickerView, components, row, component)
    }
}

/// A reactive UIPickerView adapter which uses `func pickerView(pickerView:, viewForRow row:, forComponent component:)` to desplay content
/**
 Example:
 
 let stringPickerAdapter = RxPickerViewViewAdapter<[T]>(...)
 
 items
 .bind(to: firstPickerView.rx.items(adapter: stringPickerAdapter))
 .disposed(by: disposeBag)
 
 */
open class RxPickerViewViewAdapter<T>: RxPickerViewDataSource<T>, UIPickerViewDelegate {
    public typealias ViewForRow = (RxPickerViewViewAdapter<T>, UIPickerView, T, Int, Int, UIView?) -> UIView
    
    private let viewForRow: ViewForRow
    
    public init(components: T,
                numberOfComponents: @escaping NumberOfComponents,
                numberOfRowsInComponent: @escaping NumberOfRowsInComponent,
                viewForRow: @escaping ViewForRow) {
        self.viewForRow = viewForRow
        super.init(components: components,
                   numberOfComponents: numberOfComponents,
                   numberOfRowsInComponent: numberOfRowsInComponent)
    }
    
    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return viewForRow(self, pickerView, components, row, component, view)
    }
}

/// A reactive UIPickerView data source  
open class RxPickerViewDataSource<T>: NSObject, UIPickerViewDataSource {
    public typealias NumberOfComponents = (RxPickerViewDataSource, UIPickerView, T) -> Int
    public typealias NumberOfRowsInComponent = (RxPickerViewDataSource, UIPickerView, T, Int) -> Int
    
    fileprivate var components: T
    
    init(components: T,
         numberOfComponents: @escaping NumberOfComponents,
         numberOfRowsInComponent: @escaping NumberOfRowsInComponent) {
        self.components = components
        self.numberOfComponents = numberOfComponents
        self.numberOfRowsInComponent = numberOfRowsInComponent
        super.init()
    }
    
    private let numberOfComponents: NumberOfComponents
    private let numberOfRowsInComponent: NumberOfRowsInComponent
    
    //MARK: UIPickerViewDataSource
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents(self, pickerView, components)
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfRowsInComponent(self, pickerView, components, component)
    }
}

extension RxPickerViewDataSource: RxPickerViewDataSourceType {
    public func pickerView(_ pickerView: UIPickerView, observedEvent: Event<T>) {
        UIBindingObserver(UIElement: self) { (dataSource, components) in
            dataSource.components = components
            pickerView.reloadAllComponents()
        }.on(observedEvent)
    }
}
