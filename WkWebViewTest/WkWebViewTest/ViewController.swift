//
//  ViewController.swift
//  WkWebViewTest
//
//  Created by Koki Tanaka on 5/16/19.
//  Copyright © 2019 Koki Tanaka. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    @IBOutlet var UITestWebView: UIWebView!
    
    @IBOutlet var WKTestWebView: WKWebView!
    
    let htmlFormat = """
    <html>
    <head>
    <style type="text/css">
    body {{font-family: "%@"; font-style: normal;
    font-weight: lighter; font-size: %@; margin: 0;
    padding: 0; line-height: 1.3; }}
    a:link {{color:#007AFF; text-decoration: none;}}
    </style>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    </head>
    <body>%@</body>
    </html>
    """;
    let memoText = "388 Carlaw Ave, Toronto, ON M4M 2T4\nhttps://google.com";
    let font = UIFont.systemFont(ofSize: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let displayText = String.init(format:htmlFormat, font.familyName, font.pointSize.description, memoText.replacingOccurrences(of: "\n", with: "<br>"))
        SetWkWebView(displayText: displayText);
        SetUIWebView(displayText: displayText);
        // Do any additional setup after loading the view, typically from a nib.
    }

    func SetWkWebView(displayText: String)
    {
        WKTestWebView.loadHTMLString(displayText, baseURL: nil)
        WKTestWebView.autoresizingMask = UIView.AutoresizingMask.flexibleTopMargin
        WKTestWebView.navigationDelegate = self
        WKTestWebView.uiDelegate = self
        WKTestWebView.allowsLinkPreview = true
    }
    
    func SetUIWebView(displayText: String)
    {
        
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if (WKNavigationType.linkActivated == navigationAction.navigationType)
        {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
//            var scheme = url?.scheme?.lowercased()
//                webView.BeginInvokeOnMainThread(async () =>
//                    {
//                        await UIApplication.SharedApplication.OpenUrlAsync(url, new UIApplicationOpenUrlOptions());
//                        decisionHandler?.Invoke(WKNavigationActionPolicy.Cancel);
//                    });
        }
        else
        {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        if let url = elementInfo.linkURL
        {
            // UIViewControllerのサブクラスを使い、アクションリストを表示
            // (プレビュー時上にスワイプした際にアクションリストが表示される)
            let vc = WebPreviewViewController.init(url: url, actions: previewActions)
            
            vc.preferredContentSize = vc.view.bounds.size
            
            return vc;
        }
        else
        {
            return nil;
        }
    }
    
//    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
//        <#code#>
//    }
}

class WebPreviewViewController : UIViewController
{
    var webViewPreviewActionItems: [WKPreviewActionItem] = []
    var linkURL: URL?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(url: URL, actions: [WKPreviewActionItem]) {
        self.init(nibName: nil, bundle: nil)
        self.linkURL = url
        self.webViewPreviewActionItems = actions
    }
    
    // 受け取ったアクションのリストを表示するため
    override var previewActionItems: [UIPreviewActionItem] {
        get {
            return self.webViewPreviewActionItems
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Peek & Pop用のWKWebViewを表示
        if let url = self.linkURL {
            let web = WKWebView()
            web.frame = self.view.bounds
            self.view.addSubview(web)
            web.load(URLRequest(url: url))
        }
    }

}
