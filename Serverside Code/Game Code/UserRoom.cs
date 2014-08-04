using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.IO;
using PlayerIO.GameLibrary;

namespace Wargrounds {
	[RoomType("UserRoom2.4")]
	public class UserRoom : Game<Player> {
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
			foreach (Player p in Players) {
				if (p != player) {
					p.Send(MessageID.REMOTE_LOGIN);
					p.Disconnect();
					//return false;
				}
			}
			return true;
		}

		public override void UserJoined(Player player) {
			
			player.PlayerObject.Set("LastTimeLogged", DateTime.Now);
			//player.PlayerObject.Set("BetaTester", true);
			//player.PlayerObject.Save();
			DateTime lastRewardDate = player.PlayerObject.GetDateTime("LastShardsReward");
			int consecutiveDays = player.PlayerObject.GetInt("ConsecutiveVisits");
			// dont do anything if last reward was less than 20 hours from now
			double hours = (DateTime.Now - lastRewardDate).TotalHours;
			if (hours > 20) {
				if (hours > 48) {
					// reset reward if we are too late
					consecutiveDays = 0;
				}
				consecutiveDays++;
				player.PlayerObject.Set("ConsecutiveVisits", consecutiveDays);

				int reward = consecutiveDays * 10;
				if (reward > 50) {
					reward = 50;
				}
				player.PlayerObject.Set("LastShardsReward", DateTime.Now);
				player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") + reward);
				player.Send(MessageID.USER_GET_LOGIN_REWARD, consecutiveDays, reward);
			}

			if (!player.PlayerObject.Contains("SavedUsername")) {
				DatabaseObject newObject = new DatabaseObject();
				newObject.Set("UsernameLowercase", player.username.ToLower());
				newObject.Set("Key", player.PlayerObject.Key);
				PlayerIO.BigDB.CreateObject("Usernames", player.username, newObject, delegate(DatabaseObject obj) {
					player.PlayerObject.Set("SavedUsername", true);
					player.savePlayerData();
				}, delegate(PlayerIOError error) {});
			}

			// check if any of invited players started playing
			int invitesReceived = 0;
			DatabaseArray invites = player.PlayerObject.GetArray("FBInvites");
			string[] keys = new string[invites.Count];
			for (int j = 0; j < invites.Count; j++) {
				keys[j] = "fb" + invites.GetString(j);
			}
			// remove already playing players
			if (invites.Count > 0) {
				PlayerIO.BigDB.LoadKeys("PlayerObjects", keys, delegate(DatabaseObject[] arr) {
					foreach (DatabaseObject dbo in arr) {
						if (dbo != null) {
							for (int j = invites.Count - 1; j >= 0; j--) {
								if (keys[j] == dbo.Key) {
									invites.RemoveAt(j);
									invitesReceived++;
								}
							}
						}
					}
					if (invitesReceived > 0) {
						player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") + invitesReceived * 100);
						player.Send(MessageID.FB_INVITES_REWARD, invitesReceived * 100);
					}
					player.savePlayerData();
				});
			}
			else {
				player.savePlayerData();
			}

			player.playerGotOnline();
			//player.savePlayerData();
		}

		public override void UserLeft(Player player) {
			base.UserLeft(player);

			player.playerGotOffline();
		}

		public override void GotMessage(Player player, Message message) {
			switch(message.Type) {
				case MessageID.ITEM_BUY: {
						if (message.GetBoolean(1)) {
							buyItem(player, message.GetString(0), false, 0);
						}
						else {
							PlayerIO.BigDB.Load("PayVaultItems", message.GetString(0), delegate(DatabaseObject dbo) {
								player.RefreshPlayerObject(delegate() {
									buyItem(player, message.GetString(0), true, dbo.GetInt("PriceShards"));
								});
							});
						}
					}
					break;
				case MessageID.USER_SET_RACE:
					player.setRace(message.GetInt(0));
					break;
				case MessageID.USER_SET_BG:
					player.setBackground(message.GetInt(0));
					break;
				case MessageID.USER_SET_USERNAME:
					if (!player.PlayerObject.Contains("Username")) {
						player.PlayerObject.Set("Username", message.GetString(0));
						player.savePlayerData();
						player.username = message.GetString(0);
					}
					player.Send(MessageID.USER_USERNAME_SET);
					break;
				case MessageID.GAME_TUTORIAL_FINISHED:
					player.tutorialFinished();
					break;

				case MessageID.SOCIAL_GET_PLAYER_INFO:
					SocialGetPlayerInfo(player, message.GetString(0));
					break;
				case MessageID.SOCIAL_ADD_FRIEND: 
					SocialAddFriend(player, message.GetString(0));
					break;
				case MessageID.SOCIAL_ADD_TO_BLACKLIST:
					SocialAddToBlacklist(player, message.GetString(0), message.GetString(1));
					break;
				case MessageID.SOCIAL_REMOVE_FROM_BLACKLIST:
					SocialRemoveFromBlacklist(player, message.GetString(0));
					break;
				case MessageID.SOCIAL_GET_FRIENDLIST:
					SocialGetFriendList(player);
					break;
				case MessageID.SOCIAL_REMOVE_FROM_FRIENDLIST:
					SocialRemoveFromFriendlist(player, message.GetString(0));
					break;
				case MessageID.SOCIAL_GET_PLAYER_PROFILE:
					string userId = message.GetString(0);
					if (userId != "")
						SocialGetUserDetails(player, userId);
					else {
						string username = message.GetString(1);
						if(username != "") 
							PlayerIO.BigDB.LoadSingle("Usernames", "UsernameLowercase", new object[]{username.ToLower()}, delegate(DatabaseObject userObject) {
								if (userObject == null) {
									Message m = Message.Create(MessageID.SOCIAL_GET_PLAYER_PROFILE, 1);
									player.Send(m);
								}
								else {
									userId = userObject.GetString("Key");
									SocialGetUserDetails(player, userId);
								}
							}, delegate(PlayerIOError error) {
								Message m = Message.Create(MessageID.SOCIAL_GET_PLAYER_PROFILE, 2);
								player.Send(m);
							});
					}
					break;

				// map editor stuff
				case MessageID.MAP_EDITOR_SAVE: 
					EditorSave(message, player);
					break;
				case MessageID.MAP_EDITOR_LOAD:
					EditorLoad(message, player);	
					break;
				case MessageID.MAP_EDITOR_NEW_MAP:
					EditorNewMap(message, player);
					break;
				case MessageID.MAP_EDITOR_DELETE_MAP:
					EditorDeleteMap(message, player);
					break;
				case MessageID.MAP_EDITOR_SUBMIT_MAP_NEW:
					EditorSubmitMap(message, player);
					break;
				case MessageID.REPORT_MAP:
					EditorReportMap(message, player);
					break;
				case MessageID.MAP_EDITOR_SUBMIT_MAP:
					PlayerIO.BigDB.Load("CustomMaps", message.GetString(0), delegate(DatabaseObject mapObj) {
						if (mapObj.GetString("Owner") == player.ConnectUserId) {
							if (mapObj.GetBool("ContainsErrors") || mapObj.GetInt("Status") != 0) {
								player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_RESULT, 101);
							}
							else {
								mapObj.Set("Status", 1);
								mapObj.Set("SubmitDate", DateTime.Now);
								mapObj.Save(delegate() {
									player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_RESULT, -1);
								}, delegate(PlayerIOError error) {
									player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_RESULT, error.ErrorCode);
								});
							}
						}
						else {
							player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_RESULT, 100);
						}
					}, delegate(PlayerIOError error) {
						player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_RESULT, error.ErrorCode);
					});
					break;
				case MessageID.MAP_EDITOR_ALLOW_MAP:
					EditorAllowMap(message, player);
					break;
				case MessageID.MAP_EDITOR_DENY_MAP:
					EditorDenyMap(message, player);
					break;
				case MessageID.MAP_EDITOR_BAN:
					EditorBan(message, player);
					break;
				case MessageID.USER_SET_HIDE_PREMIUM:
					player.PlayerObject.Set("HidePremium", message.GetBoolean(0));
					player.savePlayerData();
					break;
				case MessageID.USER_SET_PUBLIC_PROFILE:
					player.PlayerObject.Set("PublicProfile", message.GetBoolean(0));
					player.savePlayerData();
					break;
				case MessageID.LOBBY_MAP_RATED: {
						bool like = message.GetBoolean(1);
						String mapKey = message.GetString(0);
						rateMap(player, like, mapKey);
						
					}
					break;
				case MessageID.ACHIEVEMENT_HOWTOPLAY_VISITED:
					player.achievManager.howToPlayVisited();
					break;
			}
		}

		private void rateMap(Player player, bool like, string mapKey) {
			PlayerIO.BigDB.Load("CustomMaps", mapKey, delegate(DatabaseObject mapObj) {
				DatabaseArray likedMaps = player.PlayerObject.GetArray("LikedMaps");
				DatabaseArray dislikedMaps = player.PlayerObject.GetArray("DislikedMaps");
				// check if we liked/disliked this map before
				int liked = -1;
				int disliked = -1;
				for (int i = 0; i < likedMaps.Count; i++) {
					if (likedMaps.Contains(i) && likedMaps.GetString(i) == mapKey) {
						liked = i;
						break;
					}
				}
				for (int i = 0; i < dislikedMaps.Count; i++) {
					if (dislikedMaps.Contains(i) && dislikedMaps.GetString(i) == mapKey) {
						disliked = i;
						break;
					}
				}

				// first handle like click
				if (like) {
					// if we liked this map before, remove like
					if (liked != -1) {
						//likedMaps.RemoveAt(liked);
						if (mapObj.GetInt("LikeCount") > 0)
							mapObj.Set("LikeCount", mapObj.GetInt("LikeCount") - 1);
					}
					else {
						// add like if we didn't like it before
						//likedMaps.Add(mapKey);
						mapObj.Set("LikeCount", mapObj.GetInt("LikeCount") + 1);

						// if we disliked map before, remove dislike
						if (disliked != -1) {
							//dislikedMaps.RemoveAt(disliked);
							if (mapObj.GetInt("DislikeCount") > 0)
								mapObj.Set("DislikeCount", mapObj.GetInt("DislikeCount") - 1);
						}
					}
				}
				// dislike is same as like, but in reverse
				else {
					if (disliked != -1) {
						//dislikedMaps.RemoveAt(disliked);
						if (mapObj.GetInt("DislikeCount") > 0)
							mapObj.Set("DislikeCount", mapObj.GetInt("DislikeCount") - 1);
					}
					else {
						//dislikedMaps.Add(mapKey);
						mapObj.Set("DislikeCount", mapObj.GetInt("DislikeCount") + 1);
						if (liked != -1) {
							//likedMaps.RemoveAt(liked);
							if (mapObj.GetInt("LikeCount") > 0)
								mapObj.Set("LikeCount", mapObj.GetInt("LikeCount") - 1);
						}
					}
				}

				float likeCount = (float)mapObj.GetInt("LikeCount");
				float dislikeCount = (float)mapObj.GetInt("DislikeCount");
				float numVotes = likeCount + dislikeCount;
				if (numVotes == 0) {
					mapObj.Set("LikeRatio", 0.5);
				}
				else {
					float rating = likeCount / numVotes;
					mapObj.Set("LikeRatio", ((100 * 0.5) + (numVotes * rating)) / (100 + numVotes));
				}
	
				mapObj.Save(true, delegate() {
					player.RefreshPlayerObject(delegate() {
						likedMaps = player.PlayerObject.GetArray("LikedMaps");
						dislikedMaps = player.PlayerObject.GetArray("DislikedMaps");
						// check if we liked/disliked this map before
						liked = -1;
						disliked = -1;
						for (int i = 0; i < likedMaps.Count; i++) {
							if (likedMaps.Contains(i) && likedMaps.GetString(i) == mapKey) {
								liked = i;
								break;
							}
						}
						for (int i = 0; i < dislikedMaps.Count; i++) {
							if (dislikedMaps.Contains(i) && dislikedMaps.GetString(i) == mapKey) {
								disliked = i;
								break;
							}
						}

						if (like) {
							// if we liked this map before, remove like
							if (liked != -1) {
								likedMaps.RemoveAt(liked);
							}
							else {
								// add like if we didn't like it before
								likedMaps.Add(mapKey);
								if (disliked != -1) {
									dislikedMaps.RemoveAt(disliked);
								}
							}
						}
						// dislike is same as like, but in reverse
						else {
							if (disliked != -1) {
								dislikedMaps.RemoveAt(disliked);
							}
							else {
								dislikedMaps.Add(mapKey);
								if (liked != -1) {
									likedMaps.RemoveAt(liked);
								}
							}
						}

						player.savePlayerData();
					});

				}, delegate(PlayerIOError error) {
					rateMap(player, like, mapKey);
				});
			});
		}

		private void buyItem(Player player, String itemName, bool withShards, int shardsPrice) {
			switch (itemName) {
				case "PremiumWeek":
					if (withShards) {
						if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
							player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								if ((player.PlayerObject.GetDateTime("PremiumUntil") - DateTime.Now).Seconds > 0) {
									player.PlayerObject.Set("PremiumUntil", player.PlayerObject.GetDateTime("PremiumUntil").AddDays(7));
								}
								else {
									player.PlayerObject.Set("PremiumUntil", DateTime.Now.AddDays(7));
								} 
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
						else {
							Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
						}
					}
					else {
						player.PayVault.Buy(false, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
							if ((player.PlayerObject.GetDateTime("PremiumUntil") - DateTime.Now).Seconds > 0) {
								player.PlayerObject.Set("PremiumUntil", player.PlayerObject.GetDateTime("PremiumUntil").AddDays(7));
							}
							else {
								player.PlayerObject.Set("PremiumUntil", DateTime.Now.AddDays(7));
							}
							player.savePlayerData();
							onSuccessfulPurchase(player);
						}, delegate(PlayerIOError error) { onFailedPurchase(error); });
					}
					break;
				case "PremiumMonth":
					if (withShards) {
						if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
							player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								if ((player.PlayerObject.GetDateTime("PremiumUntil") - DateTime.Now).Seconds > 0) {
									player.PlayerObject.Set("PremiumUntil", player.PlayerObject.GetDateTime("PremiumUntil").AddDays(30));
								}
								else {
									player.PlayerObject.Set("PremiumUntil", DateTime.Now.AddDays(30));
								}
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
						else {
							Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
						}
					}
					else {
						player.PayVault.Buy(false, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
							onSuccessfulPurchase(player);
							if ((player.PlayerObject.GetDateTime("PremiumUntil") - DateTime.Now).Seconds > 0) {
								player.PlayerObject.Set("PremiumUntil", player.PlayerObject.GetDateTime("PremiumUntil").AddDays(30));
							}
							else {
								player.PlayerObject.Set("PremiumUntil", DateTime.Now.AddDays(30));
							}
							player.savePlayerData();
						}, delegate(PlayerIOError error) { onFailedPurchase(error); });
					}
					break;
				case "Premium3Months":
					if (withShards) {
						if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
							player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								if ((player.PlayerObject.GetDateTime("PremiumUntil") - DateTime.Now).Seconds > 0) {
									player.PlayerObject.Set("PremiumUntil", player.PlayerObject.GetDateTime("PremiumUntil").AddDays(90));
								}
								else {
									player.PlayerObject.Set("PremiumUntil", DateTime.Now.AddDays(90));
								}
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
						else {
							Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
						}
					}
					else {
						player.PayVault.Buy(false, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
							onSuccessfulPurchase(player);
							if ((player.PlayerObject.GetDateTime("PremiumUntil") - DateTime.Now).Seconds > 0) {
								player.PlayerObject.Set("PremiumUntil", player.PlayerObject.GetDateTime("PremiumUntil").AddDays(90));
							}
							else {
								player.PlayerObject.Set("PremiumUntil", DateTime.Now.AddDays(90));
							}
							player.savePlayerData();
						}, delegate(PlayerIOError error) { onFailedPurchase(error); });
					}
					break;
				case "PremiumLifetime":
					if (withShards) {
						if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
							player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								player.PlayerObject.Set("PremiumUntil", DateTime.Now.AddYears(100));
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
						else {
							Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
						}
					}
					else {
						player.PayVault.Buy(true, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
							player.PlayerObject.Set("PremiumUntil", DateTime.Now.AddYears(100));
							player.savePlayerData();
							onSuccessfulPurchase(player);
						}, delegate(PlayerIOError error) { onFailedPurchase(error); });
					}
					break;
				case "AttackBoostPack10":
				case "AttackBoostPack50":
				case "AttackBoostPack200":
				case "AttackBoostPack1000": {
						int amount = Convert.ToInt32(itemName.Substring(15));
						if (withShards) {
							if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
								player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
									player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
									player.PlayerObject.Set("AttackBoosts", player.PlayerObject.GetInt("AttackBoosts") + amount);
									player.PlayerObject.Save(delegate() {
										onSuccessfulPurchase(player);
									});
								}, delegate(PlayerIOError error) { onFailedPurchase(error); });
							}
							else {
								Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
							}
						}
						else {
							player.PayVault.Buy(true, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								player.PlayerObject.Set("AttackBoosts", player.PlayerObject.GetInt("AttackBoosts") + amount);
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
					}
					break;
				case "DefenseBoostPack10":
				case "DefenseBoostPack50":
				case "DefenseBoostPack200":
				case "DefenseBoostPack1000": {
						int amount = Convert.ToInt32(itemName.Substring(16));
						if (withShards) {
							if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
								player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
									player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
									player.PlayerObject.Set("DefenseBoosts", player.PlayerObject.GetInt("DefenseBoosts") + amount);
									player.PlayerObject.Save(delegate() {
										onSuccessfulPurchase(player);
									});
								}, delegate(PlayerIOError error) { onFailedPurchase(error); });
							}
							else {
								Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
							}
						}
						else {
							player.PayVault.Buy(true, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								player.PlayerObject.Set("DefenseBoosts", player.PlayerObject.GetInt("DefenseBoosts") + amount);
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
					}
					break;
				case "EditorDeluxe":
					if (withShards) {
						if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
							player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								player.PlayerObject.Set("EditorSlots", 5);
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
						else {
							Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
						}
					}
					else {
						player.PayVault.Buy(true, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
							player.PlayerObject.Set("EditorSlots", 5);
							player.PlayerObject.Save(delegate() {
								onSuccessfulPurchase(player);
							});
							
						}, delegate(PlayerIOError error) { onFailedPurchase(error); });
					}
					break;
				case "EditorSlot":
					if (withShards) {
						if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
							player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								player.PlayerObject.Set("EditorSlots", player.PlayerObject.GetInt("EditorSlots") + 1);
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
						else {
							Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
						}
					}
					else {
						player.PayVault.Buy(true, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
							player.PlayerObject.Set("EditorSlots", player.PlayerObject.GetInt("EditorSlots") + 1);
							player.PlayerObject.Save(delegate() {
								onSuccessfulPurchase(player);
							});
						}, delegate(PlayerIOError error) { onFailedPurchase(error); });
					}
					break;
				default:
					if(withShards) {
						if (player.PlayerObject.GetInt("Shards") >= shardsPrice) {
							player.PayVault.Give(new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() {
								player.PlayerObject.Set("Shards", player.PlayerObject.GetInt("Shards") - shardsPrice);
								player.PlayerObject.Save(delegate() {
									onSuccessfulPurchase(player);
								});
							}, delegate(PlayerIOError error) { onFailedPurchase(error); });
						}
						else {
							Broadcast(MessageID.ITEM_BUY_FAILED, "NotEnoughShards");
						}
					}
					else {
						player.PayVault.Buy(true, new BuyItemInfo[] { new BuyItemInfo(itemName) }, delegate() { onSuccessfulPurchase(player); }, delegate(PlayerIOError error) { onFailedPurchase(error); });
					}
					break;
			}
		}

		private void onSuccessfulPurchase(Player player) {
			player.RefreshPlayerObject(delegate() { });
			Broadcast(MessageID.ITEM_BOUGHT);
		}

		private void onFailedPurchase(PlayerIOError error) {
			Broadcast(MessageID.ITEM_BUY_FAILED, error.ErrorCode.ToString());
		}

		private byte getMapSize(int width, int height) {
			int avg = (width + height) / 2;
			if (avg < 20) {
				return 0;
			}
			if (avg < 35) {
				return 1;
			}
			if (avg < 50) {
				return 2;
			}
			if (avg < 80) {
				return 3;
			}
			if (avg < 120) {
				return 4;
			}
			return 5;
		}

		private int getRegionCount(byte[] data) {
			int maxRegion = 0;

			for (int i = 0; i < data.Length; ++i) {
				int value = data[i];
				if (value > maxRegion)
					maxRegion = value;
			}

			return maxRegion;
		}

		private bool mapContainsErrors(byte[] data, bool deluxe) {
			int maxRegion = getRegionCount(data);

			/*for (int i = 0; i < width * height; ++i) {
				int value = data[i % width + (i / width) * width];
				if (value == 255) {
					return true;
				}
				if (value > maxRegion)
					maxRegion = value;
			}*/

			if (deluxe) {
				if (maxRegion > 250) return true;
			}
			else {
				if (maxRegion > 40) return true;
			}

			return false;
		}

		private byte[] shrinkMap(byte[] data, ref int width, ref int height) {
			// find map boundaries
			int minX = 200;
			int minY = 200;
			int maxX = 0;
			int maxY = 0;
			for(int i = 0; i < data.Length; i++) {
				int tileX = i % width;
				int tileY = i / width;
				if(data[i] != 0) {
					if(tileX < minX) minX = tileX;
					if(tileX > maxX) maxX = tileX;
					if(tileY < minY) minY = tileY;
					if(tileY > maxY) maxY = tileY;
				}
			} 

			// align start of map to even number so it doesn't break (hex lines offsets
			if(minY % 2 == 1) minY--;
			int mapWidth = maxX - minX + 1;
			int mapHeight = maxY - minY + 1;
			
			byte[] croppedTiles = new byte[mapWidth * mapHeight];
			for(int i = 0; i < mapWidth * mapHeight; i++) {
				croppedTiles[i] = data[(i % mapWidth + minX) + (int)(i / mapWidth + minY) * width];
			}

			width = mapWidth;
			height = mapHeight;

			return croppedTiles;
		}

		private void SocialGetPlayerInfo(Player player, String playerKey) {
			PlayerIO.BigDB.Load("PlayerObjects", playerKey, delegate(DatabaseObject playerObject)
			{
				//Console.WriteLine(playerObject.Key);
				Message m = Message.Create(MessageID.SOCIAL_GET_PLAYER_INFO);
				DatabaseObject stats = playerObject.GetObject("Stats");
				m.Add(stats.GetInt("TotalMatches"));
				m.Add(stats.GetInt("TotalWins"));

				DatabaseObject friendObject = null;
				DatabaseArray friends = player.PlayerObject.GetArray("Friends");
				foreach (DatabaseObject friend in friends) {
					if (friend.Contains(BigDBID.SOCIAL_FRIENDS_CONNECTID) && friend.GetString(BigDBID.SOCIAL_FRIENDS_CONNECTID) == playerKey) {
						friendObject = friend;
						break;
					}
				}

				m.Add(friendObject != null);

				DatabaseObject blacklistObject = null;
				DatabaseArray blacklist = player.PlayerObject.GetArray("Blacklist");
				foreach (DatabaseObject p in blacklist) {
					if (p.Contains(BigDBID.SOCIAL_BLACKLIST_CONNECTID) && p.GetString(BigDBID.SOCIAL_BLACKLIST_CONNECTID) == playerKey) {
						blacklistObject = p;
						break;
					}
				}

				m.Add(blacklistObject != null);

				player.Send(m);
			});
		}

		private void SocialAddFriend(Player player, String playerKey) {
			DatabaseObject friendObject = null;
			DatabaseArray friends = player.PlayerObject.GetArray("Friends");
			foreach (DatabaseObject friend in friends) {
				if (friend.Contains(BigDBID.SOCIAL_FRIENDS_CONNECTID) && friend.GetString(BigDBID.SOCIAL_FRIENDS_CONNECTID) == playerKey) {
					friendObject = friend;
					break;
				}
			}

			DatabaseObject blacklistObject = null;
			DatabaseArray blacklist = player.PlayerObject.GetArray("Blacklist");
			foreach (DatabaseObject p in blacklist) {
				if (p.Contains(BigDBID.SOCIAL_BLACKLIST_CONNECTID) && p.GetString(BigDBID.SOCIAL_BLACKLIST_CONNECTID) == playerKey) {
					blacklistObject = p;
					break;
				}
			}

			if (friendObject == null) {
				PlayerIO.BigDB.Load("PlayerObjects", playerKey, delegate(DatabaseObject playerObject)
				{
					DatabaseObject newFriend = new DatabaseObject();
					newFriend.Set(BigDBID.SOCIAL_FRIENDS_NAME, playerObject.GetString("Username"));
					newFriend.Set(BigDBID.SOCIAL_FRIENDS_CONNECTID, playerKey);
					friends.Add(newFriend);

					player.PlayerObject.Save(delegate()
					{
						player.Send(MessageID.SOCIAL_ADD_FRIEND, true, true, blacklistObject != null);
					}, delegate(PlayerIOError error)
					{
						player.Send(MessageID.SOCIAL_ADD_FRIEND, false, false, blacklistObject != null);
					});
				});
			}
			else {
				player.Send(MessageID.SOCIAL_ADD_FRIEND, true, true, blacklistObject != null);
			}
		}

		private void SocialAddToBlacklist(Player player, String playerKey, String reason) {
			DatabaseObject friendObject = null;
			DatabaseArray friends = player.PlayerObject.GetArray("Friends");
			foreach (DatabaseObject friend in friends) {
				if (friend.Contains(BigDBID.SOCIAL_FRIENDS_CONNECTID) && friend.GetString(BigDBID.SOCIAL_FRIENDS_CONNECTID) == playerKey) {
					friendObject = friend;
					break;
				}
			}

			DatabaseObject blacklistObject = null;
			DatabaseArray blacklist = player.PlayerObject.GetArray("Blacklist");
			foreach (DatabaseObject p in blacklist) {
				if (p.Contains(BigDBID.SOCIAL_BLACKLIST_CONNECTID) && p.GetString(BigDBID.SOCIAL_BLACKLIST_CONNECTID) == playerKey) {
					blacklistObject = p;
					break;
				}
			}

			if (blacklistObject == null) {
				PlayerIO.BigDB.Load("PlayerObjects", playerKey, delegate(DatabaseObject playerObject)
				{
					DatabaseObject newBlacklist = new DatabaseObject();
					newBlacklist.Set(BigDBID.SOCIAL_BLACKLIST_NAME, playerObject.GetString("Username"));
					newBlacklist.Set(BigDBID.SOCIAL_BLACKLIST_CONNECTID, playerKey);
					newBlacklist.Set(BigDBID.SOCIAL_BLACKLIST_REASON, reason);
					blacklist.Add(newBlacklist);

					player.PlayerObject.Save(delegate()
					{
						player.Send(MessageID.SOCIAL_ADD_TO_BLACKLIST, true, friendObject != null, true, playerKey, playerObject.GetString("Username"), reason);
					}, delegate(PlayerIOError error)
					{
						player.Send(MessageID.SOCIAL_ADD_TO_BLACKLIST, false, friendObject != null, false);
					});
				});
			}
			else {
				player.Send(MessageID.SOCIAL_ADD_TO_BLACKLIST, true, friendObject != null, true, playerKey, blacklistObject.GetString(BigDBID.SOCIAL_BLACKLIST_NAME), reason);
			}
		}

		private void SocialRemoveFromBlacklist(Player player, String playerKey) {
			DatabaseArray blacklist = player.PlayerObject.GetArray("Blacklist");
			for (int i = blacklist.Count - 1; i >= 0; i--) {
				DatabaseObject p = blacklist.GetObject(i);
				if (p != null && p.Contains(BigDBID.SOCIAL_BLACKLIST_CONNECTID) && p.GetString(BigDBID.SOCIAL_BLACKLIST_CONNECTID) == playerKey) {
					blacklist.RemoveAt(i);
					break;
				}
			}
			player.PlayerObject.Save(delegate()
			{
				player.Send(MessageID.SOCIAL_REMOVE_FROM_BLACKLIST, true, playerKey);
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.SOCIAL_REMOVE_FROM_BLACKLIST, false, playerKey);
			});
		}

		private void SocialGetFriendList(Player player) {
			//string[] keys = {};
			List<string> keys = new List<string>();
			DatabaseArray friends = player.PlayerObject.GetArray("Friends");
			foreach(DatabaseObject friend in friends) {
				if (friend.Contains(BigDBID.SOCIAL_FRIENDS_CONNECTID))
					keys.Add(friend.GetString(BigDBID.SOCIAL_FRIENDS_CONNECTID));
			}
			if (keys.Count > 0) {
				PlayerIO.BigDB.LoadKeys("PlayerObjects", keys.ToArray(), delegate(DatabaseObject[] friendsData)
				{
					Message message = Message.Create(MessageID.SOCIAL_GET_FRIENDLIST);
					message.Add(friendsData.Length);
					foreach (DatabaseObject friend in friendsData) {
						message.Add(friend.Key);
						message.Add(friend.GetString("Username"));
						message.Add(friend.GetInt("Level"));
						try {
							message.Add(friend.Contains("RankingRating") ? friend.GetFloat("RankingRating") : 1500);
						}
						catch (Exception e) {
							message.Add(friend.Contains("RankingRating") ? friend.GetInt("RankingRating") : 1500);
						}
						message.Add(friend.Contains("PresenceStatus") ? friend.GetInt("PresenceStatus") : 0);
						message.Add(friend.Contains("LastSeenOnline") ? (int)(friend.GetDateTime("LastSeenOnline") - new DateTime(1970, 1, 1, 0, 0, 0, 0).ToLocalTime()).TotalSeconds : 0);
						message.Add(friend.Contains("RoomName") ? friend.GetString("RoomName") : "");
						message.Add(friend.Contains("RoomId") ? friend.GetString("RoomId"): "");
					}

					player.Send(message);
				});
			}
			else {
				Message message = Message.Create(MessageID.SOCIAL_GET_FRIENDLIST, 0);
				player.Send(message);
			}
		}

		private void SocialRemoveFromFriendlist(Player player, String friendKey) {
			DatabaseArray friendlist = player.PlayerObject.GetArray("Friends");
			for (int i = friendlist.Count - 1; i >= 0; i--) {
				DatabaseObject p = friendlist.GetObject(i);
				if (p != null && p.Contains(BigDBID.SOCIAL_FRIENDS_CONNECTID) && p.GetString(BigDBID.SOCIAL_FRIENDS_CONNECTID) == friendKey) {
					friendlist.RemoveAt(i);
					break;
				}
			}

			player.PlayerObject.Save(delegate()
			{
				//player.Send(MessageID.SOCIAL_REMOVE_FROM_BLACKLIST, true, playerKey);
				SocialGetFriendList(player);
			}, delegate(PlayerIOError error)
			{
				//player.Send(MessageID.SOCIAL_REMOVE_FROM_BLACKLIST, false, playerKey);
				SocialGetFriendList(player);
			});
		}

		private void SocialGetUserDetails(Player player, String userKey) {
			PlayerIO.BigDB.Load("PlayerObjects", userKey, delegate(DatabaseObject userObject)
			{
				bool profileIsPublic = userObject.GetBool("PublicProfile", false);

				Message message = Message.Create(MessageID.SOCIAL_GET_PLAYER_PROFILE);
				message.Add(0);		// everything is ok
				message.Add(userKey);
				message.Add(userObject.GetString("Username"));
				try {
					message.Add(userObject.GetFloat("RankingRating", 0));
				}
				catch (Exception e) {
					message.Add(userObject.GetInt("RankingRating", 0));
				}
				message.Add(userObject.GetInt("Level"));

				bool isFriend = false;
				DatabaseArray friends = player.PlayerObject.GetArray("Friends");
				foreach (DatabaseObject friend in friends) {
					if (friend.Contains(BigDBID.SOCIAL_FRIENDS_CONNECTID) && friend.GetString(BigDBID.SOCIAL_FRIENDS_CONNECTID) == userKey) {
						isFriend = true;
						break;
					}
				}
				message.Add(isFriend);
				//message.Add(userObject.GetInt("XP"));
				message.Add(profileIsPublic);

				if (profileIsPublic) {
					DatabaseObject stats = userObject.GetObject("Stats");
					message.Add(stats.GetInt("TotalMatches"));
					message.Add(stats.GetInt("TotalWins"));
					message.Add(stats.GetInt("RegionsConquered"));
					message.Add(stats.GetInt("RegionsLost"));
					message.Add(userObject.GetInt("AttackBoosts"));
					message.Add(userObject.GetInt("DefenseBoosts"));

					DatabaseArray maps = userObject.GetArray("Maps");
					string[] keys = new string[maps.Count];
					for (int i = 0; i < maps.Count; ++i) {
						keys[i] = maps.GetString(i);
					}
					if (keys.Length > 0) {
						PlayerIO.BigDB.LoadKeys("CustomMaps", keys, delegate(DatabaseObject[] loadedMaps)
						{
							int count = 0;
							foreach (DatabaseObject mapObj in loadedMaps) {
								if (mapObj.GetInt("Status") == 2)
									count++;
							}
							message.Add(count);
							foreach (DatabaseObject mapObj in loadedMaps) {
								if (mapObj.GetInt("Status") == 2)
									message.Add(mapObj.Key);
							}

							DatabaseObject achievs = userObject.GetObject("Achievements");
							message.Add(achievs.Properties.Count);
							foreach (String achievKey in achievs.Properties) {
								message.Add(achievKey);
							}

							player.Send(message);
						}, delegate(PlayerIOError error)
						{
							message = Message.Create(MessageID.SOCIAL_GET_PLAYER_PROFILE);
							message.Add(3);	// there was an error
							player.Send(message);
						});
					}
					else {
						message.Add(0);

						DatabaseObject achievs = userObject.GetObject("Achievements");
						message.Add(achievs.Properties.Count);
						foreach (String achievKey in achievs.Properties) {
							message.Add(achievKey);
						}

						player.Send(message);
					}
				}
				else {
					player.Send(message);
				}
				
			}, delegate(PlayerIOError error)
			{
				Message message = Message.Create(MessageID.SOCIAL_GET_PLAYER_PROFILE);
				message.Add(2);	// there was an error
				player.Send(message);
			});
		}

		private void EditorSave(Message message, Player player) {
			String mapKey = message.GetString(0);
			String mapName = message.GetString(1);
			int mapWidth = message.GetInt(2);
			int mapHeight = message.GetInt(3);
			byte[] tiles = message.GetByteArray(4);
			bool containsErrors = message.GetBoolean(5);
			containsErrors |= mapContainsErrors(tiles, player.PayVault.Has("EditorDeluxe"));
			PlayerIO.BigDB.Load("CustomMaps", mapKey, delegate(DatabaseObject map)
			{
				map.Set("Name", mapName);
				map.Set("ContainsErrors", containsErrors);
				map.Set("Status", 0);
				map.Set("RegionCount", getRegionCount(tiles));
				map.Set("MapSize", getMapSize(mapWidth, mapHeight));
				map.Save(delegate()
				{
					PlayerIO.BigDB.Load("CustomMapsData", mapKey, delegate(DatabaseObject mapData)
					{
						mapData.Set("Width", mapWidth);
						mapData.Set("Height", mapHeight);
						mapData.Set("MapData", tiles);
						mapData.Save(delegate()
						{
							player.Send(MessageID.MAP_EDITOR_SAVE_SUCCESSFUL);
						}, delegate(PlayerIOError error)
						{
							player.Send(MessageID.MAP_EDITOR_SAVE_FAILED, error.Message);
						});
					});
				}, delegate(PlayerIOError error)
				{
					player.Send(MessageID.MAP_EDITOR_SAVE_FAILED, error.Message);
				});
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.MAP_EDITOR_SAVE_FAILED, error.Message);
			});
		}

		private void EditorLoad(Message message, Player player) {
			String mapKey = message.GetString(0);
			PlayerIO.BigDB.Load("CustomMaps", mapKey, delegate(DatabaseObject map)
			{
				if (map == null) {
					player.Send(MessageID.MAP_EDITOR_LOAD_FAILED, "Map not found.");
				}
				else {
					PlayerIO.BigDB.Load("CustomMapsData", mapKey, delegate(DatabaseObject mapData)
					{
						player.Send(MessageID.MAP_EDITOR_LOAD_RESULT, map.GetString("Name"), mapData.GetInt("Width"), mapData.GetInt("Height"), mapData.GetBytes("MapData"));
					});
				}

			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.MAP_EDITOR_LOAD_FAILED, error.Message);
			});
		}

		private void EditorNewMap(Message message, Player player) {
			DatabaseObject mapObject = new DatabaseObject();
			mapObject.Set("Name", message.GetString(0));
			mapObject.Set("Owner", player.PlayerObject.Key);
			mapObject.Set("OwnerName", player.username);
			mapObject.Set("ContainsErrors", true);
			mapObject.Set("LikeCount", 0);
			mapObject.Set("DislikeCount", 0);
			mapObject.Set("LikeRatio", 0.0);
			mapObject.Set("SubmitDate", DateTime.Now);
			mapObject.Set("Status", 0);
			mapObject.Set("Reports", new DatabaseArray());
			mapObject.Set("CanBeReported", true);

			byte[] data = new byte[100];
			DatabaseObject mapDataObject = new DatabaseObject();
			mapDataObject.Set("Width", 10);
			mapDataObject.Set("Height", 10);
			mapDataObject.Set("MapData", data);

			PlayerIO.BigDB.CreateObject("CustomMaps", null, mapObject, delegate(DatabaseObject obj)
			{
				player.PlayerObject.GetArray("Maps").Add(obj.Key);
				player.savePlayerData();
				PlayerIO.BigDB.CreateObject("CustomMapsData", obj.Key, mapDataObject, delegate(DatabaseObject dataObj)
				{
					player.Send(MessageID.MAP_EDITOR_NEW_MAP_RESULT, -1, obj.Key);
				}, delegate(PlayerIOError error)
				{
					player.Send(MessageID.MAP_EDITOR_NEW_MAP_RESULT, error.ErrorCode);
				});
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.MAP_EDITOR_NEW_MAP_RESULT, error.ErrorCode);
			});
		}

		private void EditorDeleteMap(Message message, Player player) {
			PlayerIO.BigDB.Load("CustomMaps", message.GetString(0), delegate(DatabaseObject mapObj)
			{
				if (mapObj.GetString("Owner") == player.ConnectUserId) {
					string[] keys = { message.GetString(0) };
					PlayerIO.BigDB.DeleteKeys("CustomMaps", keys, delegate()
					{
						PlayerIO.BigDB.DeleteKeys("CustomMapsData", keys, delegate()
						{
							DatabaseArray maps = player.PlayerObject.GetArray("Maps");
							String key = message.GetString(0);
							for (int i = 0; i < maps.Count; ++i) {
								if (maps.GetString(i) == key) {
									maps.RemoveAt(i);
									break;
								}
							}
							player.PlayerObject.Save(delegate()
							{
								player.Send(MessageID.MAP_EDITOR_DELETE_MAP_RESULT, -1);
							}, delegate(PlayerIOError error)
							{
								player.Send(MessageID.MAP_EDITOR_DELETE_MAP_RESULT, error.ErrorCode);
							});
						}, delegate(PlayerIOError error)
						{
							player.Send(MessageID.MAP_EDITOR_DELETE_MAP_RESULT, error.ErrorCode);
						});
					}, delegate(PlayerIOError error)
					{
						player.Send(MessageID.MAP_EDITOR_DELETE_MAP_RESULT, error.ErrorCode);
					});
				}
				else {
					player.Send(MessageID.MAP_EDITOR_DELETE_MAP_RESULT, 100);
				}
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.MAP_EDITOR_DELETE_MAP_RESULT, error.ErrorCode);
			});
		}

		private void EditorSubmitMap(Message message, Player player) {
			PlayerIO.BigDB.Load("CustomMaps", message.GetString(0), delegate(DatabaseObject mapObj)
			{
				if (mapObj.GetString("Owner") == player.ConnectUserId) {
					if (mapObj.GetBool("ContainsErrors") || mapObj.GetInt("Status") != 0) {
						player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, 101);
					}
					else {
						PlayerIO.BigDB.Load("CustomMapsData", message.GetString(0), delegate(DatabaseObject mapDataObj)
						{
							// check if map is valid
							byte[] tiles = mapDataObj.GetBytes("MapData");
							int mapWidth = mapDataObj.GetInt("Width");
							int mapHeight = mapDataObj.GetInt("Height");
							MEMap map = new MEMap(mapWidth, mapHeight, tiles, player.PayVault.Has("EditorDeluxe"));
							MEMap.MapResult result = map.checkMap();
							Console.WriteLine("Map check result: " + result);

							if (result != MEMap.MapResult.MAP_OK) {
								player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, 1000);
							}
							else {
								// create map preview
								string base64String = System.Convert.ToBase64String(map.tiles, 0, map.tiles.Length);
								Dictionary<string, string> postParams = new Dictionary<string, string>();
								postParams.Add("mapName", message.GetString(0));
								postParams.Add("w", map.width.ToString());
								postParams.Add("h", map.width.ToString());
								postParams.Add("mapData", base64String);
								PlayerIO.Web.Post("http://vortexwars.com/vwmapgen.php", postParams, delegate(HttpResponse response)
								{
									if (response.StatusCode == 200) {
										if (response.Text == "ok") {
											mapObj.Set("Status", 2);
											mapObj.Set("SubmitDate", DateTime.Now);
											mapObj.Set("MapSize", getMapSize(map.width, map.height));
											mapObj.Save(delegate()
											{
												player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, -1);
											}, delegate(PlayerIOError error)
											{
												player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, error.ErrorCode);
											});
										}
										else {
											player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, 200);
										}
									}
									else {
										player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, 201);
									}
								}, delegate(PlayerIOError error)
								{
									player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, error.ErrorCode);
								});
							}
						}, delegate(PlayerIOError error)
						{
							player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, error.ErrorCode);
						});
					}
				}
				else {
					player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, 100);
				}
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.MAP_EDITOR_SUBMIT_MAP_NEW, error.ErrorCode);
			});
		}

		private void EditorReportMap(Message message, Player player) {
			PlayerIO.BigDB.Load("CustomMaps", message.GetString(0), delegate(DatabaseObject mapObj)
			{
				
				if (!mapObj.Contains("CanBeReported")) mapObj.Set("CanBeReported", true);
				if (!mapObj.Contains("Reports")) mapObj.Set("Reports", new DatabaseArray());
			
				if (mapObj.GetBool("CanBeReported")) {
					DatabaseArray reports = mapObj.GetArray("Reports");
					bool alreadyReported = false;
					for (int i = 0; i < reports.Count; i++) {
						if (reports.GetString(i) == player.ConnectUserId) {
							alreadyReported = true;
							break;
						}
					}
					if (alreadyReported || reports.Count >= 5) {
						player.Send(MessageID.REPORT_MAP, 0);
						return;
					}

					reports.Add(player.ConnectUserId);
					if (reports.Count >= 5) {
						mapObj.Set("Status", 4);
					}
					//mapObj.Set("Reports", reports);
					mapObj.Save(delegate()
					{
						player.Send(MessageID.REPORT_MAP, 0);
					}, delegate(PlayerIOError error)
					{
						player.Send(MessageID.REPORT_MAP, error.ErrorCode);
					});
				}
				else {
					// if the map can't be reported (it was reported before and considered ok) we behave as if we reported it normally
					player.Send(MessageID.REPORT_MAP, 0);
				}
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.REPORT_MAP, error.ErrorCode);
			});
		}

		private void EditorAllowMap(Message message, Player player) {
			if (!player.moderator) return;

			PlayerIO.BigDB.Load("CustomMapsData", message.GetString(0), delegate(DatabaseObject mapObj)
			{
				byte[] mapData = mapObj.GetBytes("MapData");
				int width = mapObj.GetInt("Width");
				int height = mapObj.GetInt("Height");

				mapData = shrinkMap(mapData, ref width, ref height);

				mapObj.Set("MapData", mapData);
				mapObj.Set("Width", width);
				mapObj.Set("Height", height);

				mapObj.Save(delegate()
				{
					PlayerIO.BigDB.Load("CustomMaps", message.GetString(0), delegate(DatabaseObject mapObj2)
					{
						mapObj2.Set("Status", 2);
						mapObj2.Set("SubmitDate", DateTime.Now);
						mapObj2.Set("MapSize", getMapSize(width, height));
						if (mapObj2.Contains("CanBeReported")) {
							mapObj2.Set("CanBeReported", false);
							mapObj2.GetArray("Reports").Clear();
						}
						mapObj2.Save(delegate()
						{
							player.Send(MessageID.MAP_EDITOR_ALLOW_MAP_RESULT, -1);
						}, delegate(PlayerIOError error)
						{
							player.Send(MessageID.MAP_EDITOR_ALLOW_MAP_RESULT, error.ErrorCode);
						});
					}, delegate(PlayerIOError error)
					{
						player.Send(MessageID.MAP_EDITOR_ALLOW_MAP_RESULT, error.ErrorCode);
					});
				}, delegate(PlayerIOError error)
				{
					player.Send(MessageID.MAP_EDITOR_ALLOW_MAP_RESULT, error.ErrorCode);
				});
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.MAP_EDITOR_ALLOW_MAP_RESULT, error.ErrorCode);
			});
		}

		private void EditorDenyMap(Message message, Player player) {
			if (!player.moderator) return;

			PlayerIO.BigDB.Load("CustomMaps", message.GetString(0), delegate(DatabaseObject mapObj)
			{
				mapObj.Set("Status", 3);
				mapObj.Set("DenyReason", message.GetString(1));
				if (mapObj.Contains("CanBeReported")) {
					DatabaseArray reports = mapObj.GetArray("Reports");
					reports.Clear();
					Console.WriteLine("reports: " + reports.Count);
				}

				mapObj.Save(delegate()
				{
					player.Send(MessageID.MAP_EDITOR_DENY_MAP_RESULT, -1);
				}, delegate(PlayerIOError error)
				{
					player.Send(MessageID.MAP_EDITOR_DENY_MAP_RESULT, error.ErrorCode);
				});
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.MAP_EDITOR_DENY_MAP_RESULT, error.ErrorCode);
			});
		}

		private void EditorBan(Message message, Player player) {
			if (!player.moderator) return;

			PlayerIO.BigDB.Load("CustomMaps", message.GetString(0), delegate(DatabaseObject mapObj)
			{
				PlayerIO.BigDB.Load("PlayerObjects", mapObj.GetString("Owner"), delegate(DatabaseObject obj)
				{
					obj.Set("BannedUntil", DateTime.Now.AddDays(3));

					obj.Set("BannedReason", "Inapropriate map submited");

					DatabaseObject banEntry = new DatabaseObject();
					banEntry.Set("D", DateTime.Now);
					banEntry.Set("Dur", 3);
					banEntry.Set("R", "Inapropriate map submited");
					banEntry.Set("M", player.username);

					obj.GetArray("BanHistory").Add(banEntry);

					obj.Save(delegate() {
						player.Send(MessageID.MAP_EDITOR_BAN, -1);
					}, delegate(PlayerIOError error)
					{
						player.Send(MessageID.MAP_EDITOR_BAN, error.ErrorCode);
					});
				}, delegate(PlayerIOError error)
				{
					player.Send(MessageID.MAP_EDITOR_BAN, error.ErrorCode);
				});
			}, delegate(PlayerIOError error)
			{
				player.Send(MessageID.MAP_EDITOR_BAN, error.ErrorCode);
			});
		}
	}
}
