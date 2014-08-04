using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Wargrounds {
	[RoomType("LobbyRoom2.4")]
	public class LobbyRoom : Game<Player> {
		private List<Player> lobbyPlayers = new List<Player>();

		public override void GameStarted() {
			PreloadPlayerObjects = true;
		}

		public override bool AllowUserJoin(Player player) {
			player.Init(PlayerIO.BigDB);
			if (player.banned) {
				int duration = (player.PlayerObject.GetDateTime("BannedUntil") - DateTime.Now).Days + 1;
				if (duration < 0)
					duration = -1;
				player.Send(MessageID.PLAYER_BANNED, player.bannedReason, duration);
				//player.Disconnect();
				return false;
			}

			return base.AllowUserJoin(player);
		}

		private Object thisLock = new Object();
		public override void UserJoined(Player player) {
			try {
				Message postJoin = Message.Create(MessageID.LOBBY_POST_JOIN);
				//player.Init(false, PlayerIO.BigDB);

				lock (lobbyPlayers) {
					postJoin.Add(lobbyPlayers.Count);
					foreach (Player p in lobbyPlayers) {
						if (p.Id != player.Id) {
							postJoin.Add(p.Id);
							postJoin.Add(p.username);
							postJoin.Add(p.level);
							postJoin.Add(!p.hidePremium && p.isPremium());
							postJoin.Add(p.moderator);
							postJoin.Add(p.isGuest ? "" : p.PlayerObject.Key);
							postJoin.Add((int)p.rankingNew);
						}
					}
					lobbyPlayers.Add(player);
				}
				player.Send(postJoin);
				Broadcast(MessageID.LOBBY_PLAYER_JOINED, player.Id, player.username, player.level, !player.hidePremium && player.isPremium(), player.moderator, player.isGuest ? "" : player.PlayerObject.Key, (int)player.rankingNew);
				player.messageTimer = AddTimer(player.messageTimerTick, 4000);
			}
			catch (Exception e) {
				PlayerIO.ErrorLog.WriteError("user " + player.username + " joined " + e.Message + " " + e.StackTrace);
			}

			player.playerEnteredRoom(this.RoomId, "", false);
		}

		public override void UserLeft(Player player) {
			try {
				Broadcast(MessageID.LOBBY_PLAYER_LEFT, player.Id);

				lock (lobbyPlayers) {
					lobbyPlayers.Remove(player);
				}

				if (player.messageTimer != null)
					player.messageTimer.Stop();
			}
			catch(Exception e) {
				PlayerIO.ErrorLog.WriteError("user left", e);
			}

			player.playerLeftRoom();
		}

		private Player findPlayerByUsername(String username) {
			username = username.ToLower();
			foreach (Player p in lobbyPlayers) {
				if (p.username.ToLower().Replace(" ", "").Equals(username)) {
					return p;
				}
			}
			return null;
		}

		private void handleModCommand(Player player, String message) {
			if (!player.moderator) return;

			string[] parts = message.Split(' ');

			switch (parts[0]) {
				case "/ban":
					if (parts.Length < 4) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "Not enough parameters, ban requires 3 parameters: name, duration (-1 for permaban) and reason");
						return;
					}

					// find user to ban
					Player playerToBan = findPlayerByUsername(parts[1]);
					if (playerToBan == null) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "User \"" + parts[1] + "\" not found.");
					}
					else {
						if (playerToBan.isGuest) break;

						//p.PlayerObject.Set("Banned", true);
						int duration;
						try {
							duration = Convert.ToInt32(parts[2]);
						}
						catch (Exception e) {
							player.Send(MessageID.MOD_COMMAND_FAILED, "Format malfunction, second parameter (duration) wasn't proper integer.");
							return;
						}

						String reason = parts[3];
						for (int i = 4; i < parts.Length; i++) {
							reason += " " + parts[i];
						}

						playerToBan.ban(duration, reason, player.username);

						playerToBan.Send(MessageID.LOBBY_KICKED, reason);

						player.Send(MessageID.MOD_COMMAND_SUCCESS, "Player banned succesfully.");
						Broadcast(MessageID.LOBBY_PLAYER_KICKED, playerToBan.username, reason);
					}
					break;
				case "/kick":
					if (parts.Length < 3) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "Not enough parameters, kick requires 2 parameters: name and reason");
						return;
					}

					Player playerToKick = findPlayerByUsername(parts[1]);
					if (playerToKick == null) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "User \"" + parts[1] + "\" not found.");
					}
					else {
						// build reason from rest of the message
						String reason = parts[2];
						for (int i = 3; i < parts.Length; i++) {
							reason += " " + parts[i];
						}
						playerToKick.Send(MessageID.LOBBY_KICKED, reason);

						Broadcast(MessageID.LOBBY_PLAYER_KICKED, playerToKick.username, reason);
					}
					break;
				case "/warn":
					if (parts.Length < 3) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "Not enough parameters, warn requires 2 parameters: name and reason");
						return;
					}

					Player playerToWarn = findPlayerByUsername(parts[1]);
					if (playerToWarn == null) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "User \"" + parts[1] + "\" not found.");
					}
					else {
						// build reason from rest of the message
						String reason = parts[2];
						for (int i = 3; i < parts.Length; i++) {
							reason += " " + parts[i];
						}
						playerToWarn.warn(reason, player.username);

						player.Send(MessageID.MOD_COMMAND_SUCCESS, "Warn entry added succesfully.");
					}
					break;

				case "/list":
					Player playerToList = findPlayerByUsername(parts[1]);
					if (playerToList == null) {
						player.Send(MessageID.MOD_COMMAND_FAILED, "User \"" + parts[1] + "\" not found.");
					}
					else {
						player.Send(MessageID.MOD_COMMAND_SUCCESS, playerToList.list());
					}
					break;
				case "/listips":
					String ipList = "";
					foreach (Player p in lobbyPlayers) {
						ipList += p.username + " - " + p.IPAddress.ToString() + "\n";
					}
					player.Send(MessageID.MOD_COMMAND_SUCCESS, ipList);
					break;
			}
		}

		public override void GotMessage(Player player, Message m) {
			try {
				switch (m.Type) {
					case MessageID.LOBBY_MESSAGE_SEND:
						if (m.GetString(0).StartsWith("/")) {
							handleModCommand(player, m.GetString(0));
						}
						else {
							if (player.messageCounter > 2) {
								player.Send(MessageID.LOBBY_TOO_MANY_MESSAGES);
							}
							else {
								player.messageCounter++;

								Console.WriteLine(player.username + " " + m.GetString(0) + " " + (!player.hidePremium && player.isPremium()).ToString());
								Broadcast(MessageID.LOBBY_MESSAGE_SEND, player.username, m.GetString(0), !player.hidePremium && player.isPremium(), player.moderator);
							}
						}
						break;
				}
			}
			catch (Exception e) {
				PlayerIO.ErrorLog.WriteError("got message", e);
			}
		}
	}
}
