//
//  Array.Channel+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordKit

extension Array where Element == Channel {
	func discordSorted() -> Self {
		sorted { c1, c2 in
			// This is a DM/Group DM channel
			if c1.type == .dm || c1.type == .groupDM,
			   let c1m = c1.last_message_id,
			   let c2m = c2.last_message_id  {
				return c1m > c2m
			}
			
			if c1.type == .voice, c2.type != .voice { return false }
			if c1.type != .voice, c2.type == .voice { return true }
			if c1.position != nil, c2.position != nil { return c2.position! > c1.position! }
			return c2.id > c1.id
		}
	}
}
