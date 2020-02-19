package actions;

import Action.ActionState;

class Gather extends Action {
    var target : Unit;

    public function new (target : Unit) {
        this.target = target;
    }   

    public override function update(dt : Float){
        if (target != null && target.carries != null) {
            unit.setCarries(target.carries);
            state = ActionState.Complete;
        }
    }
}