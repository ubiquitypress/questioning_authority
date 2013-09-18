module Authorities
  
  class Local
    
    attr_accessor :response
    
    def initialize(q, sub_authority)
      begin
        sub_authority_hash = YAML.load(File.read(File.join(Authorities::Local.sub_authorities_path, "#{sub_authority}.yml")))
      rescue
        sub_authority_hash = {}
      end
      @terms = sub_authority_hash.fetch(:terms, [])
      if q.blank?
        @response = @terms
      else
        sub_terms = []
        @terms.each { |term| sub_terms << term if term[:label].start_with?(q) }
        @response = sub_terms
      end
    end

    def parse_authority_response
      @response.to_json
    end
    
    def get_full_record(id)
      target_term = {}
      @terms.each do |term|
        if term[:id] == id
          target_term = term
        end
      end
      target_term.to_json
    end
    
    def self.sub_authorities_path
      config_path = AUTHORITIES_CONFIG[:local_path]
      if config_path.starts_with?(File::Separator)
        config_path
      else
        File.join(Rails.root, config_path)
      end
    end
    
    def self.sub_authorities
      sub_auths = []
      Dir.foreach(Authorities::Local.sub_authorities_path) { |file| sub_auths << File.basename(file, File.extname(file)) }
      sub_auths
    end
        
  end
  
end