class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :check_authentication,
                :check_authorization
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'eb31ad6d3bdb5e8ae780ee0b73c6b7a9'

  def check_authentication
    user = User.find_by_id(session[:user_id])
    if user == nil
      if xml_request?
        xml_error("RedirectLogin", "Login Needed")
        debug("check_authentication login redirect")
        return false
      else
        session[:intended_action] = action_name
        session[:intended_controller] = controller_name
        session[:params] = params
        redirect_to(:controller => "users", :action => "login")
        return false
      end
    else
      session[:user_email] = user.email
    end
  end

  def check_authorization
    if session[:user_id]
      user = User.find(session[:user_id])
      unless user.roles.detect{|role|
        role.rights.detect{|right|
          (right.action == action_name || right.action == "*") && right.controller == self.class.controller_path
          }
        }
        if xml_request?
          xml_error("RedirectSignup", "")
        else
          flash[:notice] = "You are not authorized to view the page you requested"
          error("authorization failed for user: #{session[:user_id]}")
          redirect_to(:controller => "users", :action => "login")
        end
        return false
      end
    else
      check_authentication
    end
  end
  def xml_error(code, message, errors = nil)
    @xml_error_code = code
    @xml_error_message = message
    @xml_error_details = errors
    render :file => 'shared/error.rxml', :layout => false, :use_full_path => true
  end
  
  def configure_charsets
    if request.xhr?
      response.headers["Content-Type"] ||= "text/javascript; charset=iso-8859-1"
    else
      response.headers["Content-Type"] ||= "text/html; charset=iso-8859-1"
    end
  end
  
  def user_id
    if session[:user_id]
      session[:user_id]
    else
      -1
    end
  end

  def log_time
    t = Time.now
    "%02d/%02d %02d:%02d:%02d.%06d" % [t.day, t.month, t.hour, t.min, t.sec, t.usec]
  end

  def info(text)
    logger.info("cs_info %s %s %s %d %s %s: %s" % [log_time, params[:xml_request] ? "xml" : "web", request.remote_ip, user_id, controller_name, action_name, text])
  end

  def warn(text)
    logger.warn("cs_warn %s %s %s %d %s %s: %s" % [log_time, params[:xml_request] ? "xml" : "web", request.remote_ip, user_id, controller_name, action_name, text])
  end

  def error(text)
    logger.error("cs_error %s %s %s %d %s %s: %s" % [log_time, params[:xml_request] ? "xml" : "web", request.remote_ip, user_id, controller_name, action_name, text])
  end

  def debug(text)
    logger.debug("cs_debug %s %s %s %d %s %s: %s" % [log_time, params[:xml_request] ? "xml" : "web", request.remote_ip, user_id, controller_name, action_name, text])
  end
  
  def paginate_collection(collection, options = {})
    default_options = {:per_page => 10, :page => 1}
    options = default_options.merge options

    debug("Set page to #{options[:page]}")

    pages = Paginator.new self, collection.size, options[:per_page], options[:page]
    first = pages.current.offset
    last = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    return [pages, slice]
  end
  
  def xml_request?
    debug("Content Type: #{request.content_type}")
    debug("Accepts: #{request.accepts}")
    params[:xml_request] || request.content_type == "application/xml" || request.content_type == "text/xml" || request.accepts.to_s == "application/xml"
  end

end
