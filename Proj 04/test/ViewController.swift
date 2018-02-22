//
//  ViewController.swift
//  test
//
//  Created by yu wang on 19/02/2018.
//  Copyright © 2018 yu wang. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["www.baidu.com","youtube.com", "apple.com", "hackingwithswift.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let url = URL(string: "https://" + websites[0])
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))

        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))

        toolbarItems = [progressButton, spacer, refresh]
        navigationController?.isToolbarHidden = false

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page", message: "Please select the page you like.", preferredStyle: .actionSheet)
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }

    func openPage(_ sender: UIAlertAction) {
        let url = URL(string: "https://\(sender.title ?? "baidu.com")/")
        webView.load(URLRequest(url: url!))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if let host = url!.host {
            for website in websites {
                if host.range(of: website) != nil {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        decisionHandler(.cancel)
        let ac = UIAlertController(title: "forbidden", message: "you cannot open the page", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        super.viewWillDisappear(animated)
    }
}

