package actions;

import h3d.Vector;
import Action.ActionState;

class TrainUnit extends Action {
    var trainUnit : Unit;
    var delta : Vector;

    public function new(unit : Unit, delta : Vector) {
        this.trainUnit = unit;
        this.delta = delta;    
    }

    public override function update(dt : Float) {
        trainUnit.addToScene(unit.position.add(delta));
        state = ActionState.Complete;
    }

}