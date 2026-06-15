public without sharing class ContactService {
	public static Contact getProfile() {
        List<Contact> contacts = [SELECT Id, Account.Name, Account.Website, Languages_t__c,
                                  Website_url__c, MailingAddress, Description, Name, Phone,
                                  Birthdate, Age_f__c, Email, GitHub_u__c, LinkedIn_u__c
                                  FROM Contact
                                  WHERE LastName = 'Das' AND FirstName = 'Vishal'];
        return contacts[0];
    }
    
    public static void push(List<Contact> newList) {
        for(Contact c: newList){
            if (c.LastName == 'Das' && c.FirstName == 'Vishal') {
                GitHubWorkflowInvoker.enqueueJob('profile');
                break;
            }
        }
    }
    
    public static String processMessage(String message) {
        RequestBody body;
        try {
            body = (RequestBody) JSON.deserialize(message, RequestBody.Class);
        } catch(Exception e) {
            throw new GeneralException('Invalid body!', 400);
        }
        if (String.isBlank(body.message) || String.isBlank(body.email) || String.isBlank(body.name))
            throw new GeneralException('Atleast one of the following fields are missing [name, email, message].', 400);
        String[] names = body.name.trim().split('\\s');
        String firstName = '', lastName;
        if (names.size() == 1)
            lastName = names[0];
        else {
            firstName = names[0];
            names.remove(0);
            lastName = String.join(names, ' ');
        }
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :body.email];
        if (contacts.isEmpty())
            contacts.add(new Contact());
        for (Contact c: contacts) {
            c.LastName = lastName;
            c.FirstName = firstName;
            c.Email = body.email;
        }
        upsert contacts;
        List<Message__c> messages = new List<Message__c>();
        for (Contact c: contacts) {
            messages.add(new Message__c(Text_tal__c = body.message, Contact_mdr__c = c.Id));
        }
        insert messages;
        return 'ok';
    }
    
    class RequestBody {
        String message;
        String email;
        String name;
    }
    
}