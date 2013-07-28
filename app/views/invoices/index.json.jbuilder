json.array!(@invoices) do |invoice|
  json.extract! invoice, :project_id, :total, :vat_percent, :paid, :invoice_no, :invoice_link, :receipt_no, :receipt_link, :commments
  json.url invoice_url(invoice, format: :json)
end
