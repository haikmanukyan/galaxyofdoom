package network;

import network.LobbyState;
import io.colyseus.Client;
import io.colyseus.Room;


class Network {
    public var client : Client;
    public var room : Room<LobbyState>;
    static var instance : Network;

    public function new () {
    }

    public static function getInstance() {
        if (instance == null)
            instance = new Network();
        return instance;
    }

    public function join() {
        client = new Client('ws://localhost:2567');
        // client = new Client('wss://galaxy-of-doom.herokuapp.com/');

        client.joinOrCreate("lobby", [], LobbyState, function(err, room) {           
            if (err != null) {
                trace("JOIN ERROR: " + err);
                return;
            }

            this.room = room;
        });
    }

    public static function SendUnitCreated(unit : Unit) {

    }

    public static function SendUnitDeath(unitId : String) {

    }

    public static function SendUnitDamage(unitId : String, amount : Float) {

    }

    public static function SendUnitCommand(unitId : String, task : Task) {
        if (instance.room != null) {
            instance.room.send({
                type: "unitCommand",
                unitId: unitId,
                task: task.dump(),
                repeat: task.repeat
            });
        }
    }
}