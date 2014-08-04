package MapEditor
{
	import Errors.ErrorManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import playerio.DatabaseObject;
	import playerio.PlayerIOError;

	public class MapEditorPreviewCreator
	{
		
		private var fileName:String;
		private var fileData:ByteArray;
		
		public function MapEditorPreviewCreator(mapKey:String)
		{
			G.client.bigDB.load("CustomMapsData", mapKey, function(mapObj:DatabaseObject):void {
				fileName = mapKey + ".png";
				
				var bitmapData:BitmapData = drawMap(mapObj.Width, mapObj.Height, mapObj.MapData);
				fileData = pngEncodeBitmapData(bitmapData);
				
				var f:FileReference = new FileReference();
				f.save(fileData, fileName);

			}, function(error:PlayerIOError):void {
				ErrorManager.showPIOError(error);
			});
		}
		
		private function getNeighborTile(tiles:Array, x:int, y:int, dir:int, width:int):int {
			var nx:int = x;
			var ny:int = y;
			switch(dir) {
				case 0: nx += (ny % 2 == 1) ? 1 : 0;
						ny--; break;
				case 1:	nx++; break;
				case 2:	nx += (ny % 2 == 1) ? 1 : 0;
						ny++; break;
				case 3: nx -= (ny % 2 == 1) ? 0 : 1;
						ny++; break;
				case 4:	nx--; break;
				case 5:	nx -= (ny % 2 == 1) ? 0 : 1;
						ny--; break;
			}
			var index:int = ny * width + nx;
			if(index < 0 || index >= tiles.length) return -1;
			
			return tiles[index];
		}
		
		private function regionsHaveSameOwner(id1:int, id2:int):Boolean {
			if(id1 <= 0 || id2 <= 0) return false;
			
			return id1 == id2;
		}
		
		private function drawMap(width:int, height:int, data:ByteArray):BitmapData {
			
			// find map boundaries
			var minX:int = width;
			var minY:int = height;
			var maxX:int = 0;
			var maxY:int = 0;
			var atLeastOneHexPresent:Boolean = false;
			for(var i:int = 0; i < width*height; i++) {
				var tileX:int = i % width;
				var tileY:int = i / width;
				if(data[i] != 0) {
					atLeastOneHexPresent = true;
					if(tileX < minX) minX = tileX;
					if(tileX > maxX) maxX = tileX;
					if(tileY < minY) minY = tileY;
					if(tileY > maxY) maxY = tileY;
				}
			} 
			if(!atLeastOneHexPresent) {
				minX = minY = 0;
				maxX = maxY = 10;
			}
			// align start of map to even number so it doesn't break (hex lines offsets
			if(minY % 2) minY--;
			var mapWidth:int = maxX - minX + 1;
			var mapHeight:int = maxY - minY + 1;
			
			var croppedTiles:Array = new Array(mapWidth * mapHeight);
			for(i = 0; i < mapWidth * mapHeight; i++) {
				croppedTiles[i] = data[(i % mapWidth + minX) + int(i / mapWidth + minY) * width];
			}
			
			var imgWidth:int = mapWidth * MERegion.hexW + 10;
			var imgHeight:int = mapHeight * (MERegion.hexH + MERegion.hexSide) + 10;
			
			var size:int = imgWidth > imgHeight ? imgWidth : imgHeight;
			
			var offsetX:int = (size - imgWidth) / 2;
			var offsetY:int = (size - imgHeight) / 2;
			
			var sprite:Sprite = new Sprite();
			
			var points:Array = new Array();
			
			points[0] = new Point(0, 0); 
			points[1] = new Point(MERegion.hexR, MERegion.hexH);
			points[2] = new Point(MERegion.hexR, MERegion.hexSide + MERegion.hexH);
			points[3] = new Point(0, MERegion.hexSide + 2*MERegion.hexH);
			points[4] = new Point(- MERegion.hexR, MERegion.hexSide + MERegion.hexH);
			points[5] = new Point(- MERegion.hexR, MERegion.hexH);
			
			//sprite.graphics.lineStyle(4);
			sprite.graphics.clear();
			sprite.graphics.beginFill(0xFFFFFF);
			
			for(var index:int = 0; index < mapHeight * mapWidth; ++index) {
				var tile:int = croppedTiles[index];
				if(tile == 0) continue;
				
				tileX = index % mapWidth;
				tileY = index / mapWidth;
				
				sprite.graphics.moveTo(MERegion.hexW * tileX + ((tileY % 2 == 1) ? MERegion.hexW / 2 : 0) + points[0].x + offsetX, tileY * (MERegion.hexSide + MERegion.hexH) + points[0].y + offsetY);
				
				for (var j:int=1; j < 6; j++) {
					var newX:int = MERegion.hexW * tileX + ((tileY % 2 == 1) ? MERegion.hexW / 2 : 0) + points[j].x + offsetX;
					var newY:int = tileY * (MERegion.hexSide + MERegion.hexH) + points[j].y + offsetY;
					sprite.graphics.lineTo(newX, newY);
				}
			}
			sprite.graphics.endFill();
			
			sprite.graphics.lineStyle(4);
			for(index = 0; index < croppedTiles.length; ++index) {
				tile = croppedTiles[index];
				if(tile == 0) continue;
				
				tileX = index % mapWidth;
				tileY = index / mapWidth;
				
				newX = MERegion.hexW * tileX + ((tileY % 2 == 1) ? MERegion.hexW / 2 : 0) + points[0].x + offsetX;
				newY = tileY * (MERegion.hexSide + MERegion.hexH) + points[0].y + offsetY;
				
				sprite.graphics.moveTo(newX, newY);
				
				for (j = 1; j < 6; j++) {
					newX = MERegion.hexW * tileX + ((tileY % 2 == 1) ? MERegion.hexW / 2 : 0) + points[j].x + offsetX;
					newY = tileY * (MERegion.hexSide + MERegion.hexH) + points[j].y + offsetY;
					if (regionsHaveSameOwner(getNeighborTile(croppedTiles, tileX, tileY, j-1, mapWidth), tile)) {
						sprite.graphics.moveTo(newX, newY);						
					} else {
						sprite.graphics.lineTo(newX, newY);
					}
				}
				if (!regionsHaveSameOwner(getNeighborTile(croppedTiles, tileX, tileY, 5, mapWidth), tile)) {
					newX = MERegion.hexW * tileX + ((tileY % 2 == 1) ? MERegion.hexW / 2 : 0) + points[0].x + offsetX;
					newY = tileY * (MERegion.hexSide + MERegion.hexH) + points[0].y + offsetY;
					sprite.graphics.lineTo(newX, newY);						
				}
			}
			sprite.graphics.endFill();
			
			var matrix:Matrix = new Matrix();
			matrix.scale(100 / size, 100 / size);
			var result:BitmapData = new BitmapData(100, 100, true, 0x00FFFFFF); 
			result.draw(sprite, matrix);

			return result;
		}
		
		
		/////////////////
		// png encoder
		////////////////
		private function pngEncodeBitmapData(img:BitmapData):ByteArray {
			// Create output byte array
			var png:ByteArray = new ByteArray();
			// Write PNG signature
			png.writeUnsignedInt(0x89504e47);
			png.writeUnsignedInt(0x0D0A1A0A);
			// Build IHDR chunk
			var IHDR:ByteArray = new ByteArray();
			IHDR.writeInt(img.width);
			IHDR.writeInt(img.height);
			IHDR.writeUnsignedInt(0x08060000); // 32bit RGBA
			IHDR.writeByte(0);
			writeChunk(png,0x49484452,IHDR);
			// Build IDAT chunk
			var IDAT:ByteArray= new ByteArray();
			for(var i:int=0;i < img.height;i++) {
				// no filter
				IDAT.writeByte(0);
				var p:uint;
				if ( !img.transparent ) {
					for(var j:int=0;j < img.width;j++) {
						p = img.getPixel(j,i);
						IDAT.writeUnsignedInt(
							uint(((p&0xFFFFFF) << 8)|0xFF));
					}
				} else {
					for(j = 0; j < img.width; j++) {
						p = img.getPixel32(j,i);
						IDAT.writeUnsignedInt(uint(((p&0xFFFFFF) << 8)|((p>>>24))));
					}
				}
			}
			IDAT.compress();
			writeChunk(png,0x49444154,IDAT);
			// Build IEND chunk
			writeChunk(png,0x49454E44,null);
			// return PNG
			return png;
		}
		
		private var crcTable:Array;
		private var crcTableComputed:Boolean = false;
		
		private function writeChunk(png:ByteArray, type:uint, data:ByteArray):void {
			if (!crcTableComputed) {
				crcTableComputed = true;
				crcTable = [];
				for (var n:uint = 0; n < 256; n++) {
					var c:uint = n;
					for (var k:uint = 0; k < 8; k++) {
						if (c & 1) {
							c = uint(uint(0xedb88320) ^ 
								uint(c >>> 1));
						} else {
							c = uint(c >>> 1);
						}
					}
					crcTable[n] = c;
				}
			}
			var len:uint = 0;
			if (data != null) {
				len = data.length;
			}
			png.writeUnsignedInt(len);
			var p:uint = png.position;
			png.writeUnsignedInt(type);
			if ( data != null ) {
				png.writeBytes(data);
			}
			var e:uint = png.position;
			png.position = p;
			c = 0xffffffff;
			for (var i:int = 0; i < (e-p); i++) {
				c = uint(crcTable[
					(c ^ png.readUnsignedByte()) & 
					uint(0xff)] ^ uint(c >>> 8));
			}
			c = uint(c^uint(0xffffffff));
			png.position = e;
			png.writeUnsignedInt(c);
		}
	}
}