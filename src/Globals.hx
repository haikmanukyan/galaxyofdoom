import gamedata.States.StatesEnum;
import hxd.res.Image;

typedef Resource = { minerals : Int, gas : Int }
typedef Transition = { condition : Dynamic, trueState : StatesEnum }
typedef ControlNode = { key:Int, action:Dynamic, name:String, icon:Image, description:String}

