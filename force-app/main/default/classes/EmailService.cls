/**
 * EmailService provides functionality for sending emails with attachment support
 * Designed for Lightning email templates and standard email communication
 */
public with sharing class EmailService {
    
    /**
     * Sends emails to specified recipients with optional attachments
     * @param toAddresses List of email addresses to send to
     * @param subject Email subject line
     * @param body Email body content
     * @param attachments List of email attachments
     * @param templateId Optional Lightning email template ID
     * @param targetObjectId Optional target object ID for template merge fields
     * @return Boolean indicating success of email send operation
     */
    public static Boolean sendEmailToRecipients(
        List<String> toAddresses,
        String subject,
        String body,
        List<Messaging.EmailFileAttachment> attachments
    ) {
        return sendEmailToRecipients(toAddresses, subject, body, attachments, null, null);
    }
    
    /**
     * Sends emails to specified recipients with optional attachments and template support
     * @param toAddresses List of email addresses to send to
     * @param subject Email subject line (ignored if templateId is provided)
     * @param body Email body content (ignored if templateId is provided)
     * @param attachments List of email attachments
     * @param templateId Optional Lightning email template ID
     * @param targetObjectId Optional target object ID for template merge fields
     * @return Boolean indicating success of email send operation
     */
    public static Boolean sendEmailToRecipients(
        List<String> toAddresses,
        String subject,
        String body,
        List<Messaging.EmailFileAttachment> attachments,
        Id templateId,
        Id targetObjectId
    ) {
        try {
            // Validate input parameters
            if (toAddresses == null || toAddresses.isEmpty()) {
                throw new EmailServiceException('To addresses cannot be null or empty');
            }
            
            // Create email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            // Set recipients
            email.setToAddresses(toAddresses);
            
            // Configure template or manual content
            if (templateId != null) {
                email.setTemplateId(templateId);
                if (targetObjectId != null) {
                    email.setTargetObjectId(targetObjectId);
                }
            } else {
                if (String.isBlank(subject)) {
                    throw new EmailServiceException('Subject cannot be blank when not using a template');
                }
                email.setSubject(subject);
                email.setHtmlBody(body);
            }
            
            // Apply attachments if provided
            if (attachments != null && !attachments.isEmpty()) {
                email.setFileAttachments(attachments);
            }
            
            // Send email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            
            // Check if email was sent successfully
            if (results != null && results.size() > 0) {
                Messaging.SendEmailResult result = results[0];
                if (!result.isSuccess()) {
                    System.debug('Email send failed: ' + result.getErrors());
                    return false;
                }
                return true;
            }
            
            return false;
            
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
            throw new EmailServiceException('Failed to send email: ' + e.getMessage());
        }
    }
    
    /**
     * Sends emails to multiple recipients with attachments using Lightning email template
     * @param recipientAddresses List of email addresses to send to
     * @param templateId Lightning email template ID
     * @param targetObjectId Target object ID for template merge fields
     * @param attachments List of email attachments
     * @return Boolean indicating success of email send operation
     */
    public static Boolean sendTemplateEmailWithAttachments(
        List<String> recipientAddresses,
        Id templateId,
        Id targetObjectId,
        List<Messaging.EmailFileAttachment> attachments
    ) {
        return sendEmailToRecipients(recipientAddresses, null, null, attachments, templateId, targetObjectId);
    }
    
    /**
     * Creates an email attachment from a ContentDocument
     * @param contentDocumentId The ID of the ContentDocument to attach
     * @return Messaging.EmailFileAttachment or null if not found
     */
    public static Messaging.EmailFileAttachment createAttachmentFromContentDocument(Id contentDocumentId) {
        try {
            // Query ContentVersion to get file data
            ContentVersion cv = [
                SELECT Title, VersionData, FileExtension, ContentSize 
                FROM ContentVersion 
                WHERE ContentDocumentId = :contentDocumentId 
                AND IsLatest = true 
                LIMIT 1
            ];
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(cv.Title + (String.isNotBlank(cv.FileExtension) ? '.' + cv.FileExtension : ''));
            attachment.setBody(cv.VersionData);
            attachment.setContentType(getContentType(cv.FileExtension));
            
            return attachment;
            
        } catch (QueryException e) {
            System.debug('ContentDocument not found: ' + contentDocumentId);
            return null;
        }
    }
    
    /**
     * Creates email attachments from multiple ContentDocument IDs
     * @param contentDocumentIds List of ContentDocument IDs
     * @return List of Messaging.EmailFileAttachment objects
     */
    public static List<Messaging.EmailFileAttachment> createAttachmentsFromContentDocuments(List<Id> contentDocumentIds) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        if (contentDocumentIds == null || contentDocumentIds.isEmpty()) {
            return attachments;
        }
        
        for (Id contentDocId : contentDocumentIds) {
            Messaging.EmailFileAttachment attachment = createAttachmentFromContentDocument(contentDocId);
            if (attachment != null) {
                attachments.add(attachment);
            }
        }
        
        return attachments;
    }
    
    /**
     * Helper method to determine content type based on file extension
     * @param fileExtension The file extension
     * @return Content type string
     */
    private static String getContentType(String fileExtension) {
        if (String.isBlank(fileExtension)) {
            return 'application/octet-stream';
        }
        
        String ext = fileExtension.toLowerCase();
        
        Map<String, String> contentTypes = new Map<String, String>{
            'pdf' => 'application/pdf',
            'doc' => 'application/msword',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls' => 'application/vnd.ms-excel',
            'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'txt' => 'text/plain',
            'csv' => 'text/csv',
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'zip' => 'application/zip'
        };
        
        return contentTypes.containsKey(ext) ? contentTypes.get(ext) : 'application/octet-stream';
    }
    
    /**
     * Custom exception class for EmailService errors
     */
    public class EmailServiceException extends Exception {}
}