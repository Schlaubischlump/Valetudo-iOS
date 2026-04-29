//
//  VTMaterialSelectionViewController.swift
//  Valetudo
//
//  Created by OpenAI Codex on 29.09.25.
//

import UIKit

@MainActor
final class VTMaterialSelectionViewController: UITableViewController {
    private let materials: [VTMaterial]
    private let onConfirm: (VTMaterial) -> Void
    private var selectedMaterial: VTMaterial

    init(
        materials: [VTMaterial],
        selectedMaterial: VTMaterial,
        onConfirm: @escaping (VTMaterial) -> Void
    ) {
        self.materials = materials
        self.selectedMaterial = selectedMaterial
        self.onConfirm = onConfirm
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MATERIAL".localized()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MaterialCell")

        let cancelAction = UIAction(title: "CANCEL".localized()) { [weak self] _ in
            guard let self else { return }
            dismiss(animated: true)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: cancelAction)
        let okAction = UIAction(title: "OK".localized()) { [weak self] _ in
            guard let self else { return }
            onConfirm(selectedMaterial)
            dismiss(animated: true)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: okAction)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        materials.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MaterialCell", for: indexPath)
        let material = materials[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = material.description
        content.image = material == selectedMaterial ? .checkmarkCircleFill : UIImage(systemName: "circle")
        content.imageProperties.tintColor = material == selectedMaterial ? .tintColor : .secondaryLabel
        cell.contentConfiguration = content
        cell.selectionStyle = .default
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMaterial = materials[indexPath.row]
        tableView.reloadData()
    }
}
