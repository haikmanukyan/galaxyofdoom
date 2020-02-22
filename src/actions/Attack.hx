package actions;

import h3d.Vector;
import Action.ActionState;

class Attack extends Action {
    var target : Unit;

    public function new (target : Unit) {
        this.target = target;
    }   

    public override function update(dt : Float){
        if (target != null  && ! target.stats.isInvulnerable) {
            if (target.isAlive) {
                target.stats.damage();
                unit.display.setDirection(target.position.sub(unit.position));
                state = ActionState.Complete;
            }
            else {
                state = ActionState.Failed;
                unit.playAnimation("idle");
            }
        }
        else {
            state = ActionState.Failed;
        }
    }

}