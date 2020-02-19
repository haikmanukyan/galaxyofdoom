import States.StatesEnum;

typedef Resource = { minerals : Int, gas : Int }
typedef Transition = { condition : Dynamic, trueState : StatesEnum }
typedef ControlNode = { key:Int, action:Dynamic }

