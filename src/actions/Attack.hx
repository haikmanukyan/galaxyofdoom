package actions;

import h3d.Vector;
import Action.ActionState;

class Attack extends Action {
    var target : Unit;
    var amount : Float;

    public function new (target : Unit, amount : Float = -1) {
        this.target = target;
        this.amount = amount;
    }   

    public override function update(dt : Float){
        if (target != null  && ! target.stats.isInvulnerable) {
            if (target.isAlive) {
                amount = this.amount == -1 ? 1 : this.amount;
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
            unit.playAnimation("idle");
        }
    }

    public override function dump() : Dynamic {
        return {
            type: "Attack",
            target: target.uid,
            amout: amount
        };
    }

}