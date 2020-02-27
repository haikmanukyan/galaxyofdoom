package controllers;
import io.colyseus.serializer.schema.Schema.DataChange;
import gamedata.Units;
import network.LobbyState;
import io.colyseus.Room;
import h3d.Vector;
import actions.Move;
import hxd.Key in K;


class GhostUnitController extends Controller {
    public var playerId: String;
    public var networkPlayer: network.Player;
    var room : Room<LobbyState>;
    public var unit : Unit;

    public function new (game : Game, networkPlayer : network.Player) {
        this.room = game.network.room;
        this.networkPlayer = networkPlayer;
        this.playerId = networkPlayer.uid;
        var player = new Player();
        player.color = Vector.fromColor(networkPlayer.color);
        
        super(game, player);
        this.isGhost = true;
    }

    public function onChange(changes : Array<DataChange>) {
        trace(changes);
    }

    public function onRemove() {
        unit.kill();        
    }

    function startNetworkCommand(message : Dynamic) {
        trace("starting");
        unit.startTask(Task.fromData(message.task, this));
    }

    public override function update(dt : Float) {
        
    }
}