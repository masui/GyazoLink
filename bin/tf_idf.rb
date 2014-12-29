class TfIdf
  def initialize(data, sparse=false)
    @sparse = sparse
    @data = data
  end
  
  def tf
    @tf ||= calculate_term_frequencies
  end
  
  def idf
    @idf ||= calculate_inverse_document_frequency
  end
  
  # This is basically calculated by multiplying tf by idf
  def tf_idf
    STDERR.puts "Calculating TF_IDF..."
    tf_idf = tf.map(&:clone)
    
    tf.each_with_index do |document, index|
      STDERR.puts "  document #{index}" if index > 0 && index % 10000 == 0
      document.each_pair do |term, tf_score|
        tf_idf[index][term] = tf_score * idf[term]
      end
    end
    
    STDERR.puts "end Calculating TF_IDF."
    tf_idf
  end
    
  private
  
  def total_documents
    @data.size.to_f
  end
  
  # Returns all terms, once
  def terms
    STDERR.puts "Calculating terms..."
    result = @sparse ? @data.map(&:keys).flatten : @data.map(&:uniq).flatten
    STDERR.puts "end calculating terms. length = #{result.length}"
    result
  end
  
  # IDF = total_documents / number_of_document_term_appears_in
  # This calculates how important a term is.
  def calculate_inverse_document_frequency
    STDERR.puts "Calculating IDF..."
    results = Hash.new {|h, k| h[k] = 0 }

    terms.each do |term|
      results[term] += 1
    end

    log_total_count = Math.log10(total_documents)
    results.each_pair do |term, count|
      results[term] = log_total_count - Math.log10(count)
    end

    results.default = nil
    STDERR.puts "end calculating IDF."
    results
  end
  
  # TF = number_of_n_term_in_document / number_of_terms_in_document
  # Calculates the number of times a term appears in the document
  # It is then normalized (as some documents are longer than others)
  def calculate_term_frequencies
    STDERR.puts "Calculating TF..."
    results = []
    
    @data.each_with_index do |document,index|
      STDERR.puts "  document #{index}" if index > 0 && index % 10000 == 0
      document_result = Hash.new {|h, k| h[k] = 0 }
      document_size = @sparse ? document.values.inject(&:+).to_f : document.size.to_f

      if @sparse
        document_result = document
      else
        document.each do |term|
          document_result[term] += 1
        end
      end
      # Normalize the count
      document_result.each_key do |term|
        document_result[term] /= document_size
      end
      
      results << document_result
    end
    STDERR.puts "end calculating TF."
    
    results
  end
end
