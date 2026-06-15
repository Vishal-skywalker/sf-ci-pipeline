trigger ContactTrigger on Contact (after insert, after update, after delete) {
	ContactService.push(Trigger.new);
}