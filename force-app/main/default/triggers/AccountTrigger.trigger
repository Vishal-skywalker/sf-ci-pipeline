trigger AccountTrigger on Account (after insert, after delete, after update) {
	AccountService.push(Trigger.New);
}