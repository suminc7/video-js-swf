/**
 * Created by sumin on 2016. 9. 19..
 */
package {
import com.videojs.structs.NetworkState;
import com.videojs.structs.ReadyState;

import flash.display.Sprite;
import flash.media.Video;

import org.mangui.hls.HLS;
import org.mangui.hls.constant.HLSPlayStates;
import org.mangui.hls.constant.HLSSeekStates;
import org.mangui.hls.event.HLSEvent;
import org.mangui.hls.utils.Log;

public class Main extends Sprite {

    private var _loop:Boolean = false;
    private var _looping:Boolean = false;
    private var _hls:HLS;
    private var _src:Object;
//    private var _model:VideoJSModel;
    private var _videoReference:Video;
    private var _metadata:Object;
    private var _mediaWidth:Number;
    private var _mediaHeight:Number;

    private var _hlsState:String = HLSPlayStates.IDLE;
    private var _networkState:Number = NetworkState.NETWORK_EMPTY;
    private var _readyState:Number = ReadyState.HAVE_NOTHING;
    private var _position:Number = 0;
    private var _duration:Number = 0;
    private var _isAutoPlay:Boolean = false;
    private var _isManifestLoaded:Boolean = false;
    private var _isPlaying:Boolean = false;
    private var _isSeeking:Boolean = false;
    private var _isPaused:Boolean = true;
    private var _isEnded:Boolean = false;

    private var _bytesLoaded:Number = 0;
    private var _bytesTotal:Number = 0;
    private var _bufferedTime:Number = 0;
    private var _backBufferedTime:Number = 0;

    public function Main() {

        _hls = new HLS();
        _hls.currentLevel = 0;
        _hls.addEventListener(HLSEvent.PLAYBACK_COMPLETE,_completeHandler);
        _hls.addEventListener(HLSEvent.ERROR,_errorHandler);
        _hls.addEventListener(HLSEvent.MANIFEST_LOADED,_manifestHandler);
        _hls.addEventListener(HLSEvent.MEDIA_TIME,_mediaTimeHandler);
        _hls.addEventListener(HLSEvent.PLAYBACK_STATE,_playbackStateHandler);
        _hls.addEventListener(HLSEvent.SEEK_STATE,_seekStateHandler);
        _hls.addEventListener(HLSEvent.LEVEL_SWITCH,_levelSwitchHandler);


        _hls.load("https://content.epiqvr.com/local/contents/ADSUuj8PzUOJ1_BiRtJM0l9B79YFZh0dnmB%2BB3_Fdec%3D/vSPs_1p3g94FKLYEYDgndA%3D%3D/2016/09/08/3446/3446_0_0_1473323909824_720p/3446_0_0_1473323909824.m3u8");
        _hls.stream.play();



    }

    private function _completeHandler(event:HLSEvent):void {
        if(!_loop){
            _isEnded = true;
            _isPaused = true;
            _isPlaying = false;
//            _model.broadcastEvent(new VideoPlaybackEvent(VideoPlaybackEvent.ON_STREAM_CLOSE, {}));
//            _model.broadcastEventExternally(ExternalEventName.ON_PAUSE);
//            _model.broadcastEventExternally(ExternalEventName.ON_PLAYBACK_COMPLETE);
        } else {
            _looping = true;
            load();
        }
    };

    private function _errorHandler(event:HLSEvent):void {
        Log.debug("error!!!!:"+ event.error.msg);
//        _model.broadcastErrorEventExternally(ExternalErrorEventName.SRC_404);
        _networkState = NetworkState.NETWORK_NO_SOURCE;
        _readyState = ReadyState.HAVE_NOTHING;
        stop();
    };

    private function _manifestHandler(event:HLSEvent):void {
        _isManifestLoaded = true;
        _networkState = NetworkState.NETWORK_IDLE;
        _readyState = ReadyState.HAVE_METADATA;
        _duration = event.levels[0].duration;
        _metadata.width = event.levels[0].width;
        _metadata.height = event.levels[0].height;
        if(_isAutoPlay || _looping) {
            _looping = false;
            play();
        }
//        _model.broadcastEventExternally(ExternalEventName.ON_LOAD_START);
//        _model.broadcastEventExternally(ExternalEventName.ON_DURATION_CHANGE, _duration);
//        _model.broadcastEvent(new VideoPlaybackEvent(VideoPlaybackEvent.ON_META_DATA, {metadata:_metadata}));
//        _model.broadcastEventExternally(ExternalEventName.ON_METADATA, _metadata);
    };

    private function _mediaTimeHandler(event:HLSEvent):void {
        _position = event.mediatime.position;
        _bufferedTime = event.mediatime.buffer+event.mediatime.position;
        _backBufferedTime = event.mediatime.position - event.mediatime.backbuffer;

        if(event.mediatime.duration != _duration) {
            _duration = event.mediatime.duration;
//            _model.broadcastEventExternally(ExternalEventName.ON_DURATION_CHANGE, _duration);
        }
    };

    private function _playbackStateHandler(event:HLSEvent):void {
        _hlsState = event.state;
        Log.debug("state:"+ _hlsState);
        switch(event.state) {
            case HLSPlayStates.IDLE:
                _networkState = NetworkState.NETWORK_IDLE;
                _readyState = ReadyState.HAVE_METADATA;
                break;
            case HLSPlayStates.PLAYING_BUFFERING:
                _isPaused = false;
                _isEnded = false;
                _networkState = NetworkState.NETWORK_LOADING;
                _readyState = ReadyState.HAVE_CURRENT_DATA;
//                _model.broadcastEventExternally(ExternalEventName.ON_BUFFER_EMPTY);
                if(!_isPlaying) {
//                    _model.broadcastEventExternally(ExternalEventName.ON_RESUME);
                    _isPlaying = true;
                }
                break;
            case HLSPlayStates.PLAYING:
                _isPaused = false;
                _isEnded = false;
                _networkState = NetworkState.NETWORK_LOADING;
                _readyState = ReadyState.HAVE_ENOUGH_DATA;
//                _model.broadcastEventExternally(ExternalEventName.ON_BUFFER_FULL);
                if(!_isPlaying) {
//                    _model.broadcastEventExternally(ExternalEventName.ON_RESUME);
                    _isPlaying = true;
                }
//                _model.broadcastEventExternally(ExternalEventName.ON_CAN_PLAY);
//                _model.broadcastEvent(new VideoPlaybackEvent(VideoPlaybackEvent.ON_STREAM_START, {info:{}}));
                break;
            case HLSPlayStates.PAUSED:
                _isPaused = true;
                _isPlaying = false;
                _isEnded = false;
                _networkState = NetworkState.NETWORK_LOADING;
                _readyState = ReadyState.HAVE_ENOUGH_DATA;
//                _model.broadcastEventExternally(ExternalEventName.ON_BUFFER_FULL);
//                _model.broadcastEventExternally(ExternalEventName.ON_CAN_PLAY);
                break;
            case HLSPlayStates.PAUSED_BUFFERING:
                _isPaused = true;
                _isPlaying = false;
                _isEnded = false;
                _networkState = NetworkState.NETWORK_LOADING;
                _readyState = ReadyState.HAVE_CURRENT_DATA;
//                _model.broadcastEventExternally(ExternalEventName.ON_BUFFER_EMPTY);
                break;
        }
    };


    private function _seekStateHandler(event:HLSEvent):void {
        switch(event.state) {
            case HLSSeekStates.SEEKED:
                _isSeeking = false;
//                _model.broadcastEventExternally(ExternalEventName.ON_SEEK_COMPLETE);
                break;
            case HLSSeekStates.SEEKING:
                _isSeeking = true;
//                _model.broadcastEventExternally(ExternalEventName.ON_SEEK_START);
                break;
        }
    }

    private function _levelSwitchHandler(event:HLSEvent):void {
        var levelIndex:Number = event.level;
        var bitrate:Number = _hls.levels[levelIndex].bitrate;
        var width:Number = _hls.levels[levelIndex].width;
        var height:Number = _hls.levels[levelIndex].height;
        Log.info("HLSProvider: new level index " + levelIndex + " bitrate=" + bitrate + ", width=" + width + ", height=" + height);
//        _model.broadcastEventExternally(ExternalEventName.ON_LEVEL_SWITCH, {levelIndex: levelIndex, bitrate: bitrate, width: width, height: height});
    }

    public function stop():void {
        Log.debug("HLSProvider.stop");
        _hls.stream.close();
        _bufferedTime = 0;
        _duration = 0;
        _position = 0;
        _networkState = NetworkState.NETWORK_EMPTY;
        _readyState = ReadyState.HAVE_NOTHING;
        _isManifestLoaded = false;
    }

    /**
     * Called when the media asset should be preloaded, but not played.
     */
    public function load():void {
        if(_src !=null) {
            Log.debug("HLSProvider.load:"+ _src.m3u8);
            _isManifestLoaded = false;
            _position = 0;
            _duration = 0;
            _bufferedTime = 0;
            _hls.load(_src.m3u8);
        }
    }

    /**
     * Called when the media asset should be played immediately.
     */
    public function play():void {
        Log.debug("HLSProvider.play.state:" + _hlsState);
        if(_isManifestLoaded) {
            switch(_hlsState) {
                case HLSPlayStates.IDLE:
                    _hls.stream.play();
                    break;
                case HLSPlayStates.PAUSED:
                case HLSPlayStates.PAUSED_BUFFERING:
                    _hls.stream.resume();
                    break;
                default:
                    break;
            }
        }
    }

}
}
