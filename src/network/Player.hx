// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 0.5.30
// 

package network;
import io.colyseus.serializer.schema.Schema;

class Player extends Schema {
	@:type("string")
	public var uid: String = "";

	@:type("number")
	public var color: Dynamic = 0;

	@:type("string")
	public var name: String = "";

	@:type("map", Unit)
	public var units: MapSchema<Unit> = new MapSchema<Unit>();

}
