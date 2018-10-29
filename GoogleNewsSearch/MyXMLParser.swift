//
//  MyXMLParser.swift
//  GoogleNewsSearch
//
//  Created by user on 2018/10/29.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit

class MyXMLParser: NSObject,XMLParserDelegate {
    
    // できたItemを入れておくところ
    public var itemArray:[Item] = []
    
    // 解析時に使うItemインスタンスの入れ物
    private var workItem:Item?
    
    // 解析時に使う要素名の入れ物
    private var nowElementName:String!
    
    // 要素が開始した
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // 見つかった要素名を保存
        nowElementName = elementName
        
        // Itemのときは
        if elementName == "item" {
            // Itemの入れ物を用意する
            workItem = Item()
        }
    }
    
    // 文字が見つかった
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if nowElementName == "title" {
            // titleだったら内容を保存
            workItem?.title = string
        } else if nowElementName == "link" {
            // linkのときも内容を保存
            workItem?.link = string
        }
    }
    
    // 要素が終了した
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            // １つのItemが完成したので配列に追加する
            itemArray.append(workItem!)
        }
    }
    
    // XML文書の終了
    func parserDidEndDocument(_ parser: XMLParser) {
        // 特になにもなし
    }
}
