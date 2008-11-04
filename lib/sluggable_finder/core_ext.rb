require 'iconv'
class String
  # Iconv use borrowed from http://svn.robertrevans.com/plugins/Permalize/
  # Thanks!
  def to_slug
      (Iconv.new('US-ASCII//TRANSLIT', 'utf-8').iconv self).gsub(/[^\w\s\-\â€”]/,'').gsub(/[^\w]|[\_]/,' ').split.join('-').downcase  
  end
end