import '../models/email_template_model.dart';

final List<EmailTemplate> defaultEmailTemplates = [
  EmailTemplate(
    templateId: 'tmpl_customer_service',
    userId: 'system',
    templateName: 'Customer Service Reply',
    subject: 'RE: Your inquiry to AutoLedger',
    body: 'Hello {{customer_name}},\n\nThank you for contacting us. Our team will respond to your question as soon as possible.\n\nBest,\nAutoLedger Support',
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
  ),
  EmailTemplate(
    templateId: 'tmpl_promotional',
    userId: 'system',
    templateName: 'Promotional Offer',
    subject: 'Special Offer Just for You!',
    body: 'Dear {{customer_name}},\n\nWe\'re excited to share our latest promotion with you. Enjoy 20% off your next purchase with code SAVE20.\n\nCheers,\nAutoLedger Team',
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
  ),
  EmailTemplate(
    templateId: 'tmpl_new_invoice',
    userId: 'system',
    templateName: 'New Invoice Notification',
    subject: 'New Invoice {{invoice_number}}',
    body: 'Hi {{customer_name}},\n\nA new invoice ({{invoice_number}}) has been created for your account. Please review it at your convenience.\n\nThank you,\nAutoLedger Billing',
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
  ),
  EmailTemplate(
    templateId: 'tmpl_overdue_30',
    userId: 'system',
    templateName: 'Invoice 30 Days Overdue',
    subject: 'Invoice {{invoice_number}} is 30 Days Overdue',
    body: 'Dear {{customer_name}},\n\nOur records show that invoice {{invoice_number}} is now 30 days overdue. Please make a payment as soon as possible or contact us if you need assistance.\n\nRegards,\nAutoLedger Billing',
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
  ),
  EmailTemplate(
    templateId: 'tmpl_overdue_60',
    userId: 'system',
    templateName: 'Invoice 60 Days Overdue',
    subject: 'Invoice {{invoice_number}} is 60 Days Overdue',
    body: 'Hello {{customer_name}},\n\nThis is a reminder that invoice {{invoice_number}} is 60 days past due. Please remit payment immediately or reach out to discuss payment arrangements.\n\nThank you,\nAutoLedger Billing',
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
  ),
];