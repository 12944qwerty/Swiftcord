//
//  MarkdownMessage.swift
//  Swiftcord
//
//  Created by King Fish on 7/2/23.
//

import SwiftUI
import SimpleMarkdown
import DiscordKit
import DiscordKitCore

class MentionNode: BaseNode {
	var id: String
	var _type: String
	
	init(_ id: String, type: String) {
		self.id = id
		self._type = type
		
		super.init() // swift kinda annoying with this
	}
	
	override var body: AnyView {
		let inset: CGFloat = 2
		let insets = EdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
		let radius: CGFloat = 3
		
		return AnyView(
			Text("<\(_type)\(id)>")
				.foregroundColor(.cyan)
				.padding(insets)
				.background(.cyan.opacity(0.5))
				.cornerRadius(radius)
		)
	}
	
	// MARK: - CustomStringConvertible
	override var description: String {
		String(describing: type(of: self)) + "(<\(_type)\(id)>)"
	}
}


class MentionRule: BaseRule {
	override func getNode(_ groups: [String]) -> MentionNode {
		return MentionNode(groups[2], type: groups[1])
	}
	
	override var regex: String {
		get {
			"<((?:@&?)|#)(\\d+?)>"
		}
		set {}
	}
}

struct MarkdownMessage: View {
	let message: String
	
	var body: some View {
		let rules = [
			.codeBlock(),
			.quote(),
			.inlineCode(),
			MentionRule(),
			.bold(),
			.italic()
		]
		SimpleMarkdown(message, rules: rules)
	}
}
