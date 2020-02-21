// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 0.5.30
// 

package network;
import io.colyseus.serializer.schema.Schema;

class Unit extends Schema {
	@:type("string")
	public var uid: String = "";

	@:type("string")
	public var name: String = "";

	@:type("array", "number")
	public var position: ArraySchema<Dynamic> = new ArraySchema<Dynamic>();

}
