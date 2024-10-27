//
//  SettingCharacterSelect.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/01/11.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class SettingCharacterSelect: UIViewController, UICollectionViewDataSource,
	UICollectionViewDelegateFlowLayout, UISearchBarDelegate
{
	var StudentData: [String: [String: Any]] = [:] // JSONが辞書形式になった
	var jsonArrays: [[String: Any]] = [] // フィルタリングされた配列形式のデータ
	var SearchString: String = ""
	@IBOutlet var searchBar: UISearchBar!
	override func viewDidLoad()
	{
		jsonArrays = Array(LoadFile.shared.getStudents().values)
		jsonArrays.sort
		{
			let order1 = ($0["DefaultOrder"] as? Int) ?? Int.max
			let order2 = ($1["DefaultOrder"] as? Int) ?? Int.max
			return order1 < order2
		}
		StudentData = LoadFile.shared.getStudents()
	}

	@IBAction func backButton(_: Any)
	{
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let viewController = storyboard.instantiateViewController(withIdentifier: "Setting") as? Setting
		{
			present(viewController, animated: false, completion: nil)
		} else
		{
			Logger.standard.fault("Error: Failed to instantiate CharacterSelect")
		}
	}

	@IBOutlet var collectionView: UICollectionView!
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let testCell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "setting-character-cell", for: indexPath)

		let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
		imageView.image = nil
		let label = testCell.contentView.viewWithTag(2) as! UILabel
		label.text = nil
		if jsonArrays.count > indexPath.row
		{
			let characterInfo = jsonArrays[indexPath.row]
			if let unitId = characterInfo["Id"] as? Int,
			   let name = characterInfo["Name"] as? String
			{
				testCell.tag = unitId
				// libraryにある画像を読み込む
				let fileManager = FileManager.default
				let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
				let imagePath = libraryDirectory.appendingPathComponent("assets/images/student/collection/\(unitId).webp")
				imageView.image = UIImage(contentsOfFile: imagePath.path)
				label.text = name
			}
		}

		return testCell
	}

	func collectionView(_: UICollectionView,
	                    layout _: UICollectionViewLayout,
	                    sizeForItemAt _: IndexPath) -> CGSize
	{
		let horizontalSpace: CGFloat = 8
		let cellSize: CGFloat = (view.bounds.width - (horizontalSpace * 8)) / 8
		return CGSize(width: cellSize, height: 165)
	}

	func numberOfSections(in _: UICollectionView) -> Int
	{
		// section数は１つ
		return 1
	}

	func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int
	{
		return jsonArrays.count
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
		// 選択されたセルを取得
		let selectedCell = collectionView.cellForItem(at: indexPath)

		// セルのtagを取得
		let cellTag = selectedCell?.tag
		// セル選択の解除
		collectionView.deselectItem(at: indexPath, animated: true)
		let matchingCharacters = jsonArrays.filter { $0["Id"] as? Int == cellTag }
		let name: String = matchingCharacters.first?["Name"] as! String
		// アラートで完了したことを伝える
		let confirmationAlert = UIAlertController(title: "確認", message: "\(name)を選択して保存しますか？", preferredStyle: .alert)
		confirmationAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
			let alert = UIAlertController(title: "保存しました", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
				UserDefaults.standard.set(cellTag, forKey: "CharacterID")
				let storyboard = UIStoryboard(name: "Main", bundle: nil)
				if let viewController = storyboard.instantiateViewController(withIdentifier: "Setting") as? Setting
				{
					self.present(viewController, animated: false, completion: nil)
				} else
				{
					Logger.standard.fault("Error: Failed to instantiate Setting")
				}
			}))
			self.present(alert, animated: true, completion: nil)
		}))
		confirmationAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))

		present(confirmationAlert, animated: true, completion: nil)
	}

	func searchBar(_: UISearchBar, textDidChange searchText: String)
	{
		Logger.standard.debug("検索文字:\(searchText)")
		// 検索する
		searchItems(searchText: searchText)
	}

	func searchItems(searchText: String)
	{
		// 配列を定義
		var searchTerms: [String] = []
		// 検索結果配列を空にする
		jsonArrays.removeAll()
		// searchTermsにsearchTextを加える
		searchTerms.append(searchText)
		if searchText != ""
		{
			searchTerms += LoadFile.shared.findMatchingKeys(searchText: searchText)
			// 検索文字列を含む要素を検索結果配列に追加する
			jsonArrays = StudentData.values.filter
			{ student in
				let searchTerms: [String] = (searchTerms as? [String]) ?? [searchTerms as? String].compactMap { $0 }
				return searchTerms.contains
				{ term in
					(student["Name"] as? String)?.contains(term) == true ||
						(student["FamilyName"] as? String)?.contains(term) == true ||
						(student["FamilyNameRuby"] as? String)?.contains(term) == true ||
						(student["CharacterAge"] as? String)?.contains(term) == true ||
						(student["School"] as? String)?.contains(term) == true ||
						(student["SchoolYear"] as? String)?.contains(term) == true ||
						(student["Club"] as? String)?.contains(term) == true ||
						(student["Birthday"] as? String)?.contains(term) == true ||
						(student["CharHeightMetric"] as? String)?.contains(term) == true ||
						(student["Hobby"] as? String)?.contains(term) == true ||
						(student["Designer"] as? String)?.contains(term) == true ||
						(student["Illustrator"] as? String)?.contains(term) == true ||
						(student["CharacterVoice"] as? String)?.contains(term) == true ||
						(student["WeaponType"] as? String)?.contains(term) == true
				}
			}
			jsonArrays.sort
			{
				let order1 = ($0["DefaultOrder"] as? Int) ?? Int.max
				let order2 = ($1["DefaultOrder"] as? Int) ?? Int.max
				return order1 < order2
			}
		} else
		{
			jsonArrays = []
		}
		// テーブルを再読み込みする
		collectionView.reloadData()
	}
}
