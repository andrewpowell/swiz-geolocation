package org.swizframework.processors {
    import flash.desktop.NativeApplication;
    import flash.events.Event;
    import flash.events.GeolocationEvent;

    import flash.sensors.Geolocation;

    import flash.utils.Dictionary;

	import org.swizframework.config.GeolocationSetup;
	import org.swizframework.core.Bean;
    import org.swizframework.metadata.GeolocationMetadataTag;
    import org.swizframework.reflection.IMetadataTag;

    public class GeolocationProcessor extends BaseMetadataProcessor {

        private var _geo:Geolocation;
        private var _isSetup:Boolean = false;
        private var _callbacks:Dictionary = new Dictionary();

        [Inject]
        public var config:GeolocationSetup;

        

        public function GeolocationProcessor() {

            super(["Geolocation"], GeolocationMetadataTag);

        }

        protected function setup():void {


            if(!Geolocation.isSupported)
                    throw new Error("Geolocation must be supported to use this metadata tag.")
                else
                    if(this._geo==null)
                        this._geo=new Geolocation();


            if(this.config.stopOnDeactivate){
                NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,onActivate);
                NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,onDeactivate);
            }
			
			if(this.config.updateInterval>0)
				this._geo.setRequestedUpdateInterval(this.config.updateInterval);

            if(!this._geo.hasEventListener(GeolocationEvent.UPDATE))
                this._geo.addEventListener(GeolocationEvent.UPDATE,onGeolocationUpdate);

            this._isSetup=true;
        }

        /**
        * Executed when a new [Scheduled] metadata tag is found
        */
        override public function setUpMetadataTag(metadataTag:IMetadataTag, bean:Bean):void {
            var method:Function = bean.source[ metadataTag.host.name ] as Function;
            var geolocationTag:GeolocationMetadataTag = GeolocationMetadataTag(metadataTag);

            if(!this._isSetup){

                setup();
				setupGeolocation(geolocationTag,method);

            }
        }

        /**
        * Executed when a [Scheduled] metadata tag has been removed
        */
        override public function tearDownMetadataTag(metadataTag:IMetadataTag, bean:Bean):void {
            var geolocation:GeolocationMetadataTag = GeolocationMetadataTag(metadataTag);
            var method:Function = bean.source[ metadataTag.host.name ] as Function;

            removeGeolocation(geolocation,method);

            if(this.config.stopOnDeactivate){
                NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE,onActivate);
                NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE,onDeactivate);
            }
        }

        private function setupGeolocation(geo:GeolocationMetadataTag,method:Function):void{

            var geoMetadata:GeolocationMetadata = new GeolocationMetadata();
            geoMetadata.callback = method;
            geoMetadata.tag = geo;

            this._callbacks[geo.host.name] = geoMetadata;
        }

        private function removeGeolocation(geo:GeolocationMetadataTag,method:Function):void{
            for each(var o:GeolocationMetadata in this._callbacks){
                if(geo.host.name==o.tag.host.name){
                    delete this._callbacks[geo.host.name];
                    break;
                }
            }
        }

        private function onGeolocationUpdate(event:GeolocationEvent):void {
            for each (var o:GeolocationMetadata in this._callbacks){
                var f:Function = o.callback;
                var params:Array = [event.latitude,event.longitude];
                f(event.latitude,event.longitude);
            }
        }

        private function onActivate(event:Event):void {
            if(this._geo==null){
                this._geo=new Geolocation();
                this._geo.addEventListener(GeolocationEvent.UPDATE,onGeolocationUpdate);
            }
        }

        private function onDeactivate(event:Event):void {
            if(this._geo!==null){
                this._geo.removeEventListener(GeolocationEvent.UPDATE,onGeolocationUpdate);
                this._geo=null;
            }
        }
    }
}

import org.swizframework.metadata.GeolocationMetadataTag;

class GeolocationMetadata{

    public var tag:GeolocationMetadataTag;
    public var callback:Function;

}