package controllers;
import gamedata.Units;
import network.LobbyState;
import io.colyseus.Room;
import h3d.Vector;
import actions.Move;
import hxd.Key in K;


class GhostController extends GroupController {
    var room : Room<LobbyState>;
    public var playerId: String;
    public var networkPlayer: network.Player;

    var demoUnit:Unit;

    public function new (game : Game, networkPlayer : network.Player) {
        this.room = game.network.room;
        this.networkPlayer = networkPlayer;
        this.playerId = networkPlayer.uid;
        var player = new Player();
        player.color = Vector.fromColor(networkPlayer.color);
        
        super(game, player);
        
        initNetwork();
    }

    function onUnitAdded(networkUnit : network.Unit, unitId : String) {
        trace("NEW UJNIT");
        var unitSpawn = Units.Get(networkUnit.name);
        if (unitSpawn != null) {
            var unit = unitSpawn(this);
            unit.uid = networkUnit.uid;
            unit.addToScene(new Vector(
                networkUnit.position.items[0], 
                networkUnit.position.items[1],
                networkUnit.position.items[2]));
        }
        
    }

    public function initNetwork() {
        for (networkUnit in networkPlayer.units) {
            onUnitAdded(networkUnit, networkUnit.uid);
        }

        networkPlayer.units.onAdd = onUnitAdded;
        room.onMessage += onMessage;
    }

    public function onMessage (message : Dynamic) {
        switch (message.type) {
            case "command":
                trace(message.playerId, playerId);
                if (message.playerId == playerId) {
                    startNetworkCommand(message);
                }
        }
    }

    function startNetworkCommand(message : Dynamic) {
        trace("starting");
        var arr: Array<String> = message.unitIds;
        for (unitId in arr) {
            var unit = game.unitMap[unitId];
            if (unit != null) {
                unit.startTask(Task.fromData(message.task));
            }
        }
    }

    public override function update(dt : Float) {
        
    }
}