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

    var demoUnit:Unit;

    public function new (game : Game, player : Player, playerId : String) {
        super(game, player);
        this.playerId = playerId;
        initNetwork();
    }

    public function initNetwork() {
        room = Network.getInstance().room;
        room.onMessage += onMessage;

        room.send({
            "type":"getUnitById",
            "uid":playerId + "_startingUnit"
        });
    }

    public function onMessage (message : Dynamic) {
        switch (message.type) {
            case "command":
                if (message.playerId != playerId) return;
                startNetworkCommand(message.task);
            case "unitInfo":
                var unit = Units.Worker(this);
                unit.uid = playerId + "_startingUnit";
                unit.addToScene(Utils.arr2vec(message.position));

                demoUnit = unit;
        }
    }

    function startNetworkCommand(taskData : Dynamic) {
        var task = Task.fromData(taskData);
        demoUnit.startTask(task);
    }

    public override function update(dt : Float) {
        
    }
}