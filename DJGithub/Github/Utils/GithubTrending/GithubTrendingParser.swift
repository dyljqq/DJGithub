//
//  GithubTrendingParser.swift
//  DJGithub
//
//  Created by polaris dev on 2023/1/19.
//

import Foundation
import SwiftSoup

struct GithubTrendingParser {
    
    let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func parse() async -> [GithubTrendingRepo] {
        guard let html = await self.load() else { return [] }
        do {
            let doc = try SwiftSoup.parse(html)
            guard let box = try parseBox(with: doc) else { return [] }
            let elements = try parseArticles(with: box)
            return try elements.map { try parseArticle(with: $0) }
        } catch {
            print("Github Trending Parse Error: \(error)")
        }
        return []
    }
}

private extension GithubTrendingParser {
    func load() async -> String? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error to load github trending:")
            print("url: \(urlString)")
            print("errot: \(error)")
        }
        return nil
    }
    
    func parseBox(with doc: Document) throws -> Element? {
        let elements = try doc.getElementsByClass("Box")
        return try elements.filter { try $0.className() == "Box" }.first
    }
    
    func parseArticles(with element: Element) throws -> Elements {
        return try element.getElementsByTag("Article")
    }
    
    func parseArticle(with element: Element) throws -> GithubTrendingRepo {
        let (userName, repoName) = try parseUserNameAndRepoName(with: element)
        let desc = try parseDesc(with: element)
        let footer = try parseFooter(with: element)
        let languange = try parseRepoLanguage(with: footer)
        let starNum = try parseRepoStar(with: footer)
        let repoFork = try parseRepoFork(with: footer)
        let footerDesc = try parseFooterDesc(with: footer)
        
        return GithubTrendingRepo(
            userName: userName,
            repoName: repoName,
            languange: languange,
            desc: desc,
            star: starNum,
            fork: repoFork,
            footerDesc: footerDesc
        )
    }
    
    func parseUserNameAndRepoName(with element: Element) throws -> (String, String) {
        let h1 = try element.getElementsByTag("h1").get(0)
        let a = try h1.getElementsByTag("a").get(0)
        let text = try a.text()
        let arr = text.components(separatedBy: "/").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard arr.count == 2 else { return ("", "") }
        return (arr[0], arr[1])
    }
    
    func parseDesc(with element: Element) throws -> String {
        let p = try element.getElementsByClass("col-9 color-fg-muted my-1 pr-4").get(0)
        return try p.text()
    }
    
    func parseFooter(with element: Element) throws -> Element {
        let div = try element.getElementsByClass("f6 color-fg-muted mt-2")
        return div.get(0)
    }
    
    func parseRepoLanguage(with element: Element) throws -> String {
        let ele = try element.getElementsByClass("d-inline-block ml-0 mr-3").get(0)
        let span = try ele.getElementsByAttributeValue("itemprop", "programmingLanguage")
        return try span.text()
    }
    
    func parseRepoStar(with element: Element) throws -> String {
        let ele = try element.getElementsByClass("Link--muted d-inline-block mr-3").get(0)
        return try ele.text(trimAndNormaliseWhitespace: true)
    }
    
    func parseRepoFork(with element: Element) throws -> String {
        let ele = try element.getElementsByClass("Link--muted d-inline-block mr-3").get(1)
        return try ele.text(trimAndNormaliseWhitespace: true)
    }
    
    func parseFooterDesc(with element: Element) throws -> String {
        let ele = try element.getElementsByClass("d-inline-block float-sm-right").get(0)
        return try ele.text(trimAndNormaliseWhitespace: true)
    }
}
