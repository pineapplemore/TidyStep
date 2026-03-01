//
//  EncouragementLibrary.swift
//  TidyStep
//
//  统一励志语库：小组件与推送共用。按日期 seed 每天固定一句。
//

import Foundation

enum EncouragementLibrary {

    private static let phrasesEN: [String] = [
        "Start a tidy today!",
        "A little tidy goes a long way.",
        "Ready when you are.",
        "Nice work!",
        "Every tidy counts.",
        "Keep the momentum!",
        "You're on fire!",
        "Amazing consistency!",
        "Keep it up!",
        "A good environment can brighten your whole day.",
        "A tidy space helps you get twice the result with half the effort.",
        "A clean room makes the mind clear.",
        "Your future self will thank you.",
        "Small steps, big impact.",
        "One room at a time.",
        "Today's tidy is tomorrow's calm.",
        "You've got this!",
        "Progress over perfection.",
        "Clear space, clear mind.",
        "Every little bit helps.",
        "Make it a habit.",
        "Consistency is key.",
        "Feel the difference.",
        "Tidy now, relax later.",
        "You're building a better routine.",
        "One step closer to a cleaner home.",
    ]

    private static let phrasesZH: [String] = [
        "今天开始整理吧！",
        "小小整理，大大改变。",
        "准备好了就开始。",
        "做得好！",
        "每次整理都算数。",
        "保持节奏！",
        "太棒了！",
        "坚持得真好！",
        "继续保持！",
        "好的环境可以让你的一天心情舒畅。",
        "好的环境能让你事半功倍。",
        "整洁的环境能让心情更明朗。",
        "动动手，房间焕然一新。",
        "小步前进，大有不同。",
        "一间一间来。",
        "今天的整理是明天的从容。",
        "你可以的！",
        "进步比完美更重要。",
        "空间清爽，心情也清爽。",
        "一点一滴都有用。",
        "养成习惯就好。",
        "贵在坚持。",
        "感受一下变化。",
        "现在整理，待会轻松。",
        "你在养成更好的习惯。",
        "离整洁的家又近一步。",
    ]

    /// 按日期取一句励志语，同一天始终返回同一条。lang: "en" 或 "zh-Hans"
    static func phraseForDate(lang: String, date: Date) -> String {
        let list = lang == "zh-Hans" ? phrasesZH : phrasesEN
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        let seed = (c.year ?? 0) * 10000 + (c.month ?? 0) * 100 + (c.day ?? 0)
        let idx = abs(seed) % list.count
        return list[idx]
    }
}
