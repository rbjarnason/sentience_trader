# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091020230004) do

  create_table "classification_strategies", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.binary   "compressed_data_1",   :limit => 2147483647
    t.binary   "compressed_data_2",   :limit => 2147483647
    t.binary   "compressed_data_3",   :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "classification_type"
  end

  create_table "classification_strategies_classified_paragraphs", :id => false, :force => true do |t|
    t.integer "classification_strategy_id"
    t.integer "classified_paragraph_id"
  end

  create_table "classified_paragraphs", :force => true do |t|
    t.integer  "rss_item_id"
    t.integer  "parent_id"
    t.binary   "original_compressed_text"
    t.binary   "processed_compressed_text"
    t.float    "sentiment_score"
    t.float    "importance_score"
    t.float    "objective_subjective_score"
    t.float    "trusted_untrusted_score"
    t.float    "relevant_irrelevant_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_type"
    t.integer  "quote_target_id"
    t.integer  "sequence_number"
    t.boolean  "junk"
    t.integer  "modified_by_user_id"
    t.string   "text_hash"
    t.integer  "copy_of_id"
  end

  add_index "classified_paragraphs", ["parent_id"], :name => "index_classified_paragraphs_on_parent_id"
  add_index "classified_paragraphs", ["rss_item_id"], :name => "index_classified_paragraphs_on_rss_item_id"
  add_index "classified_paragraphs", ["text_hash"], :name => "index_classified_paragraphs_on_text_hash"

  create_table "classified_paragraphs_classified_people", :id => false, :force => true do |t|
    t.integer "classified_person_id"
    t.integer "classified_paragraph_id"
  end

  create_table "classified_people", :force => true do |t|
    t.string   "person_name"
    t.string   "person_type"
    t.string   "person_nationality"
    t.string   "position"
    t.string   "organization_name"
    t.string   "organization_type"
    t.string   "organization_nationality"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                         :default => true, :null => false
    t.integer  "classified_person_category_id"
  end

  create_table "classified_person_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exchanges", :force => true do |t|
    t.string   "name"
    t.string   "symbol_data_url"
    t.string   "symbol_data_format"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "neural_populations", :force => true do |t|
    t.integer  "max_generations"
    t.integer  "population_size"
    t.float    "best_fitness"
    t.integer  "current_generation",                               :default => 0
    t.integer  "quote_target_id"
    t.boolean  "complete",                                         :default => false
    t.boolean  "active",                                           :default => false
    t.boolean  "in_process",                                       :default => false
    t.datetime "last_processing_start_time"
    t.datetime "last_processing_stop_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "network_type"
    t.string   "time_span_type"
    t.binary   "population_data",            :limit => 2147483647
    t.integer  "best_neural_strategy_id"
  end

  create_table "neural_populations_neural_strategies", :id => false, :force => true do |t|
    t.integer "neural_population_id"
    t.integer "neural_strategy_id"
  end

  create_table "neural_strategies", :force => true do |t|
    t.string   "title"
    t.boolean  "active",                          :default => false
    t.datetime "last_work_unit_time"
    t.integer  "max_epochs"
    t.text     "network"
    t.string   "network_type"
    t.string   "time_span_type"
    t.boolean  "in_process",                      :default => false
    t.boolean  "error_flag",                      :default => false
    t.integer  "quote_target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "processing_time_interval",        :default => 1800
    t.datetime "last_neural_processing_time"
    t.datetime "last_prediction_processing_time"
    t.boolean  "only_trading_hours",              :default => true
    t.float    "desired_error"
    t.datetime "last_processing_start_time"
    t.datetime "last_processing_stop_time"
    t.boolean  "complete",                        :default => false
    t.boolean  "in_population_process",           :default => false
    t.binary   "hidden_neurons_data"
    t.binary   "selected_inputs_data"
    t.binary   "inputs_scaling_data"
    t.binary   "compressed_network"
  end

  create_table "predictions", :force => true do |t|
    t.integer  "neural_strategy_id"
    t.float    "float_value"
    t.float    "error_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "data_time"
    t.float    "last_trade"
    t.float    "double_value"
  end

  create_table "processed_rss_items", :force => true do |t|
    t.string   "guid"
    t.integer  "quote_target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "processed_rss_items", ["guid"], :name => "index_processed_rss_items_on_guid"
  add_index "processed_rss_items", ["quote_target_id"], :name => "index_processed_rss_items_on_quote_target_id"

  create_table "quote_targets", :force => true do |t|
    t.string   "symbol"
    t.string   "search_strings"
    t.integer  "processing_time_interval"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_processing_time"
    t.integer  "exchange_id"
    t.boolean  "yahoo_quote_enabled"
    t.datetime "last_yahoo_processing_time"
  end

  create_table "quote_targets_rss_items", :id => false, :force => true do |t|
    t.integer "quote_target_id"
    t.integer "rss_item_id"
  end

  create_table "quote_values", :force => true do |t|
    t.integer  "quote_target_id"
    t.datetime "data_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "ask"
    t.float    "average_daily_volume"
    t.float    "ask_size"
    t.float    "book_value"
    t.float    "change"
    t.float    "dividend_by_share"
    t.float    "last_trade_date"
    t.float    "earnings_by_share"
    t.float    "eps_estimate_current_year"
    t.float    "eps_estimate_next_year"
    t.float    "eps_estimate_next_quarter"
    t.float    "days_low"
    t.float    "days_high"
    t.float    "a_52_week_low"
    t.float    "a_52_week_high"
    t.float    "market_capitalization"
    t.float    "ebitda"
    t.float    "change_from_52_week_low"
    t.float    "percent_change_from_52_week_low"
    t.float    "change_from_52_week_high"
    t.float    "percent_change_from_52_week_high"
    t.float    "last_trade"
    t.float    "a_50_day_moving_average"
    t.float    "a_200_day_moving_Average"
    t.float    "change_from_200_day_moving_average"
    t.float    "percent_change_from_200_day_moving_average"
    t.float    "change_from_50_day_moving_average"
    t.float    "percent_change_from_50_day_moving_average"
    t.float    "open"
    t.float    "previous_close"
    t.float    "change_in_percent"
    t.float    "price_by_sales"
    t.float    "price_by_book"
    t.float    "pe_ratio"
    t.float    "peg_ratio"
    t.float    "price_by_eps_estimate_current_year"
    t.float    "price_by_eps_estimate_next_year"
    t.float    "short_ratio"
    t.float    "last_trade_time"
    t.float    "a_1_yr_target_price"
    t.float    "volume"
    t.string   "indicated_symbol"
  end

  create_table "rights", :force => true do |t|
    t.string "name"
    t.string "controller"
    t.string "action"
  end

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer "right_id"
    t.integer "role_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "rss_item_scores", :force => true do |t|
    t.integer  "rss_item_id"
    t.integer  "classification_strategy_id"
    t.float    "sentiment_score"
    t.float    "objective_subjective_score"
    t.float    "average_sentiment_score"
    t.float    "average_importance_score"
    t.float    "average_objective_subjective_score"
    t.float    "average_trusted_untrusted_score"
    t.float    "average_relevant_irrelevant_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quote_target_id"
  end

  add_index "rss_item_scores", ["classification_strategy_id"], :name => "index_rss_item_scores_on_classification_strategy_id"
  add_index "rss_item_scores", ["rss_item_id"], :name => "index_rss_item_scores_on_rss_item_id"

  create_table "rss_items", :force => true do |t|
    t.string   "title"
    t.string   "link"
    t.string   "language"
    t.string   "copyright"
    t.boolean  "compressed"
    t.integer  "rss_target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "guid"
    t.string   "pubDate"
    t.text     "description"
    t.binary   "compressed_page"
    t.boolean  "has_been_scored",        :default => false
    t.boolean  "has_created_paragraphs", :default => false
    t.datetime "last_scored_at"
    t.boolean  "has_processed_calais",   :default => false
  end

  add_index "rss_items", ["guid"], :name => "index_rss_items_on_guid", :unique => true

  create_table "rss_targets", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "url_type"
    t.integer  "processing_time_interval"
    t.datetime "last_processing_time"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parser"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
