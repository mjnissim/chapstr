require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  setup do
    @invoice = invoices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice" do
    assert_difference('Invoice.count') do
      post :create, invoice: { commments: @invoice.commments, invoice_link: @invoice.invoice_link, invoice_no: @invoice.invoice_no, paid: @invoice.paid, project_id: @invoice.project_id, receipt_link: @invoice.receipt_link, receipt_no: @invoice.receipt_no, total: @invoice.total, vat_percent: @invoice.vat_percent }
    end

    assert_redirected_to invoice_path(assigns(:invoice))
  end

  test "should show invoice" do
    get :show, id: @invoice
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @invoice
    assert_response :success
  end

  test "should update invoice" do
    patch :update, id: @invoice, invoice: { commments: @invoice.commments, invoice_link: @invoice.invoice_link, invoice_no: @invoice.invoice_no, paid: @invoice.paid, project_id: @invoice.project_id, receipt_link: @invoice.receipt_link, receipt_no: @invoice.receipt_no, total: @invoice.total, vat_percent: @invoice.vat_percent }
    assert_redirected_to invoice_path(assigns(:invoice))
  end

  test "should destroy invoice" do
    assert_difference('Invoice.count', -1) do
      delete :destroy, id: @invoice
    end

    assert_redirected_to invoices_path
  end
end
