module PredictionsHelper
  def get_first_quote_from_date(neural_strategy_id, from_date)
    neural_strategy = NeuralStrategy.find(neural_strategy_id)
    quote=QuoteValue.find(:first, :conditions=>["quote_target_id = ? AND data_time > ?",neural_strategy.quote_target_id, from_date])
    if quote
      [quote.last_trade.to_s,quote.created_at.strftime("%d/%m/%Y %H:%M")]
    else
      ["N/A","N/A"]
    end
  end
end
