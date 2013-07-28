# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130728133356) do

  create_table "invoices", force: true do |t|
    t.integer  "project_id"
    t.decimal  "total"
    t.decimal  "vat_percent"
    t.boolean  "paid"
    t.integer  "invoice_no"
    t.string   "invoice_link"
    t.integer  "receipt_no"
    t.string   "receipt_link"
    t.text     "commments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: true do |t|
    t.string   "title"
    t.integer  "start"
    t.integer  "finish"
    t.decimal  "quote"
    t.decimal  "per_hour"
    t.integer  "expected_percentage"
    t.integer  "hours_so_far"
    t.integer  "hours_expected"
    t.integer  "milestone"
    t.string   "milestone_label"
    t.date     "date_started"
    t.date     "date_ended"
    t.boolean  "completed"
    t.decimal  "after_finalised"
    t.boolean  "finalised"
    t.integer  "project_id"
    t.string   "tt_module"
    t.integer  "tt_project_id"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
