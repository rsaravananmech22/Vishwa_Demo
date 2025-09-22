# Vishwa_Demo

## EmailUtils Enhancement

This repository includes enhanced EmailUtils functionality with support for sending emails with flexible attachment handling.

### New Methods

#### `EmailUtils.sendEmailToRecipients(recipients, subject, body, options)`

Sends an email to the specified recipients with support for multiple attachment types.

**Parameters:**
- `recipients` (string|array): Email addresses of recipients (string or array of strings)
- `subject` (string): Email subject line
- `body` (string): Email body content
- `options` (object, optional): Additional options for the email
  - `attachment` (object): Single attachment (for backward compatibility)
  - `attachments` (array): Array of attachment objects
  - `files` (array): Array of file objects that will be converted to attachments

**Returns:** Email data object with processed attachments

**Example:**
```javascript
// Basic usage
var email = EmailUtils.sendEmailToRecipients(
  ['user1@example.com', 'user2@example.com'],
  'Meeting Notes',
  'Please find the meeting notes attached.'
);

// With attachments
var email = EmailUtils.sendEmailToRecipients(
  'user@example.com',
  'Documents',
  'Here are the requested documents.',
  {
    files: [
      { name: 'report.pdf', content: 'base64content', type: 'application/pdf' },
      { name: 'data.csv', content: 'csvdata', type: 'text/csv' }
    ]
  }
);
```

#### `EmailUtils.createAttachment(filename, content, contentType, encoding)`

Creates a standardized attachment object for use with email sending.

**Parameters:**
- `filename` (string): Name of the attachment file
- `content` (string): File content (typically base64 encoded)
- `contentType` (string, optional): MIME type of the file (defaults to 'application/octet-stream')
- `encoding` (string, optional): Content encoding (defaults to 'base64')

**Returns:** Attachment object

**Example:**
```javascript
var attachment = EmailUtils.createAttachment(
  'document.pdf',
  'base64encodedcontent',
  'application/pdf'
);
```

### Features

- **Backward Compatibility**: Supports existing `attachment` parameter
- **Flexible Attachment Handling**: Multiple ways to add attachments
- **Validation**: Comprehensive parameter validation with meaningful error messages
- **Generic Attachment Creation**: Utility method for creating standardized attachment objects