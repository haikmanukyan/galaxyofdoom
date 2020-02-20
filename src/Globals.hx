import hxd.res.Image;
import States.StatesEnum;

typedef Resource = { minerals : Int, gas : Int }
typedef Transition = { condition : Dynamic, trueState : StatesEnum }
typedef ControlNode = { key:Int, action:Dynamic, name:String, icon:Image, description:String}

