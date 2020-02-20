package gamedata;

import controllers.Controller;
import gamedata.States.StatesEnum;
import box2D.dynamics.B2BodyType;
import actions.*;
import h3d.Vector;
import hxd.Key in K;

class RecourceNodes {
    public static function MineralPatch (controller : Controller) {
		var stats = new UnitStats();
        stats.physicsSize = 0.7;
        stats.isResource = true;
        
        var model = controller.game.cache.loadModel(hxd.Res.Cube);
        model.scale(0.7);
        model.getMaterials()[0].color = new Vector(0,0.4,1);
        stats.movementSpeed = 0;
		
		var resourceNode : Unit = new Unit(controller, model, stats, StatesEnum.Passive, STATIC_BODY);
        resourceNode.carries = {minerals: 50, gas: 0};
        
        return resourceNode;
    }
    public static function GasGeyser (controller : Controller) {
		var stats = new UnitStats();
        stats.physicsSize = 0.7;
        stats.isResource = true;
        
        var model = controller.game.cache.loadModel(hxd.Res.Cube);
        model.scale(1.1);
        model.getMaterials()[0].color = new Vector(0,1,0.5);
        stats.movementSpeed = 0;
        
        var resourceNode : Unit = new Unit(controller, model, stats, StatesEnum.Passive, STATIC_BODY);
        resourceNode.carries = {minerals: 0, gas: 50};
		
        return resourceNode;
    }
}