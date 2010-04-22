require 'net/http'

module RequestWithSocketCheck
  def self.included(base)
    base.instance_eval do
      alias_method :request_without_socket_check, :request
      alias_method :request, :request_with_socket_check
    end
  end
  
  def request_with_socket_check(*args)
    begin
      request_without_socket_check(*args)
    rescue NoMethodError => e
      if e.message =~ /undefined method `closed\?' for nil/
        raise Errno::ECONNREFUSED
      else
        raise e
      end
    end
  end
end

if Net::HTTP::Revision.to_i == 25851
  Net::HTTP.send :include, RequestWithSocketCheck
end
