module Hudhub
  class Processor
    def self.config
      @@config ||= Hudhub::Config.new
    end

    def config
      self.class.config
    end
  end
end
