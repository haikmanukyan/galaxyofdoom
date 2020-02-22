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
        stats.physicsSize = 1;
        stats.isResource = true;
        stats.isInvulnerable = true;
        stats.physicsSize = 1.5;
        
        var model = controller.game.cache.loadModel(hxd.Res.Ore);
        model.scale(0.03);
        model.getMaterials()[0].color = new Vector(0,0.4,1);
        stats.movementSpeed = 0;
		
		var resourceNode : Unit = new Unit(controller, model, stats, StatesEnum.Passive, STATIC_BODY);
        resourceNode.carries = {minerals: 50, gas: 0};
        
        return resourceNode;
    }
    public static function GasGeyser (controller : Controller) {
		var stats = new UnitStats();
        stats.physicsSize = 4;
        stats.isResource = true;
        stats.isInvulnerable = true;
        
        var model = controller.game.cache.loadModel(hxd.Res.OilWell);
        model.scale(0.03);
        // model.getMaterials()[0].color = new Vector(0,1,0.5);
        stats.movementSpeed = 0;
        
        var resourceNode : Unit = new Unit(controller, model, stats, StatesEnum.Passive, STATIC_BODY);
        resourceNode.carries = {minerals: 0, gas: 50};
		
        return resourceNode;
    }
}