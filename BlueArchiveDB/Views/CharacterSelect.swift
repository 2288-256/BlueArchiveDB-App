//
//  CharacterSelect.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/22.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterSelect: UIViewController, UICollectionViewDataSource,
	UICollectionViewDelegateFlowLayout, UISearchBarDelegate
{
	var viewMode: String = ""
	var StudentData: [[String: Any]] = []
	var jsonArrays: [[String: Any]] = []
	var SearchString: String = ""
	@IBOutlet var searchBar: UISearchBar!
	override func viewDidLoad()
	{
		super.viewDidLoad()
		if viewMode == "Main"
		{
			loadMainStudents()
		} else if viewMode == "Support"
		{
			loadSupportStudents()
		} else
		{
			jsonArrays = LoadFile.shared.getStudents()
			StudentData = jsonArrays
		}
		if SearchString != ""
		{
			searchBar.text = String(SearchString)
			searchItems(searchText: SearchString)
		}
	}

	@IBAction func BackButton(_: Any)
	{
		dismiss(animated: false, completion: nil)
	}

	@IBAction func HomeButton(_: UIButton)
	{
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let nextVC = storyboard.instantiateViewController(withIdentifier: "Home") as! ViewController
		present(nextVC, animated: false, completion: nil)
	}

	@IBAction func MainStudentsFilter(_: UIButton)
	{
		loadMainStudents()
		collectionView.reloadData()
	}

	@IBAction func AllStudentsFilter(_: UIButton)
	{
		jsonArrays = LoadFile.shared.getStudents()
		collectionView.reloadData()
	}

	@IBAction func SupporterStudentsFilter(_: UIButton)
	{
		loadSupportStudents()
		collectionView.reloadData()
	}

	@IBOutlet var collectionView: UICollectionView!
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let testCell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "character-cell", for: indexPath)

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

	//    func collectionView(_ collectionView: UICollectionView,
	//                       layout collectionViewLayout: UICollectionViewLayout,
	//                       insetForSectionAt section: Int) -> UIEdgeInsets {
	//        return UIEdgeInsets(top: 0, left: 0, bottom: 11, right: 0)
	//    }

	func numberOfSections(in _: UICollectionView) -> Int
	{
		// section数は１つ
		return 1
	}

	func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int
	{
		return jsonArrays.count
	}

	func loadMainStudents()
	{
		do
		{
			jsonArrays.removeAll()
			jsonArrays = StudentData.filter { ($0["SquadType"] as? String) == "Main" }
			print("STRIKERの生徒数:\(jsonArrays.count)人")
		} catch
		{
			print("Error reading students JSON file: \(error)")
		}
	}

	func loadSupportStudents()
	{
		do
		{
			jsonArrays.removeAll()
			jsonArrays = StudentData.filter { ($0["SquadType"] as? String) == "Support" }
			print("SUPPORTERの生徒数:\(jsonArrays.count)人")
		} catch
		{
			print("Error reading students JSON file: \(error)")
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
		// 選択されたセルを取得
		let selectedCell = collectionView.cellForItem(at: indexPath)

		// セルのtagを取得
		let cellTag = selectedCell?.tag
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterInfo") as? CharacterInfo
		{
			// 引き渡したい変数を設定する
			viewController.unitId = Int(cellTag!)
			viewController.modalTransitionStyle = .crossDissolve
			viewController.modalPresentationStyle = .fullScreen
			present(viewController, animated: false, completion: nil)
		} else
		{
			print("Error: Failed to instantiate CharacterSelect")
		}
		// セル選択の解除
		collectionView.deselectItem(at: indexPath, animated: true)
	}

	func searchBar(_: UISearchBar, textDidChange searchText: String)
	{
		print("検索文字:\(searchText)")
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
			print("検索結果:\(searchTerms)")
			// 検索文字列を含む要素を検索結果配列に追加する
			jsonArrays = StudentData.filter
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
		} else
		{
			// 検索文字列が空の場合は全てを表示する
			if viewMode == "Main"
			{
				loadMainStudents()
			} else if viewMode == "Support"
			{
				loadSupportStudents()
			} else
			{
				jsonArrays = LoadFile.shared.getStudents()
			}
		}
		// テーブルを再読み込みする
		collectionView.reloadData()
	}
}
