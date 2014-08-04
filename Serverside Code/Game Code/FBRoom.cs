using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Wargrounds
{
	public class FBPlayer : BasePlayer
	{
	}

	[RoomType("FBRoom")]
	class FBRoom : Game<FBPlayer>
	{
		public override void GameStarted() {


		}

		public override void UserJoined(FBPlayer player) {
			
		}

		public override bool AllowUserJoin(FBPlayer player) {
			return base.AllowUserJoin(player);
		}

		public override void GotMessage(FBPlayer player, Message m) {
			switch (m.Type) {
				case MessageID.FB_INVITED_USERS:
					player.RefreshPlayerObject(delegate() {
						DatabaseArray invited = player.PlayerObject.GetArray("FBInvites");
						if (invited == null) {
							player.PlayerObject.Set("FBInvites", new DatabaseArray());
							invited = player.PlayerObject.GetArray("FBInvites");
						}

						int count = m.GetInt(0);
						string[] keys = new string[count];
						int keyCount = 0;
						for (uint i = 0; i < count; i++) {
							string id = m.GetString(i + 1);
							bool found = false;
							for (int j = 0; j < invited.Count; j++) {
								if (id == invited.GetString(j)) {
									found = true;
									break;
								}
							}
							if (!found) {
								//invited.Add(id);
								keys[keyCount++] = id;
							}
						}

						/*for (int j = 0; j < invited.Count; j++) {
							keys[j] = invited.GetString(j);
						}*/
						// remove already playing players
						PlayerIO.BigDB.LoadKeys("PlayerObjects", keys, delegate(DatabaseObject[] arr) {
							foreach (DatabaseObject dbo in arr) {
								if (dbo != null) {
									for (int j = count - 1; j >= 0; j--) {
										if ("fb" + keys[j] == dbo.Key) {
											//invited.RemoveAt(j);
											keys[j] = null;
										}
									}
								}
							}
							for (int i = 0; i < count; i++) {
								if (keys[i] != null) {
									invited.Add(keys[i]);
								}
							}
							player.PlayerObject.Save();
						});
					});
					
					break;
			}
		}

	}
}
