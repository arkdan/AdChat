//
//  ChatViewController.swift
//  Contacts
//
//  Created by ark dan on 21/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

final class ChatViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var keyboardConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var attachmentButton: UIButton!

    var viewModel: ConversationViewModel!

    private var cells = [ChatListCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        automaticallyAdjustsScrollViewInsets = false

        title = viewModel.outputs.title

        collectionView.dataSource = self
        collectionView.delegate = self

        TextRect.messages.maxWidth = view.bounds.size.width * 0.6

        collectionView.reloadData()

        viewModel.outputs.newMessageSignal
            .observe(on: UIScheduler())
            .observeValues { index in
                self.collectionView.reloadData()
                self.collectionView.scrollToBottom()
        }

        let tap = UITapGestureRecognizer()
        collectionView.addGestureRecognizer(tap)
        tap.reactive.stateChanged.observeValues { _ in
            self.textField.endEditing(true)
        }

        textField.delegate = self

        sendButton.reactive.ping(on: .touchUpInside).observeValues {
            self.sendText()
        }

        attachmentButton.reactive.ping(on: .touchUpInside).observeValues {
                let picker = UIImagePickerController()
                picker.delegate = self
//                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//                alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {
//                    action in
//                    picker.sourceType = .Camera
//                    picker.allowsEditing = true
//                    self.presentViewController(picker, animated: true, completion: nil)
//                }))

                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardNotification(_:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        textField.becomeFirstResponder()
        collectionView.scrollToBottom()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func sendText() {
        if let text = textField.text, !text.isEmpty {
            viewModel.send(content: .text(text))
        }
        textField.text = nil
    }

    fileprivate func sendImage(image: UIImage) {
        viewModel.send(content: .image(UIImagePNGRepresentation(image)!))
    }

    @objc private func onKeyboardNotification(_ notification: NSNotification) {

        guard let userInfo = notification.userInfo,
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let animationCurveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else {
                return
        }

        let animationCurve = UIViewAnimationOptions(rawValue: animationCurveNumber.uintValue)

        if endFrame.origin.y >= UIScreen.main.bounds.size.height {
            keyboardConstraint.constant = 0.0
        } else {
            keyboardConstraint.constant = endFrame.size.height
        }
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: animationCurve,
                       animations: { self.view.layoutIfNeeded() },
                       completion: nil)
    }
}

extension ChatViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.outputs.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = viewModel.outputs.messages[indexPath.row]

        let cellMapping: () -> (MessageCell.Type) = {
            switch (cellViewModel.isOwn, cellViewModel.messageInfo.content) {
            case (true, .text):
                return OwnTextMessageCell.self
            case (true, .image):
                return OwnImageMessageCell.self
            case (false, .text):
                return PartnersTextMessageCell.self
            case (false, .image):
                return PartnersImageMessageCell.self
            }
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellMapping().identifier, for: indexPath) as! MessageCell

        cell.configure(with: viewModel.outputs.messages[indexPath.row])

        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellViewModel = viewModel.outputs.messages[indexPath.row]

        var size = cellViewModel.contentSize
        size.width = collectionView.bounds.size.width
        return size
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendText()
        return false
    }
}

extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            sendImage(image: image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendImage(image: image)
        } else {
            print("something is wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController: UINavigationControllerDelegate {}
