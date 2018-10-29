//
//  Item.swift
//  GoogleNewsSearch
//
//  Created by user on 2018/10/29.
//  Copyright © 2018年 user. All rights reserved.
//

import Foundation

struct Item {
    // タイトル
    var title:String
    // 説明文（今回未使用)
    var description:String
    // リンクURL
    var link:String
    
    // 文字列のURLをURL型にするコンピューテッドプロパティ
    var url:URL? {
        get{
            return URL(string: link)
        }
    }
    
    // 空っぽで用意するイニシャライザ
    init() {
        title = ""
        description = ""
        link = ""
    }
}
