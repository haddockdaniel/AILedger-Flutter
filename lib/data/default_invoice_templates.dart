import '../models/invoice_template_model.dart';

final List<InvoiceTemplate> defaultInvoiceTemplates = [
  InvoiceTemplate(
    templateId: 'tmpl_labor_only',
    userId: 'system',
    templateName: 'Labor Only',
    lineItems: [
      TemplateLineItem(description: 'Labor', amount: 150.0),
    ],
    taxPercentage: 7.0,
    chargeTaxes: true,
    sendAutomatically: false,
    createdAt: '2024-01-01T00:00:00Z',
  ),
  InvoiceTemplate(
    templateId: 'tmpl_labor_materials',
    userId: 'system',
    templateName: 'Labor and Materials',
    lineItems: [
      TemplateLineItem(description: 'Labor', amount: 150.0),
      TemplateLineItem(description: 'Materials', amount: 75.0),
    ],
    taxPercentage: 7.0,
    chargeTaxes: true,
    sendAutomatically: false,
    createdAt: '2024-01-01T00:00:00Z',
  ),
  InvoiceTemplate(
    templateId: 'tmpl_estimate',
    userId: 'system',
    templateName: 'Estimate',
    lineItems: [
      TemplateLineItem(description: 'Estimated Labor', amount: 120.0),
      TemplateLineItem(description: 'Materials Estimate', amount: 60.0),
    ],
    taxPercentage: 7.0,
    chargeTaxes: true,
    sendAutomatically: false,
    createdAt: '2024-01-01T00:00:00Z',
  ),
  InvoiceTemplate(
    templateId: 'tmpl_overdue_30',
    userId: 'system',
    templateName: '30 Days Past Due',
    lineItems: [
      TemplateLineItem(description: 'Labor', amount: 150.0),
      TemplateLineItem(description: 'Late Fee', amount: 25.0),
    ],
    taxPercentage: 7.0,
    chargeTaxes: true,
    sendAutomatically: false,
    createdAt: '2024-01-01T00:00:00Z',
  ),
  InvoiceTemplate(
    templateId: 'tmpl_overdue_60',
    userId: 'system',
    templateName: '60 Days Past Due',
    lineItems: [
      TemplateLineItem(description: 'Labor', amount: 150.0),
      TemplateLineItem(description: 'Late Fee', amount: 25.0),
      TemplateLineItem(description: 'Additional Penalty', amount: 25.0),
    ],
    taxPercentage: 7.0,
    chargeTaxes: true,
    sendAutomatically: false,
    createdAt: '2024-01-01T00:00:00Z',
  ),
];