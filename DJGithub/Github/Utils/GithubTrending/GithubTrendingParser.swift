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

    func parse<T: Codable>(with type: TrendingType) async -> [T] {
        guard let html = await load() else { return [] }
        do {
            let doc = try SwiftSoup.parse(html)
            guard let box = try parseBox(with: doc) else { return [] }
            let elements = try parseArticles(with: box, className: type.className)

            return elements.compactMap { element in
                switch type {
                case .repo: return try? parseRepoArticle(with: element) as? T
                case .developer: return try? parseDeveloper(with: element) as? T
                }
            }
        } catch {
            print("Github Trending Parse Error: \(error)")
        }
        return []
    }

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
}

extension GithubTrendingParser {
    enum TrendingType {
        case repo
        case developer

        var className: String {
            switch self {
            case .repo: return "Box-row"
            case .developer: return "Box-row d-flex"
            }
        }
    }
}

private extension GithubTrendingParser {

    func parseBox(with doc: Document) throws -> Element? {
        let elements = try doc.getElementsByClass("Box")
        return try elements.filter { try $0.className() == "Box" }.first
    }

    func parseArticles(with element: Element, className: String) throws -> [Element] {
        let elements = try element.getElementsByTag("Article")
        return try elements.filter { try $0.className() == className }
    }

    func parseRepoArticle(with element: Element) throws -> GithubTrendingRepo {
        let (userName, repoName) = try parseUserNameAndRepoName(with: element)
        let desc = try parseDesc(with: element)
        let footer = try parseFooter(with: element)
        let (languange, color) = try parseRepoLanguage(with: footer)
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
            footerDesc: footerDesc,
            languageColor: color
        )
    }

    func parseDeveloper(with element: Element) throws -> GithubTrendingDeveloper {
        let avatarImageUrl = try parseAvatarImageUrl(with: element)
        let name = try parseDeveloperName(with: element)
        let login = try parseDeveloperLoginName(with: element)
        let repoName = try parseDeveloperHotRepoName(with: element)
        let repoDesc = try parseDeveloperHotRepoDesc(with: element)
        return GithubTrendingDeveloper(
            avatarImageUrl: avatarImageUrl,
            name: name,
            login: login,
            repoName: repoName,
            repoDesc: repoDesc
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

    func parseRepoLanguage(with element: Element) throws -> (String, String) {
        guard let ele = try element.getElementsByClass("d-inline-block ml-0 mr-3").first() else {
            return ("", "")
        }
        let colorSpan = try ele.getElementsByClass("repo-language-color").get(0)
        let languageSpan = try ele.getElementsByAttributeValue("itemprop", "programmingLanguage").get(0)
        let language = try languageSpan.text()
        guard let style = try colorSpan.attr("style").components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return (language, "")
        }
        return (language, style)
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

    func parseAvatarImageUrl(with element: Element) throws -> String {
        guard let div = try element.getElementsByClass("mx-3").first() else { return "" }
        let src = try div.getElementsByTag("img").attr("src")
        return src
    }

    func parseDeveloperName(with element: Element) throws -> String {
        let h1Tags = try element.getElementsByTag("h1")
        for tag in h1Tags {
            let className = try tag.className()
            if className == "h3 lh-condensed" {
                return try tag.text(trimAndNormaliseWhitespace: true)
            }
        }
        return ""
    }

    func parseDeveloperLoginName(with element: Element) throws -> String {
        let h1Tags = try element.getElementsByTag("p")
        for tag in h1Tags {
            let className = try tag.className()
            if className == "f4 text-normal mb-1" {
                return try tag.text(trimAndNormaliseWhitespace: true)
            }
        }
        return ""
    }

    func parseDeveloperHotRepoName(with element: Element) throws -> String {
        let h1Tags = try element.getElementsByTag("h1")
        for tag in h1Tags {
            let className = try tag.className()
            if className == "h4 lh-condensed" {
                return try tag.text(trimAndNormaliseWhitespace: true)
            }
        }
        return ""
    }

    func parseDeveloperHotRepoDesc(with element: Element) throws -> String {
        let div = try element.getElementsByClass("f6 color-fg-muted mt-1").get(0)
        return try div.text(trimAndNormaliseWhitespace: true)
    }
}
