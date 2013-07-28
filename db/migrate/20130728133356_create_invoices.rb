class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :project_id
      t.decimal :total
      t.decimal :vat_percent
      t.boolean :paid
      t.integer :invoice_no
      t.string :invoice_link
      t.integer :receipt_no
      t.string :receipt_link
      t.text :commments

      t.timestamps
    end
  end
end
