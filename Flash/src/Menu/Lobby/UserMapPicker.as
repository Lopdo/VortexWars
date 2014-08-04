package Menu.Lobby
{
	import Errors.ErrorManager;
	
	import IreUtils.ResList;
	
	import Menu.Button;
	import Menu.ButtonHex;
	import Menu.Loading;
	import Menu.NinePatchSprite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import playerio.DatabaseObject;
	import playerio.PlayerIOError;
	
	public class UserMapPicker extends Sprite
	{
		private var createGameScreen:CreateGameScreen;
		
		private var favouriteButton:ButtonHex;
		private var lastPlayedButton:ButtonHex;
		private var topMapsButton:ButtonHex;
		private var allMapsButton:ButtonHex;
		private var myMapsButton:ButtonHex;
		
		private var mapListSprite:Sprite;
		private var loading:Loading;
		
		private var mapGroup:int = 0;
		private var nextMapStack:Array = new Array();
		
		private var pagerSprite:NinePatchSprite;
		private var firstPageButton:Button;
		private var prevPageButton:Button;
		private var nextPageButton:Button;
		private var pageLabel:TextField;
		
		private var previewSprite:Sprite;
		
		private var currentMap:String;
		
		private var isLastPage:Boolean;
		private var pageOffset:int = 0;
		
		public function UserMapPicker(createScreen:CreateGameScreen)
		{
			super();
			
			createGameScreen = createScreen;
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, 800, 600);
			
			var bg:NinePatchSprite = new NinePatchSprite("9patch_popup", 632, 554);
			bg.x = width / 2 - bg.width / 2;
			bg.y = height / 2 - bg.height / 2;
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Arial", 18, -1, true);
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = "USER MAPS";
			label.width = bg.width - 20;
			label.x = 10;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.y = 40 / 2 - label.height / 2;
			label.mouseEnabled = false;
			bg.addChild(label);
			
			tf.size = 14;
			
			var tabsBg:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 150, 250);
			tabsBg.x = 10;
			tabsBg.y = 50;
			bg.addChild(tabsBg);
			
			favouriteButton = new ButtonHex("FAVOURITE", setupFavourite, "button_small_gold", 14, -1, 140);
			favouriteButton.x = 5;
			favouriteButton.y = 5;
			tabsBg.addChild(favouriteButton);
			
			lastPlayedButton = new ButtonHex("LAST PLAYED", setupLastPlayed, "button_small_gold", 14, -1, 140);
			lastPlayedButton.x = 5;
			lastPlayedButton.y = 55;
			tabsBg.addChild(lastPlayedButton);
			
			topMapsButton = new ButtonHex("TOP MAPS", setupTopMaps, "button_small_gray", 14, -1, 140);
			topMapsButton.x = 5;
			topMapsButton.y = 105;
			tabsBg.addChild(topMapsButton);
			
			allMapsButton = new ButtonHex("ALL MAPS", setupAllMaps, "button_small_gray", 14, -1, 140);
			allMapsButton.x = 5;
			allMapsButton.y = 155;
			tabsBg.addChild(allMapsButton);
			
			myMapsButton = new ButtonHex("MY MAPS", setupMyMaps, "button_small_gray", 14, -1, 140);
			myMapsButton.x = 5;
			myMapsButton.y = 205;
			tabsBg.addChild(myMapsButton);
			
			var mapListBg:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 450, 456);
			mapListBg.x = 170;
			mapListBg.y = 50;
			bg.addChild(mapListBg);
			
			mapListSprite = new Sprite();
			mapListBg.addChild(mapListSprite);
			
			var button:ButtonHex = new ButtonHex("CANCEL", onCancel, "button_small_gray");
			button.x = bg.width - button.width - 124;
			button.y = bg.height - 44;
			bg.addChild(button);
			
			button = new ButtonHex("SELECT", onSelect, "button_small_gold");
			button.x = bg.width - button.width - 8;
			button.y = bg.height - 44;
			bg.addChild(button);
			
			pagerSprite = new NinePatchSprite("9patch_emboss_panel", 120, 32);
			pagerSprite.x = mapListBg.x;
			pagerSprite.y = mapListBg.y + mapListBg.height + 4;
			bg.addChild(pagerSprite);
			//pagerSprite.visible = false;
			
			var prevButtonSprite:Sprite = new Sprite();
			prevButtonSprite.addChild(ResList.GetArtResource("selector_arrow_disabled"));
			var b:Bitmap = ResList.GetArtResource("selector_arrow_disabled");
			b.x = 14;
			prevButtonSprite.addChild(b);
			
			firstPageButton = new Button(null, onFirstPageClicked, prevButtonSprite);
			firstPageButton.x = 4;
			firstPageButton.y = 4;
			pagerSprite.addChild(firstPageButton);
			
			prevPageButton = new Button(null, onPrevPageClicked, ResList.GetArtResource("selector_arrow_disabled"));
			prevPageButton.x = 46;
			prevPageButton.y = 4;
			pagerSprite.addChild(prevPageButton);
			
			b = ResList.GetArtResource("selector_arrow_disabled");
			b.scaleX = -1;
			b.x = b.width;
			
			nextPageButton = new Button(null, onNextPageClicked, b);
			nextPageButton.x = 96;
			nextPageButton.y = 4;
			pagerSprite.addChild(nextPageButton);
			
			pageLabel = new TextField();
			pageLabel.defaultTextFormat = new TextFormat("Arial", 16, -1, true);
			pageLabel.text = "1";
			pageLabel.autoSize = TextFieldAutoSize.CENTER;
			pageLabel.x = 73;
			pageLabel.y = pagerSprite.height / 2 - pageLabel.height / 2;
			pageLabel.mouseEnabled = false;
			pagerSprite.addChild(pageLabel);
			
			var previewBg:NinePatchSprite = new NinePatchSprite("9patch_emboss_panel", 150, 150);
			previewBg.x = 10;
			previewBg.y = mapListBg.y + mapListBg.height - previewBg.height;
			bg.addChild(previewBg);

			label = new TextField();
			label.text = "Map preview:";
			label.setTextFormat(new TextFormat("Arial", 14, -1, true));
			label.x = 10;
			label.y = previewBg.y - 20;
			label.mouseEnabled = false;
			bg.addChild(label);
			

			previewSprite = new Sprite();
			previewSprite.x = 25;
			previewSprite.y = 25;
			previewBg.addChild(previewSprite);
			
			setupLastPlayed();
			
			G.gatracker.trackPageview("/userMapPicker");
		}
		
		private function setupFavourite():void {
			favouriteButton.setImage("button_small_gold");
			lastPlayedButton.setImage("button_small_gray");
			topMapsButton.setImage("button_small_gray");
			allMapsButton.setImage("button_small_gray");
			myMapsButton.setImage("button_small_gray");
			
			while(mapListSprite.numChildren > 0) mapListSprite.removeChildAt(mapListSprite.numChildren - 1);
			
			nextMapStack.length = 0;
			mapGroup = 4;
			
			onFirstPageClicked(null);
		}
		
		private function setupLastPlayed():void {
			favouriteButton.setImage("button_small_gray");
			lastPlayedButton.setImage("button_small_gold");
			topMapsButton.setImage("button_small_gray");
			allMapsButton.setImage("button_small_gray");
			myMapsButton.setImage("button_small_gray");
			
			while(mapListSprite.numChildren > 0) mapListSprite.removeChildAt(mapListSprite.numChildren - 1);
			
			nextMapStack.length = 0;
			mapGroup = 0;
			
			onFirstPageClicked(null);
		}
		
		private function setupTopMaps():void {
			favouriteButton.setImage("button_small_gray");
			lastPlayedButton.setImage("button_small_gray");
			topMapsButton.setImage("button_small_gold");
			allMapsButton.setImage("button_small_gray");
			myMapsButton.setImage("button_small_gray");
			
			while(mapListSprite.numChildren > 0) mapListSprite.removeChildAt(mapListSprite.numChildren - 1);

			nextMapStack.length = 0;
			mapGroup = 1;
			
			onFirstPageClicked(null);
		}
		
		private function setupAllMaps():void {
			favouriteButton.setImage("button_small_gray");
			lastPlayedButton.setImage("button_small_gray");
			topMapsButton.setImage("button_small_gray");
			allMapsButton.setImage("button_small_gold");
			myMapsButton.setImage("button_small_gray");
			
			while(mapListSprite.numChildren > 0) mapListSprite.removeChildAt(mapListSprite.numChildren - 1);
			
			nextMapStack.length = 0;
			mapGroup = 2;
			
			onFirstPageClicked(null);
		}
		
		private function setupMyMaps():void {
			favouriteButton.setImage("button_small_gray");
			lastPlayedButton.setImage("button_small_gray");
			topMapsButton.setImage("button_small_gray");
			allMapsButton.setImage("button_small_gray");
			myMapsButton.setImage("button_small_gold");
			
			while(mapListSprite.numChildren > 0) mapListSprite.removeChildAt(mapListSprite.numChildren - 1);
			
			nextMapStack.length = 0;
			mapGroup = 3;
			
			onFirstPageClicked(null);
		}
		
		private function mapsLoaded(maps:Array):void {
			if(loading) {
				mapListSprite.removeChild(loading);
				loading = null;
			}
			
			for(var i:int = 8 * pageOffset; i < maps.length && i < 8 * (pageOffset + 1); i++) {
				var mapCell:UserMapCell = new UserMapCell(maps[i], this);
				mapCell.x = 8;
				mapCell.y = 8 + (i - 8 * pageOffset) * 55;
				mapListSprite.addChild(mapCell);
			}
			firstPageButton.alpha = prevPageButton.alpha = nextMapStack.length > 0 ? 1 : 0.5;
			firstPageButton.enabled = prevPageButton.enabled = nextMapStack.length > 0;
			
			pageLabel.text = (nextMapStack.length + 1).toString();

			isLastPage = maps[8 * (pageOffset + 1)] == null;
			
			if(maps[8 * (pageOffset + 1)])
				nextMapStack.push(maps[8 * (pageOffset + 1)]);
			
			nextPageButton.alpha = isLastPage ? 0.5 : 1;
			nextPageButton.enabled = !isLastPage;
		}
		
		private function onFirstPageClicked(button:Button):void {
			if(loading) return;
			
			while(mapListSprite.numChildren > 0) mapListSprite.removeChildAt(mapListSprite.numChildren - 1);
			
			nextMapStack.length = 0;
			
			pagerSprite.visible = mapGroup != 0;
			pageOffset = 0;

			if(mapGroup == 0) {
				if(G.user.isGuest) {
					mapsLoaded(new Array());
					return;
				}
				
				var lastMapsArr:Array = new Array();
				for(var i:int = 0; i < G.user.playerObject.LastPlayedMaps.length; i++) {
					lastMapsArr.push(G.user.playerObject.LastPlayedMaps[i].Map);
				}
				lastMapsArr = lastMapsArr.reverse();
				if(lastMapsArr.length > 0) {
				G.client.bigDB.loadKeys("CustomMaps", lastMapsArr, function(maps:Array):void {
					mapsLoaded(maps);
				}, function(error:PlayerIOError):void {
					if(loading) {
						mapListSprite.removeChild(loading);
						loading = null;
					}
					ErrorManager.showPIOError(error);
				});
				}
			}
			if(mapGroup == 1) {
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				G.client.bigDB.loadRange("CustomMaps", "quality", [2], null, null, 9, function(maps:Array):void {
					mapsLoaded(maps);
					
				}, function(error:PlayerIOError):void {
					if(loading) {
						mapListSprite.removeChild(loading);
						loading = null;
					}
					ErrorManager.showPIOError(error);
				});
			}
			if(mapGroup == 2) {
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				G.client.bigDB.loadRange("CustomMaps", "date", [2], null, null, 9, function(maps:Array):void {
					mapsLoaded(maps);
					
				}, function(error:PlayerIOError):void {
					if(loading) {
						mapListSprite.removeChild(loading);
						loading = null;
					}
					ErrorManager.showPIOError(error);
				});
			}
			if(mapGroup == 3) {
				if(G.user.isGuest) {
					mapsLoaded(new Array());
					return;
				}
				
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				G.client.bigDB.loadRange("CustomMaps", "owner", [2, G.user.playerObject.key], null, null, 9, function(maps:Array):void {
					mapsLoaded(maps);
					
				}, function(error:PlayerIOError):void {
					if(loading) {
						mapListSprite.removeChild(loading);
						loading = null;
					}
					ErrorManager.showPIOError(error);
				});
			}
			if(mapGroup == 4) {
				if(G.user.isGuest) {
					mapsLoaded(new Array());
					return;
				}
				
				lastMapsArr = new Array();
				for(i = 0; i < G.user.playerObject.LikedMaps.length; i++) {
					lastMapsArr.push(G.user.playerObject.LikedMaps[i]);
				}
				lastMapsArr.reverse();
				if(lastMapsArr.length > 0) {
					loading = new Loading("LOADING...", false);
					mapListSprite.addChild(loading);
					loading.x = 450 / 2 - loading.width / 2;
					loading.y = 420 / 2 - loading.height / 2;
					
					G.client.bigDB.loadKeys("CustomMaps", lastMapsArr, function(maps:Array):void {
						mapsLoaded(maps);
					}, function(error:PlayerIOError):void {
						if(loading) {
							mapListSprite.removeChild(loading);
							loading = null;
						}
						ErrorManager.showPIOError(error);
					});
				}
			}
		}
		
		private function onPrevPageClicked(button:Button):void {
			if(loading) return;
			while(mapListSprite.numChildren > 0) mapListSprite.removeChildAt(mapListSprite.numChildren - 1);
			
			nextMapStack.pop();
			if(!isLastPage)
				nextMapStack.pop();
			
			if(mapGroup == 1) {
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				if(nextMapStack.length > 0) {
					if(nextMapStack[nextMapStack.length - 1].LikeRatio > 0) {
						G.client.bigDB.loadRange("CustomMaps", "quality", [2], nextMapStack[nextMapStack.length - 1].LikeRatio, null, 9, function(maps:Array):void {
							mapsLoaded(maps);
							
						}, function(error:PlayerIOError):void {
							if(loading) {
								mapListSprite.removeChild(loading);
								loading = null;
							}
							ErrorManager.showPIOError(error);
						});	
					}
					else {
						G.client.bigDB.loadRange("CustomMaps", "quality", [2, 0], nextMapStack[nextMapStack.length - 1].SubmitDate, null, 9, function(maps:Array):void {
							mapsLoaded(maps);
							
						}, function(error:PlayerIOError):void {
							if(loading) {
								mapListSprite.removeChild(loading);
								loading = null;
							}
							ErrorManager.showPIOError(error);
						});
					}
				}
				else {
					G.client.bigDB.loadRange("CustomMaps", "quality", [2], null, null, 9, function(maps:Array):void {
						mapsLoaded(maps);
						
					}, function(error:PlayerIOError):void {
						if(loading) {
							mapListSprite.removeChild(loading);
							loading = null;
						}
						ErrorManager.showPIOError(error);
					});
				}
				
			}
			if(mapGroup == 2) {
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				G.client.bigDB.loadRange("CustomMaps", "date", [2], nextMapStack.length > 0 ? nextMapStack[nextMapStack.length - 1].SubmitDate : null, null, 9, function(maps:Array):void {
					mapsLoaded(maps);
					
				}, function(error:PlayerIOError):void {
					mapListSprite.removeChild(loading);
					ErrorManager.showPIOError(error);
				});
			}
			if(mapGroup == 3) {
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				pageOffset--;
				if(pageOffset < 0) pageOffset = 0;
				
				G.client.bigDB.loadRange("CustomMaps", "owner", [2, G.user.playerObject.key], nextMapStack.length > 0 ? nextMapStack[nextMapStack.length - 1].SubmitDate : null, null, 9, function(maps:Array):void {
					mapsLoaded(maps);
					
				}, function(error:PlayerIOError):void {
					mapListSprite.removeChild(loading);
					ErrorManager.showPIOError(error);
				});
			}
			if(mapGroup == 4) {
				pageOffset--;
				if(pageOffset < 0) pageOffset = 0;

				var likedMapsArr:Array = new Array();
				for(var i:int = 0; i < G.user.playerObject.LikedMaps.length; i++) {
					likedMapsArr.push(G.user.playerObject.LikedMaps[i]);
				}
				if(likedMapsArr.length > 0) {
					loading = new Loading("LOADING...", false);
					mapListSprite.addChild(loading);
					loading.x = 450 / 2 - loading.width / 2;
					loading.y = 420 / 2 - loading.height / 2;
					
					G.client.bigDB.loadKeys("CustomMaps", likedMapsArr, function(maps:Array):void {
						mapsLoaded(maps);
					}, function(error:PlayerIOError):void {
						if(loading) {
							mapListSprite.removeChild(loading);
							loading = null;
						}
						ErrorManager.showPIOError(error);
					});
				}
			}
		}
		
		private function onNextPageClicked(button:Button):void {
			if(loading) return;
			while(mapListSprite.numChildren > 0) mapListSprite.removeChildAt(mapListSprite.numChildren - 1);
			
			if(mapGroup == 1) {
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				if(nextMapStack[nextMapStack.length - 1].LikeRatio > 0) {
					G.client.bigDB.loadRange("CustomMaps", "quality", [2], nextMapStack[nextMapStack.length - 1].LikeRatio, null, 9, function(maps:Array):void {
						mapsLoaded(maps);
						
					}, function(error:PlayerIOError):void {
						mapListSprite.removeChild(loading);
						ErrorManager.showPIOError(error);
					});	
				}
				else {
					G.client.bigDB.loadRange("CustomMaps", "quality", [2, 0], nextMapStack[nextMapStack.length - 1].SubmitDate, null, 9, function(maps:Array):void {
						mapsLoaded(maps);
						
					}, function(error:PlayerIOError):void {
						mapListSprite.removeChild(loading);
						ErrorManager.showPIOError(error);
					});
				}
			}
			if(mapGroup == 2) {
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				G.client.bigDB.loadRange("CustomMaps", "date", [2], nextMapStack[nextMapStack.length - 1].SubmitDate, null, 9, function(maps:Array):void {
					mapsLoaded(maps);
					
				}, function(error:PlayerIOError):void {
					mapListSprite.removeChild(loading);
					ErrorManager.showPIOError(error);
				});
			}
			if(mapGroup == 3) {
				loading = new Loading("LOADING...", false);
				mapListSprite.addChild(loading);
				loading.x = 450 / 2 - loading.width / 2;
				loading.y = 420 / 2 - loading.height / 2;
				
				G.client.bigDB.loadRange("CustomMaps", "owner", [2, G.user.playerObject.key], nextMapStack[nextMapStack.length - 1].SubmitDate, null, 9, function(maps:Array):void {
					mapsLoaded(maps);
					
				}, function(error:PlayerIOError):void {
					mapListSprite.removeChild(loading);
					ErrorManager.showPIOError(error);
				});
			}
			if(mapGroup == 4) {
				pageOffset++;
				
				var likedMapsArr:Array = new Array();
				for(var i:int = 0; i < G.user.playerObject.LikedMaps.length; i++) {
					likedMapsArr.push(G.user.playerObject.LikedMaps[i]);
				}
				if(likedMapsArr.length > 0) {
					loading = new Loading("LOADING...", false);
					mapListSprite.addChild(loading);
					loading.x = 450 / 2 - loading.width / 2;
					loading.y = 420 / 2 - loading.height / 2;
					
					G.client.bigDB.loadKeys("CustomMaps", likedMapsArr, function(maps:Array):void {
						mapsLoaded(maps);
					}, function(error:PlayerIOError):void {
						if(loading) {
							mapListSprite.removeChild(loading);
							loading = null;
						}
						ErrorManager.showPIOError(error);
					});
				}
			}
		}
		
		private function onSelect():void {
			createGameScreen.setUserMap(currentMap);
			parent.removeChild(this);
		}
		
		private function onCancel():void {
			parent.removeChild(this);
		}
		
		public function selectMap(mapKey:String, mapImage:DisplayObject):void {
			currentMap = mapKey;
			
			while(previewSprite.numChildren > 0) previewSprite.removeChildAt(previewSprite.numChildren - 1);
			
			if(mapImage)
				previewSprite.addChild(mapImage);
			
			for(var i:int = 0; i < mapListSprite.numChildren; i++) {
				UserMapCell(mapListSprite.getChildAt(i)).deselect();
			}
		}
	}
}