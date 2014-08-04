package Menu.MainMenu
{
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import playerio.DatabaseObject;
	
	public class LeaderboardsScreen extends Sprite
	{
		private var sortArrows:Array = new Array();
		
		private var positions:Array = new Array();
		private var names:Array = new Array();
		private var levels:Array = new Array();
		private var ratings:Array = new Array();
		private var matches:Array = new Array();
		private var wins:Array = new Array();
		
		private var initialized:Boolean = false;

		private var meBgSprite:Sprite;
		
		private var bg:NinePatchSprite;
		
		
		public function LeaderboardsScreen()
		{
			super();
			
			graphics.beginFill(0, 0.65);
			graphics.drawRect(0, 0, 800, 600);
			//graphics.beginBitmapFill(ResList.GetArtResource("bg").bitmapData);
			//graphics.drawRect(0, 0, 800, 600);
			
			bg = new NinePatchSprite("9patch_popup", 756, 530);
			bg.x = 400 - bg.width / 2;
			bg.y = 22;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "LEADERBOARDS";
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			meBgSprite = new Sprite();
			meBgSprite.addChild(ResList.GetArtResource("lb_me"));
			meBgSprite.x = bg.width / 2 - meBgSprite.width / 2;
			bg.addChild(meBgSprite);
			meBgSprite.visible = false;
			
			var legend:Sprite = new Sprite();
			legend.addChild(ResList.GetArtResource("lb_legend_bg"));
			legend.x = bg.width / 2 - legend.width / 2;
			legend.y = 52;
			bg.addChild(legend);
			
			label = new TextField();
			label.text = "POS.";
			label.setTextFormat(tf);
			label.x = 14;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = legend.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			legend.addChild(label);
			
			label = new TextField();
			label.text = "NAME";
			label.setTextFormat(tf);
			label.x = 84;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = legend.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			legend.addChild(label);
			
			label = new TextField();
			label.text = "RATING";
			label.setTextFormat(tf);
			label.x = 356;//421;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = legend.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			legend.addChild(label);

			label = new TextField();
			label.text = "LVL";
			label.setTextFormat(tf);
			label.x = 456;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = legend.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			legend.addChild(label);
			
			label = new TextField();
			label.text = "MATCHES";
			label.setTextFormat(tf);
			label.x = 521;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = legend.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			legend.addChild(label);
			
			label = new TextField();
			label.text = "WINS";
			label.setTextFormat(tf);
			label.x = 639;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.y = legend.height / 2 - label.height / 2;
			label.mouseEnabled = false;
			legend.addChild(label);
			
			for(var i:int = 0; i < 4; ++i) {
				var arrow:Bitmap = ResList.GetArtResource("lb_legend_sortArrow");
				arrow.y = legend.height / 2 - arrow.height / 2;
				legend.addChild(arrow);
				arrow.visible = i == 0;
				sortArrows[i] = arrow;
			}
			sortArrows[0].x = 436;
			sortArrows[1].x = 498;
			sortArrows[2].x = 614;
			sortArrows[3].x = 691;
			
			var button:Button = new Button(null, function(button:Button):void {sortByRating();}, null, 0, 0, 100, 47);
			button.x = 350;
			legend.addChild(button);
			
			button = new Button(null, function(button:Button):void {sortByLevel();}, null, 0, 0, 62, 47);
			button.x = 453;
			legend.addChild(button);
			
			button = new Button(null, function(button:Button):void {sortByMatches();}, null, 0, 0, 118, 47);
			button.x = 514;
			legend.addChild(button);
			
			button = new Button(null, function(button:Button):void {sortByWins();}, null, 0, 0, 74, 47);
			button.x = 634;
			legend.addChild(button);
			
			var content:NinePatchSprite = new NinePatchSprite("9patch_transparent_panel", 714, 370);
			content.x = bg.width / 2 - content.width / 2;
			content.y = 114;
			content.graphics.lineStyle(1, 0x686868);
			content.graphics.moveTo(74, 5);
			content.graphics.lineTo(74, 365);
			content.graphics.moveTo(352, 5);
			content.graphics.lineTo(352, 365);
			content.graphics.moveTo(455, 5);
			content.graphics.lineTo(455, 365);
			content.graphics.moveTo(517, 5);
			content.graphics.lineTo(517, 365);
			content.graphics.moveTo(636, 5);
			content.graphics.lineTo(636, 365);
			bg.addChild(content);
			
			for(i = 0; i < 10; i++) {
				content.graphics.moveTo(9, 35 + 32*i);
				content.graphics.lineTo(708, 35 + 32*i);
			}
			
			tf.size = 16;
			
			for(i = 0; i < 11; ++i) {
				label = new TextField();
				label.defaultTextFormat = tf;
				label.text = " ";
				label.x = 9;
				label.width = 65;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.y = 5 + 32*i + 16 - label.height / 2;
				label.mouseEnabled = false;
				content.addChild(label);
				positions[i] = label;
				
				label = new TextField();
				label.defaultTextFormat = tf;
				label.text = " ";
				label.x = 88;
				label.autoSize = TextFieldAutoSize.LEFT;
				label.y = 5 + 32*i + 16 - label.height / 2;
				label.mouseEnabled = false;
				content.addChild(label);
				names[i] = label;
				
				label = new TextField();
				label.defaultTextFormat = tf;
				label.text = " ";
				label.x = 344;
				label.width = 118;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.y = 5 + 32*i + 16 - label.height / 2;
				label.mouseEnabled = false;
				content.addChild(label);
				ratings[i] = label;
				
				label = new TextField();
				label.defaultTextFormat = tf;
				label.text = " ";
				label.x = 458;
				label.width = 64;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.y = 5 + 32*i + 16 - label.height / 2;
				label.mouseEnabled = false;
				content.addChild(label);
				levels[i] = label;
				
				label = new TextField();
				label.defaultTextFormat = tf;
				label.text = " ";
				label.x = 520;
				label.width = 118;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.y = 5 + 32*i + 16 - label.height / 2;
				label.mouseEnabled = false;
				content.addChild(label);
				matches[i] = label;
				
				label = new TextField();
				label.defaultTextFormat = tf;
				label.text = " ";
				label.x = 639;
				label.width = 74;
				label.autoSize = TextFieldAutoSize.CENTER;
				label.y = 5 + 32*i + 16 - label.height / 2;
				label.mouseEnabled = false;
				content.addChild(label);
				wins[i] = label;
			}
			
			if(G.user.isGuest) {
				sortByRating();
			}
			else {
				var loading:Loading = new Loading("LOADING...", false);
				loading.x = bg.width / 2 - loading.width / 2;
				loading.y = bg.height / 2 - loading.height / 2;
				bg.addChild(loading);
				
				G.client.bigDB.loadMyPlayerObject(function(playerobject:DatabaseObject):void{
					G.user.totalXP = playerobject.TotalXP;
					G.user.stats = playerobject.Stats;
					G.user.playerObject = playerobject;
					
					if(loading) {
						bg.removeChild(loading);
						loading = null;
					}
					
					sortByRating();
				});
			}
			
			var closeButton:ButtonHex = new ButtonHex("CLOSE", onClose, "button_small_gray");
			closeButton.x = 756 / 2 - button.width / 2;
			closeButton.y = 530 - 40;
			bg.addChild(closeButton);
			//addChild(new MenuShortcutsPanel(onBack));
			
			G.gatracker.trackPageview("/leaderboards");
		}
		
		private function fillInValues(scores:Array, myScore:DatabaseObject):void {
			var found:Boolean = false;
			meBgSprite.visible = false;
			
			for(var i:int = 0; i < 10; ++i) {
				var dbo:DatabaseObject = scores[i];
				if(myScore && dbo && myScore.Username == dbo.Username) {
					positions[i].text = "YOU";
					found = true;
					meBgSprite.y = 122 + 32*i;
					meBgSprite.visible = true;
				}
				else
					positions[i].text = (i + 1).toString();
				if(dbo) {
					names[i].text = dbo.Username;
					levels[i].text = dbo.Level.toString();
					if(dbo.RankingRating)
						ratings[i].text = dbo.RankingRating.toString();
					else
						ratings[i].text = "";
					matches[i].text = dbo.Stats.TotalMatches.toString();
					wins[i].text = dbo.Stats.TotalWins.toString();
				}
			}
			
			if(!found && myScore) {
				positions[10].text = "YOU";
				names[10].text = myScore.Username;
				levels[10].text = myScore.Level.toString();
				if(myScore.RankingRating)
					ratings[10].text = myScore.RankingRating.toString();
				matches[10].text = myScore.Stats.TotalMatches.toString();
				wins[10].text = myScore.Stats.TotalWins.toString();
				meBgSprite.y = 122 + 32*10;
				meBgSprite.visible = true;
			}
			else {
				positions[10].text = "";
				names[10].text = "";
				levels[10].text = "";
				ratings[10].text = "";
				matches[10].text = "";
				wins[10].text = "";	
			}
		}
		
		private function sortByLevel():void {
			var loading:Loading = new Loading("LOADING...", false);
			loading.x = bg.width / 2 - loading.width / 2;
			loading.y = bg.height / 2 - loading.height / 2;
			bg.addChild(loading);
			
			sortArrows[0].visible = false;
			sortArrows[1].visible = true;
			sortArrows[2].visible = false;
			sortArrows[3].visible = false;
			
			if(G.user.isGuest) {
				G.client.bigDB.loadRange("PlayerObjects", "level", [], null, null, 11, 
					function(scores:Array):void{
						bg.removeChild(loading);
						
						fillInValues(scores, null);
					}
				);
			}
			else {
				G.client.bigDB.loadSingle("PlayerObjects", "level", [false, G.user.totalXP, G.user.name], function(score:DatabaseObject):void {
					G.client.bigDB.loadRange("PlayerObjects", "level", [], null, null, 11, 
						function(scores:Array):void{
							bg.removeChild(loading);
						
							fillInValues(scores, score);
						}
					)
				});
			}
			
			G.gatracker.trackPageview("/leaderboards/sort/level");
		}
		
		private function sortByRating():void {
			var loading:Loading = new Loading("LOADING...", false);
			loading.x = bg.width / 2 - loading.width / 2;
			loading.y = bg.height / 2 - loading.height / 2;
			bg.addChild(loading);
			
			sortArrows[0].visible = true;
			sortArrows[1].visible = false;
			sortArrows[2].visible = false;
			sortArrows[3].visible = false;
			
			if(G.user.isGuest) {
				G.client.bigDB.loadRange("PlayerObjects", "rating", [], null, null, 11, 
					function(scores:Array):void{
						bg.removeChild(loading);
						
						fillInValues(scores, null);
					}
				);
			}
			else {
				G.client.bigDB.loadSingle("PlayerObjects", "rating", [false, G.user.rating, G.user.name], function(score:DatabaseObject):void {
					G.client.bigDB.loadRange("PlayerObjects", "rating", [], null, null, 11, 
						function(scores:Array):void{
							bg.removeChild(loading);
							
							fillInValues(scores, score);
						}
					)
				});
			}
			
			G.gatracker.trackPageview("/leaderboards/sort/rating");
		}
		
		private function sortByMatches():void {
			var loading:Loading = new Loading("LOADING...", false);
			loading.x = bg.width / 2 - loading.width / 2;
			loading.y = bg.height / 2 - loading.height / 2;
			bg.addChild(loading);
			
			sortArrows[0].visible = false;
			sortArrows[1].visible = false;
			sortArrows[2].visible = true;
			sortArrows[3].visible = false;
			
			if(G.user.isGuest) {
				G.client.bigDB.loadRange("PlayerObjects", "matches", [], null, null, 11, 
					function(scores:Array):void{
						bg.removeChild(loading);
						
						fillInValues(scores, null);
					}
				);
			}
			else {
				G.client.bigDB.loadSingle("PlayerObjects", "matches", [false, G.user.stats.TotalMatches, G.user.name], function(score:DatabaseObject):void {
					G.client.bigDB.loadRange("PlayerObjects", "matches", [], null, null, 11, 
						function(scores:Array):void{
							bg.removeChild(loading);
							
							fillInValues(scores, score);
						}
					)
				});
			}
			
			G.gatracker.trackPageview("/leaderboards/sort/matches");
		}
		
		private function sortByWins():void {
			var loading:Loading = new Loading("LOADING...", false);
			loading.x = bg.width / 2 - loading.width / 2;
			loading.y = bg.height / 2 - loading.height / 2;
			bg.addChild(loading);
			
			sortArrows[0].visible = false;
			sortArrows[1].visible = false;
			sortArrows[2].visible = false;
			sortArrows[3].visible = true;
			
			if(G.user.isGuest) {
				G.client.bigDB.loadRange("PlayerObjects", "wins", [], null, null, 11, 
					function(scores:Array):void{
						bg.removeChild(loading);
						
						fillInValues(scores, null);
					}
				);
			}
			else {
				G.client.bigDB.loadSingle("PlayerObjects", "wins", [false, G.user.stats.TotalWins, G.user.name], function(score:DatabaseObject):void {
					G.client.bigDB.loadRange("PlayerObjects", "wins", [], null, null, 11, 
						function(scores:Array):void{
							bg.removeChild(loading);
							
							fillInValues(scores, score);
						}
					)
				});
			}
			
			G.gatracker.trackPageview("/leaderboards/sort/wins");
		}
		
		private function onClose():void {
			//parent.addChild(new MainMenu());
			parent.removeChild(this);
			
			G.gatracker.trackPageview("/leaderboards/close");
		}
	}
}