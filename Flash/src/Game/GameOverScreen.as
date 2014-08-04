package Game
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.NinePatchSprite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import playerio.DatabaseObject;
	
	public class GameOverScreen extends Sprite
	{
		private var resumeButton:ButtonHex;
		private var position:int;
		
		private var gameOverSoundPlayed:Boolean = false;
		
		//protected var gameId:String;
		protected var mapId:String;
		
		protected function init(widePanel:Boolean, position:int = -1, xp:int = 0, bonus:int = 0, playersStartedCount:int = 0, shards:int = 0, prevRanking:int = 0, rankGain:int = 0):void {
			this.position = position;
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			
			var screen:NinePatchSprite;
			
			var hasShare:Boolean = false;
			if(G.user.isGuest) {
				screen = new NinePatchSprite("9patch_popup", 368, 230);	
			}
			else {
				if(position == -1) {
					screen = new NinePatchSprite("9patch_popup", 368, 160);	
				}
				else {
					hasShare = G.host == G.HOST_FACEBOOK;
					screen = new NinePatchSprite("9patch_popup", 368, 350 + (hasShare ? 40 : 0));
					
					if(mapId != "") {
						G.client.bigDB.load("CustomMaps", mapId, function(map:DatabaseObject):void {
							var ratingPanel:GameOverRatingScreen = new GameOverRatingScreen(map);
							ratingPanel.x = screen.x;
							ratingPanel.y = screen.y + screen.height;
							addChild(ratingPanel);
						});
					}
				}
			}
			if(widePanel)
				screen.x = 5 + 550 / 2 - screen.width / 2;
			else 
				screen.x = 5 + 655 / 2 - screen.width / 2;
			//screen.x = width / 2 - screen.width / 2;
			
			if(mapId == "") {
				screen.y = height / 2 - screen.height / 2;
			}
			else {
				screen.y = height / 2 - (screen.height + 90) / 2;	
			}
			addChild(screen);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			tf.align = TextFormatAlign.CENTER;
			
			var label:TextField = new TextField();
			label.text = "GAME OVER";
			label.setTextFormat(tf);
			label.width = screen.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			screen.addChild(label);
			
			var quitButton:ButtonHex = new ButtonHex("LEAVE GAME", onLeave, "button_small_gold");
			//if(position == -1)
			//	quitButton.x = screen.width / 2 - quitButton.width / 2;
			//else 
			quitButton.x = 37;
			quitButton.y = screen.height - 50;
			
			screen.addChild(quitButton);
			
			tf.size = 14;
			
			if(position == -1) {
				label = new TextField();
				label.text = "Game has ended, you can leave to the lobby.";
				label.setTextFormat(tf);
				label.multiline = true;
				label.wordWrap = true;
				label.x = 20;
				label.width = screen.width - 40;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.y = screen.height / 2 - label.height / 2;
				label.mouseEnabled = false;
				screen.addChild(label);
				
				resumeButton = new ButtonHex("WATCH GAME", onResume, "button_small_gray");
				// hack button into having correct width
				resumeButton.setText("CLOSE");
				resumeButton.x = 192;
				resumeButton.y = screen.height - 50;
				screen.addChild(resumeButton);
			}
			else {
				tf.color = 0xFF0000;
				
				var place:TextField = new TextField();
				if(position == -2) {
					place.text = "DRAW!";
				}
				else if(position == 1) {
					place.text = "YOU WON!";
				}
				else {
					place.text = "YOU FINISHED " + position + (position == 2 ? "nd" : (position == 3 ? "rd" : "th"));
				}
				place.x = 0;
				place.width = screen.width;
				place.setTextFormat(tf);
				place.autoSize = TextFieldAutoSize.CENTER;
				place.y = 48;
				place.mouseEnabled = false;
				screen.addChild(place);
				
				tf.size = 14;
				tf.color = -1;
				
				var offsetY:int = 0;
				
				/*if(hasShare) {
					var button:ButtonHex = new ButtonHex("SHARE", function():void { onSharePressed(position); }, "button_small_blue");
					button.x = screen.width / 2 - button.width / 2;
					button.y = 78;
					screen.addChild(button);
					
					offsetY = 40;
				}*/
				
				if(G.user.isGuest) {
					label = new TextField();
					label.text = "You need to register to receive XP";
					label.setTextFormat(tf);
					label.x = 20;
					label.width = screen.width - 40;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.y = screen.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					screen.addChild(label);
				}
				else {
					var line:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 283, 30);
					line.x = screen.width / 2 - line.width / 2;
					line.y = 76 + offsetY;
					screen.addChild(line);
					
					tf.bold = false;
					
					label = new TextField();
					label.text = "XP reward:";
					label.setTextFormat(tf);
					label.width = 150;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					label = new TextField();
					label.text = xp.toString();
					label.setTextFormat(tf);
					label.width = 90;
					label.x = 160;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					line = new NinePatchSprite("9patch_emboss_panel", 282, 30);
					line.x = screen.width / 2 - line.width / 2;
					line.y = 112 + offsetY;
					screen.addChild(line);
					
					label = new TextField();
					label.text = "Performance Bonus:";
					label.setTextFormat(tf);
					label.width = 150;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					label = new TextField();
					label.text = bonus.toString();
					label.setTextFormat(tf);
					label.width = 90;
					label.x = 160;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					line = new NinePatchSprite("9patch_emboss_panel", 282, 30);
					line.x = screen.width / 2 - line.width / 2;
					line.y = 148 + offsetY;
					screen.addChild(line);
					
					tf.color = 0xFFFF70;
					
					label = new TextField();
					label.text = "Premium Bonus:";
					label.setTextFormat(tf);
					label.width = 150;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					label = new TextField();
					label.text = G.user.isPremium() ? "2x" : "1x";
					label.setTextFormat(tf);
					label.width = 90;
					label.x = 160;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					line = new NinePatchSprite("9patch_emboss_panel", 282, 30);
					line.x = screen.width / 2 - line.width / 2;
					line.y = 184 + offsetY;
					screen.addChild(line);
					
					tf.color = -1;
					
					label = new TextField();
					label.text = "Total XP:";
					label.setTextFormat(tf);
					label.width = 150;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					label = new TextField();
					label.text = ((bonus + xp) * (G.user.isPremium() ? 2 : 1)).toString();
					label.setTextFormat(tf);
					label.width = 90;
					label.x = 160;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					line = new NinePatchSprite("9patch_emboss_panel", 282, 30);
					line.x = screen.width / 2 - line.width / 2;
					line.y = 220 + offsetY;
					screen.addChild(line);
					
					label = new TextField();
					label.text = "Vortex Shards:";
					label.setTextFormat(tf);
					label.width = 150;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					label = new TextField();
					label.text = "" + shards;
					label.setTextFormat(tf);
					label.width = 90;
					label.x = 160;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					line = new NinePatchSprite("9patch_emboss_panel", 282, 30);
					line.x = screen.width / 2 - line.width / 2;
					line.y = 256 + offsetY;
					screen.addChild(line);
					
					label = new TextField();
					label.text = "Ranking:";
					label.setTextFormat(tf);
					label.width = 150;
					label.autoSize = TextFieldAutoSize.RIGHT;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					label = new TextField();
					label.text = prevRanking + " " + (rankGain > 0 ? "+ " : "- ") + Math.abs(rankGain);
					label.setTextFormat(tf);
					if(rankGain > 0)
						tf.color = 0x00FF00;
					else 
						tf.color = 0xFF0000;
					tf.bold = true;
					label.setTextFormat(tf, prevRanking.toString().length + 1, label.text.length);
					
					label.width = 90;
					label.x = 160;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.y = line.height / 2 - label.height / 2;
					label.mouseEnabled = false;
					line.addChild(label);
					
					if(G.host == G.HOST_KONGREGATE && position == 1) {
						G.kongregate.stats.submit("GamesWon" + playersStartedCount, 1);
					}
				}
				
				resumeButton = new ButtonHex("WATCH GAME", onResume, "button_small_gray");
				resumeButton.x = 192;
				resumeButton.y = screen.height - 50;
				screen.addChild(resumeButton);
			}
			
			G.gatracker.trackPageview("/game/gameOverScreen");
			G.gatracker.trackEvent("XP Awards", "xp", xp + "");
			G.gatracker.trackEvent("XP Awards", "bonus", bonus + "");
			G.gatracker.trackEvent("XP Awards", "total", (xp + bonus) + "");
		}
		
		public function GameOverScreen(mapId:String, widePanel:Boolean, position:int = -1, xp:int = 0, bonus:int = 0, playersStartedCount:int = 0, shards:int = 0, prevRanking:int = 0, nextRanking:int = 0)
		{
			super();
			
			this.mapId = mapId;
			
			init(widePanel, position, xp, bonus, playersStartedCount, shards, prevRanking, nextRanking - prevRanking);
			
			if(nextRanking != 0) {
				G.user.rating = nextRanking;
			}
		}
		
		public function playGameOverSound():void {
			if(gameOverSoundPlayed) return;
			
			if(position == 1) {
				G.sounds.playSound("game_over_win");
			}
			if(position > 1) {
				G.sounds.playSound("game_over_lose");
			}
			
			gameOverSoundPlayed = true;
		}
		
		private function onLeave():void {
			(Game)(this.parent).exitGame();
			
			G.gatracker.trackPageview("/game/leave");
		}
		
		private function onResume():void {
			(Game)(this.parent).removeGameOverScreen();
			
			G.gatracker.trackPageview("/game/resume");
		}
		
		public function removeContinueButton():void {
			if(resumeButton.parent != null) {
				//resumeButton.parent.removeChild(resumeButton);
				resumeButton.setText("CLOSE");
			}
		}
		
		/*private function onSharePressed(position:int):void {
			var title:String;
			var text:String;
			
			if(position == -2) {
				title = "We had a tie!";
				text = "It was pretty tough fight so we decided we should call it a draw. Would you do better?"
			}
			else if(position == 1) {
				title = "I won!";
				text = "He didn't stand a chance, would you?";
			}
			else {
				title = "I finished " + position + (position == 2 ? "nd" : (position == 3 ? "rd" : "th"));
				text = "I didn't win, but I will get there, how about you?";
			}
			
			
			Facebook.ui({
				method: "feed",
				name: title,
				link: "",
				picture: "lost-bytes.com/vortexwars/images/logo_93x74.png",
				//caption: '',
				description: text
			}, function(response:Object):void {

			});
		} */
	}
}