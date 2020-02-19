package actions;

import box2D.common.math.B2Vec2;
import Action.ActionState;
import h3d.Vector;

class MoveTarget extends Action {
    var target : Unit;
    var stoppingDistance : Float;

    public function new(target : Unit, stoppingDistance : Float = 3) {
        this.target = target;
        this.stoppingDistance = stoppingDistance;
    }

    public override function update(dt : Float) {
        if (target != null && target.isAlive) {
            unit.setDestination(target.position);
            unit.stoppingDistance = stoppingDistance + target.stats.physicsSize + unit.stats.physicsSize;
            
            if (unit.reachedDestination()) {
                state = ActionState.Complete;
                unit.stoppingDistance = 1;
            }
        }
        else {
            state = ActionState.Failed;
        }
    }
}