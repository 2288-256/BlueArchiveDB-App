//
//  ViewController.swift
//  BlueArchive Database
//
//  Created by clark on 2023/11/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            versionLabel.text = "Version: \(version) Build: \(build)"
        }
    }
    @IBAction func destinationWindow(_ sender: UISegmentedControl) {
        //"「未実装です」というアラートを表示"
        let alert = UIAlertController(title: "エラー", message: "まだ実装されていない機能です", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

