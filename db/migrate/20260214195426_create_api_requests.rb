class CreateApiRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :api_requests do |t|
      t.string   :http_method
      t.string   :path
      t.jsonb    :params, default: {}
      t.integer  :response_status
      t.string   :ip_address
      t.float    :duration_ms 
      t.timestamps
    end

    add_index :api_requests, :http_method
    add_index :api_requests, :path
    add_index :api_requests, :response_status
  end
end
