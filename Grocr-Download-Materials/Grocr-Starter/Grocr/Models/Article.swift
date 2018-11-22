//
//  Article.swift
//  Grocr
//
//  Created by Ron Yi on 2018/11/19.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

struct Article {

    let ref: DatabaseReference?
    let key: String

    let addByAuthor: String
    var title: String
    var content: String
    var date: String
    var isLike: Bool

    init(addByAuthor: String, key: String = "", title: String, content: String, date: String, isLike: Bool) {

        self.ref = nil
        self.key = key

        self.addByAuthor = addByAuthor
        self.title = title
        self.content = content
        self.date = date
        self.isLike = isLike

    }

    init?(snapshot: DataSnapshot) {

        guard
            let value = snapshot.value as? [String: AnyObject],
            let addByAuthor = value["addByAuthor"] as? String,
            let title = value["title"] as? String,
            let content = value["content"] as? String,
            let date = value["date"] as? String,
            let isLike = value["isLike"] as? Bool else {

            print("Artcle init? property error.")
            return nil

        }

        self.ref = snapshot.ref
        self.key = snapshot.key

        self.addByAuthor = addByAuthor
        self.title = title
        self.content = content
        self.date = date
        self.isLike = isLike

    }

    func toAnyObject() -> Any {

        return [

            "addByAuthor": addByAuthor,
            "title": title,
            "content": content,
            "date": date,
            "isLike": isLike

        ]

    }

}
