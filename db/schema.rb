# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 1) do
  create_table "pets", force: :cascade do |t|
    t.string "name", default: "nemie", null: false
    t.integer "stage", default: 0, null: false
    t.integer "hunger", default: 50, null: false
    t.integer "happiness", default: 80, null: false
    t.integer "energy", default: 80, null: false
    t.integer "hygiene", default: 90, null: false
    t.integer "discipline", default: 50, null: false
    t.integer "health", default: 100, null: false
    t.integer "weight", default: 50, null: false
    t.integer "age_ticks", default: 0, null: false
    t.boolean "sleeping", default: false, null: false
    t.boolean "sick", default: false, null: false
    t.boolean "poop_on_screen", default: false, null: false
    t.datetime "last_tick_at"
    t.string "death_cause"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
