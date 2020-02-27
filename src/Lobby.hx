import controllers.Controller;
import controllers.GameController;

class Lobby {
    public var terrain : Terrain;
    public var player : GameController;
    public var controllers : Array<Controller>;

    public var units : Map<String, Unit>;

    public function new () {

    }

    public function update(dt : Float) {

    }

    public function dump() {
        
    }
}