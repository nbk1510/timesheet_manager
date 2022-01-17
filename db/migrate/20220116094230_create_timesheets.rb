class CreateTimesheets < ActiveRecord::Migration[5.2]
  def change
    create_table :timesheets do |t|
      t.datetime :date, null: false
      t.string :start_time, null: false
      t.string :end_time, null: false
      t.float :calculated_pay
    end
  end
end
