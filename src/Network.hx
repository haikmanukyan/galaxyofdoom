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

        client.joinOrCreate("lobby", [], LobbyState, function(err, room) {           
            if (err != null) {
                trace("JOIN ERROR: " + err);
                return;
            }

            this.room = room;
            // room.state.units.onAdd = onEntityAdd;
            // room.onMessage += onMessage;        
            // room.state.units.onChange = onEntitiesChange;
            // room.state.units.onRemove = onEntityRemoved;
        });
    }

    public function onMessage(message : Dynamic) {
        trace(message);
    }

    public function onEntityAdd(entity : Dynamic, key : Dynamic) {
        entity.onChange = onEntityChange;
        trace("entity added at " + key + " => " + entity);
    }

    public function onEntityChange(changes : Dynamic) {
        trace("entity changes => " + changes);
    }

    public function onEntitiesChange(entity : Dynamic, key : Dynamic) {
        trace("entity changed at " + key + " => " + entity);
    }

    public function onEntityRemoved(entity : Dynamic, key : Dynamic) {
        trace("entity removed at " + key + " => " + entity);
    }
}