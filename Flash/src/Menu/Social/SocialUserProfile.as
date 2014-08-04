package Menu.Social
{
	import Errors.ErrorManager;
	
	import Game.Races.Race;
	
	import IreUtils.Input;
	import IreUtils.ResList;
	
	import Menu.ButtonHex;
	import Menu.LevelIcon;
	import Menu.Loading;
	import Menu.Lobby.BlacklistReasonPopup;
	import Menu.MainMenu.ScrollableSprite;
	import Menu.NinePatchSprite;
	import Menu.Tooltips.TextTooltip;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	
	public class SocialUserProfile extends Sprite
	{
		private var loading:Loading;
		private var userKey:String;
		private var usernameField:TextField;
		private var content:ScrollableSprite;
		
		public function SocialUserProfile(username:String = null, userKey:String = null)
		{
			super();
			
			G.userConnection.addMessageHandler(MessageID.SOCIAL_GET_PLAYER_PROFILE, onMessageReceived);
			G.userConnection.addMessageHandler(MessageID.SOCIAL_ADD_FRIEND, onMessageReceived);
			G.userConnection.addMessageHandler(MessageID.SOCIAL_ADD_TO_BLACKLIST, onMessageReceived);
			
			var line:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 410, 44);
			line.x = 420 / 2 - line.width / 2;
			line.y = 4;
			addChild(line);
			
			var label:TextField = new TextField();
			label.text = "USERNAME:";
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 4;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = line.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			line.addChild(label);
			
			var editbox:NinePatchSprite = new NinePatchSprite("9patch_editText", 186, 26);
			editbox.x = 100;
			editbox.y = line.height / 2 - editbox.height/2;
			line.addChild(editbox);
			
			usernameField = new TextField();
			usernameField.defaultTextFormat = new TextFormat("Arial", 14, -1, true);
			usernameField.type = TextFieldType.INPUT;
			usernameField.x = 8;
			usernameField.y = 4;
			usernameField.width = editbox.width - 16;
			usernameField.text = "";
			usernameField.autoSize = TextFieldAutoSize.LEFT;
			trace("1: " + usernameField.height);
			usernameField.autoSize = TextFieldAutoSize.NONE;
			//trace("2: " + usernameField.height);
			usernameField.width = editbox.width - 16;
			if(username != null)
				usernameField.text = username;
			usernameField.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 125, 125, 125, 0);
			usernameField.addEventListener(KeyboardEvent.KEY_UP, onEnterPressed, false, 0, true);
			editbox.addChild(usernameField);
			
			var button:ButtonHex = new ButtonHex("SEARCH", onStartSearch, "button_small_gold");
			button.x = line.width - button.width - 4;
			button.y = line.height / 2 - button.height / 2;
			line.addChild(button);
			
			if(userKey != null) {
				G.userConnection.send(MessageID.SOCIAL_GET_PLAYER_PROFILE, userKey, "");
				
				loading = new Loading("LOADING...", false);
				loading.x = 420 / 2 - loading.width / 2;
				loading.y = 464 / 2 - loading.height / 2;
				addChild(loading);
			}
			
			var contentWrap:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 410, 410);
			contentWrap.x = 420 / 2 - contentWrap.width / 2;
			contentWrap.y = line.height + line.y + 4;
			addChild(contentWrap);
			
			content = new ScrollableSprite(400, 400);
			content.x = 5;
			content.y = 5;
			contentWrap.addChild(content);
			content.visible = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onAddedToStage(e:Event):void {
			stage.focus = usernameField;
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onRemovedFromStage(e:Event):void {
			G.userConnection.removeMessageHandler(MessageID.SOCIAL_GET_PLAYER_PROFILE, onMessageReceived);
			G.userConnection.removeMessageHandler(MessageID.SOCIAL_ADD_FRIEND, onMessageReceived);
			G.userConnection.removeMessageHandler(MessageID.SOCIAL_ADD_TO_BLACKLIST, onMessageReceived);
			
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onEnterPressed(event:KeyboardEvent):void {
			if(event.charCode == Input.KEY_ENTER)
				onStartSearch();
		}
		
		private function onStartSearch():void {
			if(loading != null) return;
			
			if(usernameField.text.length == 0) {
				ErrorManager.showCustomError2("Username field can't be empty", "Error", 0);
				return;
			}
			
			content.removeAllItems();
			content.visible = false;
			
			G.userConnection.send(MessageID.SOCIAL_GET_PLAYER_PROFILE, "", usernameField.text);
			
			loading = new Loading("LOADING...", false);
			loading.x = 420 / 2 - loading.width / 2;
			loading.y = 464 / 2 - loading.height / 2;
			addChild(loading);
		}
		
		private function onAddFriendPressed():void {
			if(loading != null) return;
			
			content.removeAllItems();
			content.visible = false;
			
			loading = new Loading("LOADING...", false);
			loading.x = 420 / 2 - loading.width / 2;
			loading.y = 464 / 2 - loading.height / 2;
			addChild(loading);
			
			G.userConnection.send(MessageID.SOCIAL_ADD_FRIEND, userKey);
		}
		
		private function onBanPressed():void {
			G.errorSprite.addChild(new BlacklistReasonPopup(onBlacklistConfirmed));
		}
		
		private function onBlacklistConfirmed(reason:String):void {
			if(loading != null) return;
			
			content.removeAllItems();
			content.visible = false;
			
			loading = new Loading("LOADING...", false);
			loading.x = 420 / 2 - loading.width / 2;
			loading.y = 464 / 2 - loading.height / 2;
			addChild(loading);
			
			G.userConnection.send(MessageID.SOCIAL_ADD_TO_BLACKLIST, userKey, reason);
		}
		
		private function onMessageReceived(message:Message):void {
			if(message.type == MessageID.SOCIAL_ADD_FRIEND || message.type == MessageID.SOCIAL_ADD_TO_BLACKLIST) {
				G.userConnection.send(MessageID.SOCIAL_GET_PLAYER_PROFILE, userKey);
				if(message.type == MessageID.SOCIAL_ADD_TO_BLACKLIST) {
					var newEntry:Object = new Object();
					newEntry.a = message.getString(3);
					newEntry.b = message.getString(4);
					newEntry.c = message.getString(5);
					G.user.blackList.push(newEntry);
				}
			}
			else if(message.type == MessageID.SOCIAL_GET_PLAYER_PROFILE) {
				if(loading) {
					removeChild(loading);
					loading = null;
				}
				
				var index:int = 0;
				var status:int = message.getInt(index++);
				if(status == 0) {
					content.visible = true;
					
					userKey = message.getString(index++);
					var username:String = message.getString(index++);
					var ranking:int = message.getNumber(index++);
					var level:int = message.getInt(index++);
					//var xp:int = message.getInt(index++);
					var isFriend:Boolean = message.getBoolean(index++);
					var profileIsPublic:Boolean = message.getBoolean(index++);
					
					var tf:TextFormat = new TextFormat("Arial", 20, -1, true);
					
					var label:TextField = new TextField();
					label.text = username;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 20;
					label.y = 8;
					label.autoSize = TextFieldAutoSize.LEFT;
					content.addSprite(label);
					
					tf.size = 16;
					
					label = new TextField();
					label.text = "R: " + ranking;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.x = content.width - label.width - 30;
					label.y = 8;
					content.addSprite(label);
					
					tf.size = 18;
					
					label = new TextField();
					label.text = "LEVEL " + level;
					label.setTextFormat(tf);
					label.mouseEnabled = false;
					label.x = 20;
					label.y = 45;
					label.autoSize = TextFieldAutoSize.LEFT;
					content.addSprite(label);
					
					var levelIcon:LevelIcon = new LevelIcon(level);
					levelIcon.x = label.x + label.width + 8;
					levelIcon.y = label.y + label.height / 2 - levelIcon.height / 2;
					content.addSprite(levelIcon);
					
					tf.size = 14;
					
					if(!isFriend && userKey != G.user.playerObject.key) {
						var button:ButtonHex = new ButtonHex("ADD FRIEND", onAddFriendPressed, "button_small_gray");
						button.x = content.width - 20 - button.width;
						button.y = label.y + (int)(label.height / 2 - button.height / 2);
						content.addSprite(button);
					}
					
					if(!G.user.isBanned(userKey) && userKey != G.user.playerObject.key) {
						button = new ButtonHex("BAN", onBanPressed, "button_small_gray");
						button.x = levelIcon.x + levelIcon.width + 15;
						button.y = label.y + (int)(label.height / 2 - button.height / 2);
						content.addSprite(button);
					}
					
					var divider:Sprite = new Sprite();
					divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
					divider.width = 350;
					divider.y = label.y + label.height + 10;
					divider.x = (content.width - 10 ) / 2 - divider.width / 2;
					content.addSprite(divider);
					
					if(!profileIsPublic) {
						label = new TextField();
						label.text = "This user's profile is private";
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.x = 20;
						label.y = divider.y + 20;
						label.width = content.width - 50;
						label.autoSize = TextFieldAutoSize.CENTER;
						content.addSprite(label);
					}
					else {
						var totalMatches:int = message.getInt(index++);
						var totalWins:int = message.getInt(index++);
						var regionsConquered:int = message.getInt(index++);
						var regionsLost:int = message.getInt(index++);
						var attackBoosts:int = message.getInt(index++);
						var defenceBoosts:int = message.getInt(index++);
						
						tf.size = 14;
						
						label = new TextField();
						label.text = "Matches played:";
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.autoSize = TextFieldAutoSize.LEFT;
						label.x = 20;
						label.y = 94;
						content.addSprite(label);
						
						label= new TextField();
						label.text = totalMatches + "";
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.x = 170;
						label.y = 94;
						content.addSprite(label);
						
						label = new TextField();
						label.text = "Matches won:";
						label.autoSize = TextFieldAutoSize.LEFT;
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.x = 20;
						label.y = 120;
						content.addSprite(label);
						
						label= new TextField();
						label.text = totalWins + "";
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.x = 170;
						label.y = 120;
						content.addSprite(label);
						
						label = new TextField();
						label.text = "Regions conquered:";
						label.autoSize = TextFieldAutoSize.LEFT;
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.x = 20;
						label.y = 146;
						content.addSprite(label);
						
						label= new TextField();
						label.text = regionsConquered + "";
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.x = 170;
						label.y = 146;
						content.addSprite(label);
						
						label = new TextField();
						label.text = "Regions lost:";
						label.autoSize = TextFieldAutoSize.LEFT;
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.x = 20;
						label.y = 172;
						content.addSprite(label);
						
						label= new TextField();
						label.text = regionsLost + "";
						label.setTextFormat(tf);
						label.mouseEnabled = false;
						label.x = 170;
						label.y = 172;
						label.autoSize = TextFieldAutoSize.LEFT;
						content.addSprite(label);
						
						divider = new Sprite();
						divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
						divider.width = 350;
						divider.y = label.y + label.height + 6;
						divider.x = (content.width - 10 ) / 2 - divider.width / 2;
						content.addSprite(divider);
						
						var icon:Sprite = new Sprite();
						icon.addChild(ResList.GetArtResource("boost_attack_icon"));
						icon.x = 260;
						icon.y = 96;
						content.addSprite(icon);
						
						label = new TextField();
						label.text = attackBoosts + "";
						label.setTextFormat(tf);
						label.x = 274;
						label.y = 94;
						label.mouseEnabled = false;
						content.addSprite(label);
						
						icon = new Sprite();
						icon.addChild(ResList.GetArtResource("boost_defense_icon"));
						icon.x = 260;
						icon.y = 122;
						content.addSprite(icon);
						
						label = new TextField();
						label.text = defenceBoosts + "";
						label.setTextFormat(tf);
						label.x = 274;
						label.y = 120;
						label.mouseEnabled = false;
						content.addSprite(label);
						
						var mapCount:int = message.getInt(index++);
						
						tf.size = 18;
						
						label = new TextField();
						label.text = "Maps:";
						label.setTextFormat(tf);
						label.x = 20;
						label.y = divider.y + 10;
						label.autoSize = TextFieldAutoSize.LEFT;
						content.addSprite(label);
						
						var offset:int = label.y + label.height + 6;
						
						for(var i:int = 0; i < mapCount; i++) {
							var mapPreview:SocialProfileMapPreview = new SocialProfileMapPreview(message.getString(index++));
							mapPreview.x = 20 + 130 * (i % 3);
							mapPreview.y = offset + 110 * (int)(i / 3);
							mapPreview.mouseEnabled = false;
							//imageSprite.scaleX = imageSprite.scaleY = 0.5;
							content.addSprite(mapPreview);
							
							//var req:URLRequest = new URLRequest(PlayerIO.gameFS("wargrounds-pvrpqmt1ee2jwqueof8ig").getURL("/MapImages/" + message.getString(index++) + ".png"));
						}
						
						offset += 120 * (int)(Math.ceil(i / 3));
						
						divider = new Sprite();
						divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
						divider.width = 350;
						divider.y = offset + 6;
						divider.x = (content.width - 10 ) / 2 - divider.width / 2;
						content.addSprite(divider);
						
						offset += 16;
						
						label = new TextField();
						label.text = "Achievements:";
						label.setTextFormat(tf);
						label.x = 20;
						label.y = offset;
						label.autoSize = TextFieldAutoSize.LEFT;
						content.addSprite(label);
						
						offset += 30;
						
						var achievCount:int = message.getInt(index++);
						var achievPosIndex:int = 0; 
						for(i = 0; i < achievCount; i++) {
							var achievName:String = message.getString(index++);
							var achievIndex:int = -1;
							var achievLevel:int = -1;
							var achievNiceName:String = "";
							switch(achievName) {
								case "AchievementConquer50": achievIndex = 2; achievLevel = 1; achievNiceName = "Soldier"; break;
								case "AchievementConquer250": achievIndex = 2; achievLevel = 2; achievNiceName = "Chieftain"; break;
								case "AchievementConquer1000": achievIndex = 2; achievLevel = 3; achievNiceName = "Warlord"; break;
								case "AchievementConquer5000": achievIndex = 2; achievLevel = 4; achievNiceName = "Emperor"; break;
								case "AchievementConquer20000": achievIndex = 2; achievLevel = 5; achievNiceName = "Conqueror"; break;
								case "AchievementHowToPlay": achievIndex = 1; achievLevel = 1; achievNiceName = "Learning the ropes"; break;
								case "AchievementRaceWins3": achievIndex = 3; achievLevel = 1; achievNiceName = "Race-curious"; break;
								case "AchievementRaceWins5": achievIndex = 3; achievLevel = 2; achievNiceName = "Multitasker"; break;
								case "AchievementRaceWins8": achievIndex = 3; achievLevel = 3; achievNiceName = "Multiculturalist"; break;
								case "AchievementRaceWins10": achievIndex = 3; achievLevel = 4; achievNiceName = "Overlord"; break;
								case "AchievementRaceWins15": achievIndex = 3; achievLevel = 5; achievNiceName = "Master of all"; break;
								case "AchievementWins10": achievIndex = 4; achievLevel = 1; achievNiceName = "Getting the hang of it"; break;
								case "AchievementWins50": achievIndex = 4; achievLevel = 2; achievNiceName = "Noob no more"; break;
								case "AchievementWins100": achievIndex = 4; achievLevel = 3; achievNiceName = "Keep going!"; break;
								case "AchievementWins500": achievIndex = 4; achievLevel = 4; achievNiceName = "Almost pro"; break;
								case "AchievementWins2000": achievIndex = 4; achievLevel = 5; achievNiceName = "Unstoppable"; break;
								case "AchievementRollWins3": achievIndex = 5; achievLevel = 1; achievNiceName = "Lucker"; break;
								case "AchievementRollWins5": achievIndex = 5; achievLevel = 2; achievNiceName = "What are the odds?"; break;
								case "AchievementRollWins10": achievIndex = 5; achievLevel = 3; achievNiceName = "Fateweaver"; break;
							}
							if(achievIndex != -1) {
								var achievImage:Sprite = new Sprite();
								achievImage.addChild(ResList.GetArtResource("achiev_lvl" + achievLevel));
								achievImage.addChild(ResList.GetArtResource("achiev_icon" + achievIndex));
								achievImage.x = 14 + 90 * (achievPosIndex % 4);
								achievImage.y = offset + 74 * (int)(achievPosIndex / 4);
								achievImage.scaleX = achievImage.scaleY = 0.5;
								content.addSprite(achievImage);
								
								new TextTooltip(achievNiceName, achievImage);
								
								achievPosIndex++;
							}
						}
						
						offset += 74 * (int)(Math.ceil(achievPosIndex / 4)) + 6;
						
						divider = new Sprite();
						divider.addChild(ResList.GetArtResource("menu_divider_horizontal"));
						divider.width = 350;
						divider.y = offset;
						divider.x = (content.width - 10 ) / 2 - divider.width / 2;
						content.addSprite(divider);
						
						offset += 6;
						
						label = new TextField();
						label.text = "Races:";
						label.setTextFormat(tf);
						label.x = 20;
						label.y = offset;
						label.autoSize = TextFieldAutoSize.LEFT;
						content.addSprite(label);
						
						loading = new Loading("LOADING...", false);
						loading.x = 420 / 2 - loading.width / 2;
						loading.y = offset + 40;
						content.addSprite(loading);
						
						offset += 24;
						
						PlayerIO.connect(stage, G.gameID, "vault", userKey, "", "", function(client:Client):void {
							client.payVault.refresh(function():void {
								content.removeItem(loading);
								loading = null;

								var racePosIndex:int = 0;
								for(i = 0; i < 124; i++) {
									if(i == 8) i = 100;
									
									var r:Race = Race.Create(i);
									if(client.payVault.has(r.shopName)) {
										var raceSprite:Sprite = new Sprite();
										raceSprite.addChild(r.profileImage);
										raceSprite.x = 14 + 90 * (racePosIndex % 4);
										raceSprite.y = offset + 90 * (int)(racePosIndex / 4);
										raceSprite.scaleX = raceSprite.scaleY = 0.5;
										content.addSprite(raceSprite);
										
										new TextTooltip(r.name, raceSprite);
										
										racePosIndex++;
									}
								}
							}, function (error:PlayerIOError):void {
								content.removeItem(loading);
								loading = null;
							});
							
						}, function(error:PlayerIOError):void {
							content.removeItem(loading);
							loading = null;
						});
					}
				}
				else if(status == 1) {
					ErrorManager.showCustomError2("User with given name was not found", "Not Found", 0);
				}
				else {
					ErrorManager.showCustomError2("Unknown error occured while searching for user. Please try again later", "ERROR", 0);
				}
			}
		}
	}
}