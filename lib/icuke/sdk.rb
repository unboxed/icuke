module ICuke
  module SDK
    def self.all
      @all ||= begin
        `xcodebuild -showsdks`.grep(/iphonesimulator/).map do |s|
          s.sub(/.* iphonesimulator([0-9.]+).*/, '\1').chomp
        end.sort
      end
    end
    
    def self.installed?(sdk)
      all.include?(sdk)
    end
    
    def self.major_versions
      all.map { |s| s.split('.').first }.uniq
    end
    
    def self.latest(major_version = nil)
      @latest ||= major_version ? all.grep(/^#{major_version}\./).last : all.last
    end
    
    def self.use(version)
      unless installed?(version)
        raise "The requested SDK version #{version} doesn't appear to be installed"
      end
      
      @sdk = version
    end
    
    def self.use_latest(major_version = nil)
      use latest(major_version)
    end
    
    def self.version
      require_sdk
      
      @sdk
    end
    
    def self.major_version
      require_sdk
      
      version.split('.').first
    end
    
    def self.fullname
      require_sdk
      
      "iphonesimulator#{version}"
    end
    
    def self.root
      require_sdk
      
      "/#{`xcode-select -print-path`.chomp}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{version}.sdk"
    end
    
    def self.home
      require_sdk
      
      "#{ENV['HOME']}/Library/Application Support/iPhone Simulator/#{version}"
    end
    
    def self.dylib
      require_sdk
      
      "libicuke-sdk#{version.split('.').first}.dylib"
    end
    
    private
    
    def self.require_sdk
      raise "No SDK has been selected" unless @sdk
    end
  end
end
