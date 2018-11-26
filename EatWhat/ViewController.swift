//
//  ViewController.swift
//  EatWhat
//
//  Created by smarfid on 2018/10/24.
//  Copyright © 2018 smarfid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    // MARK: - Properties
    var filePath: String = ""
    var coolBeans = [String]()
    var coldBeans = [String]()
    var hotBeans = [String]()
    var bigBeans = [String]()
    var mixes = [String]()
    var eggs = [String]()
    var existString = ""
    var contentString = ""
    var localRecords = [String]()

    var randomColor: UIColor = .red {
        didSet {
            setAttributedString(string: contentString)
            for button in [confirmButton, cancelButton] {
                button?.setTitleColor(randomColor, for: .normal)
                button?.layer.borderColor = randomColor.cgColor
            }
        }
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        coolBeans = ["大米"]
        coldBeans = ["莲子", "薏米"]
        hotBeans = ["红豆", "黑米", "黑芝麻"]
        bigBeans = ["桂圆", "红枣", "黑豆"]
        mixes = ["冰糖"]
        eggs = ["鸡蛋"]
        cancelButton.setTitle("切换", for: .normal)
        
        let day = readFile()
        print(day)
        if day.date == Date().getDateString() {
            disableConfirmButton()
            generatePlan(day.count - 1)
        } else {
            generatePlan(day.count)
            writeFile()
            disableConfirmButton()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTomorrow" {
            let detail = segue.destination as? DetailViewController
            detail?.type = .tomorrow
        } else if segue.identifier == "toRecords" {
            let detail = segue.destination as? DetailViewController
            detail?.textColor = getRandomColor()
            detail?.type = .records
        }
    }
    
    // MARK: - filemanager method
    func readFile() -> (count: Int, date: String, exist: String) {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        filePath = (documentPath ?? "").appending("/plan.csv")
        print(filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                existString = try String(contentsOfFile: filePath)
            } catch {
                print(error)
            }
        } else {
            existString = "Date,Cool,Cold,Hot,Big\n"
            let result = FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            print(result)
        }
        let plans = existString.components(separatedBy: "\n")
        localRecords = plans
        return (plans.count - 2, plans[plans.count - 2].components(separatedBy: ",").first ?? "", existString)
    }
    
    func removeRecord(of date: String) {
        for (index, string) in localRecords.enumerated() {
            if string.contains(date) {
                localRecords.remove(at: index)
            }
        }
        existString = localRecords.joined(separator: "\n");
        writeFile()
    }
    
    private func writeFile() {
        do {
            try existString.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    
    // MARK: - plan methods
    private func generatePlan(_ day: Int) {
        let cool = coolBeans[0]
        let cold = coldBeans[day%2]
        let hot = hotBeans[day%3]
        let big = bigBeans[day%3]
        let mix = mixes[0]
        let egg = eggs[0]
        let gruel = "我今天要喝 " + cool + "、" + cold + "、" + hot + "、" + big + " 粥, " + "还要加入 " + mix + " 和 " + egg
        print(gruel)
        
        randomColor = getRandomColor()
        contentString = String(describing: coolBeans) + "\n" + String(describing: coldBeans) + "\n" + String(describing: hotBeans) + "\n" + String(describing: bigBeans) + "\n" + String(describing: mixes) + "\n" + String(describing: eggs) + "\n\n\n\n" + gruel
        setAttributedString(string: contentString)
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = ""
        pasteboard.string = gruel
        
        let beans = [cool, cold, hot, big]
        if day == localRecords.count - 2 {
            existString += "\(Date().getDateString())," + beans.joined(separator: ",") + "\n"
        }
        print(existString)
    }

    @IBAction func cancelPlan(_ sender: UIButton) {
        randomColor = getRandomColor()
    }
    @IBAction func confirmPlan(_ sender: UIButton) {
        writeFile()
        disableConfirmButton()
    }
    
    // MARK: - tool methods
    private func getRandomColor() -> UIColor {
        return UIColor(red: CGFloat(Float(arc4random_uniform(256)) / 255.0), green: CGFloat(Float(arc4random_uniform(256)) / 255.0), blue: CGFloat(Float(arc4random_uniform(256)) / 255.0), alpha: 1.0)
    }
    
    private func disableConfirmButton() {
        confirmButton.isEnabled = false
        confirmButton.backgroundColor = UIColor.lightGray
    }
    
    private func setAttributedString(string: String) {
        let attributeString = NSAttributedString(string: string)
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributeString)
        mutableAttributedString.addAttributes([
            .foregroundColor: randomColor,
            .font: UIFont.systemFont(ofSize: 18)
            ], range: NSRange(location: 0, length: string.count))
        let materials = coolBeans + coldBeans + hotBeans + bigBeans + mixes + eggs
        let materialColor = getRandomColor()
        for material in materials {
            mutableAttributedString.addAttributes([
                .link: "https://baike.baidu.com/item/\(material)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://www.baidu.com"
                ], range: string.nsrange(of: material))
        }
        contentTextView.attributedText = mutableAttributedString
        contentTextView.tintColor = materialColor //通过修改tintcolor修改超链接文本颜色，默认蓝色
    }
    
    
    
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        guard let detail = detailController else { return false }
        detail.type = .detail
        detail.url = URL
        present(detail, animated: true, completion: nil)
        return false
    }
}

