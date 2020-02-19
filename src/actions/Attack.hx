package actions;

import h3d.Vector;
import Action.ActionState;

class Attack extends Action {
    var target : Unit;

    public function new (target : Unit) {
        this.target = target;
    }   

    public override function update(dt : Float){
        if (target != null) {
            if (target.isAlive) {
                target.stats.damage();
                state = ActionState.Complete;
            }
            else {
                state = ActionState.Failed;
            }
        }
        else {
            state = ActionState.Failed;
        }
    }

}