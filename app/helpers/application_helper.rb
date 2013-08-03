module ApplicationHelper
  def nice_price sum
    number_with_delimiter( sum.round(2) )
  end
  
  def to_duration_string duration
    mm, ss = duration.divmod(60)
    hh, mm = mm.divmod(60)
    "%d:%d:%d" % [hh, mm, ss]
  end
  
  def nice_percent sum
    number_to_percentage( sum, precision: 0 )
  end
  
  def short_date date
    date.strftime( "%d/%m" )
  end
end
