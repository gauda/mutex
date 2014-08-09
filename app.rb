require_relative 'models/user_mutex.rb'

helpers do
  def link_to text, url_fragment, mode=:path_only
    case mode
      when :path_only
        base = request.script_name
      when :full_url
        if request.scheme == 'http' && request.port == 80 || request.scheme == 'https' && request.port == 443
          port = ""
        else
          port = ":#{request.port}"
        end
        base = "#{request.scheme}://#{request.host}#{port}/#{request.script_name}"
      else
        raise "Unknown script_url mode #{mode}"
    end
    "<a href='#{base}#{url_fragment}'>#{text}</a>"
  end
end

get '/' do
  'missing tenant_id'
end

get '/:tenant_id' do
  mutex = UserMutex.new(params[:tenant_id])
  [].tap do |str|
    if mutex.set?
      str << "mutex not set."
      if params[:user]
        str << link_to('set mutex', "/#{params[:tenant_id]}/set?user=#{params[:user]}")
      else
        str << "call with '?user=foobar' to get a link."
      end
    else
      str << "mutex created by #{mutex.user} at #{mutex.created_at}."
      if params[:user] == mutex.user
        str << link_to('release mutex', "/#{params[:tenant_id]}/release?user=#{mutex.user}")
      end
    end
  end.join("\n")
end

get '/:tenant_id/set' do
  mutex = UserMutex.new(params[:tenant_id])
  [].tap do |str|
    if mutex.set?
      mutex.set_to(params[:user])
      str << "mutex set to #{params[:user]}."
      str << link_to('release mutex', "/#{params[:tenant_id]}/release?user=#{params[:user]}")
    elsif mutex.user == params[:user]
      str << "mutex was already set."
    else
      status 423
      str << "ERROR: mutex was already set to #{mutex.user} at #{mutex.created_at}."
    end
  end.join("\n")
end

get '/:tenant_id/release' do
  mutex = UserMutex.new(params[:tenant_id])
  [].tap do |str|
    if mutex.set?
      status 416
      str << "ERROR: mutex not set."
    else
      if mutex.user == params[:user] || params[:force] == '1'
        old_user = mutex.release
        str << "mutex of #{old_user} released."
        str << link_to('set mutex', "/#{params[:tenant_id]}/set?user=#{params[:user]}")
      else
        status 424
        str << "ERROR: cannot release mutex created by #{mutex.user} at #{mutex.created_at}."
        str << link_to('force deletion', "/#{params[:tenant_id]}/release?user=#{params[:user]}&force=1")
      end
    end
  end.join("\n")
end

get '/:tenant_id/bin' do
  if params[:os] == 'linux'
    send_file "#{settings.root}/bin/start.sh"
  elsif params[:os] == 'windows'
    send_file "#{settings.root}/bin/start.ps1"
  else
    "call with ?os=linux or ?os=windows to get a binary"
  end
end
