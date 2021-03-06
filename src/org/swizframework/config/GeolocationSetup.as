package org.swizframework.config {
    public class GeolocationSetup {

        private var _updateInterval:int=0;
        private var _stopOnDeactivate:Boolean=true;

        public function GeolocationSetup() {
        }

        public function get updateInterval():int {
            return _updateInterval;
        }

        public function set updateInterval(value:int):void {
            _updateInterval = value;
        }

        public function get stopOnDeactivate():Boolean {
            return _stopOnDeactivate;
        }

        public function set stopOnDeactivate(value:Boolean):void {
            _stopOnDeactivate = value;
        }
    }
}