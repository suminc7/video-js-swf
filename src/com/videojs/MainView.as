package com.videojs  {
	import flash.display.BitmapData;
import flash.display.Stage;
import flash.events.ErrorEvent;
    import flash.events.Event;
	import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
    import flash.geom.Matrix;
import flash.geom.Point;
import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
    import flash.ui.Keyboard;

    import gs.TweenLite;
    import org.mangui.hls.utils.Log;

    import org.papervision3d.materials.BitmapMaterial;

    import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;

	/**
	 * @author mikepro
	 */
	public class MainView extends BasicView {
		
		private const URL : String = "https://content.epiqvr.com/prod/contents/fAiCJJErh6PTeVlil08nXdCc8E5kBHJ4rIrI2qeAdiQ%3D/vSPs_1p3g94FKLYEYDgndA%3D%3D/2016/10/28/1203/1203_4096_2048_1477631040533.mp4";

        private var _isMoving : Boolean;
        private var _stage : Stage;
        private var _click : Point = new Point();
        private var _displace : Point = new Point();
        private var _beforedisplace : Point = new Point();

		private var _videoMatrix : Matrix;
//		private var _mouse360 : Mouse360;
		private var _sphere : Sphere;
		private var _bitmapData : BitmapData;
		private var _video : Video;
		private var _sphereMaterial : BitmapMaterial;
		private var _videoWidth : int;
		private var _videoHeight : int;
		private var _netStream : NetStream;

		private var _beforeRotationX : Number;
		private var _beforeRotationY : Number;


		public function MainView() {
			super(480, 270, true, false, 'free');
			addEventListener(Event.ADDED_TO_STAGE, eAdded);
			camera.fov = 20;
		}

		private function eAdded(event : Event) : void {
            _stage = stage;

			init();
			startRendering();
//			stage.addEventListener(KeyboardEvent.KEY_DOWN, eKeyDown);

            stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}

        private function handleMouseDown(event : MouseEvent) : void {
            _isMoving = true;
            _click.x = _stage.mouseX;
            _click.y = _stage.mouseY;

            _beforeRotationX = camera.rotationX;
            _beforeRotationY = camera.rotationY;

            _stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
            visible = true;
//			drawArrow();
        }

        private function handleMouseUp(event : MouseEvent) : void {
            _isMoving = false;
            _stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
        }

		private function eKeyDown(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case 32:
					_sphereMaterial.smooth = !_sphereMaterial.smooth;
					break;
				case 38:
					TweenLite.to(camera, 1, {fov:camera.fov + 15, onUpdate:function() : void {
						camera.fov = camera.fov;
					}});
					break;
				case 40:
					TweenLite.to(camera, 1, {fov:camera.fov - 15, onUpdate:function() : void {
						camera.fov = camera.fov;
					}});
					break;
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


            if (_isMoving) {
                _displace.x = (_click.y - _stage.mouseY) * .2 + _beforeRotationX;
                _displace.y = (_click.x - _stage.mouseX) * .2 + _beforeRotationY;
            }



			camera.rotationX = _displace.x;
			camera.rotationY = _displace.y;

			// max rotation up
			if (camera.rotationX < -90)
				camera.rotationX = -90;
			// max rotation down
			if (camera.rotationX > 90)
				camera.rotationX = 90;

//			_mouse360.update();
            _bitmapData.draw(_video, _videoMatrix);


            try{
            }catch(e:ErrorEvent){
                Log.info(e);
            }


            try {
            }
            catch(error:Error){
                Log.info(error);
            }


		}

		private function init3D() : void {
//            Log.info("init3D 1");

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

//            ExternalInterface.call('console.log', width);
            if(width == 0) return;
            if(_videoWidth != 0) return;
            _videoWidth = width;
            _videoHeight = height;
            _videoMatrix.scale(_videoWidth / 320, _videoHeight / 240);

            init3D();

        }

		private function init() : void {


//			addChild(_mouse360 = new Mouse360());


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

        public function get ns():NetStream {
            return _netStream;
        }

        public function set ns(ns:NetStream):void {
            _netStream = ns;
        }
	}
}
