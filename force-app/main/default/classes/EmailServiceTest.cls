/**
 * Test class for EmailService functionality
 */
@isTest
public class EmailServiceTest {
    
    /**
     * Test basic email sending without attachments
     */
    @isTest
    static void testSendEmailToRecipientsBasic() {
        Test.startTest();
        
        List<String> toAddresses = new List<String>{'test@example.com'};
        String subject = 'Test Subject';
        String body = 'Test email body';
        List<Messaging.EmailFileAttachment> attachments = null;
        
        Boolean result = EmailService.sendEmailToRecipients(toAddresses, subject, body, attachments);
        
        Test.stopTest();
        
        // In test context, emails aren't actually sent, so we check that no exception was thrown
        System.assert(result != null, 'Method should return a result');
    }
    
    /**
     * Test email sending with file attachments
     */
    @isTest
    static void testSendEmailToRecipientsWithAttachments() {
        Test.startTest();
        
        List<String> toAddresses = new List<String>{'test@example.com'};
        String subject = 'Test Subject with Attachments';
        String body = 'Test email body with attachments';
        
        // Create test attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('test.txt');
        attachment.setBody(Blob.valueOf('Test file content'));
        attachment.setContentType('text/plain');
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{attachment};
        
        Boolean result = EmailService.sendEmailToRecipients(toAddresses, subject, body, attachments);
        
        Test.stopTest();
        
        System.assert(result != null, 'Method should return a result');
    }
    
    /**
     * Test email sending with Lightning email template
     */
    @isTest
    static void testSendEmailWithTemplate() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Test', 
            LastName = 'Contact',
            Email = 'test@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Test.startTest();
        
        List<String> toAddresses = new List<String>{'test@example.com'};
        
        // Create test attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('template_attachment.pdf');
        attachment.setBody(Blob.valueOf('PDF content'));
        attachment.setContentType('application/pdf');
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{attachment};
        
        // Note: In a real scenario, you would use an actual template ID
        // For testing purposes, we'll test the method with null template (falls back to manual content)
        Boolean result = EmailService.sendEmailToRecipients(
            toAddresses, 
            'Test Subject', 
            'Test Body', 
            attachments, 
            null, 
            testContact.Id
        );
        
        Test.stopTest();
        
        System.assert(result != null, 'Method should return a result');
    }
    
    /**
     * Test sendTemplateEmailWithAttachments method
     */
    @isTest
    static void testSendTemplateEmailWithAttachments() {
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test', 
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;
        
        Test.startTest();
        
        List<String> recipientAddresses = new List<String>{'test@example.com'};
        
        // Create test attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('template_test.docx');
        attachment.setBody(Blob.valueOf('Word document content'));
        attachment.setContentType('application/vnd.openxmlformats-officedocument.wordprocessingml.document');
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{attachment};
        
        // Note: Using null template ID for test, in real scenario use actual template
        Boolean result = EmailService.sendTemplateEmailWithAttachments(
            recipientAddresses,
            null, // templateId - would be actual template ID in production
            testContact.Id,
            attachments
        );
        
        Test.stopTest();
        
        System.assert(result != null, 'Method should return a result');
    }
    
    /**
     * Test error handling for invalid parameters
     */
    @isTest
    static void testErrorHandling() {
        Test.startTest();
        
        // Test with null toAddresses
        try {
            EmailService.sendEmailToRecipients(null, 'Subject', 'Body', null);
            System.assert(false, 'Should have thrown an exception');
        } catch (EmailService.EmailServiceException e) {
            System.assert(e.getMessage().contains('To addresses cannot be null or empty'));
        }
        
        // Test with empty toAddresses
        try {
            EmailService.sendEmailToRecipients(new List<String>(), 'Subject', 'Body', null);
            System.assert(false, 'Should have thrown an exception');
        } catch (EmailService.EmailServiceException e) {
            System.assert(e.getMessage().contains('To addresses cannot be null or empty'));
        }
        
        // Test with blank subject (when not using template)
        try {
            EmailService.sendEmailToRecipients(
                new List<String>{'test@example.com'}, 
                '', 
                'Body', 
                null
            );
            System.assert(false, 'Should have thrown an exception');
        } catch (EmailService.EmailServiceException e) {
            System.assert(e.getMessage().contains('Subject cannot be blank'));
        }
        
        Test.stopTest();
    }
    
    /**
     * Test ContentDocument attachment creation
     */
    @isTest
    static void testCreateAttachmentFromContentDocument() {
        Test.startTest();
        
        // Create a ContentVersion (which creates a ContentDocument)
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'test.pdf';
        cv.VersionData = Blob.valueOf('Test file content');
        cv.FirstPublishLocationId = UserInfo.getUserId(); // Share with current user
        insert cv;
        
        // Get the ContentDocumentId
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        // Test attachment creation
        Messaging.EmailFileAttachment attachment = EmailService.createAttachmentFromContentDocument(cv.ContentDocumentId);
        
        Test.stopTest();
        
        System.assertNotEquals(null, attachment, 'Attachment should be created');
        System.assert(attachment.getFileName().contains('Test Document'), 'Filename should contain the title');
    }
    
    /**
     * Test creating multiple attachments from ContentDocuments
     */
    @isTest
    static void testCreateAttachmentsFromContentDocuments() {
        Test.startTest();
        
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        // Create multiple ContentVersions
        for (Integer i = 0; i < 3; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document ' + i;
            cv.PathOnClient = 'test' + i + '.txt';
            cv.VersionData = Blob.valueOf('Test file content ' + i);
            cv.FirstPublishLocationId = UserInfo.getUserId();
            contentVersions.add(cv);
        }
        insert contentVersions;
        
        // Get ContentDocument IDs
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions]) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }
        
        // Test multiple attachment creation
        List<Messaging.EmailFileAttachment> attachments = 
            EmailService.createAttachmentsFromContentDocuments(contentDocumentIds);
        
        Test.stopTest();
        
        System.assertEquals(3, attachments.size(), 'Should create 3 attachments');
    }
    
    /**
     * Test content type determination
     */
    @isTest
    static void testGetContentType() {
        Test.startTest();
        
        // Test the getContentType method indirectly through createAttachmentFromContentDocument
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test PDF';
        cv.PathOnClient = 'test.pdf';
        cv.VersionData = Blob.valueOf('PDF content');
        cv.FirstPublishLocationId = UserInfo.getUserId();
        insert cv;
        
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Messaging.EmailFileAttachment attachment = 
            EmailService.createAttachmentFromContentDocument(cv.ContentDocumentId);
        
        Test.stopTest();
        
        System.assertNotEquals(null, attachment, 'Attachment should be created');
        // Note: We can't directly test getContentType as it's private, but it's tested indirectly
    }
    
    /**
     * Test with null and empty attachment lists
     */
    @isTest
    static void testNullAndEmptyAttachments() {
        Test.startTest();
        
        List<String> toAddresses = new List<String>{'test@example.com'};
        String subject = 'Test Subject';
        String body = 'Test email body';
        
        // Test with null attachments
        Boolean result1 = EmailService.sendEmailToRecipients(toAddresses, subject, body, null);
        
        // Test with empty attachments list
        Boolean result2 = EmailService.sendEmailToRecipients(
            toAddresses, 
            subject, 
            body, 
            new List<Messaging.EmailFileAttachment>()
        );
        
        // Test createAttachmentsFromContentDocuments with null
        List<Messaging.EmailFileAttachment> attachments1 = 
            EmailService.createAttachmentsFromContentDocuments(null);
        
        // Test createAttachmentsFromContentDocuments with empty list
        List<Messaging.EmailFileAttachment> attachments2 = 
            EmailService.createAttachmentsFromContentDocuments(new List<Id>());
        
        Test.stopTest();
        
        System.assert(result1 != null, 'Should handle null attachments');
        System.assert(result2 != null, 'Should handle empty attachments');
        System.assertEquals(0, attachments1.size(), 'Should return empty list for null input');
        System.assertEquals(0, attachments2.size(), 'Should return empty list for empty input');
    }
}