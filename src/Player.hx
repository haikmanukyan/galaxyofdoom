import h3d.Vector;
import Globals;

class Player {
    public var resources : Resource;
    public var color : Vector;
    public var uid: String;

    public function new () {
        resources = { minerals:0, gas:0 };
        color = new Vector(1,0,0);
    }

    public function GetResources(cost : Resource) {
        if (cost.minerals <= resources.minerals && cost.gas <= resources.gas) {
            resources.minerals -= cost.minerals;
            resources.gas -= cost.gas;
            return true;
        }
        return false;
    }
    public function AddResources(cost : Resource) {
        resources.minerals += cost.minerals;
        resources.gas += cost.gas;
    }
}