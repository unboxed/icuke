module ICuke
  module SDK
    ICUKE_EXT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'ext', 'iCuke'))
    ICUKE_BIN_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'ext', 'bin'))
    CFLAGS = '-arch i386 -pipe -ggdb -std=c99 -DTARGET_OS_IPHONE'
    
    def self.all
      @all ||= begin
        `xcodebuild -showsdks`.split.grep(/iphonesimulator/).map do |s|
          s.sub(/.*\s?iphonesimulator([0-9.]+).*/, '\1').chomp
        end.sort
      end
    end
    
    def self.installed?(sdk)
      all.include?(sdk)
    end
    
    def self.major_versions
      all.map { |s| s.split('.').first }.uniq
    end
    
    def self.minor_versions
      all.map { |s| s.split('.')[0 .. 1].join('.') }.uniq
    end
    
    def self.latest(version = nil)
      @latest ||= version ? all.grep(/^#{version}(?:\.|$)/).last : all.last
    end
    
    def self.use(version)
      unless installed?(version)
        raise "The requested SDK version #{version} doesn't appear to be installed"
      end
      
      @sdk = version
    end
    
    def self.use_latest(major_version = nil)
      case major_version
      when :iphone
        major_version = installed?('4.0') ? '4.0' : '3.1'
      when :ipad
        major_version = installed?('4.0') ? '4.0' : '3.2'
      end
      use latest(major_version)
    end
    
    def self.version
      require_sdk
      
      @sdk
    end
    
    def self.major_version
      require_sdk
      
      version.split('.')[0]
    end
    
    def self.minor_version
      require_sdk
      
      version.split('.')[0 .. 1].join('.')
    end
    
    def self.fullname
      require_sdk
      
      "iphonesimulator#{version}"
    end
    
    def self.root
      require_sdk
      
      "#{`xcode-select -print-path`.chomp}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{version}.sdk"
    end
    
    def self.home
      require_sdk
      
      "#{ENV['HOME']}/Library/Application Support/iPhone Simulator/#{version}"
    end
    
    def self.dylib(name = 'libicuke')
      require_sdk
      
      "#{name}-sdk#{minor_version}.dylib"
    end
    
    def self.dylib_fullpath(name = 'libicuke')
      require_sdk
      
      File.join(ICUKE_EXT_DIR, dylib(name))
    end
    
    def self.ext_dir
      ICUKE_EXT_DIR
    end
    
    def self.sdk_ext_dir
      File.join(ext_dir, "sdk#{minor_version}")
    end
    
    def self.cflags
      "#{CFLAGS} -isysroot #{root} -F/System/Library/PrivateFrameworks -D__IPHONE_OS_VERSION_MIN_REQUIRED=#{major_version == '3.1' ? '30000' : '40000'}"
    end
    
    def self.gcc
      if major_version == '4'
        abi_flags = "-fobjc-abi-version=2 -fobjc-legacy-dispatch"
      end
      "xcrun -sdk #{fullname} gcc -I. -I#{sdk_ext_dir} -I#{sdk_ext_dir}/json #{cflags} -x objective-c #{abi_flags}"
    end
    
    def self.ld
      if major_version == '4'
        abi_flags = "-Xlinker -objc_abi_version -Xlinker 2"
      end
      "xcrun -sdk #{fullname} gcc -I. -I#{sdk_ext_dir} -I#{sdk_ext_dir}/json #{cflags} #{abi_flags}"
    end
    
    def self.launch(application, family, environment = {})
      family ||= :iphone
      environment_args = environment.map { |k, v| %Q{-e "#{k}=#{v}"} }.join(' ')
      %Q{#{ICUKE_BIN_DIR}/waxsim -s #{version} -f #{family} #{environment_args} "#{application}"}
    end
    
    private
    
    def self.require_sdk
      raise "No SDK has been selected" unless @sdk
    end
  end
end
