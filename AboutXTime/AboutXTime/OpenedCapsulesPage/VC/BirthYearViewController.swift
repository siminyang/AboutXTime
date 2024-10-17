//
//  BirthYearViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/18.
//

import UIKit

class BirthYearViewController: UIViewController {

    private let viewModel: OpenedCapsulesViewModel
    private let datePicker = UIDatePicker()
    private let label = UILabel()
    private let alertLabel = UILabel()

    init(viewModel: OpenedCapsulesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupDatePicker()
        setupLabel()
        setupSaveButton()
        setupAlertLabel()
    }

    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        datePicker.minimumDate = Calendar.current.date(from: DateComponents(year: 1900))

        if let birthDate = viewModel.birthDate {
            datePicker.date = birthDate

        } else {
            datePicker.date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
        }

        datePicker.tintColor = STColor.C1.uiColor
        datePicker.backgroundColor = .white.withAlphaComponent(0.3)
        datePicker.layer.cornerRadius = 10
        datePicker.clipsToBounds = true
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        ])
    }

    private func setupLabel() {
        label.text = "請選擇出生日期"
        label.textAlignment = .center
        label.textColor = .white

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: datePicker.topAnchor, constant: -30)
        ])
    }

    private func setupAlertLabel() {
        alertLabel.text = "保存後將無法修改"
        alertLabel.textAlignment = .center
        alertLabel.textColor = .red
        alertLabel.font = UIFont.systemFont(ofSize: 12)

        view.addSubview(alertLabel)
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertLabel.bottomAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 50)
        ])
    }

    private func setupSaveButton() {
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("保存", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 8
        saveButton.layer.borderColor = STColor.C1.uiColor.cgColor
        saveButton.layer.borderWidth = 0.5
        saveButton.backgroundColor = .white.withAlphaComponent(0.1)

        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        saveButton.addTarget(self, action: #selector(saveBirthDate), for: .touchUpInside)

        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 70),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        label.text = "選擇出生日期: \(formatDate(date: sender.date))"
    }

    @objc private func saveBirthDate() {
        viewModel.birthDate = datePicker.date
        dismiss(animated: true, completion: nil)
    }
}
