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

ActiveRecord::Schema.define(version: 20150109161754) do

  create_table "booking_items", force: true do |t|
    t.integer  "booking_id"
    t.integer  "equipment_id"
    t.integer  "quantity",     limit: 8
    t.string   "status",       limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookings", force: true do |t|
    t.string   "num_booking",  limit: 25
    t.integer  "shipowner_id", limit: 8
    t.integer  "ship_id",      limit: 8
    t.string   "voyage",       limit: 15
    t.integer  "port_id",      limit: 8
    t.date     "eta"
    t.string   "status",       limit: 5
    t.text     "notes",        limit: 16777215
    t.date     "expiration"
    t.boolean  "to_check",                      default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carriers", force: true do |t|
    t.string   "name",       limit: 50
    t.string   "address",    limit: 50
    t.string   "zip_code",   limit: 50
    t.string   "city",       limit: 50
    t.string   "country",    limit: 50
    t.string   "email",      limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equipment", force: true do |t|
    t.string   "equipment_type", limit: 4
    t.integer  "size",           limit: 2
    t.string   "sizetype",       limit: 50
    t.string   "iso",            limit: 4
    t.boolean  "reefer",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "handling_headers", force: true do |t|
    t.string   "container_number",      limit: 11
    t.integer  "shipowner_id",          limit: 8
    t.integer  "equipment_id",          limit: 8
    t.boolean  "over_hight"
    t.boolean  "transhipment"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "handling_type",         limit: 5
    t.string   "container_type",        limit: 5
    t.boolean  "container_OH"
    t.string   "handling_status",       limit: 5
    t.boolean  "container_in_terminal",                                    default: false
    t.string   "container_status",      limit: 5
    t.string   "container_FE",          limit: 1
    t.boolean  "lock_fl"
    t.string   "lock_type",             limit: 5
    t.integer  "booking_id"
    t.integer  "booking_item_id"
    t.string   "num_booking",           limit: 25
    t.string   "seal_exp_shipowner",    limit: 15
    t.string   "seal_exp_others",       limit: 15
    t.decimal  "temperature_exp",                  precision: 5, scale: 2
    t.decimal  "weight_exp",                       precision: 5, scale: 2
    t.string   "imo_exp",               limit: 5
    t.string   "bill_of_lading",        limit: 25
    t.string   "seal_imp_shipowner",    limit: 15
    t.string   "seal_imp_others",       limit: 15
    t.decimal  "temperature_imp",                  precision: 5, scale: 2
    t.decimal  "weight_imp",                       precision: 5, scale: 2
    t.string   "imo_imp",               limit: 5
  end

  create_table "handling_items", force: true do |t|
    t.integer  "handling_header_id", limit: 8
    t.datetime "datetime_op"
    t.datetime "datetime_op_end"
    t.string   "operation_type",     limit: 2
    t.string   "handling_item_type", limit: 15
    t.string   "handling_type",      limit: 1
    t.string   "container_FE",       limit: 1
    t.integer  "ship_id",            limit: 8
    t.string   "voyage",             limit: 15
    t.integer  "carrier_id",         limit: 8
    t.string   "driver",             limit: 50
    t.boolean  "export"
    t.string   "seal_shipowner",     limit: 15
    t.string   "seal_others",        limit: 15
    t.boolean  "not_positioning"
    t.boolean  "codeco_sent"
    t.text     "notes",              limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "booking_id"
    t.integer  "booking_item_id"
    t.boolean  "lock_fl"
    t.string   "lock_type",          limit: 5
  end

  create_table "import_headers", force: true do |t|
    t.integer  "ship_id",       limit: 8
    t.string   "voyage",        limit: 15
    t.string   "import_type",   limit: 1
    t.string   "import_status", limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_items", force: true do |t|
    t.integer  "import_header_id", limit: 8
    t.integer  "shipowner_id",     limit: 8
    t.string   "container_number", limit: 15
    t.string   "container_status", limit: 1
    t.integer  "equipment_id",     limit: 8
    t.decimal  "weight",                            precision: 5, scale: 2
    t.decimal  "temperature",                       precision: 5, scale: 2
    t.string   "imo",              limit: 4
    t.string   "status",           limit: 5
    t.text     "notes",            limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iso_equipments", force: true do |t|
    t.string   "iso",          limit: 4
    t.integer  "equipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ports", force: true do |t|
    t.string   "port_code",  limit: 5
    t.string   "city",       limit: 50
    t.string   "country",    limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipowners", force: true do |t|
    t.string   "name",                 limit: 50
    t.string   "short_name",           limit: 3
    t.string   "email",                limit: 50
    t.decimal  "estimate_hourly_cost",            precision: 5, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shippers", force: true do |t|
    t.string   "name",            limit: 50
    t.string   "address",         limit: 50
    t.string   "zip_code",        limit: 50
    t.string   "city",            limit: 50
    t.string   "country",         limit: 50
    t.string   "email",           limit: 50
    t.decimal  "unit_cost",                  precision: 5, scale: 2
    t.decimal  "scartaggio_cost",            precision: 5, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ships", force: true do |t|
    t.string   "name",         limit: 50
    t.string   "short_name",   limit: 10
    t.string   "call_sign",    limit: 10
    t.integer  "shipowner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
