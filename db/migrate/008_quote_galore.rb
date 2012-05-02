class QuoteGalore < ActiveRecord::Migration
  def self.up
    remove_column :quote_values, :price
    remove_column :quote_values, :change
    remove_column :quote_values, :volume
    remove_column :quote_values, :today_open
    remove_column :quote_values, :previous_close
    remove_column :quote_values, :intraday_high
    remove_column :quote_values, :intraday_low
    remove_column :quote_values, :year_high
    remove_column :quote_values, :year_low

    add_column :quote_values, :ask, :float
    add_column :quote_values, :average_daily_volume, :float
    add_column :quote_values, :ask_size, :float
    add_column :quote_values, :book_value, :float
    add_column :quote_values, :change, :float
    add_column :quote_values, :dividend_by_share, :float
    add_column :quote_values, :last_trade_date, :float
    add_column :quote_values, :earnings_by_share, :float
    add_column :quote_values, :eps_estimate_current_year, :float
    add_column :quote_values, :eps_estimate_next_year, :float
    add_column :quote_values, :eps_estimate_next_quarter, :float
    add_column :quote_values, :days_low, :float
    add_column :quote_values, :days_high, :float
    add_column :quote_values, :a_52_week_low, :float
    add_column :quote_values, :a_52_week_high, :float
    add_column :quote_values, :market_capitalization, :float
    add_column :quote_values, :ebitda, :float
    add_column :quote_values, :change_from_52_week_low, :float
    add_column :quote_values, :percent_change_from_52_week_low, :float
    add_column :quote_values, :change_from_52_week_high, :float
    add_column :quote_values, :percent_change_from_52_week_high, :float 
    add_column :quote_values, :last_trade, :float
    add_column :quote_values, :a_50_day_moving_average, :float
    add_column :quote_values, :a_200_day_moving_Average, :float
    add_column :quote_values, :change_from_200_day_moving_average, :float
    add_column :quote_values, :percent_change_from_200_day_moving_average, :float
    add_column :quote_values, :change_from_50_day_moving_average, :float
    add_column :quote_values, :percent_change_from_50_day_moving_average, :float
    add_column :quote_values, :open, :float
    add_column :quote_values, :previous_close, :float
    add_column :quote_values, :change_in_percent, :float
    add_column :quote_values, :price_by_sales, :float
    add_column :quote_values, :price_by_book, :float
    add_column :quote_values, :pe_ratio, :float
    add_column :quote_values, :peg_ratio, :float
    add_column :quote_values, :price_by_eps_estimate_current_year, :float
    add_column :quote_values, :price_by_eps_estimate_next_year, :float
    add_column :quote_values, :short_ratio, :float
    add_column :quote_values, :last_trade_time, :float
    add_column :quote_values, :a_1_yr_target_price, :float
    add_column :quote_values, :volume, :float
    add_column :quote_values, :indicated_symbol, :string
  end

  def self.down
  end
end
