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
	
	var gateway: DiscordGateway
	var serverCtx: ServerContext
	@Binding var selCh: Channel?
	
	init(_ id: String, type: String, gateway: DiscordGateway, serverCtx: ServerContext, selCh: Binding<Channel?>) {
		self.id = id
		self._type = type
		self.gateway = gateway
		self.serverCtx = serverCtx
		self._selCh = selCh
		
		super.init() // swift kinda annoying with this
	}
	
	override var body: AnyView {
		let inset: CGFloat = 2
		let insets = EdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
		let radius: CGFloat = 3
		
		// Temporary default for now
		let color: Color = .cyan
		
		var text: String?
		
		if _type == "@" {
			if let member = serverCtx.guild?.members?.first(where: { $0.user?.id == id }) {
				text = "@\(member.nick ?? member.user?.username ?? id)"
			} else if let user = gateway.cache.users.first(where: { $0.key == id }) {
				text = "@\(user.value.username)"
			}
		} else if _type == "#", let channel = serverCtx.guild?.channels?.first(where: { $0.id == id }) {
			text = "#\(channel.name ?? "unknown_channel")"
		} else if _type == "@&" {
			do {
				if let role = try serverCtx.guild?.roles.first(where: { try $0.result.get().id == id })?.result.get() {
					text = "@\(role.name)"
				}
			} catch {}
		}
		
		return AnyView(
			Text(text ?? "<\(_type)\(id)>")
				.foregroundColor(color)
				.padding(insets)
				.background(color.opacity(0.2))
				.cornerRadius(radius)
		)
	}
	
	// MARK: - CustomStringConvertible
	override var description: String {
		String(describing: type(of: self)) + "(<\(_type)\(id)>)"
	}
}


class MentionRule: BaseRule {
	var gateway: DiscordGateway
	var serverCtx: ServerContext
	@Binding var selCh: Channel?
	
	public init(gateway: DiscordGateway, serverCtx: ServerContext, selCh: Binding<Channel?>) {
		self.gateway = gateway
		self.serverCtx = serverCtx
		self._selCh = selCh
	}
	
	override func getNode(_ groups: [String]) -> MentionNode {
		return MentionNode(groups[2], type: groups[1], gateway: gateway, serverCtx: serverCtx, selCh: $selCh)
	}
	
	override var regex: String {
		get {
			"<((?:@&?)|#)(\\d+?)>"
		}
		set {}
	}
}

struct MarkdownMessage: View {
	@EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var serverCtx: ServerContext
	
	let message: String
	
	var body: some View {
		let rules = [
			.codeBlock(),
			.quote(),
			.inlineCode(),
			MentionRule(gateway: gateway, serverCtx: serverCtx, selCh: $serverCtx.channel),
			.bold(),
			.italic()
		]
		SimpleMarkdown(message, rules: rules)
	}
}
