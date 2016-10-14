package {
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import fl.motion.Color;
	
	public class imgCut extends MovieClip {
		private var _bgLine:RectBox;//背景框
		private var _imgLine:RectBox;//图片框
		private var imgWid:Number = 400//500;
		private var imgHei:Number = 600//865;
		private var _corner:corner;//4个角
		private var _cenPoint:cenPoint;
		private var _imageMc:Sprite;//图片区
		private var _imageContainer:Sprite;//图片控制区
		private var wRatio:Number;
		private var hRatio:Number;
		private var preview:Sprite;
		private var smallImg:Boolean=false;//是不是小图
		private var img_url:String="";
		private var img_type:String="";
		private var tsTopTxt="仅支持JPG、PNG、BMP格式，建议尺寸 500*865px，文件大小 < 1.5 M ";
		private var fileType = "*.jpeg; *.jpg; *.png; *.bmp";
		private var bgColor = 0xfffff0;
		public function imgCut() {
			
			stage.scaleMode=StageScaleMode.NO_SCALE
			stage.align = StageAlign.TOP_LEFT;
			
			var param:Object = root.loaderInfo.parameters;
			
			if (param["imgWid"] != null)
			{
				imgWid = param["imgWid"];
			}
			
			if (param["imgHei"] != null)
			{
				imgHei = param["imgHei"];
			}
			if (param["img_url"] != null)
			{
				if(param["img_url"].indexOf("?")>-1){
					img_url=param["img_url"]+"&"
				}else{
					img_url=param["img_url"]+"?"
				}
			}
			if(param["fileType"] != null) {
				fileType = param["fileType"];
			}
			if(param["bgColor"] != null) {
				bgColor = param["bgColor"];
			}
			stage.color = bgColor;
			if (param["img_type"] != null)
			{
				img_type = param["img_type"];
			}
			if (param["tsTopTxt"] != null)
			{
				tsTopTxt = param["tsTopTxt"];
				topMc.errTxt.text=tsTopTxt;
			}
			this._bgLine = new RectBox(imgWid + 16-1,imgHei + 16);
			this._imgLine = new RectBox(imgWid,imgHei,0xe7e7e7);
			_imageMc = new Sprite();
			_bgLine.x = 10;
			_bgLine.y = topMc.y + topMc.height + 10;
			_imgLine.x = _bgLine.x + 8 - 0.5;
			_imgLine.y = _bgLine.y + 8 - 0.5;
			bottomMc.y = _bgLine.y + imgHei - 50;
			bottomMc.x = _bgLine.x + _bgLine.width/2;
			this.addChild(_bgLine);
			this.addChild(_imageMc);
			this.addChild(_imgLine);
			
			setCorner();
			bottomMc.zoomIn.mouseEnabled = false;
			bottomMc.zoomIn.alpha = 0.5;
			bottomMc.zoomOut.mouseEnabled = false;
			bottomMc.zoomOut.alpha = 0.5;
			bottomMc.cutBtn.mouseEnabled = false;
			bottomMc.cutBtn.alpha = 0.5;
			bottomMc.resetBtn.mouseEnabled = false;
			bottomMc.resetBtn.alpha = 0.5;
			topMc.selFileBtn.addEventListener(MouseEvent.CLICK,selFile);
			bottomMc.zoomIn.addEventListener(MouseEvent.CLICK,zoomIn);
			bottomMc.zoomOut.addEventListener(MouseEvent.CLICK,zoomOut);
			bottomMc.resetBtn.addEventListener(MouseEvent.CLICK,reset);
			bottomMc.cutBtn.addEventListener(MouseEvent.CLICK,save_img)
			stage.addEventListener(MouseEvent.MOUSE_UP,move_up);
			stage.addEventListener(MouseEvent.MOUSE_OUT,move_up);
		}
		
		private function _clearContainer(container:DisplayObjectContainer):void {
			while (container.numChildren>0) {
				container.removeChildAt(0);
			}
		}
		private function setCorner():void {//4个角
			_corner=new corner();
			_corner.x = _bgLine.x + 8;
			_corner.y = _bgLine.y + 8;
			this.addChild(_corner);
			_corner=new corner();
			_corner.rotation = 90;
			_corner.x = _bgLine.x + imgWid + 8;
			_corner.y = _bgLine.y + 8;
			this.addChild(_corner);
			_corner=new corner();
			_corner.rotation = 180;
			_corner.x = _bgLine.x + imgWid + 8;
			_corner.y = _bgLine.y + imgHei + 8;
			this.addChild(_corner);
			_corner=new corner();
			_corner.rotation = -90;
			_corner.x = _bgLine.x + 8;
			_corner.y = _bgLine.y + imgHei + 8;
			this.addChild(_corner);
			/////////////////////////////////////////////
			_cenPoint=new cenPoint();
			_cenPoint.gotoAndStop(1);
			_cenPoint.bg.width = imgWid;
			_cenPoint.bg.height = imgHei;
			_cenPoint.visible = false;
			_cenPoint.x = _imgLine.x + imgWid / 2;
			_cenPoint.y = _imgLine.y + imgHei / 2;
			_cenPoint.mouseChildren = false;
			_cenPoint.mouseEnabled = false;
			this.addChild(_cenPoint);
		}
		
		/**
		 * 保存中提示动画
		 */
		private function saveIng():void {
			preview = new Sprite()
			var myShape = new Shape();
			myShape.graphics.beginFill(0x000000);
//			myShape.graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight);
			myShape.graphics.drawRect(0, 0, imgWid + 40,imgHei + 140);
			myShape.alpha = .5;
			var _saveIngTxt = new saveIngTxt();
			_saveIngTxt.x = _imgLine.x+imgWid/2;
			_saveIngTxt.y = _imgLine.y+imgHei/2;
			preview.addChild(myShape);
			preview.addChild(_saveIngTxt);
			this.addChild(preview);
		}
		
		private function reset(_e:MouseEvent):void {//重置
			if(_imageContainer!=null){
				_imageContainer.x = 0;
				_imageContainer.y=0;
				_imageContainer.scaleX = 1;
				_imageContainer.scaleY = 1;
			}
		}
		
		private function zoomIn(_e:MouseEvent):void {//放大
			_imageContainer.scaleX +=  0.1;
			_imageContainer.scaleY +=  0.1;
		}
		
		private function zoomOut(_e:MouseEvent):void {//缩小
			_imageContainer.scaleX -=  0.1;
			_imageContainer.scaleY -=  0.1;
			if(smallImg==true){//如果是小图
				if(_imageContainer.scaleX<1){
					_imageContainer.scaleX=1
					_imageContainer.scaleY=1
				}
				return
			}
			if (wRatio > hRatio) {
				if (_imageContainer.height< imgHei) {
					_imageContainer.height = imgHei;
					_imageContainer.scaleX = _imageContainer.scaleY;
					
				} 
			} else {
				
				if (_imageContainer.width  < imgWid) {
					_imageContainer.width = imgWid;
					_imageContainer.scaleY =_imageContainer.scaleX
						;
				} 
			}
			if(_imageContainer.x<imgWid/2-_imageContainer.width/2){
				_imageContainer.x=imgWid/2-_imageContainer.width/2
			}
			if(_imageContainer.y<imgHei/2-_imageContainer.height/2){
				_imageContainer.y=imgHei/2-_imageContainer.height/2
			}
			if(_imageContainer.x>-imgWid/2+_imageContainer.width/2){
				_imageContainer.x=-imgWid/2+_imageContainer.width/2
			}
			if(_imageContainer.y>-imgHei/2+_imageContainer.height/2){
				_imageContainer.y=-imgHei/2+_imageContainer.height/2
			}
		}
		
		private function selFile(_e:MouseEvent):void {//选择文件
			startLoadingFile();
		}
		
		// ------- 浏览文件处理 -------
		// --- Load ---
		private var _loadFile:FileReference;
		
		private function startLoadingFile():void {/////////浏览框的设置
			_loadFile = new FileReference();
			_loadFile.addEventListener(Event.SELECT, selectHandler);
			var fileFilter:FileFilter = new FileFilter("Images: (" + fileType + ")",fileType);
			_loadFile.browse([fileFilter]);
		}
		
		private function selectHandler(event:Event):void {
			//选择图片成功
			_loadFile.removeEventListener(Event.SELECT, selectHandler);
			_loadFile.addEventListener(Event.COMPLETE, loadCompleteHandler);
			if(_loadFile.size<1.5 * 1024 * 1024){
				_loadFile.load();
			}else{
				topMc.errTxt.htmlText="<font color='#ff0000'>文件的尺寸超过1.5 M,请重新上传</font>"
			}
		}
		
		private function loadCompleteHandler(event:Event):void {
			////文件加载成功
			_loadFile.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
			loader.loadBytes(_loadFile.data);
			
		}
		
		private function loadBytesHandler(event:Event):void {
			var loaderInfo:LoaderInfo = (event.target as LoaderInfo);
			loaderInfo.removeEventListener(Event.COMPLETE, loadBytesHandler);
			
			showImage(loaderInfo.content);
		}
		// ------- 浏览文件处理 end------
		
		private function showImage(bitmap:DisplayObject):void {
			topMc.errTxt.text=tsTopTxt;
			if(bitmap.width>4800 || bitmap.height>3600){
				topMc.errTxt.htmlText="<font color='#ff0000'>文件的尺寸超过4800*3600px,请重新上传</font>";
				return
			}
			if(bitmap.width<imgWid || bitmap.height<imgHei){
				smallImg=true;
			}else{
				smallImg=false;
			}
			_cenPoint.visible = true;
			bottomMc.zoomIn.mouseEnabled = true;
			bottomMc.zoomIn.alpha = 1;
			bottomMc.zoomOut.mouseEnabled = true;
			bottomMc.zoomOut.alpha = 1;
			bottomMc.cutBtn.mouseEnabled = true;
			bottomMc.cutBtn.alpha = 1;
			bottomMc.resetBtn.mouseEnabled = true;
			bottomMc.resetBtn.alpha = 1;
			if (_imageMc != null) {
				_clearContainer(_imageMc);
			}
			if (_imageContainer == null) {
				_imageContainer = new Sprite();
				
			}else{
				_clearContainer(_imageContainer)
			}
			var _imageMask=new Sprite();
			var myShape:Shape=new Shape();
			myShape.graphics.beginFill(0x4F4F4F);
			myShape.graphics.drawRect(-imgWid/2,-imgHei/2,imgWid+1,imgHei);
			//画矩形;
			_imageMask.addChild(myShape);
			_imageMask.alpha = 0.5;
			_imageMc.x = _imgLine.x + imgWid / 2;
			_imageMc.y = _imgLine.y + imgHei / 2;
			var bd:BitmapData = new BitmapData(bitmap.width,bitmap.height,true);
			bd.draw(bitmap);
			var btmp:Bitmap = new Bitmap(bd);
			btmp.smoothing = true;
			_imageContainer.addChild(btmp);
			btmp.x =  -bitmap.width / 2;
			btmp.y =  -bitmap.height / 2;
			wRatio = bitmap.width / imgWid;
			hRatio = bitmap.height / imgHei;
			_imageContainer.x = 0;
			_imageContainer.y = 0;
			_imageContainer.scaleX = 1;
			_imageContainer.scaleY = 1;
			_imageMc.addChild(_imageContainer);
			_imageContainer.mask = _imageMask;
			_imageMc.addChild(_imageMask);
			
			////////////////////////////////////
			_imageContainer.addEventListener(MouseEvent.MOUSE_OVER,move_over);
			_imageContainer.addEventListener(MouseEvent.MOUSE_OUT,move_out);
			_imageContainer.addEventListener(MouseEvent.MOUSE_DOWN,img_move);
			setChildIndex(bottomMc, 4);
			up_before_img.visible = false;
		}
		private function move_over(_e:MouseEvent):void {
			Mouse.cursor="hand"
		}
		private function img_move(_e:MouseEvent):void {
			if(_cenPoint.visible != false){
				_cenPoint.visible = false;
			}
			_imageContainer.startDrag(false, new Rectangle(imgWid/2-_imageContainer.width/2,imgHei/2-_imageContainer.height/2,_imageContainer.width-imgWid,_imageContainer.height-imgHei));
			// _imageContainer.startDrag(false);
		}
		private function move_up(_e:MouseEvent):void {
			stopDrag();
		}
		
		private function move_out(_e:MouseEvent):void {
			Mouse.cursor="auto"
			stopDrag();
		}
		
		/**
		 * 点击上传按钮处理函数
		 */
		private function save_img(_e:MouseEvent):void {
			saveIng();
			var _tm = new Timer(200,1);
			_tm.addEventListener(TimerEvent.TIMER_COMPLETE, this.send_imgStart);
			_tm.reset();
			_tm.start()
		}
		
		private function send_imgStart(t:TimerEvent):void{//发送图片
			var bitmapData:BitmapData = new BitmapData(imgWid,imgHei)
			var matrix:Matrix = new Matrix()
			matrix.translate(imgWid/2,imgHei/2)
			bitmapData.draw(_imageMc,matrix)
			var _nowPicture = new Bitmap();
			_nowPicture.bitmapData = bitmapData;
			var urlReq:URLRequest = new URLRequest(img_url+"&img_type="+img_type)
			urlReq.requestHeaders.push(new URLRequestHeader("Content-type", "application/octet-stream"));
			urlReq.method = URLRequestMethod.POST;
			var jpgEnc:JPGEncoder=new JPGEncoder(100);
			urlReq.data = jpgEnc.encode(bitmapData);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, this.uploadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
			urlLoader.load(urlReq);
		}
		
		/**
		 * 上传完成
		 */
		private function uploadComplete(e:Event):void {
			_clearContainer(preview);
			removeChild(preview);
			//			trace("上传成功");
			var _loader:URLLoader = e.target as URLLoader;
			_loader.removeEventListener(Event.COMPLETE, this.uploadComplete);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
			ExternalInterface.call("sendToJavaScript","" + e.currentTarget.data);
		}
		
		/**
		 * 上传失败io_error
		 */
		private function errorHandler(e:IOErrorEvent):void {
			var _loader:URLLoader = e.target as URLLoader;
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
			var errorMsg = "上传失败！错误信息:" + e.text;
			ExternalInterface.call("alert(\"" + errorMsg + "\")");
			_clearContainer(preview);
			removeChild(preview);
			//trace("上传失败");
			return;
		}
	}
}