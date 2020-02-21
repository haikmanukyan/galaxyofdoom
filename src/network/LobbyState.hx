// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 0.5.30
// 

package network;
import io.colyseus.serializer.schema.Schema;

class LobbyState extends Schema {
	@:type("map", Unit)
	public var units: MapSchema<Unit> = new MapSchema<Unit>();

	@:type("map", Player)
	public var players: MapSchema<Player> = new MapSchema<Player>();

}
