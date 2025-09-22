/**
 * Example usage of EmailService with attachment support
 * This class demonstrates various ways to use the enhanced sendEmailToRecipients method
 */
public with sharing class EmailServiceUsageExample {
    
    /**
     * Example 1: Send a basic email with file attachments
     */
    public static void sendBasicEmailWithAttachments() {
        try {
            // Prepare recipients
            List<String> recipients = new List<String>{'user@example.com', 'manager@example.com'};
            
            // Create attachments
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            // Add a text file attachment
            Messaging.EmailFileAttachment textAttachment = new Messaging.EmailFileAttachment();
            textAttachment.setFileName('report.txt');
            textAttachment.setBody(Blob.valueOf('Monthly sales report data...'));
            textAttachment.setContentType('text/plain');
            attachments.add(textAttachment);
            
            // Add a CSV file attachment
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            csvAttachment.setFileName('data.csv');
            csvAttachment.setBody(Blob.valueOf('Name,Amount\nClient A,1000\nClient B,2000'));
            csvAttachment.setContentType('text/csv');
            attachments.add(csvAttachment);
            
            // Send email with attachments
            Boolean success = EmailService.sendEmailToRecipients(
                recipients,
                'Monthly Report with Attachments',
                '<h2>Monthly Report</h2><p>Please find the attached monthly sales report.</p>',
                attachments
            );
            
            if (success) {
                System.debug('Email sent successfully with attachments');
            }
            
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
        }
    }
    
    /**
     * Example 2: Send email using Lightning email template with attachments
     */
    public static void sendTemplateEmailWithAttachments(Id templateId, Id contactId) {
        try {
            // Get contact email
            Contact contact = [SELECT Email FROM Contact WHERE Id = :contactId LIMIT 1];
            List<String> recipients = new List<String>{contact.Email};
            
            // Create attachment from existing ContentDocument
            List<Id> contentDocIds = new List<Id>();
            // Assume we have ContentDocument IDs (these would come from file uploads or document library)
            // contentDocIds.add('069XXXXXXXXXXXXXXX'); // Replace with actual ContentDocument ID
            
            List<Messaging.EmailFileAttachment> attachments = 
                EmailService.createAttachmentsFromContentDocuments(contentDocIds);
            
            // Send template email with attachments
            Boolean success = EmailService.sendTemplateEmailWithAttachments(
                recipients,
                templateId,
                contactId,
                attachments
            );
            
            if (success) {
                System.debug('Template email sent successfully with attachments');
            }
            
        } catch (Exception e) {
            System.debug('Error sending template email: ' + e.getMessage());
        }
    }
    
    /**
     * Example 3: Send email with mixed attachment types
     */
    public static void sendEmailWithMixedAttachments() {
        try {
            List<String> recipients = new List<String>{'client@example.com'};
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            // PDF attachment
            Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
            pdfAttachment.setFileName('contract.pdf');
            pdfAttachment.setBody(createSamplePdfBlob()); // Helper method to create PDF blob
            pdfAttachment.setContentType('application/pdf');
            attachments.add(pdfAttachment);
            
            // Image attachment
            Messaging.EmailFileAttachment imageAttachment = new Messaging.EmailFileAttachment();
            imageAttachment.setFileName('company_logo.png');
            imageAttachment.setBody(createSampleImageBlob()); // Helper method to create image blob
            imageAttachment.setContentType('image/png');
            attachments.add(imageAttachment);
            
            // Send email
            Boolean success = EmailService.sendEmailToRecipients(
                recipients,
                'Contract and Logo Files',
                '<p>Please find attached the contract and our company logo.</p>',
                attachments
            );
            
            if (success) {
                System.debug('Email sent with mixed attachments');
            }
            
        } catch (Exception e) {
            System.debug('Error sending email with mixed attachments: ' + e.getMessage());
        }
    }
    
    /**
     * Example 4: Bulk email sending with attachments
     */
    public static void sendBulkEmailsWithAttachments(List<Contact> contacts) {
        try {
            // Create common attachments for all emails
            List<Messaging.EmailFileAttachment> commonAttachments = new List<Messaging.EmailFileAttachment>();
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('newsletter.pdf');
            attachment.setBody(Blob.valueOf('Newsletter content...'));
            attachment.setContentType('application/pdf');
            commonAttachments.add(attachment);
            
            // Send to each contact individually
            for (Contact contact : contacts) {
                if (String.isNotBlank(contact.Email)) {
                    List<String> recipients = new List<String>{contact.Email};
                    
                    Boolean success = EmailService.sendEmailToRecipients(
                        recipients,
                        'Monthly Newsletter',
                        '<p>Dear ' + contact.FirstName + ',</p><p>Please find our monthly newsletter attached.</p>',
                        commonAttachments
                    );
                    
                    if (!success) {
                        System.debug('Failed to send email to: ' + contact.Email);
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Error in bulk email sending: ' + e.getMessage());
        }
    }
    
    /**
     * Helper method to create a sample PDF blob (placeholder)
     */
    private static Blob createSamplePdfBlob() {
        // In a real scenario, this would create actual PDF content
        return Blob.valueOf('%PDF-1.4 Sample PDF content...');
    }
    
    /**
     * Helper method to create a sample image blob (placeholder)
     */
    private static Blob createSampleImageBlob() {
        // In a real scenario, this would be actual image binary data
        return Blob.valueOf('Sample image binary data...');
    }
    
    /**
     * Example 5: Error handling demonstration
     */
    public static void demonstrateErrorHandling() {
        try {
            // This will throw an exception due to empty recipients
            EmailService.sendEmailToRecipients(
                new List<String>(),
                'Test Subject',
                'Test Body',
                null
            );
            
        } catch (EmailService.EmailServiceException e) {
            System.debug('Caught EmailServiceException: ' + e.getMessage());
            // Handle the error appropriately - log, notify admin, etc.
        }
    }
}