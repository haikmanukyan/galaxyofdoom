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

    public function initNetwork() {
        for (networkUnit in networkPlayer.units) {
            onUnitAdded(networkUnit, networkUnit.uid);
        }

        room.onMessage += onMessage;
        networkPlayer.units.onAdd = onUnitAdded;
    }

    public function onMessage (message : Dynamic) {
        switch (message.type) {
            case "command":
                if (message.playerId == playerId) {
                    startNetworkCommand(message);
                }
            case "unitCommand":
                if (message.playerId == playerId) {
                    startUnitCommand(message);
                }
        }
    }

    function onUnitAdded(networkUnit : network.Unit, unitId : String) {
        var unitSpawn = Units.Get(networkUnit.name);
        if (unitSpawn != null) {
            var unit = unitSpawn(this);
            unit.uid = networkUnit.uid;
            unit.ai = new GhostUnitController(game, networkPlayer);
            unit.addToScene(new Vector(
                networkUnit.position.items[0], 
                networkUnit.position.items[1],
                networkUnit.position.items[2]));
            
            var networkAi : GhostUnitController = cast(unit.ai, GhostUnitController);
        }
        
    }

    function onUnitKilled() {

    }

    function startNetworkCommand(message : Dynamic) {
        var arr: Array<String> = message.unitIds;
        for (unitId in arr) {
            var unit = game.unitMap[unitId];
            if (unit != null) {
                unit.startTask(Task.fromData(message.task, this));
            }
        }
    }

    function startUnitCommand(message : Dynamic) {
        var unit = game.unitMap[message.unitId];
        if (unit != null)
            unit.startTask(Task.fromData(message.task, this));
    }

    public override function update(dt : Float) {
        
    }
}