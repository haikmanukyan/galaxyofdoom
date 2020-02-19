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

class UnitController extends Controller {
    public var unit : Unit;

    public function new (unit : Unit, game : Game, player : Player) {
        super(game, player);
        this.unit = unit;
    }

    public override function Start(task : Dynamic, queue = false) {
        return function () {
            unit.startTask(task(unit, this));
        }
    }
    public override function SetPending(task : Dynamic, queue = false, preview = null) {
        return function () {
            unit.startTask(task(unit, this));
        }
    }

    public override function SetTree (controlTree : Array<ControlNode>) {
        return function() {

        }
    }
    
    public override function update (dt : Float) {
    }
}