package actions;

import Action.ActionState;

class Play extends Action {
    var animationName : String;

    public function new(animationName : String) {
        this.animationName = animationName;
    }

    public override function update(dt:Float) {
        if (unit.animations.exists(animationName)) {
            unit.playAnimation(animationName);
            state = Complete;        
        }
        else {
            state = Complete;   
        }
    }
}