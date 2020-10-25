
ActiveRecord::Schema.define(version: 2018_08_16_185151) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clicks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "url_id"
    t.string "browser", null: false
    t.string "platform", null: false
    t.index ["url_id"], name: "index_clicks_on_url_id"
  end

  create_table "urls", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "short_url", null: false
    t.string "original_url", null: false
    t.integer "clicks_count", default: 0
  end

  add_foreign_key "clicks", "urls"
end
