//
//  Article.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/8/21.
//

public class Article {
    var title: String
    var lastPathComponentURL: String
    
    init(title: String, lastPathComponentURL: String) {
        self.title = title
        self.lastPathComponentURL = lastPathComponentURL
    }
}
