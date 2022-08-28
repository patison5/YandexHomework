//
//  WebController.swift
//  YandexHomework
//
//  Created by Fedor Penin on 21.08.2022.
//

import UIKit
import WebKit

class WebController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!

    var action: (() -> Void)?

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let forceConfirm = "&force_confirm=true"
        let urlString = "https://oauth.yandex.ru/authorize?response_type=token&client_id=0d0970774e284fa8ba9ff70b6b06479a\(forceConfirm)"
        let url = URL(string: urlString)
        guard let url = url else { return }
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
        webView.navigationDelegate = self
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = webView.url, url.absoluteString.starts(with: "https://oauth.yandex.ru/verification_code") {
            guard var components = URLComponents(string: url.absoluteString) else {
                decisionHandler(.allow)
                return
            }
            components.query = components.fragment
            guard let items = components.queryItems else {
                decisionHandler(.allow)
                return
            }
            if let token = items.first(where: { item in
                item.name == "access_token"
            })?.value {
                Variables.shared.isOAuth = true
                Variables.shared.token = token
            }
            dismiss(animated: true)
            action?()
        }
        decisionHandler(.allow)
    }
}
