# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_fann_scaling(quote_target_id)
    if [1,6,9].include?(quote_target_id)
      1000.0
    elsif [10].include?(quote_target_id)
      10.0
    else
      100.0
    end
  end
end
