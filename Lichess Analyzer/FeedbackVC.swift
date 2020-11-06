//
//  FeedbackVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 03/11/2020.
//

import UIKit
import StoreKit
import FirebaseFirestore


class FeedbackVC: UIViewController {

    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextView.delegate = self
        textView.delegate = self
        label.text = "Everything you see was made with 🦕 by Enrico Castelli.\n(Lichess account polistirolo99)\n\nFeedbacks are always appreciated! (as well as good reviews 🤓)"
    }

    @IBAction func send() {
        sendFeedback {
            self.dismiss(animated: true) {
                SKStoreReviewController.requestReview()
            }
        } failure: { (error) in }
    }

    private func sendFeedback(success: @escaping() ->(), failure: @escaping(Error) ->()) {
        Firestore.firestore().collection("reviews").addDocument(data: [emailTextView.text ?? "No email" : textView.text ?? "No text", "date": Date().toString() ?? "No date"])
        DispatchQueue.main.async {
            success()
        }
    }
}

extension FeedbackVC: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            if textView == emailTextView {
                self.textView.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
            return false
        }
        return true
     }

}
