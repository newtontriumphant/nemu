class CreatePets < ActiveRecord::Migration[7.1]
  def change
    create_table :pets do |t|
      t.string :name, null: false, default: "nemie"
      t.integer :stage, null: false, default: 0
      # stage 0 is egg up to stage 6 which is dead
      t.integer :hunger, null: false, default: 50
      t.integer :happiness, null: false, default: 80
      t.integer :energy, null: false, default: 80
      t.integer :hygiene, null: false, default: 90
      t.integer :discipline, null:false, default: 50
      t.integer :health, null: false, default: 100
      t.integer :weight, null:false, default: 50
      t.integer :age_ticks, null: false, default: 0
      t.boolean :sleeping, null: false, default: false
      t.boolean :sick, null: false, default: false
      t.boolean :poop_on_screen, null: false, default: false
      t.datetime :last_tick_at
      t.string :death_cause
      t.timestamps
    end
  end
end