class AddRecentyAcitivityCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :recent_activity_count, :integer, default: 0, null: false
  end
end
