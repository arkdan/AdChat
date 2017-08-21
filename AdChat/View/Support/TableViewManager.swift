//
//  TableViewManager.swift
//  AdChat
//
//  Created by mac on 8/12/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result


protocol ViewModelConfiguredCell {
    associatedtype ViewModelType

    func configure(with: ViewModelType)
    static var identifier: String { get }
}

protocol GeneralDataSourceDelegate: UITableViewDataSource, UITableViewDelegate {}


// These 2 classes should inherit from a parent class; but because of their generic nature they cannot.
// It will be possible with release of swift 4.


/// Generic uiTableViewManager which acceps initial data as [ViewModelType];
///
/// with updates to be submitted into **func pushUpdate(_ update: Update<ViewModelType>)**
class PushTableViewManager<ViewModelType, CellType: ViewModelConfiguredCell>: NSObject, GeneralDataSourceDelegate
where CellType.ViewModelType == ViewModelType {
    enum Update<T> {
        case append(T)
        case insert(T, Int)
        case remove(Int)
        case move(Int, Int)
    }

    // MARK: - private
    fileprivate var viewModels = [ViewModelType]()
    fileprivate let tableView: UITableView
    private let rowActionObserver: Signal<(ViewModelType, IndexPath), NoError>.Observer

    // MARK: - public
    var cellHeight: CGFloat = 44
    var canEdit: (ViewModelType) -> Bool = { _ in return false }
    var delete: (ViewModelType) -> Void = { _ in }

    let rowActionSignal: Signal<(ViewModelType, IndexPath), NoError>
    typealias CellMapping = (ViewModelType) -> CellType.Type
    var cellMapping: CellMapping

    init(data: [ViewModelType], tableView: UITableView, cellMapping: @escaping CellMapping) {
        self.viewModels = data

        let (signal, observer) = Signal<(ViewModelType, IndexPath), NoError>.pipe()
        self.rowActionSignal = signal
        self.rowActionObserver = observer

        self.tableView = tableView

        self.cellMapping = cellMapping

        super.init()

        tableView.dataSource = self
        tableView.delegate = self
    }

    func pushUpdate(_ update: Update<ViewModelType>) {
        self.tableView.beginUpdates()
        switch update {
        case .append(let viewModel):
            self.viewModels.append(viewModel)
            self.tableView.insertRows(at: [IndexPath(row: self.viewModels.count - 1, section: 0)], with: .automatic)
        case .insert(let viewModel, let index):
            self.viewModels.insert(viewModel, at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        case .remove(let index):
            self.viewModels.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move(let from, let to):
            swap(&self.viewModels[from], &self.viewModels[to])
            let indexPath1 = IndexPath(row: from, section: 0)
            let indexPath2 = IndexPath(row: to, section: 0)
            self.tableView.moveRow(at: indexPath1, to: indexPath2)
        }
        self.tableView.endUpdates()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.identifier) as! CellType
        cell.configure(with: viewModels[indexPath.row])
        return cell as! UITableViewCell // need force cast until swift4
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowActionObserver.send(value: (viewModels[indexPath.row], indexPath))
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEdit(viewModels[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            delete(viewModels[indexPath.row])
        }
    }
}

/// Generic uiTableViewManager which acceps data in form of SignalProducer<[ViewModelType], NoError>
///
/// Emphasis: **Array of cellViewModels**
class SignalTableViewManager<ViewModelType, CellType: ViewModelConfiguredCell>: NSObject, GeneralDataSourceDelegate
where CellType.ViewModelType == ViewModelType {

    // MARK: - private
    fileprivate var viewModels = [ViewModelType]()
    fileprivate let tableView: UITableView
    private let rowActionObserver: Signal<(ViewModelType, IndexPath), NoError>.Observer

    // MARK: - public
    var cellHeight: CGFloat = 44
    var canEdit: (ViewModelType) -> Bool = { _ in return false }
    var delete: (ViewModelType) -> Void = { _ in }

    let rowActionSignal: Signal<(ViewModelType, IndexPath), NoError>
    typealias CellMapping = (ViewModelType) -> CellType.Type
    var cellMapping: CellMapping

    init(producer: SignalProducer<[ViewModelType], NoError>,
         tableView: UITableView,
         cellMapping: @escaping CellMapping) {

        let (signal, observer) = Signal<(ViewModelType, IndexPath), NoError>.pipe()
        self.rowActionSignal = signal
        self.rowActionObserver = observer

        self.tableView = tableView

        self.cellMapping = cellMapping

        super.init()

        tableView.dataSource = self
        tableView.delegate = self

        let _ = self.cellHeight

        producer.startWithValues { viewModels in
            self.viewModels = viewModels
            self.tableView.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.identifier) as! CellType
        cell.configure(with: viewModels[indexPath.row])
        return cell as! UITableViewCell // need force cast until swift4
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowActionObserver.send(value: (viewModels[indexPath.row], indexPath))
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEdit(viewModels[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            delete(viewModels[indexPath.row])
        }
    }
}
