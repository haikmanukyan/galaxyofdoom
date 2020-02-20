import hxd.res.Model;
import hxd.res.Image;
import h3d.scene.Object;
import Globals.Resource;

class UnitStats {
    public var isResource : Bool = false;
    public var isBuilding : Bool = false;
    public var isDropPoint : Bool = false;

    public var physicsSize : Float = 1;
    public var maxHitPoints : Float = 10;
    public var movementSpeed : Float = 25;
    
    public var attackRange : Float = 3;
    public var visionRange : Float = 20;
    public var attackDamage : Float = 1;
    public var attackType : Int; // Ranged mellee
    public var armor : Int; // OR enum?

    public var name : String;
    public var model : Model;
    public var icon : Image;
    public var portrait : Image;
    public var resourceModel : Model;

    // NON EDITABLE!
    public var hitPoints : Float;
    public var cost : Resource;


    public function new () {
        hitPoints = maxHitPoints;
        cost = {minerals: 0, gas: 0};
    }

    public function damage() {
        hitPoints -= 1;
    }
} 