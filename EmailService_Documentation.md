# Email Service with Attachment Support

## Overview

The `EmailService` class provides enhanced email functionality for Salesforce applications, specifically designed to support Lightning email templates with attachments. This addresses the limitation where attachments from Lightning email templates were not being sent in emails.

## Key Features

### 1. Enhanced `sendEmailToRecipients` Method

The main method now supports attachments as a parameter:

```apex
public static Boolean sendEmailToRecipients(
    List<String> toAddresses,
    String subject,
    String body,
    List<Messaging.EmailFileAttachment> attachments
)
```

### 2. Lightning Email Template Support

Send emails using Lightning email templates with attachments:

```apex
public static Boolean sendEmailToRecipients(
    List<String> toAddresses,
    String subject,
    String body,
    List<Messaging.EmailFileAttachment> attachments,
    Id templateId,
    Id targetObjectId
)
```

### 3. Content Document Integration

Create attachments directly from Salesforce ContentDocuments:

```apex
// Single attachment
Messaging.EmailFileAttachment attachment = 
    EmailService.createAttachmentFromContentDocument(contentDocumentId);

// Multiple attachments
List<Messaging.EmailFileAttachment> attachments = 
    EmailService.createAttachmentsFromContentDocuments(contentDocumentIds);
```

## Method Signatures

### Core Methods

1. **`sendEmailToRecipients`** - Basic email with attachments
   - Parameters: toAddresses, subject, body, attachments
   - Returns: Boolean (success/failure)

2. **`sendEmailToRecipients`** - Full featured with template support
   - Parameters: toAddresses, subject, body, attachments, templateId, targetObjectId
   - Returns: Boolean (success/failure)

3. **`sendTemplateEmailWithAttachments`** - Template-focused method
   - Parameters: recipientAddresses, templateId, targetObjectId, attachments
   - Returns: Boolean (success/failure)

### Utility Methods

4. **`createAttachmentFromContentDocument`** - Single attachment from ContentDocument
   - Parameters: contentDocumentId
   - Returns: Messaging.EmailFileAttachment

5. **`createAttachmentsFromContentDocuments`** - Multiple attachments from ContentDocuments
   - Parameters: contentDocumentIds
   - Returns: List<Messaging.EmailFileAttachment>

## Usage Examples

### Basic Email with Attachments

```apex
List<String> recipients = new List<String>{'user@example.com'};

// Create attachment
Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
attachment.setFileName('report.pdf');
attachment.setBody(pdfBlob);
attachment.setContentType('application/pdf');

List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{attachment};

// Send email
Boolean success = EmailService.sendEmailToRecipients(
    recipients,
    'Monthly Report',
    'Please find the attached report.',
    attachments
);
```

### Lightning Template with Attachments

```apex
List<String> recipients = new List<String>{'contact@example.com'};
Id templateId = '00XXXXXXXXXXXXX'; // Your Lightning email template ID
Id contactId = '003XXXXXXXXXXXXX'; // Target contact ID

// Create attachments from ContentDocuments
List<Id> contentDocIds = new List<Id>{'069XXXXXXXXXXXXX'};
List<Messaging.EmailFileAttachment> attachments = 
    EmailService.createAttachmentsFromContentDocuments(contentDocIds);

// Send template email with attachments
Boolean success = EmailService.sendTemplateEmailWithAttachments(
    recipients,
    templateId,
    contactId,
    attachments
);
```

### Content Document Attachments

```apex
// From ContentDocument IDs (from file uploads or document library)
List<Id> contentDocIds = new List<Id>{'069XXXXXXXXXXXXX', '069YYYYYYYYYYY'};
List<Messaging.EmailFileAttachment> attachments = 
    EmailService.createAttachmentsFromContentDocuments(contentDocIds);

EmailService.sendEmailToRecipients(
    recipients,
    'Documents Attached',
    'Please review the attached documents.',
    attachments
);
```

## Supported File Types

The service automatically determines content types for common file extensions:

- **Documents**: PDF, DOC, DOCX, XLS, XLSX, TXT, CSV
- **Images**: PNG, JPG, JPEG, GIF
- **Archives**: ZIP
- **Default**: application/octet-stream

## Error Handling

The service includes comprehensive error handling:

- **EmailServiceException**: Custom exception for email-specific errors
- **Validation**: Checks for required parameters (recipients, subject when not using templates)
- **Logging**: Debug logs for troubleshooting failed email sends

```apex
try {
    Boolean success = EmailService.sendEmailToRecipients(recipients, subject, body, attachments);
} catch (EmailService.EmailServiceException e) {
    System.debug('Email error: ' + e.getMessage());
    // Handle error appropriately
}
```

## Best Practices

1. **Attachment Size**: Be mindful of Salesforce email attachment size limits (25MB total)
2. **Bulk Operations**: For bulk emails, consider governor limits and use batch processing if needed
3. **Error Handling**: Always wrap email operations in try-catch blocks
4. **Template Testing**: Test Lightning email templates with attachments in sandbox environments first
5. **Content Security**: Ensure proper sharing settings on ContentDocuments used as attachments

## Testing

Comprehensive test coverage is provided in `EmailServiceTest.cls`:

- Basic email functionality
- Attachment handling
- Template email support
- Error scenarios
- ContentDocument integration
- Edge cases (null/empty parameters)

## Migration from Legacy Code

If you have existing `sendEmailToRecipients` implementations:

1. **Add attachment parameter**: Modify method signature to include `List<Messaging.EmailFileAttachment> attachments`
2. **Update calls**: Add `null` or empty list for existing calls without attachments
3. **Enhanced calls**: Use new attachment functionality where needed

### Before
```apex
Boolean result = sendEmailToRecipients(toAddresses, subject, body);
```

### After
```apex
Boolean result = EmailService.sendEmailToRecipients(toAddresses, subject, body, null);
// or with attachments
Boolean result = EmailService.sendEmailToRecipients(toAddresses, subject, body, attachments);
```

## Performance Considerations

- **Single Email Message**: Each method call sends one email to multiple recipients
- **Governor Limits**: Consider daily email limits and DML operations when processing large batches
- **Attachment Processing**: ContentDocument queries are optimized but consider batch processing for large volumes

## Security

- **Sharing Rules**: Respects Salesforce sharing rules for ContentDocuments
- **Permission Checks**: Ensures users have access to referenced ContentDocuments
- **Data Security**: Uses `with sharing` for proper security context enforcement