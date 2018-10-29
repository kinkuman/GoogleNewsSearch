//
//  ViewController.swift
//  GoogleNewsSearch
//
//  Created by user on 2018/10/29.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    // 前の画面画からセットしてもらう
    var item:Item?
    
    // 最初にページ読み込み判断用
    var isFirst = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // itemがあって
        guard let item = item else {
            self.dismiss(animated: true) {
                print("no item")
            }
            
            return
        }
        
        // タイトルをセットする
        self.title = item.title
        
        // URLもちゃんとしている
        guard let url = item.url else {
            self.dismiss(animated: true) {
                print("item url fail")
            }
            
            return
        }
        
        // URLを読み込む
        let urlRequest = URLRequest(url: url)
        webView.navigationDelegate = self
        webView.load(urlRequest)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // コンテンツの読み込み時に続行するかどうか判断するメソッド
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // 初回のページ表示のときは
        if isFirst {
            // 読み込みを許可
            decisionHandler(WKNavigationActionPolicy.allow)
        } else {
            // そうでないときは別のページへはいかない
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
    }
    
    // ページの読み込みが終わったら呼ばれる
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isFirst = false
    }
}

