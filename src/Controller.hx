import Globals.ControlNode;
import Unit.HighlightMode;
import h3d.col.Point;
import h3d.col.Collider;
import h3d.col.Ray;
import hxd.Event;
import h3d.Vector;
import h3d.scene.Object;
import haxe.Constraints.Function;
import hxd.Key in K;

class Controller {
    var queueTask : Bool;
    public var game : Game;
    public var player : Player;
    
    public var position : Vector;
    public var target : Dynamic;

    public function new (game : Game, player : Player) {
        this.game = game;
        this.player = player;
        position = new Vector();
    }

    public function reset() {
    }


    public function Start(task : Dynamic, queue = false) {
        return function () {  
        }
    }
    public function SetPending(task : Dynamic, queue = false, preview = null) {
        return function () {
            
        }
    }

    public function SetTree (controlTree : Array<ControlNode>) {
        return function() {
            
        }
    }

    public function hasTarget() {
        if (target == null) return false;
        return target.isAlive;
    }
    
    public function update (dt : Float) {
    }
}