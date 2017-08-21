//
//  LoginViewController.swift
//  Contacts
//
//  Created by ark dan on 16/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit
import Result
import ReactiveCocoa
import ReactiveSwift


final class LoginViewController: UIViewController {

    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!

    var viewModel: LoginViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.tintColor = .white

        viewModel.inputs.usernameProperty <~ nameTextField.reactive.continuousTextValues
        viewModel.inputs.loginPressed <~ loginButton.reactive.ping(on: .touchUpInside)
        viewModel.inputs.loginPressed <~ nameTextField.reactive.ping(on: .primaryActionTriggered)

        loginButton.reactive.isEnabled <~ viewModel.outputs.loginEnabled

        loginButton.reactive.controlEvents(.touchUpInside).observeValues { _ in
            self.resignFirstResponder()
        }

        nameTextField.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nameTextField.becomeFirstResponder()
    }

    @IBAction private func onButton(_ sender: UIButton) {
    }
}
