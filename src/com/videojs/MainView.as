package com.videojs  {
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
import flash.external.ExternalInterface;
import flash.geom.Matrix;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
import flash.ui.Keyboard;

import gs.TweenLite;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;

	/**
	 * @author mikepro
	 */
	public class MainView extends BasicView {
		
//		private const URL : String = "http://www.flashls.org/playlists/test_001/stream.m3u8";
		private const URL : String = "videos/14_2160_1080_1472223755054.mp4";
//		private const URL : String = "http://content.epiqvr.com/local/contents/z2Xhzehgm%2BuPCsyV1DCMlEmIrZBi1cFgf1euqCVZjtE%3D/vSPs_1p3g94FKLYEYDgndA%3D%3D/2016/09/08/3770/3770_0_0_1473324819434_1080p/3770_0_0_1473324819434.m3u8";
//		private const URL : String = "videos/Metlife.mp4";
		private const BOTTOM_URL : String = "videos/bottom.flv";
		private const BOTTOM_SIZE : int = 500;
		
		private var _videoMatrix : Matrix;
		private var _mouse360 : Mouse360;
		private var _sphere : Sphere;
		private var _bitmapData : BitmapData;
		private var _video : Video;
		private var _sphereMaterial : BitmapMaterial;
		private var _videoWidth : int;
		private var _videoHeight : int;
		private var _netStream : NetStream;
		private var _bottomPlane : Plane;
		private var _netStreamBottom : NetStream;
		private var _matrixBottom : Matrix;
		private var _videoBottom : Video;
		private var _bitmapDataBottom : BitmapData;
		private var _drawBottom : Boolean;
		private var _lookStep:int = 2;

		public function MainView() {
			super(480, 270, true, false, 'free');
			addEventListener(Event.ADDED_TO_STAGE, eAdded);
			camera.fov = 20;
		}

		private function eAdded(event : Event) : void {
			init();
			startRendering();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, eKeyDown);
		}

		private function eKeyDown(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case 32:
					_sphereMaterial.smooth = !_sphereMaterial.smooth;
					break;
//				case 38:
//					TweenLite.to(camera, 1, {fov:camera.fov + 15, onUpdate:function() : void {
//						camera.fov = camera.fov;
//					}});
//					break;
//				case 40:
//					TweenLite.to(camera, 1, {fov:camera.fov - 15, onUpdate:function() : void {
//						camera.fov = camera.fov;
//					}});
//					break;
				case Keyboard.UP:
					TweenLite.to(camera, 1, {rotationX:camera.rotationX - 30, onUpdate:function() : void {
						if (camera.rotationX < -90)
							camera.rotationX = -90;
					}});
					break;
				case Keyboard.DOWN:
					TweenLite.to(camera, 1, {rotationX:camera.rotationX + 30, onUpdate:function() : void {
						if (camera.rotationX < -90)
							camera.rotationX = -90;
					}});
					break;
				case Keyboard.LEFT:
					TweenLite.to(camera, 1, {rotationY:camera.rotationY - 30});
					break;
				case Keyboard.RIGHT:
					TweenLite.to(camera, 1, {rotationY:camera.rotationY + 30});
					break;

			}
		}

		private function loop3D(event : Event) : void {

			camera.rotationX += _mouse360.rotate.x;
			camera.rotationY += _mouse360.rotate.y;

			// max rotation up
			if (camera.rotationX < -90)
				camera.rotationX = -90;
			// max rotation down
			if (camera.rotationX > 90)
				camera.rotationX = 90;

			_mouse360.update();
			
			_bitmapData.draw(_video, _videoMatrix);

			if (_drawBottom) {
				_bitmapDataBottom.fillRect(_bitmapDataBottom.rect, 0x00000000);
				_bitmapDataBottom.draw(_videoBottom, _matrixBottom);
			}
		}

		private function init3D() : void {



			_bitmapData = new BitmapData(_videoWidth, _videoWidth / 2, false, 0x000000) ;
			_sphereMaterial = new BitmapMaterial(_bitmapData);
			_sphereMaterial.smooth = true;
			_sphereMaterial.doubleSided = true;
			_sphere = new Sphere(_sphereMaterial, 100, 32, 24);
			_sphere.rotationY = -90;
			_sphere.scaleX = -1;
			scene.addChild(_sphere);
			camera.fov = 75;
			camera.z = 0;



			addEventListener(Event.ENTER_FRAME, loop3D);



			//initBottom();
		}

		public function onMetaData(width:int, height:int):void {

            trace(width);

            ExternalInterface.call('console.log', width);
            if(width == 0) return;
            if(_videoWidth != 0) return;
            _videoWidth = width;
            _videoHeight = height;
            _videoMatrix.scale(_videoWidth / 320, _videoHeight / 240);

            init3D();

        }

		private function init() : void {


			addChild(_mouse360 = new Mouse360());


			CONFIG::debugging {

                trace('debugging');

                var nc : NetConnection = new NetConnection();
                nc.connect(null);
                var client : Object = new Object();

                client.onMetaData = function(o : Object) : void {
                    trace('onMetaData');
                    if(_videoWidth != 0) return;
                    _videoWidth = o.width;
                    _videoHeight = o.height;
                    _videoMatrix.scale(_videoWidth / 320, _videoHeight / 240);
                    init3D();
                };

                _netStream = new NetStream(nc);
                _netStream.addEventListener(NetStatusEvent.NET_STATUS, eStatus);
                _netStream.client = client;
				// Execute debugging code here.

                _netStream.play(URL);
//                _video = new Video();
                _video.attachNetStream(_netStream);
			}


			_videoMatrix = new Matrix();
		}

//		private function initBottom() : void {
//			var nc : NetConnection = new NetConnection();
//			nc.connect(null);
//			var client : Object = new Object();
//			client.onMetaData = function(o : Object) : void {
//				_drawBottom = true;
//			};
//
//			_netStreamBottom = new NetStream(nc);
//			_netStreamBottom.addEventListener(NetStatusEvent.NET_STATUS, eStatus);
//			_netStreamBottom.client = client;
//			_netStreamBottom.play(BOTTOM_URL);
//
//			_videoBottom = new Video();
//			_videoBottom.attachNetStream(_netStreamBottom);
//			_videoBottom.width = BOTTOM_SIZE;
//			_videoBottom.height = BOTTOM_SIZE;
//			_matrixBottom = new Matrix();
//			_matrixBottom.scale(BOTTOM_SIZE / 320, BOTTOM_SIZE / 240);
//
//			_bottomPlane = new Plane(null, 0, 0, 4, 4);
//			_bitmapDataBottom = new BitmapData(BOTTOM_SIZE, BOTTOM_SIZE, true);
//			var bbm : BitmapMaterial;
//			_bottomPlane.material = bbm = new BitmapMaterial(_bitmapDataBottom);
//			bbm.smooth = true;
//
//			_bottomPlane.y = -300;
//			_bottomPlane.rotationX = 90;
//			scene.addChild(_bottomPlane);
//		}

		// RESTART VIDEOS WHEN COMPLETE

		private function eStatus(event : NetStatusEvent) : void {
			switch(event.info.code) {
				case "NetStream.Play.Stop":
					event.target.seek(0);
					event.target.resume();
					break;
			}
		}

		public function get video():Video {
			return _video;
		}

        public function set video(video:Video):void {
            _video = video;
        }

	}
}
