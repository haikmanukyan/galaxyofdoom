// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 0.5.30
// 

package network;
import io.colyseus.serializer.schema.Schema;

class MoveAction extends Action {
	@:type("ref", Vector)
	public var destination: Vector = new Vector();

	@:type("number")
	public var stoppingDistance: Dynamic = 0;

}
