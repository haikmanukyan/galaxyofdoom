package actions;

import Action.ActionState;

class Deliver extends Action {
    var target : Unit;

    public function new (target : Unit) {
        this.target = target;
    }   

    public override function update(dt : Float){
        if (target != null && target.isAlive && target.stats.isDropPoint) {
            target.player.AddResources(unit.carries);
            unit.setCarries({minerals: 0, gas: 0});
            
            state = ActionState.Complete;
        }
        else {
            state = ActionState.Failed;
        }
    }
}