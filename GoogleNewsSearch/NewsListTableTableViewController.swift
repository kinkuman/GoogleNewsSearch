//
//  NewsListTableTableViewController.swift
//  GoogleNewsSearch
//
//  Created by user on 2018/10/29.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit

class NewsListTableViewController: UITableViewController,UITextFieldDelegate {
    
    
    weak var activityIndicatorView:UIActivityIndicatorView!
    
    // データソースとする配列
    var newsItemList:[Item] = []
    
    // 検索窓
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // リフレッシュコントロールを作る
        let refreshControl = UIRefreshControl()
        
        // ターゲットアクションイベントを設定する
        refreshControl .addTarget(self, action: #selector(runningRefresh(_:)), for: .valueChanged)
        
        // UITableViewControllerのrefreshControlに登録
        self.refreshControl = refreshControl
        self.refreshControl?.attributedTitle = NSAttributedString(string: "下げて更新")
        
        
        // 大きいインジケータを作成
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.activityIndicatorView = activityIndicatorView
        // 背景うすい黒
        activityIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // 角をまるく
        activityIndicatorView.layer.cornerRadius = 5
        // 普通より大きめにしておく
        activityIndicatorView.frame.size = CGSize(width: 100, height: 100)
        // 画面の真ん中に配置
        activityIndicatorView.center = self.view.center
        // ぐるぐるが止まったら姿が消える設定
        activityIndicatorView.hidesWhenStopped = true
        
        // すぐ使えるよう載せておく
        self.view.addSubview(activityIndicatorView)
        
        
        // titleViewのサイズは制約ではできないので、幅は起動時に動的に生成
        searchTextField.frame = CGRect(x: 0, y: 0, width: self.navigationController!.navigationBar.bounds.width, height: 24)
        searchTextField.delegate = self
        
        // 起動時に読み込む
        self.reloadNews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.newsItemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        let item = newsItemList[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.link
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 次の画面を取得
        let viewController = segue.destination as! ViewController
        // itemを渡す
        viewController.item = newsItemList[(self.tableView.indexPathForSelectedRow?.row)!]
    }
    

    
    // MARK: - targetAction
    
    // リフレッシュコントロール下げた時
    @objc func runningRefresh(_ refreshControll:UIRefreshControl) {

        // キーボード消して
        searchTextField.endEditing(true)
        
        searchOrMainNews()
    }

    @IBAction func tapSearchButton(_ sender: UIBarButtonItem) {
        
        // キーボード消して
        searchTextField.endEditing(true)
        
        searchOrMainNews()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // キーボード消して
        textField.endEditing(true)
        
        // TODO: 検索処理をする
        searchOrMainNews()
        
        return true
    }
    
    // MARK: - 自作メソッド
    
    // 検索するかそうでないかの判断メソッド
    func searchOrMainNews() {
        
        if let searchText = searchTextField.text, !searchText.isEmpty {
            // 検索窓に文字がある場合は、検索
            reloadNews(searchWord: searchText)
        } else {
            // そうでない場合は主要ニュースの読みこみ
            reloadNews()
        }
    }
    
    // 引数があれば検索
    func reloadNews(searchWord:String?) {
        
        // アクティビティインジケーター表示
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // もっとおおきいインジケーターも回す
        self.activityIndicatorView.startAnimating()
        
        // 対象URL
        let url:URL
        
        // 引数の有無で接続先URLを作成
        if let searchWord = searchWord {
            
            // 検索ワードがある時は検索のURLを作成する
            
            // URLエンコード（日本語が混じるとエラーになるので、インターネットに通せるように変換する）
            let encodedString = searchWord.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            let string = "https://news.google.com/news/rss/search/section/q/\(encodedString!)/\(encodedString!)/?ned=jp&gl=JP&hl=ja"
            url = URL(string: string)!
        } else {
            // 主要なニュースを取るURLを作成する
            url = URL(string: "https://news.google.com/news/rss/?ned=jp&gl=JP&hl=ja")!
        }
        
        // URLセッション
        let urlSession = URLSession.shared
        
        // タイムアウト30秒
        let urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        
        let urlSessionTask = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                print("エラー:",error.localizedDescription)
                self.showAlertMainQueue(msg: "通信エラーです")
                return
            }
            
            // 得られたxmlデータを解析する
            let xmlParser = XMLParser(data: data!)
            
            // XML解析処理は別のクラスで実施
            let myXMLParser = MyXMLParser()
            xmlParser.delegate = myXMLParser
            
            if xmlParser.parse() == false {
                // XML解析に失敗
                print("XML解析失敗")
                self.showAlertMainQueue(msg: "XMLの形式が不正です")
                return
            }
            
            // 解析できた場合はデータソースの更新
            self.newsItemList = myXMLParser.itemArray
            
            // UIの更新はやはりメインスレッドでやらなけらばならない
            DispatchQueue.main.async {
                // テーブルビューに変わったことを教える
                self.tableView.reloadData()
                
                // アクティビティインジケーター非表示
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicatorView.stopAnimating()
                // リフレッシュコントロールを解除
                self.refreshControl?.endRefreshing()
            }
        }
        
        // URLセッションタスクの実行
        urlSessionTask.resume()
    }
    
    // メインキューでアラート表示
    func showAlertMainQueue(msg:String) {
        
        DispatchQueue.main.async {
            
            // アクティビティインジケーター非表示
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicatorView.stopAnimating()
            // リフレッシュコントロールを解除
            self.refreshControl?.endRefreshing()
            
            let alertController = UIAlertController(title: "メッセージ", message: msg, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // 主要なニュースを検索する
    func reloadNews() {
        // reloadNews引数ありをnilで呼ぶだけ
        reloadNews(searchWord: nil)
    }
}
