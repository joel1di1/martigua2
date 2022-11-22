class DropDelayedJobs < ActiveRecord::Migration[7.0]
  def up
    drop_table :delayed_jobs
  end
end
