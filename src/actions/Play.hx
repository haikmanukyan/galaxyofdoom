package actions;

import Action.ActionState;

class Play extends Action {
    public function new() {
        state = ActionState.Complete;
    }
}