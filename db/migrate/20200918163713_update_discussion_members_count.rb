class UpdateDiscussionMembersCount < ActiveRecord::Migration[5.2]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    execute('UPDATE discussions d SET members_count = (SELECT count(id) FROM discussion_readers dr where dr.discussion_id = d.id) WHERE members_count IS NULL')
  end
end
