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

ActiveRecord::Schema.define(version: 20170530213610) do

  create_table "activities", force: true do |t|
    t.integer  "customer_id"
    t.date     "expiration_date"
    t.time     "expiration_time"
    t.text     "notes",             limit: 16777215
    t.date     "execution_date"
    t.integer  "execution_user_id"
    t.datetime "execution_at"
    t.text     "execution_notes",   limit: 16777215
    t.decimal  "amount",                             precision: 10, scale: 2
    t.boolean  "request_received"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activity_ops", force: true do |t|
    t.string   "name",            limit: 50
    t.string   "code",            limit: 10
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "booking_items", force: true do |t|
    t.integer  "booking_id"
    t.integer  "equipment_id"
    t.integer  "quantity",        limit: 8
    t.string   "status",          limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.decimal  "temperature",               precision: 10, scale: 0
    t.string   "ventilation",     limit: 7
    t.decimal  "humidity",                  precision: 10, scale: 0
  end

  create_table "bookings", force: true do |t|
    t.string   "num_booking",          limit: 25
    t.integer  "shipowner_id",         limit: 8
    t.integer  "ship_id",              limit: 8
    t.string   "voyage",               limit: 15
    t.integer  "port_id",              limit: 8
    t.date     "eta"
    t.string   "status",               limit: 5
    t.text     "notes",                limit: 16777215
    t.date     "expiration"
    t.boolean  "to_check",                              default: true
    t.boolean  "to_weigh_in_terminal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "carriers", force: true do |t|
    t.string   "name",            limit: 50
    t.string   "address",         limit: 50
    t.string   "zip_code",        limit: 50
    t.string   "city",            limit: 50
    t.string   "country",         limit: 50
    t.string   "email",           limit: 50
    t.string   "email_notify",    limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "codeco_progressives", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "codeco_sends", force: true do |t|
    t.integer  "shipowner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "customers", force: true do |t|
    t.string   "name",       limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equipment", force: true do |t|
    t.string   "equipment_type",  limit: 4
    t.integer  "size",            limit: 2
    t.string   "sizetype",        limit: 50
    t.string   "iso",             limit: 4
    t.boolean  "reefer",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "handling_headers", force: true do |t|
    t.string   "container_number",      limit: 11
    t.integer  "shipowner_id",          limit: 8
    t.integer  "equipment_id",          limit: 8
    t.boolean  "over_hight"
    t.boolean  "transhipment"
    t.string   "notes"
    t.string   "handling_type",         limit: 5
    t.string   "container_type",        limit: 5
    t.boolean  "container_OH"
    t.string   "handling_status",       limit: 5
    t.boolean  "container_in_terminal",                                     default: false
    t.string   "container_status",      limit: 5
    t.string   "container_FE",          limit: 1
    t.boolean  "lock_fl"
    t.string   "lock_type",             limit: 10
    t.integer  "booking_id"
    t.integer  "booking_item_id"
    t.string   "num_booking",           limit: 25
    t.string   "seal_exp_shipowner",    limit: 15
    t.string   "seal_exp_others",       limit: 15
    t.decimal  "temperature_exp",                  precision: 5,  scale: 2
    t.decimal  "weight_exp",                       precision: 15, scale: 2
    t.string   "imo_exp",               limit: 5
    t.string   "bill_of_lading",        limit: 25
    t.string   "seal_imp_shipowner",    limit: 15
    t.string   "seal_imp_others",       limit: 15
    t.decimal  "temperature_imp",                  precision: 5,  scale: 2
    t.decimal  "weight_imp",                       precision: 15, scale: 2
    t.string   "imo_imp",               limit: 5
    t.string   "fila",                  limit: 5
    t.string   "blocco",                limit: 3
    t.integer  "tiro"
    t.integer  "pier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "handling_items", force: true do |t|
    t.integer  "handling_header_id",    limit: 8
    t.datetime "datetime_op"
    t.datetime "datetime_op_end"
    t.string   "operation_type",        limit: 2
    t.string   "handling_item_type",    limit: 15
    t.string   "handling_type",         limit: 1
    t.string   "container_FE",          limit: 1
    t.integer  "ship_id",               limit: 8
    t.string   "voyage",                limit: 15
    t.integer  "carrier_id",            limit: 8
    t.string   "driver",                limit: 50
    t.string   "plate",                 limit: 15
    t.string   "plate_trailer",         limit: 15
    t.boolean  "export"
    t.string   "seal_shipowner",        limit: 15
    t.string   "seal_others",           limit: 15
    t.integer  "codeco_send"
    t.decimal  "weight",                                 precision: 15, scale: 2
    t.text     "notes",                 limit: 16777215
    t.text     "notes_int",             limit: 16777215
    t.integer  "booking_id"
    t.integer  "booking_item_id"
    t.boolean  "lock_fl"
    t.string   "lock_type",             limit: 10
    t.boolean  "to_be_moved"
    t.integer  "moved_by_user_id"
    t.datetime "moved_at"
    t.boolean  "fl_send_email_carrier"
    t.boolean  "fl_send_email_shipper"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.integer  "terminal_id"
    t.integer  "shipper_id"
    t.integer  "inspection_type_id"
    t.boolean  "to_weigh"
    t.integer  "weigh_id"
  end

  add_index "handling_items", ["handling_header_id"], name: "handling_hader", using: :btree

  create_table "import_headers", force: true do |t|
    t.integer  "ship_id",         limit: 8
    t.string   "voyage",          limit: 15
    t.string   "import_type",     limit: 1
    t.string   "import_status",   limit: 5
    t.string   "handling_type",   limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "import_items", force: true do |t|
    t.integer  "import_header_id", limit: 8
    t.integer  "shipowner_id",     limit: 8
    t.string   "container_number", limit: 15
    t.string   "container_status", limit: 1
    t.integer  "equipment_id",     limit: 8
    t.decimal  "weight",                            precision: 15, scale: 2
    t.decimal  "temperature",                       precision: 5,  scale: 2
    t.string   "imo",              limit: 4
    t.string   "status",           limit: 10
    t.text     "notes",            limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.string   "num_booking",      limit: 25
  end

  create_table "inspection_types", force: true do |t|
    t.string   "name",            limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "iso_equipments", force: true do |t|
    t.string   "iso",             limit: 4
    t.integer  "equipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "piers", force: true do |t|
    t.string   "name",            limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "ports", force: true do |t|
    t.string   "port_code",       limit: 5
    t.string   "city",            limit: 50
    t.string   "country",         limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "repair_components", force: true do |t|
    t.string   "description_it",  limit: 50
    t.string   "description_en",  limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "repair_estimate_items", force: true do |t|
    t.integer  "repair_handling_item_id"
    t.integer  "repair_processing_id"
    t.decimal  "provider_time",                            precision: 10, scale: 2
    t.decimal  "provider_hourly_cost",                     precision: 10, scale: 2
    t.decimal  "provider_material_price",                  precision: 10, scale: 2
    t.decimal  "customer_time",                            precision: 10, scale: 2
    t.decimal  "customer_hourly_cost",                     precision: 10, scale: 2
    t.decimal  "customer_material_price",                  precision: 10, scale: 2
    t.decimal  "quantity",                                 precision: 10, scale: 2
    t.boolean  "confirmed"
    t.string   "preparation_time_type",   limit: 50
    t.string   "side",                    limit: 20
    t.text     "provider_notes",          limit: 16777215
    t.text     "authorization_notes",     limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "repair_handling_items", force: true do |t|
    t.integer  "handling_item_id"
    t.string   "repair_status"
    t.boolean  "disabled_wf_on_close"
    t.datetime "in_garage_at"
    t.integer  "in_garage_user_id"
    t.datetime "estimate_at"
    t.integer  "estimate_user_id"
    t.datetime "estimate_sent_at"
    t.integer  "estimate_sent_user_id"
    t.datetime "estimate_authorized_at"
    t.integer  "estimate_authorized_user_id"
    t.datetime "repair_completed_at"
    t.integer  "repair_completed_user_id"
    t.datetime "out_garage_at"
    t.integer  "out_garage_user_id"
    t.text     "in_garage_notes",                limit: 16777215
    t.text     "estimate_notes",                 limit: 16777215
    t.text     "estimate_sent_notes",            limit: 16777215
    t.text     "estimate_authorized_notes",      limit: 16777215
    t.text     "repair_completed_notes",         limit: 16777215
    t.text     "out_garage_notes",               limit: 16777215
    t.decimal  "total_cost_provider_estimate",                    precision: 10, scale: 2
    t.decimal  "total_cost_provider_authorized",                  precision: 10, scale: 2
    t.decimal  "total_cost_customer_estimate",                    precision: 10, scale: 2
    t.decimal  "total_cost_customer_authorized",                  precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  add_index "repair_handling_items", ["handling_item_id"], name: "handling_item", using: :btree

  create_table "repair_positions", force: true do |t|
    t.string   "description_it",  limit: 50
    t.string   "description_en",  limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "repair_prices", force: true do |t|
    t.integer  "repair_processing_id"
    t.integer  "shipowner_id"
    t.decimal  "customer_time",                      precision: 10, scale: 2
    t.decimal  "customer_material_price",            precision: 10, scale: 2
    t.decimal  "provider_time",                      precision: 10, scale: 2
    t.decimal  "provider_material_price",            precision: 10, scale: 2
    t.string   "code1",                   limit: 20
    t.string   "code2",                   limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "repair_processings", force: true do |t|
    t.integer  "repair_position_id"
    t.integer  "repair_component_id"
    t.string   "description_it",        limit: 50
    t.string   "description_en",        limit: 50
    t.string   "preparation_time_type", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "ship_prepare_item_weighs", force: true do |t|
    t.integer  "ship_prepare_item_id"
    t.decimal  "qty",                             precision: 15, scale: 2
    t.decimal  "qty_ric",                         precision: 15, scale: 2
    t.decimal  "qty_test",                        precision: 15, scale: 2
    t.decimal  "qty_tare",                        precision: 15, scale: 2
    t.decimal  "qty_gross",                       precision: 15, scale: 2
    t.string   "driver",               limit: 50
    t.string   "plate",                limit: 15
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ship_prepare_items", force: true do |t|
    t.integer  "ship_prepare_id"
    t.string   "item_status",        limit: 5
    t.string   "item_type",          limit: 2
    t.string   "in_out_type",        limit: 1
    t.integer  "import_header_id"
    t.integer  "ship_prepare_op_id"
    t.boolean  "to_weigh"
    t.integer  "um_id"
    t.decimal  "qty",                                 precision: 15, scale: 2
    t.integer  "moved_by_user_id"
    t.datetime "moved_at"
    t.text     "notes",              limit: 16777215
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ship_prepare_ops", force: true do |t|
    t.string   "name",            limit: 50
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ship_prepares", force: true do |t|
    t.integer  "customer_id"
    t.integer  "ship_id"
    t.string   "ship_prepare_status", limit: 5
    t.date     "departure_date"
    t.string   "voyage",              limit: 15
    t.string   "load_type",           limit: 50
    t.text     "notes",               limit: 16777215
    t.date     "execution_date"
    t.integer  "execution_user_id"
    t.datetime "execution_at"
    t.text     "execution_notes",     limit: 16777215
    t.integer  "nr_container_01"
    t.integer  "nr_container_02"
    t.integer  "nr_container_03"
    t.integer  "nr_container_04"
    t.integer  "nr_container_05"
    t.decimal  "weight",                               precision: 15, scale: 2
    t.decimal  "amount",                               precision: 10, scale: 2
    t.boolean  "request_received"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipowners", force: true do |t|
    t.string   "name",                          limit: 50
    t.string   "short_name",                    limit: 3
    t.string   "email",                         limit: 50
    t.decimal  "estimate_hourly_cost_provider",            precision: 5, scale: 2
    t.decimal  "estimate_hourly_cost_customer",            precision: 5, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.string   "email_daily"
    t.boolean  "repair_active"
  end

  create_table "shippers", force: true do |t|
    t.string   "name",            limit: 50
    t.string   "address",         limit: 50
    t.string   "zip_code",        limit: 50
    t.string   "city",            limit: 50
    t.string   "country",         limit: 50
    t.string   "email",           limit: 50
    t.string   "email_notify",    limit: 200
    t.decimal  "unit_cost",                   precision: 5, scale: 2
    t.decimal  "scartaggio_cost",             precision: 5, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "ships", force: true do |t|
    t.string   "name",            limit: 50
    t.string   "short_name",      limit: 10
    t.string   "call_sign",       limit: 10
    t.integer  "shipowner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "terminals", force: true do |t|
    t.string   "code",            limit: 5
    t.string   "name",            limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "tmp_hh_cma_to_close", id: false, force: true do |t|
    t.integer "id",                          default: 0,     null: false
    t.string  "container_number", limit: 11
    t.string  "handling_status",  limit: 5
    t.boolean "reefer",                      default: false
  end

  create_table "to_do_items", force: true do |t|
    t.string   "status",                     limit: 5
    t.string   "to_do_type",                 limit: 15
    t.string   "num_booking",                limit: 25
    t.integer  "equipment_id"
    t.integer  "booking_id"
    t.integer  "booking_item_id"
    t.string   "container_number",           limit: 11
    t.string   "handling_item_type",         limit: 15
    t.string   "handling_type",              limit: 1
    t.string   "container_FE",               limit: 1
    t.integer  "shipowner_id"
    t.integer  "ship_id"
    t.string   "voyage",                     limit: 15
    t.integer  "carrier_id"
    t.string   "driver",                     limit: 50
    t.string   "plate",                      limit: 15
    t.text     "notes",                      limit: 16777215
    t.text     "notes_int",                  limit: 16777215
    t.integer  "generated_handling_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
  end

  create_table "ums", force: true do |t|
    t.string   "code",       limit: 5
    t.string   "name",       limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                             default: "", null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.integer  "updated_user_id"
    t.string   "name"
    t.integer  "role"
    t.string   "shipowner_flt",          limit: 20
    t.string   "terminal_flt",           limit: 20
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "weighs", force: true do |t|
    t.string   "weigh_status",           limit: 5
    t.boolean  "external",                                                   default: false
    t.integer  "terminal_id"
    t.integer  "shipowner_id"
    t.string   "container_number",       limit: 11
    t.integer  "handling_item_id"
    t.integer  "equipment_id"
    t.integer  "carrier_id"
    t.string   "driver",                 limit: 50
    t.string   "plate",                  limit: 15
    t.string   "plate_trailer",          limit: 15
    t.datetime "weighed_at"
    t.decimal  "weight",                            precision: 15, scale: 2
    t.decimal  "weight_container",                  precision: 15, scale: 2
    t.decimal  "weight_goods",                      precision: 15, scale: 2
    t.string   "scan_file_file_name"
    t.string   "scan_file_content_type"
    t.integer  "scan_file_file_size"
    t.datetime "scan_file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
