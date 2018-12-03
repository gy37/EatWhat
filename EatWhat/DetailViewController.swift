//
//  DetailViewController.swift
//  EatWhat
//
//  Created by smarfid on 2018/10/30.
//  Copyright © 2018 smarfid. All rights reserved.
//

import UIKit
import WebKit

enum DetailType: Int {
    case tomorrow
    case records
    case detail
}

class DetailViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    var detailWebView: WKWebView!
    
    var type: DetailType = .detail
    var url: URL?
    var copyright: String = ""
    var textColor = UIColor.black
    var lastViewController: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        lastViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        titleLabel.text = (type == .detail ? "食材详情" : (type == .tomorrow ? "必应壁纸" : "记录详情"))
        setupWKWebView()
        loadData()
    }
    
    private func loadData() {
        switch type {
        case .detail:
            guard let url = url else { return }
            detailWebView.load(URLRequest(url: url))
        case .tomorrow:
            getBingImage()
        case .records:
            print(textColor)
            detailWebView.loadHTMLString(getHTMLString(), baseURL: nil)
        }
    }
    
    private func setupWKWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.selectionGranularity = .character
        configuration.preferences = WKPreferences()
        configuration.preferences.minimumFontSize = 10
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        let pool = WKProcessPool()
        configuration.processPool = pool
        let userController = WKUserContentController()
        configuration.userContentController = userController
        detailWebView = WKWebView(frame: CGRect(x: 20, y: 140, width: 335, height: 447), configuration: configuration)
        detailWebView.navigationDelegate = self
        view.addSubview(detailWebView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailWebView.configuration.userContentController.add(self as WKScriptMessageHandler, name: "JSObject")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detailWebView.configuration.userContentController.removeScriptMessageHandler(forName: "JSObject")
    }
    
    deinit {
        print("deinit")
    }
    
    @IBAction func backToHomepage(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func getHTMLString() -> String {
        
        //顶部加入年月日选项，可切换
        let html = "<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"/><title>计划详情</title><script>function display_alert(object) { console.log(object); var firstTD = object.getElementsByTagName('td')[0]; window.webkit.messageHandlers.JSObject.postMessage(firstTD.innerHTML); } function deleteTR(content) { console.log(content); var table = document.getElementById('content-table'); var trs = table.getElementsByTagName('tr'); for(var i = 0; i < trs.length; i++) { var tr = trs[i]; var tds = tr.getElementsByTagName('td'); if (tds.length == 0) continue; var firstTD = tds[0]; if (firstTD.innerHTML == content) { tr.parentNode.removeChild(tr); } } } function display_month_data(object) { var td = object.getElementsByTagName('td')[0]; var string = td.innerHTML; var table = document.getElementById('content-table'); var trs = table.getElementsByTagName('tr'); for (var i = trs.length - 1; i >= 0; i--) { var tr = trs[i]; console.log(tr.className); if (tr.className == string) { tr.style.display = tr.style.display == \"none\" ? \"table-row\" : \"none\"; } } } </script><style type=\"text/css\"> .month{ border-bottom: 1px solid #ff0000; height: 30px; color: #ff0000; font-weight: bold; } </style></head><body><table id=\"content-table\"; style=\"border:1px solid \(textColor.getHexString()); color:\(textColor.getHexString()); font-size:15px; width:100%; text-align:left; border-collapse: collapse;\">\(getPlanString())</table></body></html>"
        return html
    }
    
    private func getPlanString() -> String {
        guard let records = lastViewController?.readFile().exist.components(separatedBy: "\n") else { return "" }
        var recordString = ""
        for string in records {
            if string == "" { break }
            let str = string.components(separatedBy: ",")
            let className = str[0].prefix(7)
            if recordString.count == 0 {
                recordString = "<tr style=\"border-bottom:1px solid \(textColor.getHexString());\"><th>" + str[0] + "</th><th>" + str[1] + "</th><th>" + str[2] + "</th><th>" + str[3] + "</th><th>" + str[4] + "</th></tr>"
            } else {
                if recordString.contains(className) {
                    recordString += "<tr class=\"\(className)\" style=\"border-bottom:1px solid \(textColor.getHexString());height:30px;\" onclick=\"display_alert(this)\"><td>" + str[0] + "</td><td>" + str[1] + "</td><td>" + str[2] + "</td><td>" + str[3] + "</td><td>" + str[4] + "</td></tr>"//<!-- 不能给tr标签设置样式 -->
                } else {
                    recordString += "<tr class=\"month\" onclick=\"display_month_data(this)\"><td>\(className)</td></tr>";
                    recordString += "<tr class=\"\(className)\" style=\"border-bottom:1px solid \(textColor.getHexString());height:30px;\" onclick=\"display_alert(this)\"><td>" + str[0] + "</td><td>" + str[1] + "</td><td>" + str[2] + "</td><td>" + str[3] + "</td><td>" + str[4] + "</td></tr>"//<!-- 不能给tr标签设置样式 -->
                }
            }
        }
        return recordString
    }
    
    
    private func getBingImage() {
        // xmlstr=$(curl https://cn.bing.com/HPImageArchive.aspx\?format\=js\&idx\=0\&n\=1\&nc\=1501558320736\&pid\=hp)
        // url=$(expr "$xmlstr" : ".*\"url\":\"\(.*\)\",\"urlbase\":.*")
        // imgurl="http://cn.bing.com${url}"
        let bingUrl = "https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&nc=1501558320736&pid=hp"
        guard let url = URL(string: bingUrl) else { return }
        let urlRequest = URLRequest(url: url)
        detailWebView.load(urlRequest)
    }
    
    private func showSystemAlert(_ date: String) {
        let alertController = UIAlertController(title: "提示", message: "确定要删除\(date)的数据吗？", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确定", style: .destructive) { (action) in
            //1删除本地数据 2删除html中的标签
            self.lastViewController?.removeRecord(of: date)
            // self?.loadData()
            self.detailWebView.evaluateJavaScript("deleteTR(\"\(date)\")", completionHandler: { (any, error) in
                print(error ?? "no error")
            })
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(confirm)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension DetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url, url.absoluteString.contains("bing") {
            webView.evaluateJavaScript("document.body.innerHTML") { (any, error) in
                if let body = any as? String {
                    if body.contains("pre style=") {
                        if let c = body.components(separatedBy: "\"copyright\":").last?.components(separatedBy: ",").first?.components(separatedBy: "\"")[1], c.count != 0 {
                            self.copyright = c
                        }
                        if let image = body.components(separatedBy: "\"url\":").last?.components(separatedBy: ",").first?.components(separatedBy: "\"")[1] {
                            guard let imageUrl = URL(string: "https://cn.bing.com" + image) else { return }
                            webView.load(URLRequest(url: imageUrl))
                        }
                    } else {
                        let jsString = "var p = document.createElement('p'); p.innerHTML = '" + self.copyright + "'; var body = document.body; body.appendChild(p); body.style.fontSize = '50px';"
                        webView.evaluateJavaScript(jsString, completionHandler: { (any, error) in
                            print(error ?? "no error")
                        })
                    }
                }
            }
        } else if let url = webView.url, url.absoluteString.contains("about:blank") {

        }
    }
}


extension DetailViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "JSObject", let body = message.body as? String {
            showSystemAlert(body)
        }
    }
    
}
