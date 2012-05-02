# encoding: UTF-8

class QuoteValue < ActiveRecord::Base
  def normalize_float(number,position=nil)
    if number
      number = number.abs #normalize to 0..1
      if number>0.0 and number>1.0
        begin
          number/=10.0
        end while number>1.0
      end
      if position and @inputs_scaling
        scale_number=@inputs_scaling[position].abs
        if scale_number>1000
          scale=1000.0
        elsif scale_number>100
          scale=100.0
        elsif scale_number>10
          scale=10.0
        else
          scale=1.0
        end
      else
        scale=1.0
      end
      number/[scale,1.0].max
    else
      0.0
    end
  end

  def normalize_up_or_down(number)
    number>0.0 ? 1.0 : 0.0
  end

  def get_neural_input(selected_inputs,inputs_scaling)
    @inputs_scaling = inputs_scaling
    features = []
    features << normalize_up_or_down(self.change) # if selected_inputs[39]==1
    features << normalize_float(self.change,2) # if selected_inputs[2]==1
    features << normalize_float(self.last_trade,19) # if selected_inputs[19]==1
    features << normalize_float(self.ask,0) if selected_inputs[0]==1
    features << normalize_float(self.average_daily_volume,1) if selected_inputs[1]==1
    features << normalize_float(self.dividend_by_share,3) if selected_inputs[3]==1
    features << normalize_float(self.last_trade_date,4) if selected_inputs[4]==1
    features << normalize_float(self.earnings_by_share,5) if selected_inputs[5]==1
    features << normalize_float(self.eps_estimate_current_year,6) if selected_inputs[6]==1
    features << normalize_float(self.eps_estimate_next_year,7) if selected_inputs[7]==1
    features << normalize_float(self.eps_estimate_next_quarter,8) if selected_inputs[8]==1
    features << normalize_float(self.days_low,9) if selected_inputs[9]==1
    features << normalize_float(self.days_high,10) if selected_inputs[10]==1
    features << normalize_float(self.a_52_week_low,11) if selected_inputs[11]==1
    features << normalize_float(self.a_52_week_high,12) if selected_inputs[12]==1
    features << normalize_float(self.market_capitalization,13) if selected_inputs[13]==1
    features << normalize_float(self.ebitda,14) if selected_inputs[14]==1
    features << normalize_float(self.change_from_52_week_low,15) if selected_inputs[15]==1
    features << normalize_float(self.percent_change_from_52_week_low,16) if selected_inputs[16]==1
    features << normalize_float(self.change_from_52_week_high,17) if selected_inputs[17]==1
    features << normalize_float(self.percent_change_from_52_week_high,18) if selected_inputs[18]==1
    features << normalize_float(self.a_50_day_moving_average,20) if selected_inputs[20]==1
    features << normalize_float(self.a_200_day_moving_Average,21) if selected_inputs[21]==1
    features << normalize_float(self.change_from_200_day_moving_average,22) if selected_inputs[22]==1
    features << normalize_float(self.percent_change_from_200_day_moving_average,23) if selected_inputs[23]==1
    features << normalize_float(self.change_from_50_day_moving_average,24) if selected_inputs[24]==1
    features << normalize_float(self.percent_change_from_50_day_moving_average,25) if selected_inputs[25]==1
    features << normalize_float(self.open,26) if selected_inputs[26]==1
    features << normalize_float(self.previous_close,27) if selected_inputs[27]==1
    features << normalize_float(self.change_in_percent,28) if selected_inputs[28]==1
    features << normalize_float(self.price_by_sales,29) if selected_inputs[29]==1
    features << normalize_float(self.price_by_book,30) if selected_inputs[30]==1
    features << normalize_float(self.pe_ratio,31) if selected_inputs[31]==1
    features << normalize_float(self.peg_ratio,32) if selected_inputs[32]==1
    features << normalize_float(self.price_by_eps_estimate_current_year,33) if selected_inputs[33]==1
    features << normalize_float(self.price_by_eps_estimate_next_year,34) if selected_inputs[34]==1
    features << normalize_float(self.short_ratio,35) if selected_inputs[35]==1
    features << normalize_float(self.last_trade_time,36) if selected_inputs[36]==1
    features << normalize_float(self.a_1_yr_target_price,37) if selected_inputs[37]==1
    features << normalize_float(self.volume,38) if selected_inputs[38]==1
    features << normalize_float(self.created_at.wday+2) if selected_inputs[40]==1
    features << normalize_float(self.created_at.hour) if selected_inputs[41]==1
    features << normalize_float(self.created_at.min) if selected_inputs[42]==1
    features << normalize_float(self.created_at.year*365+self.created_at.month*30+self.created_at.day) if selected_inputs[43]==1
    features << normalize_float(self.created_at.hour*60+self.created_at.min) if selected_inputs[44]==1
    features << normalize_up_or_down(self.percent_change_from_52_week_low) if selected_inputs[45]==1
    features << normalize_up_or_down(self.change_from_52_week_high) if selected_inputs[46]==1
    features << normalize_up_or_down(self.change_from_52_week_low) if selected_inputs[47]==1
    features << normalize_up_or_down(self.change_from_52_week_high) if selected_inputs[48]==1
    features << normalize_up_or_down(self.a_50_day_moving_average) if selected_inputs[49]==1
    features << normalize_up_or_down(self.a_200_day_moving_Average) if selected_inputs[50]==1
    features << normalize_up_or_down(self.change_from_200_day_moving_average) if selected_inputs[51]==1
    features << normalize_up_or_down(self.change_from_50_day_moving_average) if selected_inputs[52]==1
    features << normalize_float((self.last_trade-self.a_52_week_low)/(self.a_52_week_high-self.a_52_week_low)) if selected_inputs[53]==1 # Input Value=(price-low)/(high-low)
    features << normalize_up_or_down((self.last_trade-self.a_52_week_low)/(self.a_52_week_high-self.a_52_week_low)) if selected_inputs[54]==1
    # 55 RESERVED FOR CASCADE OR NORMAL TRAINING MODE
    # 56 RESERVED FOR sell_by_prediction 
    features
  end

  def get_desired_output
    normalize_float(self.last_trade.to_f)
  end

  def import_csv_data(logger,quote_data)
    logger.debug(quote_data.inspect)
    self.ask = quote_data[0].to_f
#    self.average_daily_volume = parse_value(quote_data[1])
#    self.change = parse_value(quote_data[2])
#    self.dividend_by_share = parse_value(quote_data[3])
#    self.last_trade_date = (Time.parse(quote_data[4]).year*365+Time.parse(quote_data[4]).month*30+Time.parse(quote_data[4]).day).to_f
#    self.earnings_by_share = parse_value(quote_data[5])
#    self.eps_estimate_current_year = parse_value(quote_data[6])
#    self.eps_estimate_next_year = parse_value(quote_data[7])
#    self.eps_estimate_next_quarter = parse_value(quote_data[8])
#    self.days_low = parse_value(quote_data[9])
#    self.days_high = parse_value(quote_data[10])
#    self.a_52_week_low = parse_value(quote_data[11])
#    self.a_52_week_high = parse_value(quote_data[12])
#    self.market_capitalization = parse_b_value(quote_data[13])
#    self.ebitda = parse_b_value(quote_data[14])
#    self.change_from_52_week_low = parse_value(quote_data[15])
#    self.percent_change_from_52_week_low = parse_value(quote_data[16])
#    self.change_from_52_week_high = parse_value(quote_data[17])
#    self.percent_change_from_52_week_high = parse_value(quote_data[18])
#    self.last_trade = parse_value(quote_data[19])
#    self.a_50_day_moving_average = parse_value(quote_data[20])
#    self.a_200_day_moving_Average = parse_value(quote_data[21])
#    self.change_from_200_day_moving_average = parse_value(quote_data[22])
#    self.percent_change_from_200_day_moving_average = parse_value(quote_data[23])
#    self.change_from_50_day_moving_average = parse_value(quote_data[24]) 
#    self.percent_change_from_50_day_moving_average = parse_value(quote_data[25])
#    self.open = parse_value(quote_data[26])
#    self.previous_close = parse_value(quote_data[27])
#    self.change_in_percent = parse_value(quote_data[28])
#    self.price_by_sales = parse_value(quote_data[29])
#    self.price_by_book = parse_value(quote_data[30])
#    self.pe_ratio = parse_value(quote_data[31])
#    self.peg_ratio = parse_value(quote_data[32])
#    self.price_by_eps_estimate_current_year = parse_value(quote_data[33])
#    self.price_by_eps_estimate_next_year = parse_value(quote_data[34])
#    self.short_ratio = parse_value(quote_data[35])
#    self.last_trade_time = (Time.parse(quote_data[36]).hour*60+Time.parse(quote_data[36]).min).to_f
#    self.a_1_yr_target_price = parse_value(quote_data[37])
#    self.volume = parse_value(quote_data[38])
#    self.indicated_symbol = quote_data[39]
  end

private
  def parse_value(in_value)
    out_value = nil
    out_value = in_value.to_f if in_value and in_value!="N/A" and in_value!="N/A\r\n" and in_value!="-"
    out_value
  end

  def parse_b_value(in_value)
    out_value = nil
    if in_value
      in_value2 = in_value.gsub(".","")
      in_value3 = nil
      if in_value2[in_value2.length-1...in_value2.length]=="B"
        in_value3 = in_value2[0...in_value2.length-1].to_f * 1000
      elsif in_value2[in_value2.length-1...in_value2.length]=="M"
        in_value3 = in_value2[0...in_value2.length-1].to_f
      else
        in_value3 = in_value2.to_f
      end
      out_value = in_value3
    end
    out_value
  end
end
