package actions;

import h3d.Vector;
import Action.ActionState;

class PlaceBuilding extends Action {
    var building : Unit;
    var position : Vector;

    public function new(builing : Unit, position : Vector) {
        this.building = builing;
        this.position = position;    
    }

    public override function update(dt : Float) {
        building.addToScene();
        building.position = position;
        state = ActionState.Complete;
    }

}