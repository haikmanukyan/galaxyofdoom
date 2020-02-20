package actions;

import box2D.common.math.B2Vec2;
import Action.ActionState;
import h3d.Vector;

class Move extends Action {
    var destination : Vector;
    var stoppingDistance : Float;

    public function new(destination : Vector, stoppingDistance : Float = 3) {
        this.destination = destination;
        this.stoppingDistance = stoppingDistance;
    }

    public override function update(dt : Float) {
        if (unit.reachedDestination(destination, stoppingDistance)) {
            state = ActionState.Complete;
            unit.stoppingDistance = 1;
        }
        else {
            unit.setDestination(destination);
            unit.stoppingDistance = stoppingDistance;
        }
    }
}