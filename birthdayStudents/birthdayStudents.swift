//
//  birthdayStudents.swift
//  birthdayStudents
//
//  Created by 2288-256 on 2023/12/12.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//
import Intents
import SwiftUI
import WidgetKit

// JSONから学生データをデコードするための構造体
struct Student: Decodable
{
	var Id: Int
	var Name: String
	var FamilyName: String
	var PersonalName: String
	var BirthDay: String
}

// 今日の日付を "MM/dd" フォーマットで取得する関数
func fetchTodayDateString() -> String
{
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "M/d"
	let today = dateFormatter.string(from: Date())
	return today
}

func fetchBirthdayStudents(completion: @escaping ([String]) -> Void)
{
	let url = URL(string: "https://schaledb.com/data/jp/students.min.json")!

    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "Unknown error")
            completion(["Unknown error"])
            return
        }

        do {
            // `data` を `[String: [String: Any]]` に変換
            if let studentsData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] {
                
                let today = fetchTodayDateString()
                
                // 生徒データをフィルタリングする
                let birthdayStudents = Array(studentsData.values).filter { value in
                    guard let birthDay = value["BirthDay"] as? String,
                          let name = value["Name"] as? String else {
                        return false
                    }
                    // 本日が誕生日かどうかと、名前に「（」「）」が含まれていないかをチェック
                    return birthDay == today && !name.contains("（") && !name.contains("）")
                }

                // 誕生日の生徒がいない場合
                if birthdayStudents.isEmpty {
                    completion(["本日誕生日の生徒がいません"])
                } else {
                    // 該当する生徒の名前を取得
                    let names = birthdayStudents.map { value in
                        guard let familyName = value["FamilyName"] as? String,
                              let personalName = value["PersonalName"] as? String else {
                            return "Unknown"
                        }
                        return familyName + " " + personalName
                    }
                    completion(names)
                }
            } else {
                completion(["データフォーマットが不正です"])
            }
        } catch {
            print(error.localizedDescription)
            completion(["error"])
        }
    }.resume()

}

// ウィジェットのタイムラインエントリー
struct SimpleEntry: TimelineEntry
{
	let date: Date
	let birthdayNames: [String]
}

// ウィジェットプロバイダー
struct Provider: TimelineProvider
{
	func placeholder(in _: Context) -> SimpleEntry
	{
		SimpleEntry(date: Date(), birthdayNames: ["読み込み中..."])
	}

	func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void)
	{
		let entry = SimpleEntry(date: Date(), birthdayNames: ["早瀬 ユウカ", "天童 アリス", "白洲 アズサ"])
		completion(entry)
	}

	func getTimeline(in _: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void)
	{
		fetchBirthdayStudents
		{ names in
			let currentDate = Date()
			let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
			let entry = SimpleEntry(date: currentDate, birthdayNames: names)
			let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
			completion(timeline)
		}
	}
}

// ウィジェットのビュー
struct BirthdayStudentsWidgetEntryView: View
{
	var entry: Provider.Entry
	@Environment(\.widgetFamily) var family

	var body: some View
	{
		VStack(alignment: .leading, spacing: 5)
		{
			if family == .systemSmall
			{
				Text("本日誕生日の生徒")
					.font(.system(size: 15, weight: .semibold))
					.padding(.bottom, 5)
			} else if family == .systemMedium
			{
				if !entry.birthdayNames.isEmpty
				{
					Text("本日誕生日の生徒 (計\(entry.birthdayNames.count)人)")
						.font(.headline)
						.padding(.bottom, 5)
				} else
				{
					Text("本日誕生日の生徒")
						.font(.headline)
						.padding(.bottom, 5)
				}
			}

			ForEach(entry.birthdayNames, id: \.self)
			{ name in
				Text(name)
					.font(.subheadline)
			}
		}.widgetURL(URL(string: "bluedb://home"))
		.padding()
	}
}

struct BirthdayStudentsWidget: Widget
{
	let kind: String = "BirthdayStudentsWidget"

	var body: some WidgetConfiguration
	{
		StaticConfiguration(kind: kind, provider: Provider())
		{ entry in
			BirthdayStudentsWidgetEntryView(entry: entry)
		}
		.configurationDisplayName("誕生日の生徒ウィジェット")
		.description("今日誕生日の生徒のリストを表示します。")
		.supportedFamilies([.systemSmall, .systemMedium]) // systemMediumサイズのみをサポート
	}
}

struct BirthdayStudentsWidget_Previews: PreviewProvider
{
	static var previews: some View
	{
		BirthdayStudentsWidgetEntryView(entry: SimpleEntry(date: Date(), birthdayNames: ["Alice", "Bob", "Charlie", "Dave"]))
			.previewContext(WidgetPreviewContext(family: .systemMedium))
	}
}
